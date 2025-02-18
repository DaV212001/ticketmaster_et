import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/home_controller.dart';
import 'home_screen_carousel.dart';
import 'home_screen_categories.dart';

class HomeTabWidget extends StatelessWidget {
  final ValueNotifier<int> selectedIndex;
  HomeTabWidget({super.key, required this.selectedIndex});

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      } else {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : HomeScreenCarouselSlider(
                        selectedIndex: selectedIndex,
                      ),
                controller.categories.isNotEmpty
                    ? HomeScreenCategories(
                        selectedIndex: selectedIndex,
                      )
                    : Center(
                        child: Image.network(
                            'https://i.postimg.cc/4dyhqLLY/THICKET-MASTER-LOGO.png'),
                      ),
              ],
            ),
          ),
        );
      }
    });
  }
}
