import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/constants/assets.dart';
import 'package:ticketmaster_et/prefs/shimmer_wrapper.dart';

import '../../../../api_call_status.dart';
import '../../../../controllers/home_category_controller.dart';
import '../../../../controllers/time_controller.dart';
import '../../../../models/newmodels.dart';
import '../../../../prefs/error_card.dart';
import '../../../../prefs/error_data.dart';
import '../../../../widgets/home_food_card.dart';

class HomeScreenCategories extends StatelessWidget {
  HomeScreenCategories({super.key});

  final HomeCategoryController controller =
      Get.put(HomeCategoryController(), tag: HomeCategoryController.tag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Unified connection error (single card) - avoids duplication
      if (controller.hasConnectionError.value) {
        // Use whichever error payload is available (prefer specials then categories)
        final errorData = controller.specialsError.value ??
            controller.categoriesError.value ??
            ErrorData(
              title: 'connection_error'.tr,
              body: 'please_check_connection'.tr,
              image: Assets.empty,
            );

        return Center(child: ErrorCard(errorData: errorData));
      }

      // Normal (non-connection) flow: render sections independently
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSpecialsSection(),
          const SizedBox(height: 8),
          _buildCategoriesSection(),
        ],
      );
    });
  }

  Widget _buildSpecialsSection() {
    return Obx(() {
      if (Get.find<TimeController>(tag: TimeController.tag)
          .isLoadingWorkTimes
          .value) {
        return _buildShimmerSpecials();
      }
      switch (controller.specialsStatus.value) {
        case ApiCallStatus.loading:
          return _buildShimmerSpecials();

        case ApiCallStatus.error:
          // non-connection error for specials only
          final error = controller.specialsError.value ??
              ErrorData(
                  title: 'specials_error'.tr,
                  body: 'something_went_wrong'.tr,
                  image: Assets.empty);
          return Center(child: ErrorCard(errorData: error));

        case ApiCallStatus.success:
          if (controller.specials.isEmpty) {
            return Center(
              child: ErrorCard(
                errorData: ErrorData(
                  title: 'no_specials'.tr,
                  body: 'no_specials_found'.tr,
                  image: Assets.empty,
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'top_specials'.tr,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 202,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  itemCount: controller.specials.length,
                  itemBuilder: (context, i) {
                    final subCategory = controller.specials[i];
                    return HomeFoodCard(subCategory: subCategory);
                  },
                ),
              ),
            ],
          );

        default:
          return const SizedBox.shrink();
      }
    });
  }

  Widget _buildCategoriesSection() {
    return Obx(() {
      if (Get.find<TimeController>(tag: TimeController.tag)
          .isLoadingWorkTimes
          .value) {
        return _buildShimmerCategories();
      }
      switch (controller.categoriesStatus.value) {
        case ApiCallStatus.loading:
          return _buildShimmerCategories();

        case ApiCallStatus.error:
          final error = controller.categoriesError.value ??
              ErrorData(
                  title: 'categories_error'.tr,
                  body: 'something_went_wrong'.tr,
                  image: Assets.empty);
          return Center(child: ErrorCard(errorData: error));

        case ApiCallStatus.success:
          List<Category> categories = List.from(controller.categories);
          categories.removeWhere((categories) => categories.id == 20);

          if (categories.isEmpty) {
            return Center(
              child: ErrorCard(
                errorData: ErrorData(
                  title: 'no_categories'.tr,
                  body: 'no_categories_found'.tr,
                  image: Assets.empty,
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      category.name ?? '',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (category.foods == null || category.foods!.isEmpty)
                    Center(
                      child: SizedBox(
                        height: 100,
                        width: double.infinity,
                        child: ErrorCard(
                            makeHorizontal: true,
                            imageHeight: 100,
                            errorData: ErrorData(
                                title: 'No Foods',
                                body: 'No foods found for this category',
                                image: Assets.emptyCart)),
                      ),
                    )
                  else
                    SizedBox(
                      height: 172,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 8),
                        itemCount: category.foods!.length,
                        itemBuilder: (context, subIndex) {
                          final subCategory = category.foods![subIndex];
                          return HomeFoodCard(subCategory: subCategory);
                        },
                      ),
                    ),
                ],
              );
            },
          );

        default:
          return const SizedBox.shrink();
      }
    });
  }

  Widget _buildShimmerSpecials() {
    return SizedBox(
      height: 202,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        itemBuilder: (context, _) => HomeFoodCard(
          subCategory: Food(
            id: 0,
            name: 'Sample Food',
            image: '',
            price: 0.0,
            discountPercentage: 0.0,
            isDiscounted: false,
          ),
          shimmering: true,
        ),
      ),
    );
  }

  Widget _buildShimmerCategories() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: 2,
      itemBuilder: (context, _) {
        final sample = Category.sampleCat;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerWrapper(
              isEnabled: true,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "category",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 172,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 8),
                itemCount: 10,
                itemBuilder: (context, __) => HomeFoodCard(
                  subCategory: sample.foods![0],
                  shimmering: true,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
