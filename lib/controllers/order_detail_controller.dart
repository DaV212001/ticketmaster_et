import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/functions/functions.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/order/reorder_payment_modal.dart';
import 'package:ticketmaster_et/screens/order/user_orders.dart';

import '../../constants/theme.dart';
import '../../controllers/wallet_controller.dart';
import '../../main_layout_screen.dart';
import '../../prefs/routes.dart';
import '../../provider/loginpersistence.dart';
import '../screens/signup.dart';
import '../screens/wallet/payment_web_view.dart';

class OrderDetailController extends GetxController {
  var isLoading = true.obs;
  var orderItems = <OrderItem>[].obs;

  var onDelivery = false.obs;

  var walletPay = false.obs;

  Map<String, dynamic> convertOrderToJson(Order order) {
    final loginProvider = Get.find<LoginDataProvider>(tag: 'login');
    final customerId = loginProvider.loginData?.id ?? '';

    final items = order.orderItems ?? [];
    final totalPrice = items.fold<double>(
        0.0,
        (sum, item) =>
            sum +
            ((double.tryParse(item.price ?? '0') ?? 0) * (item.quantity ?? 1)));
    final totalQuantity =
        items.fold<int>(0, (sum, item) => sum + (item.quantity ?? 0));

    final uniqueFoods = items.map((e) => e.foodId).toSet().length;

    return {
      "organization_id": int.parse(order.organizationId ?? "0"),
      "customer_id": customerId,
      "meal_type_id": order.mealTypeId ?? '',
      "location": order.location ?? '',
      "date": DateTime.now().toLocal().toString(),
      "payment_type": order.paymentType?.toString() ?? '0',
      "total_quantity": totalQuantity.toString(),
      "total_price": totalPrice.toStringAsFixed(2),
      "total_food": uniqueFoods.toString(),
      "price": items
          .map(
              (e) => (int.parse(e.price ?? '0') * (e.quantity ?? 0)).toString())
          .toList(),
      "quantity": items.map((e) => (e.quantity ?? 0).toString()).toList(),
      "food_id": items.map((e) => e.foodId?.toString() ?? '').toList(),
    };
  }

