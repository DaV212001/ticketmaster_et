import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/utils/cached_image_widget_wrapper.dart';

import '../../../../controllers/theme_controller.dart';
import '../../../../functions/functions.dart';
import '../../../../prefs/routes.dart';

class HomeCarouselController extends GetxController {
  static const String tag = 'home_carousel';
  var popularevents = <PromotionalImages>[].obs;
  var isLoading = true.obs;
  var currentIndex = 1.obs;

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
  CarouselSliderController carouselController = CarouselSliderController();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isLoading.value
          ? Stack(
              children: [
                Shimmer.fromColors(
                  baseColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.7),
                  highlightColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.5),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: double.infinity,
                    color: Colors.green,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 15,
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        )),
                  ),
                )
              ],
            )
          : Column(
              children: [
                Stack(
                  children: [
                    CarouselSlider.builder(
                      carouselController: carouselController,
                      options: CarouselOptions(
                        autoPlay: true,
                        aspectRatio: 1.5,
                        viewportFraction: 1,
                        enlargeCenterPage: false,
                        onPageChanged: (index, reason) {
                          controller.currentIndex.value = index;
                        },
                      ),
                      itemBuilder:
                          (BuildContext context, int index, pageViewIndex) {
                        if (controller.popularevents.isNotEmpty) {
                          return GestureDetector(
                            onTap: () {
                              Get.toNamed(Routes.foodDetailRoute, arguments: {
                                'id': controller.popularevents[index].id!
                              });
                            },
                            child: cachedNetworkImageWrapper(
                              // fadeOutDuration:
                              //     const Duration(milliseconds: 300),
                              // fadeOutCurve: Curves.easeOut,
                              // fadeInDuration: const Duration(milliseconds: 700),
                              // fadeInCurve: Curves.easeIn,
                              imageUrl:
                                  controller.popularevents[index].image!.trim(),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              placeholderBuilder: (context, url) => Image.asset(
                                'assets/images/na_logo.jpg',
                                fit: BoxFit.cover,
                              ),
                              errorWidgetBuilder:
                                  (BuildContext p1, String p2, Object p3) {
                                return Image.asset(
                                  'assets/images/na_logo.jpg',
                                  fit: BoxFit.cover,
                                );
                              },
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
                    Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Stack(
                          children: [
                            Container(
                              height: 70,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                              )),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 17, vertical: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: controller.popularevents
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            var theme = Theme.of(context);
                                            return GestureDetector(
                                              // onTap: () =>
                                              //     carouselController.animateToPage(entry.key),
                                              child: Container(
                                                width: controller.currentIndex
                                                            .value ==
                                                        entry.key
                                                    ? 17
                                                    : 7,
                                                height: 7,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 3.0,
                                                ),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: controller
                                                                .currentIndex
                                                                .value ==
                                                            entry.key
                                                        ? Colors.white
                                                        : theme.colorScheme
                                                            .secondary),
                                              ),
                                            );
                                          }).toList(),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 15,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(25),
                                          topRight: Radius.circular(25),
                                        )),
                                  )
                                ],
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ],
            ),
    );
  }
}
