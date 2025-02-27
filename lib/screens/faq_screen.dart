import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/controllers/theme_controller.dart';

import '../functions/functions.dart';
import '../models/faq.dart';

class FaqController extends GetxController {
  var faq = <FAQ>[].obs;
  var isLoading = true.obs;

  void getFaq() async {
    try {
      isLoading.value = true;
      faq.value = await getFAQ(ThemeModeController.languageCode.value);
      isLoading.value = false;
    } catch (e, s) {
      isLoading.value = false;
      Logger().t(e, stackTrace: s);
    }
  }

  @override
  void onInit() {
    getFaq();
    super.onInit();
  }
}

class FAQScreen extends StatelessWidget {
  FAQScreen({super.key});
  final FaqController controller = Get.put(FaqController());

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
        child: Obx(() => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                shrinkWrap: true,
                itemCount: controller.faq.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    title: Text(controller.faq[index].title.toString()),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            controller.faq[index].description.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal)),
                      ),
                    ],
                  );
                })),
      ),
    );
  }
}
