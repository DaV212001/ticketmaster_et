import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/controllers/theme_controller.dart';
import 'package:ticketmaster_et/models/newmodels.dart';

import '../../../../constants/app_constants.dart';
import '../../../../functions/functions.dart';
import '../../../../prefs/routes.dart';

class HomeCategoryController extends GetxController {
  static const String tag = 'home_category';
  var categories = <Category>[].obs;
  var events = <Event>[].obs;
  var popularevents = <Event>[].obs;
  var organizers = <Organizer>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    updateCategories();
  }

  void updateCategories() async {
    isLoading.value = true;
    var languageCode = ThemeModeController.languageCode.value;

    var fetchedCategories = await getCategorySubCategory(languageCode);
    categories.assignAll(fetchedCategories);

    var fetchedEvents = await getEvents('$apiUrl/event', languageCode);
    events.assignAll(fetchedEvents);
    popularevents.assignAll(fetchedEvents.where((e) => e.isPopular == '1'));

    var fetchedOrganizers = await getOrganizers(languageCode);
    organizers.assignAll(fetchedOrganizers);

    isLoading.value = false;
  }
}

class HomeScreenCategories extends StatelessWidget {
  final ValueNotifier<int> selectedIndex;
  HomeScreenCategories({super.key, required this.selectedIndex});
  final HomeCategoryController controller =
      Get.put(HomeCategoryController(), tag: HomeCategoryController.tag);
  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
              if (category.subCategory!.isEmpty)
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
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: category.subCategory!.length,
                    itemBuilder: (context, subIndex) {
                      final subCategory = category.subCategory![subIndex];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(Routes.foodDetailRoute,
                                    arguments: {'id': subCategory.id!});
                              },
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(
                                      subCategory.image!.trim(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(subCategory.name!),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      );
    });
  }
}
