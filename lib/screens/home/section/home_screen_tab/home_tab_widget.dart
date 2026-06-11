import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ticketmaster_et/controllers/time_controller.dart';
import 'package:ticketmaster_et/controllers/wallet_controller.dart';

import '../../../../controllers/home_category_controller.dart';
import 'home_screen_carousel.dart';
import 'home_screen_categories.dart';

class HomeTabWidget extends StatelessWidget {
  const HomeTabWidget({super.key});

  // final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          if (Get.isRegistered<HomeCategoryController>(
              tag: HomeCategoryController.tag)) {
            Get.find<HomeCategoryController>(tag: HomeCategoryController.tag)
                .fetchAll();
          }
          if (Get.isRegistered<HomeCarouselController>()) {
            Get.find<HomeCarouselController>().fetchPromotionalImages();
          }
          if (Get.isRegistered<WalletController>(tag: WalletController.tag)) {
            Get.find<WalletController>(tag: WalletController.tag).loadBalance();
          }
          Get.find<TimeController>(tag: TimeController.tag).loadWorkTimes();
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeScreenCarouselSlider(),
                    const TargetCountCard(),
                    HomeScreenCategories(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
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
              Align(
                alignment: AlignmentGeometry.center,
                child: Obx(() {
                  WalletController wc =
                      Get.find<WalletController>(tag: WalletController.tag);
                  return wc.loadingBalance.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator())
                      : Text(
                          'Your Point is: ${NumberFormat('#,##0.00').format(double.parse(Get.find<WalletController>(tag: WalletController.tag).balance.value))}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.green),
                        );
                }),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'DEAR FAMILY, USE YOUR POINTS TO ORDER YOUR MEALS.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
