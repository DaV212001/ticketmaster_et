import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/controllers/how_we_cook_controller.dart';
import 'package:ticketmaster_et/screens/profile/how_we_cook/how_we_cook_card.dart';

class HowWeCookScreen extends StatelessWidget {
  final HowWeCookController controller = Get.put(HowWeCookController());

  HowWeCookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF23981C), // Change this to your desired color
      statusBarIconBrightness: Brightness.light, // For light icons
      statusBarBrightness: Brightness.dark, // For iOS status bar
    ));
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.howWeCook.isEmpty) {
          return const Center(child: Text("try_again"));
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            itemCount: controller.howWeCook.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final item = controller.howWeCook[index];
              return HowWeCookCard(
                  text: item.title ?? '', videoUrl: item.videoLink ?? '');
            },
          ),
        );
      }),
    );
  }
}
