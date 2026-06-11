import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/functions/functions.dart';
import 'package:ticketmaster_et/prefs/routes.dart';

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
    final body = {"phone": '251$phone', 'otp': otp.value};
    Logger().d(body);
    try {
      final response = await http.post(
        Uri.parse(sendOtpUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      Logger().d(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
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

  Future<void> verifyOtp(
    String phone,
    String otpPassed, {
    bool fromSignUp = false,
    required int userId,
  }) async {
    isLoading.value = true;
    // final body = {"phone": phone, "otp": otpPassed};
    //
    // try {
    //   final response = await http.post(
    //     Uri.parse(sendOtpUrl),
    //     headers: {"Content-Type": "application/json"},
    //     body: jsonEncode(body),
    //   );
    isLoading.value = true;

    final body = {
      "user_id": userId,
      "otp": otpPassed,
    };

    Logger().d(body);

    try {
      if (userId != 0) {
        final response = await http.post(
          Uri.parse('${baseUrlFunc}verify-otp'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );

        Logger().d(response.body);

        if (response.statusCode == 200) {
          if (fromSignUp) {
            Get.offNamed(Routes.loginRoute);
            Get.snackbar('success'.tr, 'otp_verified_login'.tr,
                backgroundColor: Colors.green, colorText: Colors.white);
            return;
          }
          isOtpVerified.value = true;
          Get.snackbar('success'.tr, 'otp_verified_success'.tr,
              backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          // ❌ WRONG OTP
          Get.snackbar('error'.tr, 'otp_verified_failure'.tr,
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        if (otpPassed == otp.value) {
          if (fromSignUp) {
            Get.offNamed(Routes.loginRoute);
            Get.snackbar('success'.tr, 'otp_verified_login'.tr,
                backgroundColor: Colors.green, colorText: Colors.white);
            return;
          }
          isOtpVerified.value = true;
          Get.snackbar('success'.tr, 'otp_verified_success'.tr,
              backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          // ❌ WRONG OTP
          Get.snackbar('error'.tr, 'otp_verified_failure'.tr,
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'otp_verified_failure'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(
      String phone, String password, String passwordConfirmation) async {
    isLoading.value = true;
    final body = {
      "phone": '251$phone',
      "password": password,
      "password_confirmation": passwordConfirmation,
    };

    try {
      final response = await http.post(
        Uri.parse(forgetPasswordUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      Logger().d(response.body);

      if (response.statusCode == 200) {
        Get.back();
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
