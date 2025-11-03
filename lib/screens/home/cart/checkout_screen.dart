import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/controllers/donation_controller.dart';
import 'package:ticketmaster_et/main_layout_screen.dart';
import 'package:ticketmaster_et/utils/shimmer_wrapper.dart';
import 'package:ticketmaster_et/widgets/order_summary.dart';

import '../../../controllers/cart_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../functions/functions.dart';
import '../../../models/newmodels.dart';
import '../../../prefs/routes.dart';
import '../../../provider/loginpersistence.dart';
import '../../order/user_orders.dart';
import '../../signup.dart';
import '../../wallet/payment_web_view.dart';

class CheckoutController extends GetxController {
  var isPaying = false.obs;
  var isDeliveryPaying = false.obs;
  var mealType = '1'.obs;
  var mealTypes = <MealType>[].obs;

  final bool? fromDonation;
  CheckoutController({this.fromDonation});

  var location = ''.obs;
  var onDelivery = false.obs;

  Map<String, dynamic> convertCartToJson(List<Food> foodPortions) {
    var cartJson = {
      'organization_id': fromDonation == true
          ? Get.find<DonationController>().selectedOrganizationId.value
          : 0,
      "customer_id":
          Get.find<LoginDataProvider>(tag: 'login').loginData?.id ?? '',
      "meal_type_id": mealType.value,
      "location": location.value,
      "date": DateTime.now().toLocal().toString(),
      "payment_type": onDelivery.value == true
          ? '1'
          : walletPay.value
              ? "3"
              : '4',
      "total_quantity":
          foodPortions.fold(0, (sum, item) => sum + item.amount!).toString(),
      "total_price": foodPortions
          .fold(
              0,
              (sum, item) =>
                  (sum + double.parse(item.totalPrice()).toInt()).toInt())
          .toString(),
      "total_food": foodPortions.map((e) => e.id).toSet().length.toString(),
      "price": foodPortions.map((e) => e.totalPrice()).toList(),
      "quantity": foodPortions.map((e) => e.amount.toString()).toList(),
      // "portion_id": foodPortions.map((e) => e.id.toString()).toList(),
      "food_id": foodPortions.map((e) => e.id.toString()).toList(),
    };
    Logger().i(cartJson);
    return cartJson;
  }

  var orderIdString = ''.obs;
  var walletPay = false.obs;
  Future<void> payForPortion(BuildContext context) async {
    final cartController = Get.find<CartController>(
        tag: fromDonation == true
            ? CartController.donationTag
            : CartController.tag);
    // final loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');

    List<Food> foodPortions = cartController.cart;
    if (location.value.isEmpty) {
      showErrorSnackbar('please_enter_location'.tr);
      return;
    }
    if (mealType.value.isEmpty) {
      showErrorSnackbar('please_select_meal_type'.tr);
      return;
    }

    isPaying.value = true;
    try {
      var response = await http.post(
        Uri.parse('${baseUrlFunc}order-food'),
        body: jsonEncode(convertCartToJson(foodPortions)),
        headers: {'Content-Type': 'application/json'},
      );

      Logger().d(response.body);
      if (jsonDecode(response.body)['message'] !=
          'We Accept your order succesfully') {
        showErrorSnackbar("error_ordering_food".tr);
        return;
      }

      var responseData = jsonDecode(response.body);
      int orderId = responseData['data']['id'];
      String totalAmount = foodPortions
          .fold(0, (sum, item) => sum + double.parse(item.totalPrice()).toInt())
          .toString();

      if (!onDelivery.value) {
        await handleOnlinePayment(context, orderId, totalAmount);
      } else {
        orderIdString.value = orderId.toString();
        showOrderSuccessDialog(totalAmount);
        updateUserOrders();
      }
    } catch (e, s) {
      Logger().t(e, stackTrace: s);
      showErrorSnackbar("error_ordering_food".tr);
    } finally {
      isPaying.value = false;
    }
  }

