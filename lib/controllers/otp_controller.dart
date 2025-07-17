import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class OtpController extends GetxController {
  var isLoading = false.obs;
  var isOtpSent = false.obs;
  var isOtpVerified = false.obs;
  var otp = ''.obs;

  final String sendOtpUrl = 'https://api.hellomesa6810.com/api/send-otp';
  final String forgetPasswordUrl =
      'https://api.hellomesa6810.com/api/forget-password';
  void fourDigitOtpGenerator() {
    otp.value = (1000 + Random().nextInt(8999)).toString();
  }

  Future<void> sendOtp(String phone) async {
    isLoading.value = true;
    fourDigitOtpGenerator();
    final body = {"phone": phone, 'otp': otp.value};
    Logger().d(body);
    try {
      final response = await http.post(
        Uri.parse(sendOtpUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      Logger().d(response.body);

      if (response.statusCode == 200) {
        isOtpSent.value = true;
        Get.snackbar('success'.tr, 'otp_sent_success'.tr,
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('error'.tr, 'otp_sent_failure'.tr,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'otp_sent_failure'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String phone, String otpPassed) async {
    // isLoading.value = true;
    // final body = {"phone": phone, "otp": otpPassed};
    //
    // try {
    //   final response = await http.post(
    //     Uri.parse(sendOtpUrl),
    //     headers: {"Content-Type": "application/json"},
    //     body: jsonEncode(body),
    //   );

    if (otpPassed == otp.value) {
      isOtpVerified.value = true;
      Get.snackbar('success'.tr, 'otp_verified_success'.tr,
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar('error'.tr, 'otp_verified_failure'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    // } catch (e) {
    //   Get.snackbar('error'.tr, 'otp_verified_failure'.tr);
    // } finally {
    //   isLoading.value = false;
    // }
  }

  Future<void> resetPassword(
      String phone, String password, String passwordConfirmation) async {
    isLoading.value = true;
    final body = {
      "phone": phone,
      "password": password,
      "password_confirmation": passwordConfirmation,
    };

    try {
      final response = await http.post(
        Uri.parse(forgetPasswordUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Get.snackbar('success'.tr, 'password_reset_success'.tr,
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('error'.tr, 'password_reset_failure'.tr,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'password_reset_failure'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
