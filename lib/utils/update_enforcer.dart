import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ticketmaster_et/functions/functions.dart';

class UpdateChecker {
  Future<void> checkForUpdates({bool fromStartUp = false}) async {
    try {
      // Get installed version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String installedVersion = packageInfo.version;

      // Fetch the latest version info from your API
      final response = await http.get(
        Uri.parse('${baseUrlFunc}check_app_versions'),
      );
      Logger().d(response.body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final apiData = responseData['data'];

        String latestVersion = apiData['latest_version_android'];
        Logger().i("Installed version: $installedVersion");
        Logger().i("Latest version from API: $latestVersion");

        // Compare versions and decide whether to perform an update
        if (_isUpdateAvailable(installedVersion, latestVersion)) {
          // Trigger immediate update and keep retrying if user cancels
          await _forceImmediateUpdate();
        } else {
          if (!fromStartUp) {
            Get.snackbar('success'.tr, 'no_update_available'.tr,
                backgroundColor: Colors.green, colorText: Colors.white);
          }
          Logger().i("App is up to date.");
        }
      } else {
        Logger()
            .e("Failed to fetch update info from API: ${response.statusCode}");
      }
    } catch (e, stack) {
      Logger().e("Error checking for updates: $e", stackTrace: stack);
    }
  }

  // Check if an update is available by comparing installed version with latest version
  bool _isUpdateAvailable(String installedVersion, String latestVersion) {
    return _compareVersions(installedVersion, latestVersion) < 0;
  }

  // Helper method to compare two version strings (returns -1 if v1 < v2, 0 if equal, 1 if v1 > v2)
  int _compareVersions(String v1, String v2) {
    List<int> v1Parts = v1.split('.').map(int.parse).toList();
    List<int> v2Parts = v2.split('.').map(int.parse).toList();
    for (int i = 0; i < v1Parts.length && i < v2Parts.length; i++) {
      if (v1Parts[i] < v2Parts[i]) return -1;
      if (v1Parts[i] > v2Parts[i]) return 1;
    }
    return 0;
  }

  // Force an immediate update, retrying if the user cancels
  Future<void> _forceImmediateUpdate() async {
    bool updateCompleted = false;
    while (!updateCompleted) {
      try {
        Logger().i("Triggering immediate update...");
        AppUpdateResult result = await InAppUpdate.startFlexibleUpdate();

        if (result == AppUpdateResult.success) {
          Logger().i("Update completed successfully.");
          await InAppUpdate.completeFlexibleUpdate();
          updateCompleted = true;
        } else {
          Logger().i("Update was canceled or failed. Retrying...");
        }
      } catch (e) {
        Logger().e("Error during update: $e. Retrying...");
      }
    }
  }
}