  Future<void> reorder(Order order, BuildContext context) async {
    if (order.orderItems == null || order.orderItems!.isEmpty) {
      Get.snackbar("Error", "No items found to reorder.",
          backgroundColor: Colors.red[100], colorText: Colors.black);
      return;
    }
    var response;
    bool? selectedPaymentMethod = await Get.bottomSheet<bool>(
      FractionallySizedBox(
        heightFactor: 0.3,
        child: ReorderPaymentModal(),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
    );
    if (selectedPaymentMethod == true) {
      try {
        final jsonBody = jsonEncode(convertOrderToJson(order));
        Logger().i(convertOrderToJson(order));

        await Get.showOverlay(
            asyncFunction: () async {
              response = await http.post(
                Uri.parse("${baseUrlFunc}order-food"),
                headers: {"Content-Type": "application/json"},
                body: jsonBody,
              );
              Logger().i(response.body);

              if (response.statusCode == 200) {
                final data = jsonDecode(response.body);

                if (data['message'] == 'We Accept your order succesfully') {
                  if (onDelivery.value) {
                    final items = order.orderItems ?? [];
                    final totalAmount = items.fold<double>(
                        0.0,
                        (sum, item) =>
                            sum +
                            ((double.tryParse(item.price ?? '0') ?? 0) *
                                (item.quantity ?? 1)));
                    showOrderSuccessDialog(totalAmount.toStringAsFixed(2));
                  } else {
                    var responseData = jsonDecode(response.body);
                    int orderId = responseData['data']['id'];
                    final items = order.orderItems ?? [];
                    final totalAmount = items.fold<double>(
                        0.0,
                        (sum, item) =>
                            sum +
                            ((double.tryParse(item.price ?? '0') ?? 0) *
                                (item.quantity ?? 1)));
                    await handleOnlinePayment(
                        context, orderId, totalAmount.toStringAsFixed(2));
                  }
                  updateUserOrders();
                } else {
                  Get.snackbar(
                    "Error",
                    "Failed to reorder. Please try again.",
                    backgroundColor: Colors.red[100],
                    colorText: Colors.black,
                  );
                }
              } else {
                Get.snackbar(
                  "Error",
                  "Failed to reorder. Server error: ${response.statusCode}",
                  backgroundColor: Colors.red[100],
                  colorText: Colors.black,
                );
              }
            },
            loadingWidget: const Center(
              child: SizedBox(
                  height: 50, width: 50, child: CircularProgressIndicator()),
            ));
      } catch (e, s) {
        Logger().t(e, stackTrace: s);
        Get.snackbar(
          "Error",
          "sth_went_wrong".trParams({'e': e.toString()}),
          backgroundColor: Colors.red[100],
          colorText: Colors.black,
        );
      }
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
      Logger().t('Error during top up: $e', stackTrace: s);
      Get.snackbar('error'.tr, 'failed_top_up'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    return false;
  }

  Future<void> handleOnlinePayment(
      BuildContext context, int orderId, String totalAmount) async {
    final loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
    // await loginDataProvider.loadLoginData();
    if (loginDataProvider.loginData == null) {
      Get.to(() => const SignupScreen());
      return;
    }

    var data = {
      "user_id": loginDataProvider.loginData?.id,
      "amount": totalAmount,
      "date": DateTime.now().toString(),
      "food_order_id": orderId,
    };
    if (!walletPay.value) {
      try {
        var loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
        // loginDataProvider.loadLoginData();

        Logger().i(jsonEncode(data));
        final response = await http.post(
          Uri.parse('${baseUrlFunc}pay-on-chapa'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        );
        Logger().i(response.body);
        if (response.statusCode == 200 &&
            jsonDecode(response.body)['data']?['checkout_url'] != null) {
          final checkoutUrl = jsonDecode(response.body)['data']['checkout_url'];
          final result = await Get.to(() => PaymentWebView(url: checkoutUrl));
          if (result == true) {
            // orderIdString.value = orderId.toString();
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
        Logger().i(data);
        final response = await http.post(
            Uri.parse('${baseUrlFunc}pay-on-wallet'),
            body: jsonEncode(data),
            headers: {
              "Content-Type": "application/json",
            });
        Logger().i(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (Get.isRegistered<WalletController>(tag: WalletController.tag)) {
            Get.find<WalletController>(tag: WalletController.tag).loadBalance();
          }
          showSuccessDialog(totalAmount);
          updateUserOrders();
        } else {
          Get.snackbar(
            "Payment Failed",
            "unable_to_complt_wallet_payment".tr,
            backgroundColor: Colors.red[100],
            colorText: Colors.black,
          );
        }
      } catch (e, s) {
        Logger().t(e, stackTrace: s);
        Get.snackbar("Error", "sth_went_wrong".trParams({'e': e.toString()}),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
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
      Get.snackbar('Error', 'failed_to_load_balance'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      loadingBalance.value = false;
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
        content: Text("$totalAmount Birr ${"paid_enjoy".tr}"),
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

  Future<void> showCancelDialog(Order order) async {
    final TextEditingController reasonController = TextEditingController();

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("cancel_order".tr),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: "reason".tr,
            hintText: "enter_reason".tr,
            border:
                OutlineInputBorder(borderSide: BorderSide(color: mainColor)),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: mainColor)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: mainColor)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("cancel".tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                Get.snackbar("error".tr, "please_enter_a_reason".tr,
                    backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }
              Get.back();
              await cancelOrder(order, reason);
            },
            child: Text("ok".tr),
          ),
        ],
      ),
    );
  }

  Future<void> cancelOrder(Order order, String reason) async {
    final loginProvider = Get.find<LoginDataProvider>(tag: 'login');
    // await loginProvider.loadLoginData();

    final userId = loginProvider.loginData?.id;
    if (userId == null) {
      Get.snackbar("error".tr, "user_not_logged_in".tr,
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final data = {
      "order_id": order.id,
      "reason": reason,
      "price": order.price?.toStringAsFixed(2) ?? '0',
      "date": DateTime.now().toString(),
      "user_id": userId,
    };

    Logger().i("Cancel Order Data: $data");

    await Get.showOverlay(
      asyncFunction: () async {
        final response = await http.post(
          Uri.parse("https://api.hellomesa6810.com/api/cancel-order"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        );

        Logger().i("Cancel Order Response: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          final resData = jsonDecode(response.body);
          if (resData['message'].toString().toLowerCase().contains("cancel")) {
            Get.snackbar(
              "success".tr,
              "order_cancelled".tr,
              backgroundColor: Colors.green[100],
              colorText: Colors.black,
            );
            updateUserOrders();
            fetchOrderItems(order);
          } else {
            Get.snackbar(
              "error".tr,
              "unexpected".tr,
              backgroundColor: Colors.red[100],
              colorText: Colors.black,
            );
          }
        } else {
          Get.snackbar(
            "Error",
            "${'failed_to_cancel_order'.tr}. (${response.statusCode})",
            backgroundColor: Colors.red[100],
            colorText: Colors.black,
          );
        }
      },
      loadingWidget: const Center(
        child: SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  /// Updates user orders
  void updateUserOrders() {
    if (Get.isRegistered<UserOrdersController>()) {
      Get.find<UserOrdersController>().updateOrders();
    }
  }

  var order = Order(id: -1).obs;
  Future<void> fetchOrderItems(Order orderPassed) async {
    if (order.value.id == -1) {
      order.value = orderPassed;
    }
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse("${baseUrlFunc}my_order_detail/${orderPassed.id}"),
      );
      Logger().d(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          orderItems.value = List<OrderItem>.from(
              data['data'].map((e) => OrderItem.fromJson(e)));
          order.value.orderItems = orderItems;
          Order orderRecieved = Order.fromJson(data['order_status'], '');
          order.value = orderRecieved;
          order.refresh();
        }
      } else {
        Logger().e("Failed to fetch order items: ${response.statusCode}");
      }
    } catch (e) {
      Logger().e("Error fetching order details: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
