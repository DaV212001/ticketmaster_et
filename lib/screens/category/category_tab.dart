import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/category/section/category_child_list_screen.dart';

import '../../controllers/theme_controller.dart';
import '../../functions/functions.dart';

class CategoryController extends GetxController
    with SingleGetTickerProviderMixin {
  var categories = <Category>[].obs;
  var subcategoriesMap = <int, List<Food>>{}.obs;
  var isLoaded = false.obs;
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    updateCategoriesAndSubCategories();
  }

  Future<void> updateCategoriesAndSubCategories() async {
    isLoaded.value = false;
    try {
      var categoryList =
          await getCategorySubCategory(ThemeModeController.languageCode.value);
      categories.assignAll(categoryList);

      for (var cat in categories) {
        try {
          var subcategoryList = await getSubCategoryByCategoryId(
              cat.id!, ThemeModeController.languageCode.value);
          subcategoriesMap[cat.id!] = subcategoryList;
        } catch (e, s) {
          Logger().t(e.toString(), stackTrace: s);
        }
      }

      tabController = TabController(length: categories.length, vsync: this);
      isLoaded.value = true;
    } catch (e, s) {
      Logger().t(e, stackTrace: s);
    }
  }
}

class CategoryTab extends StatelessWidget {
  // final ValueNotifier<int> selectedIndex;
  final CategoryController controller = Get.put(CategoryController());

  CategoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoaded.value) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: TabBar(
                  isScrollable: true,
                  controller: controller.tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.green,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  tabs: controller.categories
                      .map((category) => Tab(
                            text: category.name,
                            icon: const Icon(Icons.event),
                          ))
                      .toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: controller.tabController,
                  children: controller.categories.map((category) {
                    var subcategories =
                        controller.subcategoriesMap[category.id] ?? [];
                    return Column(
                      children: [
                        // CategoryChild(subCategories: subcategories),
                        const SizedBox(height: 15),
                        Expanded(
                            child:
                                CategoryChildList(subCategories: subcategories))
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      } else {
        return Column(
          children: [
            Center(
                child: Image.network(
                    'https://i.postimg.cc/4dyhqLLY/THICKET-MASTER-LOGO.png')),
            const CircularProgressIndicator(),
          ],
        );
      }
    });
  }
}
