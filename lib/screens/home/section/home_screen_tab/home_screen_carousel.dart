import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/models/newmodels.dart';

import '../../../../controllers/theme_controller.dart';
import '../../../../functions/functions.dart';
import '../../../../prefs/routes.dart';

class HomeCarouselController extends GetxController {
  static const String tag = 'home_carousel';
  var popularevents = <PromotionalImages>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPromotionalImages();
  }

  void fetchPromotionalImages() async {
    isLoading.value = true;
    try {
      var images = await getPromotionalImages('${baseUrlFunc}promotional-image',
          ThemeModeController.languageCode.value);
      popularevents.assignAll(images);
    } finally {
      isLoading.value = false;
    }
  }
}

class HomeScreenCarouselSlider extends StatelessWidget {
  HomeScreenCarouselSlider({super.key});
  final HomeCarouselController controller = Get.put(HomeCarouselController());
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : CarouselSlider.builder(
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 2.5,
                enlargeCenterPage: true,
              ),
              itemBuilder: (BuildContext context, int index, pageViewIndex) {
                if (controller.popularevents.isNotEmpty) {
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.foodDetailRoute, arguments: {
                        'id': controller.popularevents[index].id!
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        fadeOutDuration: const Duration(milliseconds: 300),
                        fadeOutCurve: Curves.easeOut,
                        fadeInDuration: const Duration(milliseconds: 700),
                        fadeInCurve: Curves.easeIn,
                        imageUrl: controller.popularevents[index].image!.trim(),
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => Image.asset(
                          'assets/images/na_logo.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Image.asset(
                    'assets/images/na_logo.jpg',
                    fit: BoxFit.cover,
                  );
                }
              },
              itemCount: controller.popularevents.isEmpty
                  ? 4
                  : controller.popularevents.length,
            ),
    );
  }
}
