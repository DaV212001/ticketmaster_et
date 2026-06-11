import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ticketmaster_et/controllers/current_location_controller.dart';
import 'package:ticketmaster_et/controllers/wallet_controller.dart';
import 'package:ticketmaster_et/models/delivery_address.dart';

import '../functions/functions.dart';
import '../main_layout_screen.dart';
import '../models/newmodels.dart';
import '../prefs/routes.dart';
import '../provider/loginpersistence.dart';
import '../screens/order/user_orders.dart';
import '../screens/signup.dart';
import '../screens/wallet/payment_web_view.dart';
import '../setup_files/logging_wrapper.dart';
import 'cart_controller.dart';
import 'donation_controller.dart';

class CheckoutController extends GetxController {
  var isPaying = false.obs;
  var isDeliveryPaying = false.obs;
  var mealType = '1'.obs;
  var mealTypes = <MealType>[].obs;

  final bool? fromDonation;
  CheckoutController({this.fromDonation});

  var location = ''.obs;
  var deliveryAddress = DeliveryAddress().obs;
  var onDelivery = false.obs;

  Map<String, dynamic> convertCartToJson(List<Food> foodPortions) {
    var currentLocationController = Get.find<CurrentLocationController>();
    var cartJson = {
      'organization_id': fromDonation == true
          ? Get.find<DonationController>().selectedOrganizationId.value
          : 0,
      "customer_id":
          Get.find<LoginDataProvider>(tag: 'login').loginData?.id ?? '',
      "meal_type_id": mealType.value,
      "friendly_location": location.value,
      "location":
          deliveryAddress.value.lat == null || deliveryAddress.value.lng == null
              ? currentLocationController.displayName.value
              : deliveryAddress.value.displayName,
      "latitude": deliveryAddress.value.lat ??
          currentLocationController.currentLatLng.value?.latitude,
      "longitude": deliveryAddress.value.lng ??
          currentLocationController.currentLatLng.value?.longitude,
      "date": DateTime.now().toLocal().toString(),
      "payment_type": onDelivery.value == true
          ? '1'
          : walletPay.value
              ? "3"
              : '4',
      "total_quantity": foodPortions
          .fold(0, (sum, item) => sum + (item.amount!).toInt())
          .toString(),
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
    AppLogger().i(cartJson);
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
    if (((deliveryAddress.value.lat == null ||
            deliveryAddress.value.lng == null) &&
        (Get.find<CurrentLocationController>().currentLatLng.value == null))) {
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

      AppLogger().d(response.body);
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
      AppLogger().t(e, stackTrace: s);
      showErrorSnackbar("error_ordering_food".tr);
    } finally {
      isPaying.value = false;
    }
  }

  Future<bool?> showTopUpDialog(BuildContext context) async {
    bool topUpSuccess = false;
    final amountController = TextEditingController();
    final pointsNotifier = ValueNotifier<double>(0); // For live points update

    amountController.addListener(() {
      final amount = double.tryParse(amountController.text) ?? 0;
      pointsNotifier.value = amount * 1.1; // conversion: 1 Birr = 1.1 Points
    });

    return await Get.dialog<bool>(
      AlertDialog(
        title: Text('top_up_wallet'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('1 Birr = 1.1 Point'),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'amounto'.tr,
                hintText: 'enter_topup_amount'.tr,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.green),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<double>(
              valueListenable: pointsNotifier,
              builder: (context, points, _) {
                return Text(
                  'You will get ${points.toStringAsFixed(1)} Pts',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
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
      AppLogger().t('Error during top up: $e', stackTrace: s);
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
        AppLogger().i(jsonEncode(data));
        final response = await http.post(
          Uri.parse(
              '$baseUrlFunc${fromDonation == true ? 'donation-' : ''}pay-on-chapa'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        );
        AppLogger().i(response.body);
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
        AppLogger().t(e, stackTrace: s);
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
        AppLogger().i(data);
        final response = await http.post(
            Uri.parse(
                '$baseUrlFunc${fromDonation == true ? 'donation-' : ''}pay-on-wallet'),
            body: jsonEncode(data),
            headers: {
              "Content-Type": "application/json",
            });
        AppLogger().i(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          orderIdString.value = orderId.toString();
          if (Get.isRegistered<WalletController>(tag: WalletController.tag)) {
            Get.find<WalletController>(tag: WalletController.tag).loadBalance();
          }
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
        AppLogger().t(e, stackTrace: s);
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
              // if (Get.isRegistered<UserOrdersController>()) {
              //   Get.find<UserOrdersController>().tabController.animateTo(1);
              // }
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
              // if (Get.isRegistered<UserOrdersController>()) {
              //   Get.find<UserOrdersController>().tabController.animateTo(1);
              // }
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
    updateMealTypes();
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
      AppLogger().t('Error loading balance: $e', stackTrace: s);
      Get.snackbar('error'.tr, 'failed_to_load_balance'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      loadingBalance.value = false;
    }
  }
}
