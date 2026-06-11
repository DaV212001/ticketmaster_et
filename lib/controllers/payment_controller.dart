import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/controllers/wallet_controller.dart';

import '../functions/functions.dart';
import '../models/newmodels.dart';
import '../provider/loginpersistence.dart';
import '../screens/order/user_orders.dart';
import '../screens/wallet/payment_web_view.dart';
import 'order_detail_controller.dart';

class PaymentController extends GetxController {
  final Dio dio = Dio();
  var selectedMethod = ''.obs; // 'wallet' or 'chapa'

  var isLoading = false.obs;
  var loadingBalance = false.obs;
  var balance = '0'.obs;

  @override
  void onInit() {
    super.onInit();
    loadBalance(); // fetch balance when controller is created
  }

  Future<void> loadBalance() async {
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

  Future<void> payWithWallet(Order order) async {
    try {
      isLoading.value = true;

      final loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
      // loginDataProvider.loadLoginData();

      double currentBalance = double.tryParse(balance.value) ?? 0;
      final requiredAmount = order.price ?? 0;

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

      var data = {
        "user_id": loginDataProvider.loginData?.id,
        "amount": requiredAmount.toStringAsFixed(2),
        "date": DateTime.now().toIso8601String(),
        "food_order_id": order.id,
      };

      Logger().i(data);
      http.Response? response = http.Response('', 400);
      await Get.showOverlay(
          asyncFunction: () async {
            response = await http.post(
              Uri.parse('${baseUrlFunc}pay-on-wallet'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(data),
            );
          },
          loadingWidget: const Center(
            child: SizedBox(
                height: 50, width: 50, child: CircularProgressIndicator()),
          ));
      // if (response != null) {
      Logger().i(response?.body);
      isLoading.value = false;

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        Get.back();
        Get.snackbar(
          "success".tr,
          "wallet_payment_processed".tr,
          backgroundColor: Colors.green[100],
          colorText: Colors.black,
        );
        order.paymentStatus = true;
        if (Get.isRegistered<UserOrdersController>()) {
          Get.find<UserOrdersController>().updateOrders();
        }
        if (Get.isRegistered<OrderDetailController>()) {
          Get.find<OrderDetailController>().fetchOrderItems(order);
        }
        if (Get.isRegistered<WalletController>(tag: WalletController.tag)) {
          Get.find<WalletController>(tag: WalletController.tag).loadBalance();
        }
        update();
      } else {
        Get.snackbar(
          "error".tr,
          "unable_to_complt_wallet_payment".tr,
          backgroundColor: Colors.red[100],
          colorText: Colors.black,
        );
      }
      // }
    } catch (e, s) {
      Logger().t(e, stackTrace: s);
      isLoading.value = false;
      Get.snackbar("error".tr, "sth_went_wrong".trParams({'e': e.toString()}),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> payWithChapa(Order order) async {
    try {
      isLoading.value = true;
      Get.back();
      var loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
      // loginDataProvider.loadLoginData();
      var data = {
        "user_id": loginDataProvider.loginData?.id,
        "amount": order.price?.toInt(),
        "date": DateTime.now().toString(),
        "food_order_id": order.id,
      };
      Logger().i(jsonEncode(data));
      final response = await http.post(
        Uri.parse('${baseUrlFunc}pay-on-chapa'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      Logger().i(response.body);
      isLoading.value = false;

      if (response.statusCode == 200 &&
          jsonDecode(response.body)['data']?['checkout_url'] != null) {
        final checkoutUrl = jsonDecode(response.body)['data']['checkout_url'];

        final result = await Get.to(() => PaymentWebView(url: checkoutUrl));

        if (result == true) {
          Get.back();
          Get.snackbar(
            "success".tr,
            "chapa_payment_confirmed".tr,
            backgroundColor: Colors.green[100],
            colorText: Colors.black,
          );
          order.paymentStatus = true;
          if (Get.isRegistered<UserOrdersController>()) {
            Get.find<UserOrdersController>().updateOrders();
          }
          if (Get.isRegistered<OrderDetailController>()) {
            Get.find<OrderDetailController>().fetchOrderItems(order);
          }
          update();
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
      isLoading.value = false;
      Get.snackbar("error".tr, "sth_went_wrong".trParams({'e': e.toString()}),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
