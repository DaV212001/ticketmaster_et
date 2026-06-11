import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/controllers/theme_controller.dart';
import 'package:ticketmaster_et/models/newmodels.dart';

import '../api_call_status.dart';
import '../functions/functions.dart';
import '../prefs/error_data.dart';
import '../prefs/error_utils.dart';

class HomeCategoryController extends GetxController {
  static const String tag = 'home_category';

  // Data
  final RxList<Category> categories = <Category>[].obs;
  final RxList<Food> specials = <Food>[].obs;

  // Per-section API states
  final Rx<ApiCallStatus> categoriesStatus = ApiCallStatus.holding.obs;
  final Rx<ApiCallStatus> specialsStatus = ApiCallStatus.holding.obs;

  // Per-section error payloads
  final Rx<ErrorData?> categoriesError = Rx<ErrorData?>(null);
  final Rx<ErrorData?> specialsError = Rx<ErrorData?>(null);

  // Unified flag to indicate *connection* issues (to avoid duplicate connection error cards)
  final RxBool hasConnectionError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  bool _isConnectionError(Object e) {
    return e is SocketException ||
        e is TimeoutException ||
        e is HandshakeException ||
        e is http.ClientException;
  }

  void _showConnectionSnackbar() {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text("Your internet connection is weak. Please try again."),
        ),
      );
    }
  }

  /// Fetch both sections. Independent states: each can succeed or fail on its own.
  /// If either call throws a connection error, `hasConnectionError` becomes true
  /// and the UI will display a single connection error card.
  Future<void> fetchAll() async {
    hasConnectionError.value = false;

    // Run both fetches in parallel
    await Future.wait([
      fetchSpecials(),
      fetchCategories(),
    ]);
  }

  Future<void> fetchSpecials() async {
    specialsStatus.value = ApiCallStatus.loading;
    specialsError.value = null;

    try {
      final res = await http
          .get(Uri.parse('${baseUrlFunc}today_special'))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        Logger().d(data);
        specials.assignAll(
            (data['data'] as List).map<Food>((e) => Food.fromJson(e)).toList());
        specialsStatus.value = ApiCallStatus.success;
      } else {
        // non-200
        specialsStatus.value = ApiCallStatus.error;
        specialsError.value = await ErrorUtil.getErrorData(
            'Server returned ${res.statusCode} for today_special');
      }
    } catch (e, s) {
      Logger().t(e, stackTrace: s);
      specialsError.value = await ErrorUtil.getErrorData(e.toString());
      if (_isConnectionError(e)) {
        hasConnectionError.value = true;
        _showConnectionSnackbar();
      }

      specialsStatus.value = ApiCallStatus.error;
    }
  }

  Future<void> fetchCategories() async {
    categoriesStatus.value = ApiCallStatus.loading;
    categoriesError.value = null;

    try {
      final languageCode = ThemeModeController.languageCode.value;
      final fetched = await getCategorySubCategory(languageCode);
      categories.assignAll(fetched);
      categoriesStatus.value = ApiCallStatus.success;
    } catch (e, s) {
      Logger().t(e, stackTrace: s);

      if (_isConnectionError(e)) {
        hasConnectionError.value = true;
        _showConnectionSnackbar();
      }
      categoriesStatus.value = ApiCallStatus.error;
      categoriesError.value = await ErrorUtil.getErrorData(e.toString());
    }
  }
}
