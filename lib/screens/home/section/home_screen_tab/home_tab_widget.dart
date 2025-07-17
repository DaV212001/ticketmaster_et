import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/screens/profile_screen.dart';

import '../../../../controllers/home_controller.dart';
import 'home_screen_carousel.dart';
import 'home_screen_categories.dart';

class HomeTabWidget extends StatelessWidget {
  HomeTabWidget({super.key});

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
                    : HomeScreenCarouselSlider(),
                const SizedBox(
                  height: 10,
                ),
                const TargetCountCard(),
                controller.categories.isNotEmpty
                    ? HomeScreenCategories()
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

class TargetCountCard extends StatelessWidget {
  const TargetCountCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    Obx(
                      () => Text(Get.find<ProfileController>()
                          .targetCount
                          .value
                          .toString()),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Obx(() => AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              height: 10,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: (Get.find<ProfileController>()
                                              .targetCount
                                              .value /
                                          100)
                                      .clamp(0.0, 1.0),
                                  child: Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      ),
                    ),
                    const Text('10'),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "target_count".trParams({
                    "count":
                        "${10 - Get.find<ProfileController>().targetCount.value}"
                  }),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
