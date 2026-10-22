import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ticketmaster_et/functions/functions.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  bool _isChecking = false;

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

  Future<void> _openPlayStore() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final packageName = packageInfo.packageName;
      logController.add("🌐 Launching Play Store for package: $packageName");

      final marketUri = Uri.parse('market://details?id=$packageName');
      final webUri = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');

      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri);
      }
    } catch (e) {
      logController.add("❌ Error opening Play Store: $e");
      print("Error opening Play Store: $e");
    }
  }

  // Force an update dialog leading directly to the Play Store listing
  Future<void> _forceImmediateUpdate(BuildContext context) async {
    logController.add("🔄 Showing update required dialog leading to Play Store");

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text("Update Required"),
            content: const Text(
              "A new version is available. You must update to continue.",
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  logController.add("🟢 User tapped 'Update Now' -> opening Play Store");
                  _openPlayStore();
                },
                child: const Text("Update Now"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LogController extends GetxController {
  var logs = <String>[].obs;

  void add(String log) {
    Future.microtask(() => logs.add(log));
  }

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
