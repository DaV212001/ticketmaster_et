import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ticketmaster_et/provider/loginpersistence.dart';

class ChangePasswordController extends GetxController {
  var isLoading = false.obs;
  final String url = 'https://api.hellomesa6810.com/api/change-password';

  Future<void> changePassword(
      String password, String passwordConfirmation) async {
    isLoading.value = true;
    final body = {
      "user_id": Get.find<LoginDataProvider>(tag: 'login').loginData?.id,
      "password": password,
      "password_confirmation": passwordConfirmation,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Password change successful
        Get.snackbar(
          'success'.tr,
          'change_pass_success'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Handle error
        Get.snackbar('error'.tr, 'change_pass_failure'.tr,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      // Handle connection error
      Get.snackbar('error'.tr, 'change_pass_failure'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
