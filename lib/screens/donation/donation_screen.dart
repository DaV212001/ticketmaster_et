import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/controllers/cart_controller.dart';
import 'package:ticketmaster_et/controllers/donation_controller.dart';
import 'package:ticketmaster_et/screens/category/category_tab.dart';

import '../../widgets/organization_card.dart';

class DonationTabController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
  }

  void goToNextTab() {
    if (tabController.index < tabController.length - 1) {
      tabController.animateTo(tabController.index + 1);
    }
  }

  void goToPreviousTab() {
    if (tabController.index > 0) {
      tabController.animateTo(tabController.index - 1);
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}

class DonationScreen extends StatelessWidget {
  DonationScreen({super.key});

  final DonationController controller = Get.put(DonationController());
  final CartController cartController =
      Get.put(CartController(), tag: CartController.donationTag);
  final DonationTabController tabController = Get.put(DonationTabController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF23981C),
              child: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                controller: tabController.tabController,
                onTap: (index) {
                  // ✅ Prevent switching to donate tab if no org selected
                  if (index == 1 &&
                      controller.selectedOrganizationId.value == 0) {
                    Get.snackbar(
                      "select_org".tr,
                      "choose_org".tr,
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                    // Prevent the tab change
                    tabController.tabController.animateTo(0);
                  }
                },
                tabs: [
                  Tab(text: 'organizations'.tr),
                  Tab(text: 'donate'.tr),
                ],
              ),
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.organizations.isEmpty) {
                return Center(child: Text("no_organizations".tr));
              }

              return Expanded(
                child: TabBarView(
                  controller: tabController.tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // --- TAB 1: Choose Organization ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'choose_org_don'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: controller.organizations.length,
                            itemBuilder: (context, index) {
                              final org = controller.organizations[index];
                              final isSelected =
                                  controller.selectedOrganizationId.value ==
                                      org.id;

                              return GestureDetector(
                                onTap: () {
                                  controller.selectedOrganizationId.value =
                                      org.id;
                                  tabController.goToNextTab();
                                },
                                child: OrganizationCard(
                                  organization: org,
                                  isSelected: isSelected,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    // --- TAB 2: Donation Categories ---
                    CategoryTab(fromDonation: true),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
