import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/controllers/theme_controller.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/prefs/shimmer_wrapper.dart';
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
  var isLoading = false.obs;
  var isSpecialsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    updateCategories();
  }

  void updateCategories() async {
    isLoading.value = true;
    isSpecialsLoading.value = true;
    var languageCode = ThemeModeController.languageCode.value;
    try {
      var res = await http.get(Uri.parse('${baseUrlFunc}today_special'));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        Logger().d(data);
        specials.value =
            data['data'].map<Food>((e) => Food.fromJson(e)).toList();
      }
    } catch (e, s) {
      Logger().t(e, stackTrace: s);
    }
    isSpecialsLoading.value = false;
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
        Obx(() => controller.specials.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'top_specials'.tr,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            : const SizedBox.shrink()),
        Obx(() {
          if (controller.isSpecialsLoading.value) {
            return SizedBox(
              height:
                  202, // adjust height to match your card height (image + labels)
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                shrinkWrap: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                itemBuilder: (context, subIndex) {
                  final subCategory = Category.sampleCat.foods?[0];

                  // Your card — mostly copied from your original code, trimmed a bit
                  return HomeFoodCard(
                    subCategory: subCategory ?? Food(),
                    shimmering: true,
                  );
                },
              ),
            );
          }

          final specials = controller.specials ?? [];

          // Outer ListView for vertical scrolling of rows (each row is a horizontal ListView)
          return SizedBox(
            height:
                202, // adjust height to match your card height (image + labels)
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: specials.length,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              itemBuilder: (context, subIndex) {
                final subCategory = specials[subIndex];

                // Your card — mostly copied from your original code, trimmed a bit
                return HomeFoodCard(subCategory: subCategory);
              },
            ),
          );
        }),
        Obx(() {
          if (controller.isLoading.value) {
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index) {
                final category = Category.sampleCat;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerWrapper(
                      isEnabled: true,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "category",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 172,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 8),
                        itemCount: 10,
                        itemBuilder: (context, subIndex) {
                          final subCategory = category.foods![0];
                          return HomeFoodCard(
                            subCategory: subCategory,
                            shimmering: true,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
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
                          fontSize: 16, fontWeight: FontWeight.bold),
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
                      height: 172,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 8),
                        itemCount: category.foods!.length,
                        itemBuilder: (context, subIndex) {
                          final subCategory = category.foods![subIndex];
                          return HomeFoodCard(
                            subCategory: subCategory,
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

class HomeFoodCard extends StatelessWidget {
  const HomeFoodCard({
    super.key,
    required this.subCategory,
    this.shimmering,
  });

  final Food subCategory;
  final bool? shimmering;

  @override
  Widget build(BuildContext context) {
    var width = 135.0;
    var height = 100.0;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () {
          Get.toNamed(Routes.foodDetailRoute,
              arguments: {'id': subCategory.id!});
        },
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: -8,
              blurRadius: 10,
              offset: const Offset(0, 0), // changes position of shadow
            ),
          ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image stack
              ShimmerWrapper(
                isEnabled: shimmering ?? false,
                child: Stack(
                  children: [
                    Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(7),
                            topRight: Radius.circular(7),
                          ),
                          color: Theme.of(context).cardColor),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(7),
                          topRight: Radius.circular(7),
                        ),
                        child: SizedBox(
                          width: width,
                          height: height,
                          child: cachedNetworkImageWrapper(
                            imageUrl: subCategory.image!.trim(),
                            imageBuilder: (context, imageProvider) =>
                                Image.network(
                              subCategory.image!.trim(),
                              fit: BoxFit.cover,
                              width: width,
                              height: height,
                            ),
                            placeholderBuilder: (context, path) => Container(
                              width: width,
                              height: height,
                              alignment: Alignment.center,
                              child: const SizedBox(
                                height: 40,
                                width: 40,
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidgetBuilder: (context, path, object) =>
                                Container(
                              width: width,
                              height: height,
                              child: Image.asset(
                                'assets/images/na_logo.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Discount badge
                    if (subCategory.isDiscounted == true)
                      Positioned(
                        top: 5,
                        left: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              '${subCategory.discountPercentage}% Discount',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                    // Bottom black overlay with name & price
                  ],
                ),
              ),
              Container(
                width: width,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ShimmerWrapper(
                    isEnabled: shimmering,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 2),
                          child: Text(
                            subCategory.name!,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${subCategory.price!.toStringAsFixed(2)} ${'etb'.tr}',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (subCategory.isDiscounted == true)
                                Text(
                                  '${subCategory.price! + subCategory.price! * (subCategory.discountPercentage! / 100)} ${'etb'.tr}',
                                  style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10),
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
