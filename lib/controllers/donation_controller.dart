import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../functions/functions.dart';
import '../models/organizations.dart';

class DonationController extends GetxController {
  var selectedOrganizationId = 0.obs;

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
        Logger().d(data);
        organizations.value = Organization.fromJsonList(data["data"]);
      } else {
        Get.snackbar("error_occured".tr, "error_fetching_data".tr, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("error_occured".tr, "error_fetching_data".tr, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }
}
