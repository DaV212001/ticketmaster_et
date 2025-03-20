import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/screens/profile_screen.dart';

import '../controllers/organizations_controller.dart';
import '../widgets/organization_card.dart';

class OrganizationScreen extends StatelessWidget {
  final OrganizationController controller = Get.put(OrganizationController());

  OrganizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "organizations".tr,
          style: const TextStyle(color: Colors.white),
        ),
        leading: const BackButton(
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF23981C),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.organizations.isEmpty) {
          return Center(child: Text("no_organizations".tr));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: controller.organizations.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                showDonationDialog(controller.organizations[index].id,
                    controller.organizations[index].name);
              },
              child: OrganizationCard(
                  organization: controller.organizations[index]),
            );
          },
        );
      }),
    );
  }

  void showDonationDialog(int organizationId, String organizationName) {
    final ProfileController profileController = Get.find<ProfileController>();
    // final OrganizationController controller =
    // Get.find<OrganizationController>();
    int selectedMeals = 1;

    Get.dialog(
      AlertDialog(
        title: Text("donate_to".trParams({'orgN': organizationName})),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => Text("you_have_fm".trParams(
                {'amo': profileController.freeMeals.value.toString()}))),
            const SizedBox(height: 10),
            StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: selectedMeals > 1
                          ? () => setState(() => selectedMeals--)
                          : null,
                    ),
                    Text(
                      selectedMeals.toString(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed:
                          selectedMeals < profileController.freeMeals.value
                              ? () => setState(() => selectedMeals++)
                              : null,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("cancel".tr),
          ),
          Obx(() {
            return ElevatedButton(
              onPressed: controller.donating.value
                  ? null
                  : () async {
                      if (selectedMeals > 0 &&
                          selectedMeals <= profileController.freeMeals.value) {
                        await controller.donateToOrganization(
                          amount: selectedMeals,
                          organizationId: organizationId,
                          organizationName: organizationName,
                        );
                        profileController
                            .loadData(); // Refresh free meals count
                      }
                    },
              child: controller.donating.value
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text("donate".tr),
            );
          }),
        ],
      ),
    );
  }
}
