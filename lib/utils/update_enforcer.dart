import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ticketmaster_et/functions/functions.dart';

class UpdateChecker {
  bool _isChecking = false;
  final int _retryCooldownSeconds = 2; // Wait between retries if Play throttles

  Future<void> checkForUpdates({bool fromStartUp = false}) async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      // Get installed version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String installedVersion = packageInfo.version;

      // Fetch the latest version info from your API
      final response = await http.get(
        Uri.parse('${baseUrlFunc}check_app_versions'),
      );

      if (response.statusCode != 200) {
        print("Failed to fetch version info: ${response.statusCode}");
        return;
      }

      final responseData = jsonDecode(response.body);
      final apiData = responseData['data'];
      String latestVersion = apiData['latest_version_android'];
      Logger().d(latestVersion);
      if (_isUpdateAvailable(installedVersion, latestVersion)) {
        // Force update
        if (Get.context != null) {
          await _forceImmediateUpdate(Get.context!);
        }
      } else {
        if (!fromStartUp) {
          Get.snackbar('success'.tr, 'no_update_available'.tr,
              backgroundColor: Colors.green, colorText: Colors.white);
        }
        print("App is up to date.");
      }
    } catch (e, stack) {
      print("Error checking for updates: $e");
      print(stack);
    } finally {
      _isChecking = false;
    }
  }

  // Check if an update is available by comparing installed version with latest version
  bool _isUpdateAvailable(String installedVersion, String latestVersion) {
    return _compareVersions(installedVersion, latestVersion) < 0;
  }

  // Helper method to compare two version strings
  int _compareVersions(String v1, String v2) {
    List<int> v1Parts = v1.split('.').map(int.parse).toList();
    List<int> v2Parts = v2.split('.').map(int.parse).toList();
    for (int i = 0; i < v1Parts.length && i < v2Parts.length; i++) {
      if (v1Parts[i] < v2Parts[i]) return -1;
      if (v1Parts[i] > v2Parts[i]) return 1;
    }
    return 0;
  }

  final LogController logController = Get.put(LogController(), tag: 'log');
  // Force an immediate update, retrying if the user cancels or Play throttles
  Future<void> _forceImmediateUpdate(BuildContext context) async {
    final log = Logger(filter: ProductionFilter(), level: Level.trace);
    bool updateCompleted = false;
    int attempt = 0;

    logController.add("🔄 FORCE UPDATE LOOP STARTED");

    while (!updateCompleted) {
      attempt++;
      logController.add("⏳ Attempt #$attempt — showing update dialog...");

      BuildContext? dialogContext;

      // ---- SHOW DIALOG ----
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          dialogContext = ctx;
          logController.add("📌 Dialog BUILT with dialogContext = $ctx");
          return AlertDialog(
            title: const Text("Update Required"),
            content: const Text(
              "A new version is available. You must update to continue.",
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  logController.add("🟢 User tapped 'Update Now'");
                  Navigator.of(dialogContext!).pop();
                  logController.add("📤 Dialog closed.");
                },
                child: const Text("Update Now"),
              ),
            ],
          );
        },
      );

      logController.add("🔍 Checking for update via Play Store...");

      try {
        // Must be called to satisfy Play Store rules
        AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
        logController.add(
            "ℹ️ Play Store checkForUpdate() returned: availability=${updateInfo.updateAvailability}, "
            "immediateAllowed=${updateInfo.immediateUpdateAllowed}, "
            "flexibleAllowed=${updateInfo.flexibleUpdateAllowed}");

        if (updateInfo.updateAvailability ==
            UpdateAvailability.updateNotAvailable) {
          logController.add(
              "⚠️ Update not available. Retrying in $_retryCooldownSeconds seconds...");
          await Future.delayed(Duration(seconds: _retryCooldownSeconds));
          continue;
        }

        logController.add("🚀 Starting IMMEDIATE update...");

        // VM: For forced update, immediate update is the correct choice
        AppUpdateResult result = await InAppUpdate.startFlexibleUpdate();

        logController.add("📥 startFlexibleUpdate() result = $result");

        if (result == AppUpdateResult.success) {
          logController.add("🎉 UPDATE COMPLETED SUCCESSFULLY!");
          updateCompleted = true;
        } else {
          logController.add(
              "⚠️ Update did NOT complete (result=$result). Retrying after cooldown...");
          await Future.delayed(Duration(seconds: _retryCooldownSeconds));
        }
      } catch (e, stack) {
        logController.add("❌ ERROR during update attempt #$attempt: $e");
        logController.add("📚 Stacktrace: $stack");

        logController.add(
            "⏳ Play Store error or no update available. Retrying in $_retryCooldownSeconds seconds...");
        await Future.delayed(Duration(seconds: _retryCooldownSeconds));
      }
    }

    logController.add("🏁 FORCE UPDATE LOOP EXIT — Update is completed.");
  }
}

class LogController extends GetxController {
  var logs = <String>[].obs;

  void add(String log) {
    Future.microtask(() => logs.add(log));
  }

  // void addLogSafe(String message) {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     logController.add(message);
  //   });
  // }

  void clear() {
    logs.clear();
  }
}

final logController = LogController(); // global instance

class DebugOverlay extends StatelessWidget {
  DebugOverlay({super.key});
  final LogController logController = Get.find<LogController>(tag: 'log');
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Obx(() {
      return ListView.builder(
        itemCount: logController.logs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(logController.logs[index]),
          );
        },
      );
    }));
  }
}
