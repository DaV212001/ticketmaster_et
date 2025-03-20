import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ticketmaster_et/functions/functions.dart';
import 'package:ticketmaster_et/provider/loginpersistence.dart';

import '../models/organizations.dart';

class OrganizationController extends GetxController {
  var isLoading = true.obs;
  var donating = false.obs;
  var organizations = <Organization>[].obs;

  @override
  void onInit() {
    fetchOrganizations();
    super.onInit();
  }

  Future<void> fetchOrganizations() async {
    try {
      isLoading(true);
      var response = await http.get(Uri.parse("${baseUrlFunc}organization"));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        organizations.value = Organization.fromJsonList(data["data"]);
      } else {
        Get.snackbar("error_occured".tr, "error_fetching_data".tr);
      }
    } catch (e) {
      Get.snackbar("error_occured".tr, "error_fetching_data".tr);
    } finally {
      isLoading(false);
    }
  }

  Future<void> donateToOrganization(
      {required int amount,
      required int organizationId,
      required String organizationName}) async {
    try {
      Get.find<LoginDataProvider>(tag: 'login').loadLoginData();
      donating(true);
      var response = await http.post(Uri.parse("${baseUrlFunc}donate"),
          headers: {'content-type': 'application/json'},
          body: jsonEncode({
            'user_id': Get.find<LoginDataProvider>(tag: 'login')
                .loginData
                ?.id
                .toString(),
            'organization_id': organizationId.toString(),
            'amount': amount.toString()
          }));
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        Get.snackbar(
            'success'.tr,
            'you_have_don'
                .trParams({'amo': amount.toString(), 'orgN': organizationName}),
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
        Get.back();
        Get.snackbar("error_occured".tr,
            "could_not_don".trParams({'orgN': organizationName}),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.back();
      Get.snackbar("error_occured".tr, "Something went wrong: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      donating(false);
    }
  }
}
