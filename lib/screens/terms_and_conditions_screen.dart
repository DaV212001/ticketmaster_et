import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/controllers/theme_controller.dart';

import '../functions/functions.dart';
import '../models/terms_and_conditions.dart';

class TermsAndConditionsController extends GetxController {
  var termsAndConditions = <TermsAndConditions>[].obs;
  var isLoading = true.obs;

  void fetchTermsAndConditions() async {
    try {
      isLoading.value = true;
      termsAndConditions.value =
          await getTermsAndConditions(ThemeModeController.languageCode.value);
      isLoading.value = false;
    } catch (e, s) {
      isLoading.value = false;
      Logger().t(e, stackTrace: s);
    }
  }

  @override
  void onInit() {
    fetchTermsAndConditions();
    super.onInit();
  }
}

class TermsAndConditionsScreen extends StatelessWidget {
  TermsAndConditionsScreen({super.key});
  final TermsAndConditionsController controller =
      Get.put(TermsAndConditionsController());

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF23981C), // Change this to your desired color
      statusBarIconBrightness: Brightness.light, // For light icons
      statusBarBrightness: Brightness.dark, // For iOS status bar
    ));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.green),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.termsAndConditions.length,
                  itemBuilder: (context, index) {
                    return Text(
                        controller.termsAndConditions[index].title.toString(),
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 16, fontWeight: FontWeight.normal));
                  }),
        ),
      ),
    );
  }
}
