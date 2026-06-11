// controllers/wallet_controller.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/screens/wallet/payment_web_view.dart';

import '../provider/loginpersistence.dart';

class WalletController extends GetxController {
  static String tag = 'wallet';

  final balance = '0'.obs;
  final transactions = <Transaction>[].obs;
  final isLoading = false.obs;

  final String baseUrl = 'https://api.hellomesa6810.com/api';

  @override
  void onInit() {
    super.onInit();
    loadWalletData();
  }

  Future<void> loadWalletData() async {
    try {
      isLoading.value = true;
      await loadBalance();
      await loadTransactions();
    } finally {
      isLoading.value = false;
    }
  }

  var loadingBalance = false.obs;
  Future<void> loadBalance() async {
    loadingBalance.value = true;
    try {
      final userId = Get.find<LoginDataProvider>(tag: 'login').loginData?.id;
      if (userId == null) return;

      final response =
          await http.get(Uri.parse('$baseUrl/my_wallet_amount/$userId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        balance.value = data['data'] ?? '0';
        balance.refresh();
      }
      loadingBalance.value = false;
    } catch (e, s) {
      Logger().t('Error loading balance: $e', stackTrace: s);
      Get.snackbar('Error', 'failed_to_load_balance'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
      loadingBalance.value = false;
    }
  }

  var loadingTransactions = false.obs;
  Future<void> loadTransactions() async {
    loadingTransactions.value = true;
    try {
      final userId = Get.find<LoginDataProvider>(tag: 'login').loginData?.id;
      if (userId == null) return;

      final response =
          await http.get(Uri.parse('$baseUrl/my_wallet_transaction/$userId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Logger().d(data);
        final List<dynamic> transactionData = data['data'] ?? [];

        transactions.assignAll(
            transactionData.map((item) => Transaction.fromJson(item)).toList());
        transactions
            .removeWhere((transaction) => transaction.paymentStatus == "0");
        transactions.sort((a, b) => b.id!.compareTo(a.id!));
      }
      loadingTransactions.value = false;
    } catch (e, s) {
      Logger().t('Error loading transactions: $e', stackTrace: s);
      Get.snackbar('Error', 'Failed to load transactions. Please try again.',
          backgroundColor: Colors.red, colorText: Colors.white);
      loadingTransactions.value = false;
    }
  }

  Future<void> topUp(double amount) async {
    try {
      final userId = Get.find<LoginDataProvider>(tag: 'login').loginData?.id;
      if (userId == null) return;
      var response;
      await Get.showOverlay(
          asyncFunction: () async {
            response = await http.post(
              Uri.parse('$baseUrl/wallet-payment'),
              body: {
                'user_id': userId.toString(),
                'amount': amount.toString(),
                'date': DateTime.now().toIso8601String(),
              },
            );
          },
          loadingWidget: const Center(
              child: SizedBox(
                  height: 50, width: 50, child: CircularProgressIndicator())));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final checkoutUrl = data['data']['checkout_url'];

        if (checkoutUrl != null) {
          // Open in-app browser with the checkout URL
          var paid = await Get.to<bool>(() => PaymentWebView(url: checkoutUrl));
          if (paid == true) {
            loadBalance();
            loadTransactions();
          }
        }
      }
    } catch (e, s) {
      Logger().t('Error during top up: $e', stackTrace: s);
      Get.snackbar('error'.tr, 'failed_top_up'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}

class Transaction {
  final int? id;
  final String? title;
  final String? paymentStatus;
  final DateTime? paidAt;
  final String? amount;

  Transaction({
    this.id,
    this.title,
    this.paymentStatus,
    this.paidAt,
    this.amount,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0'),
      title: json['title'] ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '0',
      paidAt: DateTime.parse(json['date']),
      amount: json['amount']?.toString() ?? '0',
    );
  }

  bool get isSuccessful => title != "Food Order Payment";
  String get formattedDate {
    if (paidAt == null) return "---";

    try {
      final date = paidAt;
      final monthNames = [
        'jan'.tr,
        'feb'.tr,
        'mar'.tr,
        'apr'.tr,
        'may'.tr,
        'jun'.tr,
        'jul'.tr,
        'aug'.tr,
        'sept'.tr,
        'oct'.tr,
        'nov'.tr,
        'dec'.tr
      ];

      return '${monthNames[date!.month - 1]}-${date.day}-${date.year}';
    } catch (e) {
      return "Invalid Date";
    }
  }
}