  Future<bool?> showTopUpDialog(BuildContext context) async {
    final amountController = TextEditingController();
    bool topUpSuccess = false;

    return await Get.dialog<bool>(
      AlertDialog(
        title: Text('top_up_wallet'.tr),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'amounto'.tr,
            hintText: 'enter_topup_amount'.tr,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                topUpSuccess = await topUp(amount);
                Get.back(result: topUpSuccess);
              } else {
                Get.snackbar('error'.tr, 'enter_valid_amount'.tr,
                    backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            child: Text('proceed'.tr),
          ),
        ],
      ),
    );
  }

  Future<bool> topUp(double amount) async {
    try {
      final userId = Get.find<LoginDataProvider>(tag: 'login').loginData?.id;
      if (userId == null) return false;

      var response;
      await Get.showOverlay(
        asyncFunction: () async {
          response = await http.post(
            Uri.parse('${baseUrlFunc}wallet-payment'),
            body: {
              'user_id': userId.toString(),
              'amount': amount.toString(),
              'date': DateTime.now().toIso8601String(),
            },
          );
        },
        loadingWidget: const Center(
          child: SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator(),
          ),
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final checkoutUrl = data['data']['checkout_url'];

        if (checkoutUrl != null) {
          var paid = await Get.to<bool>(() => PaymentWebView(url: checkoutUrl));
          if (paid == true) {
            await loadBalance(); // wait for balance refresh
            return true;
          }
        }
      }
    } catch (e, s) {
      Logger().t('Error during top up: $e', stackTrace: s);
      Get.snackbar('error'.tr, 'failed_top_up'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    return false;
  }

  /// Handles online payment with Chapa
  Future<void> handleOnlinePayment(
      BuildContext context, int orderId, String totalAmount) async {
    final loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
    // await loginDataProvider.loadLoginData();
    if (loginDataProvider.loginData == null) {
      Get.to(() => const SignupScreen());
      return;
    }
    if (!walletPay.value) {
      try {
        // var loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
        loginDataProvider.loadLoginData();

        var data = {
          "user_id": loginDataProvider.loginData?.id,
          "amount": totalAmount,
          "date": DateTime.now().toString(),
          "food_order_id": orderId,
        };
        Logger().i(jsonEncode(data));
        final response = await http.post(
          Uri.parse(
              '$baseUrlFunc${fromDonation == true ? 'donation-' : ''}pay-on-chapa'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        );
        Logger().i(response.body);
        if (response.statusCode == 200 &&
            jsonDecode(response.body)['data']?['checkout_url'] != null) {
          final checkoutUrl = jsonDecode(response.body)['data']['checkout_url'];

          final result = await Get.to(() => PaymentWebView(url: checkoutUrl));

          if (result == true) {
            orderIdString.value = orderId.toString();
            showSuccessDialog(totalAmount);
            updateUserOrders();
          }
        } else {
          Get.snackbar(
            "error".tr,
            "failed_start_chapa".tr,
            backgroundColor: Colors.red[100],
            colorText: Colors.black,
          );
        }
      } catch (e, s) {
        Logger().t(e, stackTrace: s);
        Get.snackbar("error".tr, "sth_went_wrong".trParams({'e': e.toString()}),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      try {
        var loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
        double currentBalance = double.tryParse(balance.value) ?? 0;
        final requiredAmount = double.parse(totalAmount);
        // If not enough funds, wait for top-up
        if (requiredAmount > currentBalance) {
          bool? toppedUp = await showTopUpDialog(Get.context!);
          if (!(toppedUp ?? false)) {
            Get.snackbar('error'.tr, 'top_up_cancelled_or_failed'.tr,
                backgroundColor: Colors.red, colorText: Colors.white);
            isLoading.value = false;
            return;
          }

          // Reload new balance
          await loadBalance();
          currentBalance = double.tryParse(balance.value) ?? 0;

          if (requiredAmount > currentBalance) {
            Get.snackbar('error'.tr, 'still_not_enough_balance'.tr,
                backgroundColor: Colors.red, colorText: Colors.white);
            isLoading.value = false;
            return;
          }
        }
        // loginDataProvider.loadLoginData();
        var data = {
          "user_id": loginDataProvider.loginData?.id,
          "amount": totalAmount,
          "date": DateTime.now().toString(),
          "food_order_id": orderId,
        };
        Logger().i(data);
        final response = await http.post(
            Uri.parse(
                '$baseUrlFunc${fromDonation == true ? 'donation-' : ''}pay-on-wallet'),
            body: jsonEncode(data),
            headers: {
              "Content-Type": "application/json",
            });
        Logger().i(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          orderIdString.value = orderId.toString();
          showSuccessDialog(totalAmount);
          updateUserOrders();
        } else {
          Get.snackbar(
            "error".tr,
            "unable_to_complt_wallet_payment".tr,
            backgroundColor: Colors.red[100],
            colorText: Colors.black,
          );
        }
      } catch (e, s) {
        Logger().t(e, stackTrace: s);
        Get.snackbar("error".tr, "sth_went_wrong".trParams({'e': e.toString()}),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  /// Shows an error snackbar
  void showErrorSnackbar(String message) {
    Get.snackbar("error".tr, message,
        backgroundColor: Colors.red, colorText: Colors.white);
  }

  /// Shows a success dialog
  void showSuccessDialog(String totalAmount) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("food_purchase_successful".tr),
        content: Text("$totalAmount ${'etb'.tr} ${"paid_enjoy".tr}"),
        actions: [
          TextButton(
            child: Text("ok".tr),
            onPressed: () {
              GetStorage().erase();
              Get.until((route) => Get.currentRoute == Routes.mainLayoutRoute);

              Get.find<MainLayoutController>(tag: MainLayoutController.tag)
                  .bottomTabController
                  .jumpToTab(3);
              if (Get.isRegistered<UserOrdersController>()) {
                Get.find<UserOrdersController>().tabController.animateTo(1);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Shows a success dialog
  void showOrderSuccessDialog(String totalAmount) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("food_purchase_successful".tr),
        content: Text("ordered_enjoy".tr),
        actions: [
          TextButton(
            child: Text("ok".tr),
            onPressed: () {
              GetStorage().erase();
              Get.until((route) => Get.currentRoute == Routes.mainLayoutRoute);

              Get.find<MainLayoutController>(tag: MainLayoutController.tag)
                  .bottomTabController
                  .jumpToTab(3);
              if (Get.isRegistered<UserOrdersController>()) {
                Get.find<UserOrdersController>().tabController.animateTo(1);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Updates user orders
  void updateUserOrders() {
    if (Get.isRegistered<UserOrdersController>()) {
      Get.find<UserOrdersController>().updateOrders();
    }
  }

  var isLoading = false.obs;
  var hasError = false.obs;
  Future<void> updateMealTypes() async {
    isLoading.value = true;
    try {
      var mealTypesFromAPI = await getMealTypes();
      mealTypes.assignAll(mealTypesFromAPI);
      hasError.value = false;
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  var loadingBalance = false.obs;
  var balance = '0'.obs;

  @override
  void onInit() {
    super.onInit();
    loadBalance(); // fetch balance when controller is created
  }

  Future<void> loadBalance() async {
    final Dio dio = Dio();
    loadingBalance.value = true;
    try {
      var loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
      // loginDataProvider.loadLoginData();
      final userId = loginDataProvider.loginData?.id;
      if (userId == null) return;

      final response = await dio.get('${baseUrlFunc}my_wallet_amount/$userId');

      if (response.statusCode == 200) {
        final data = response.data;
        balance.value = data['data']?.toString() ?? '0';
        if (Get.isRegistered<WalletController>(tag: WalletController.tag)) {
          Get.find<WalletController>(tag: WalletController.tag).loadBalance();
        }
      }
    } catch (e, s) {
      Logger().t('Error loading balance: $e', stackTrace: s);
      Get.snackbar('error'.tr, 'failed_to_load_balance'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      loadingBalance.value = false;
    }
  }
}

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({super.key});
  final CartController cartController = Get.find<CartController>(
      tag: Get.arguments == true
          ? CartController.donationTag
          : CartController.tag);
  final CheckoutController controller =
      Get.put(CheckoutController(fromDonation: Get.arguments));

  @override
  Widget build(BuildContext context) {
    Map<String, List<Food>> groupedProducts =
        cartController.groupCartItemsByStore();
    return PopScope(
      onPopInvokedWithResult: (c, s) {
        if (controller.orderIdString.value.isNotEmpty) {
          cartController.cart.clear();
          cartController.numberOfItemsInCart.value = 0;
          cartController.numberOfItemsInCart.refresh();
          cartController.cart.refresh();
          GetStorage().erase();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF23981C),
          title: Text(
            'checkout'.tr,
            style: const TextStyle(color: Colors.white),
          ),
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          actions: [
            Obx(() => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: ThemeModeController.isCurrentlyLight()
                                ? Colors.grey.withValues(alpha: 0.3)
                                : Colors.black38,
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: AutoSizeText(
                            'total_birr'.trParams({
                              'total': cartController.totalProductPrice
                                  .toStringAsFixed(2)
                            }),
                            maxLines: 1,
                            minFontSize: 11,
                            maxFontSize: 16,
                            textAlign: TextAlign.center,
                            stepGranularity: 0.5,
                            overflow: TextOverflow.visible,
                            style: const TextStyle(
                                color: Color(0xFF23981C),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ),
                ))
          ],
        ),
        body: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                  child: Text(
                    'order_summary'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                FoodSummary(
                    groupedProducts: groupedProducts,
                    storeNameById: cartController.storeNameById,
                    calculateTotalQuantityOfProductsFromStore: cartController
                        .calculateTotalQuantityOfProductsFromSpecificStore),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
                  child: Text(
                    'additional'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 8.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (val) {
                          controller.location.value = val;
                        },
                        decoration: InputDecoration(
                          hintText: Get.arguments == true
                              ? 'desc'.tr
                              : 'enter_location'.tr,
                          enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              borderSide:
                                  BorderSide(color: Colors.green, width: 2)),
                          focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              borderSide:
                                  BorderSide(color: Colors.green, width: 2)),
                          border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              borderSide:
                                  BorderSide(color: Colors.green, width: 2)),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      if (Get.arguments != true)
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: Obx(
                                  () => ShimmerWrapper(
                                    isEnabled: controller.isLoading.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(8)),
                                          border: Border.all(
                                              color: Colors.green, width: 2)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Obx(() => DropdownButton(
                                              value: int.parse(
                                                  controller.mealType.value),
                                              isExpanded: true,
                                              hint: Text('meal_type'.tr),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(8)),
                                              items: controller.mealTypes
                                                  .map((e) => DropdownMenuItem(
                                                      value: e.id,
                                                      child:
                                                          Text(e.name ?? '')))
                                                  .toList(),
                                              onChanged: (v) {
                                                controller.mealType.value =
                                                    v.toString();
                                              },
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
                // if (Get.arguments != true)
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 8.0, left: 16.0, top: 16),
                  child: Text(
                    'payment_method'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8),
                  child: Obx(() => controller.loadingBalance.value
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          "${'wallet_balance'.tr}: ${controller.balance.value} Pts",
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        )),
                ),
                // if (Get.arguments != true)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Row(
                    children: [
                      if (Get.arguments != true)
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                controller.onDelivery.value = true;
                                controller.walletPay.value = false;
                              },
                              child: Obx(
                                () => Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: controller.onDelivery.value
                                          ? Colors.green
                                          : Colors.grey,
                                      width:
                                          controller.onDelivery.value ? 3 : 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        Column(
                                          children: [
                                            Icon(
                                              Icons.bike_scooter,
                                              color: controller.onDelivery.value
                                                  ? Colors.green
                                                  : Colors.grey,
                                              weight:
                                                  controller.onDelivery.value
                                                      ? 2
                                                      : 1,
                                            ),
                                            Text('on_delivery'.tr)
                                          ],
                                        ),
                                        if (controller.onDelivery.value)
                                          const Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                              ))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              controller.onDelivery.value = false;
                              controller.walletPay.value = true;
                            },
                            child: Obx(
                              () => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: !controller.onDelivery.value &&
                                            controller.walletPay.value
                                        ? Colors.green
                                        : Colors.grey,
                                    width: !controller.onDelivery.value &&
                                            controller.walletPay.value
                                        ? 3
                                        : 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      Column(
                                        children: [
                                          Icon(
                                            EneftyIcons.wallet_2_bold,
                                            color: !controller
                                                        .onDelivery.value &&
                                                    controller.walletPay.value
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          Text('pay_with_wallet'.tr)
                                        ],
                                      ),
                                      if (!controller.onDelivery.value &&
                                          controller.walletPay.value)
                                        const Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            ))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              controller.onDelivery.value = false;
                              controller.walletPay.value = false;
                            },
                            child: Obx(
                              () => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: !controller.onDelivery.value &&
                                            !controller.walletPay.value
                                        ? Colors.green
                                        : Colors.grey,
                                    width: !controller.onDelivery.value &&
                                            !controller.walletPay.value
                                        ? 3
                                        : 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      Column(
                                        children: [
                                          Icon(
                                            Icons.wallet,
                                            color: !controller
                                                        .onDelivery.value &&
                                                    !controller.walletPay.value
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          Text('pay_with_chapa'.tr)
                                        ],
                                      ),
                                      if (!controller.onDelivery.value &&
                                          !controller.walletPay.value)
                                        const Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            ))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Obx(
                        () => ElevatedButton(
                            onPressed: controller.location.value.isEmpty ||
                                    controller.mealType.value.isEmpty
                                ? null
                                : controller.isPaying.value
                                    ? () {}
                                    : () => controller.payForPortion(context),
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: controller.isPaying.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(Get.arguments == true
                                    ? 'pay_and_order'.tr
                                    : 'place_order'.tr)),
                      )),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
