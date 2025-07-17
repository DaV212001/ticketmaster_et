import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chapa_unofficial/chapa_unofficial.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/main_layout_screen.dart';
import 'package:ticketmaster_et/screens/home/cart/cart_screen.dart';
import 'package:ticketmaster_et/utils/shimmer_wrapper.dart';
import 'package:ticketmaster_et/widgets/order_summary.dart';

import '../../../controllers/theme_controller.dart';
import '../../../functions/functions.dart';
import '../../../models/newmodels.dart';
import '../../../prefs/routes.dart';
import '../../../provider/loginpersistence.dart';
import '../../signup.dart';
import '../../user_tickets.dart';

class CheckoutController extends GetxController {
  var isPaying = false.obs;
  var isDeliveryPaying = false.obs;
  var mealType = '1'.obs;
  var mealTypes = <MealType>[].obs;

  var location = ''.obs;
  var onDelivery = false.obs;

  Map<String, dynamic> convertCartToJson(List<FoodPortions> foodPortions) {
    var cartJson = {
      "customer_id":
          Get.find<LoginDataProvider>(tag: 'login').loginData?.id ?? '',
      "meal_type_id": mealType.value,
      "location": location.value,
      "date": DateTime.now().toLocal().toString(),
      "payment_type": onDelivery.value == true ? '1' : '0',
      "total_quantity":
          foodPortions.fold(0, (sum, item) => sum + item.amount!).toString(),
      "total_price": foodPortions
          .fold(
              0,
              (sum, item) =>
                  (sum + double.parse(item.totalPrice()).toInt()).toInt())
          .toString(),
      "total_food": foodPortions.map((e) => e.foodId).toSet().length.toString(),
      "price": foodPortions.map((e) => e.totalPrice()).toList(),
      "quantity": foodPortions.map((e) => e.amount.toString()).toList(),
      "portion_id": foodPortions.map((e) => e.id.toString()).toList(),
      "food_id": foodPortions.map((e) => e.foodId.toString()).toList(),
    };
    Logger().i(cartJson);
    return cartJson;
  }

  var orderIdString = ''.obs;

  Future<void> payForPortion(BuildContext context) async {
    final cartController = Get.find<CartController>(tag: CartController.tag);
    // final loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');

    List<FoodPortions> foodPortions = cartController.cart;
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
        showSuccessDialog(totalAmount);
        updateUserOrders();
      }
    } catch (e, s) {
      Logger().t(e, stackTrace: s);
      showErrorSnackbar("error_ordering_food".tr);
    } finally {
      isPaying.value = false;
    }
  }

  /// Handles online payment with Chapa
  Future<void> handleOnlinePayment(
      BuildContext context, int orderId, String totalAmount) async {
    final loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');

    final accountProvider = Get.find<LoginDataProvider>(tag: 'login');
    await loginDataProvider.loadLoginData();
    if (loginDataProvider.loginData == null) {
      Get.to(() => const SignupScreen());
      return;
    }

    String txRef = TxRefRandomGenerator.generate(prefix: 'hellomesa');
    String storedTxRef = TxRefRandomGenerator.gettxRef;
    String? phone = accountProvider.loginData?.phone?.replaceFirst("251", "0");

    await Chapa.getInstance.startPayment(
      context: context,
      amount: totalAmount,
      currency: 'ETB',
      txRef: storedTxRef,
      firstName: accountProvider.loginData?.firstName ?? '',
      lastName: accountProvider.loginData?.lastName ?? '',
      phoneNumber: phone ?? '',
      onInAppPaymentSuccess: (successMsg) async {
        await bookEvent(Booking(
          userId: loginDataProvider.loginData?.id,
          foodId: 0,
          foodOrderId: orderId,
          paymentStatus: '1',
          transaction: storedTxRef,
          amount: totalAmount,
          date: DateTime.now().toIso8601String(),
        ));

        orderIdString.value = orderId.toString();
        showSuccessDialog(totalAmount);
        updateUserOrders();
      },
      onInAppPaymentError: (errorMsg) async {
        Logger().t(errorMsg);
        await bookEvent(Booking(
          userId: loginDataProvider.loginData?.id,
          foodId: 0,
          foodOrderId: orderId,
          paymentStatus: '0',
          transaction: storedTxRef,
          amount: totalAmount,
          date: DateTime.now().toIso8601String(),
        ));
        showErrorSnackbar("payment_failure".tr);
      },
    );
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
        content: Text("$totalAmount Birr ${"paid_enjoy".tr}"),
        actions: [
          TextButton(
            child: Text("ok".tr),
            onPressed: () {
              GetStorage().erase();
              Get.until((route) => Get.currentRoute == Routes.mainLayoutRoute);

              Get.find<MainLayoutController>(tag: MainLayoutController.tag)
                  .selectedIndex
                  .value = 2;
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
      Get.find<UserOrdersController>().updateCategories();
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

  @override
  void onInit() {
    updateMealTypes();
    super.onInit();
  }
}

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({super.key});
  final CartController cartController =
      Get.find<CartController>(tag: CartController.tag);
  final CheckoutController controller = Get.put(CheckoutController());

  @override
  Widget build(BuildContext context) {
    Map<String, List<FoodPortions>> groupedProducts =
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
                OrderSummary(
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
                          hintText: 'enter_location'.tr,
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
                                                    child: Text(e.name ?? '')))
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
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              controller.onDelivery.value = true;
                            },
                            child: Obx(
                              () => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: controller.onDelivery.value
                                        ? Colors.green
                                        : Colors.grey,
                                    width: controller.onDelivery.value ? 3 : 1,
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
                                            weight: controller.onDelivery.value
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
                            },
                            child: Obx(
                              () => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: !controller.onDelivery.value
                                        ? Colors.green
                                        : Colors.grey,
                                    width: !controller.onDelivery.value ? 3 : 1,
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
                                            color: !controller.onDelivery.value
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          Text('pay_now'.tr)
                                        ],
                                      ),
                                      if (!controller.onDelivery.value)
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
                                : const Text('Place Order')),
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
