import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/controllers/theme_controller.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/utils/cached_image_widget_wrapper.dart';

import '../../../../functions/functions.dart';
import '../../../../prefs/routes.dart';

class HomeCategoryController extends GetxController {
  static const String tag = 'home_category';
  var categories = <Category>[].obs;
  var events = <Event>[].obs;
  var popularevents = <Event>[].obs;
  var organizers = <Organizer>[].obs;
  var specials = <Food>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    updateCategories();
  }

  void updateCategories() async {
    isLoading.value = true;
    var languageCode = ThemeModeController.languageCode.value;
    try {
      var res = await http.get(Uri.parse('${baseUrlFunc}today_special'));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        specials.value =
            data['data'].map<Food>((e) => Food.fromJson(e, '')).toList();
      }
    } catch (e, s) {
      Logger().t(e, stackTrace: s);
    }
    var fetchedCategories = await getCategorySubCategory(languageCode);
    categories.assignAll(fetchedCategories);
    //categories.insert(
    // 0,
    // Category(
    //   id: 0,
    // image: '',
    // name: 'top_specials'.tr,
    //createdAt: DateTime.now(),
    //updatedAt: DateTime.now(),
    //foods: specials));

    // var fetchedEvents = await getEvents('$apiUrl/event', languageCode);
    // events.assignAll(fetchedEvents);
    // popularevents.assignAll(fetchedEvents.where((e) => e.isPopular == '1'));
    //
    // var fetchedOrganizers = await getOrganizers(languageCode);
    // organizers.assignAll(fetchedOrganizers);

    isLoading.value = false;
  }
}

class HomeScreenCategories extends StatelessWidget {
  // final ValueNotifier<int> selectedIndex;
  HomeScreenCategories({super.key});
  final HomeCategoryController controller =
      Get.put(HomeCategoryController(), tag: HomeCategoryController.tag);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'top_specials'.tr,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return GridView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.specials.length,
            itemBuilder: (context, subIndex) {
              final subCategory = controller.specials![subIndex];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.foodDetailRoute,
                        arguments: {'id': subCategory.id!});
                  },
                  child: Container(
                    width: 160,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 160,
                          height: 150,
                          decoration: const BoxDecoration(
                              // shape: BoxShape.rectangle,
                              // borderRadius: BorderRadius.only(
                              //     topRight: Radius.circular(15),
                              //     topLeft: Radius.circular(15)),
                              ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(15),
                                topLeft: Radius.circular(15)),
                            child: cachedNetworkImageWrapper(
                              imageUrl: subCategory.image!.trim(),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                // width: 160,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.5),
                                  // shape: BoxShape.rectangle,
                                  // borderRadius: const BorderRadius.only(
                                  //     topRight: Radius.circular(15),
                                  //     topLeft: Radius.circular(15)),
                                ),
                                child: Image.network(
                                  subCategory.image!.trim(),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              placeholderBuilder: (context, path) => Container(
                                width: 160,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.5),
                                  // shape: BoxShape.rectangle,
                                  // borderRadius: const BorderRadius.only(
                                  //     topRight: Radius.circular(15),
                                  //     topLeft: Radius.circular(15)),
                                ),
                                child: const SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidgetBuilder: (context, path, object) =>
                                  Container(
                                width: 160,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.5),
                                  // shape: BoxShape.rectangle,
                                  // borderRadius: const BorderRadius.only(
                                  //     topRight: Radius.circular(15),
                                  //     topLeft: Radius.circular(15)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.asset(
                                    'assets/images/na_logo.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: AutoSizeText(
                            subCategory.name!,
                            minFontSize: 11,
                            maxLines: 1,
                            maxFontSize: 13,
                          ),
                        )),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: SizedBox(
                            width: double.infinity,
                            height: 20,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.toNamed(Routes.foodDetailRoute,
                                    arguments: {'id': subCategory.id!});
                              },
                              child: AutoSizeText(
                                'see_detail'.tr,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                minFontSize: 10,
                                maxLines: 1,
                                maxFontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 150 / 190),
          );
          //   },
          // );
        }),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      category.name!,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (category.foods!.isEmpty)
                    Center(
                        child: Column(
                      children: [
                        Image.asset(
                          'assets/images/THICKET_MASTER_LOGO.png',
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width * 0.2,
                        ),
                        Text('no_food'.tr)
                      ],
                    ))
                  else
                    SizedBox(
                      height: 230,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: category.foods!.length,
                        itemBuilder: (context, subIndex) {
                          final subCategory = category.foods![subIndex];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Get.toNamed(Routes.foodDetailRoute,
                                    arguments: {'id': subCategory.id!});
                              },
                              child: Container(
                                width: 160,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          width: 160,
                                          height: 150,
                                          decoration: const BoxDecoration(
                                              // shape: BoxShape.rectangle,
                                              // borderRadius: BorderRadius.only(
                                              //     topRight: Radius.circular(15),
                                              //     topLeft: Radius.circular(15)),
                                              ),
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(15),
                                                    topLeft:
                                                        Radius.circular(15)),
                                            child: cachedNetworkImageWrapper(
                                              imageUrl:
                                                  subCategory.image!.trim(),
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                // width: 160,
                                                height: 150,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.5),
                                                  // shape: BoxShape.rectangle,
                                                  // borderRadius: const BorderRadius.only(
                                                  //     topRight: Radius.circular(15),
                                                  //     topLeft: Radius.circular(15)),
                                                ),
                                                child: Image.network(
                                                  subCategory.image!.trim(),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              placeholderBuilder:
                                                  (context, path) => Container(
                                                width: 160,
                                                height: 150,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.5),
                                                  // shape: BoxShape.rectangle,
                                                  // borderRadius: const BorderRadius.only(
                                                  //     topRight: Radius.circular(15),
                                                  //     topLeft: Radius.circular(15)),
                                                ),
                                                child: const SizedBox(
                                                  height: 40,
                                                  width: 40,
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              ),
                                              errorWidgetBuilder:
                                                  (context, path, object) =>
                                                      Container(
                                                width: 160,
                                                height: 150,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.5),
                                                  // shape: BoxShape.rectangle,
                                                  // borderRadius: const BorderRadius.only(
                                                  //     topRight: Radius.circular(15),
                                                  //     topLeft: Radius.circular(15)),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: Image.asset(
                                                    'assets/images/na_logo.jpg',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Positioned(
                                        //     top: 0,
                                        //     left: 0,
                                        //     child: Padding(
                                        //       padding: const EdgeInsets.all(4.0),
                                        //       child: Text(
                                        //         'See details',
                                        //         style: TextStyle(
                                        //             fontSize: 10,
                                        //             color: Theme.of(context)
                                        //                 .primaryColor,
                                        //             fontWeight: FontWeight.bold),
                                        //       ),
                                        //     )),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: AutoSizeText(
                                        subCategory.name!,
                                        minFontSize: 11,
                                        maxLines: 1,
                                        maxFontSize: 13,
                                      ),
                                    )),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 20,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Get.toNamed(Routes.foodDetailRoute,
                                                arguments: {
                                                  'id': subCategory.id!
                                                });
                                          },
                                          child: AutoSizeText(
                                            'see_detail'.tr,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                            minFontSize: 10,
                                            maxLines: 1,
                                            maxFontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        }),
      ],
    );
  }
}
