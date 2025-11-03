import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/category/section/category_child_list_screen.dart';
import 'package:ticketmaster_et/screens/home/home_tab.dart';

import '../../controllers/theme_controller.dart';
import '../../functions/functions.dart';

class CategoryController extends GetxController
    with GetTickerProviderStateMixin {
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
          // Logger().d(subcategoriesMap.entries.first.value.length);
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

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}

class CategoryTab extends StatelessWidget {
  // final ValueNotifier<int> selectedIndex;
  final CategoryController controller = Get.put(CategoryController());

  CategoryTab({super.key, this.fromDonation});
  final bool? fromDonation;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF23981C), // Change this to your desired color
      statusBarIconBrightness: Brightness.light, // For light icons
      statusBarBrightness: Brightness.dark, // For iOS status bar
    ));
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoaded.value) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: TabBar(
                            isScrollable: true,
                            physics: const BouncingScrollPhysics(),
                            controller: controller.tabController,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.green,
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black,
                            tabs: controller.categories
                                .map((category) => Tab(
                                      child: Text(
                                        category.name ?? '',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                      if (fromDonation != true)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: CartIcon(),
                        )
                    ],
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
                                child: CategoryChildList(
                              subCategories: subcategories,
                              fromDonation: fromDonation,
                            ))
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
        }),
      ),
    );
  }
}
