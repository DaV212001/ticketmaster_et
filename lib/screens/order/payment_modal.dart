import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/payment_controller.dart';
import '../../models/newmodels.dart';

class PaymentModal extends StatelessWidget {
  const PaymentModal({super.key, required this.order});
  final Order order;
  PaymentController get paymentController =>
      Get.put(PaymentController(), tag: order.id.toString());
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (paymentController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'complete_payment'.tr,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // 💰 Wallet Balance
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      color: Color(0xFF23981C)),
                  const SizedBox(width: 8),
                  paymentController.loadingBalance.value
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          "${'wallet_balance'.tr}: ${paymentController.balance.value} Pts",
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                ],
              ),
              const SizedBox(height: 12),

              // 🎯 Selectable Payment Chips (Custom Style)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPaymentOption(
                    label: "pay_with_chapa".tr,
                    icon: Icons.payment,
                    method: "chapa",
                    controller: paymentController,
                    onTap: () async {
                      if (paymentController.selectedMethod.value == "chapa") {
                        // Get.showOverlay(
                        //     asyncFunction: () async =>
                        await paymentController.payWithChapa(order);
                        // loadingWidget: const Center(
                        //     child: CircularProgressIndicator()));
                      } else {
                        paymentController.selectedMethod.value = "chapa";
                        Get.back();
                        // Get.showOverlay(
                        //     asyncFunction: () async =>
                        await paymentController.payWithChapa(order);
                        // loadingWidget: const Center(
                        //     child: CircularProgressIndicator()));
                      }
                    },
                  ),
                  _buildPaymentOption(
                    label: "pay_with_wallet".tr,
                    icon: Icons.account_balance_wallet_outlined,
                    method: "wallet",
                    controller: paymentController,
                    onTap: () async {
                      if (paymentController.selectedMethod.value == "wallet") {
                        // Get.back();
                        // Get.showOverlay(
                        //     asyncFunction: () async =>
                        await paymentController.payWithWallet(order);
                        // loadingWidget: const Center(
                        //     child: CircularProgressIndicator()));
                      } else {
                        paymentController.selectedMethod.value = "wallet";
                        // Get.back();
                        // Get.showOverlay(
                        //     asyncFunction: () async =>
                        await paymentController.payWithWallet(order);
                        // loadingWidget: const Center(
                        //     child: CircularProgressIndicator()));
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String label,
    required IconData icon,
    required String method,
    required PaymentController controller,
    required VoidCallback onTap,
  }) {
    final bool isSelected = controller.selectedMethod.value == method;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF23981C) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF23981C) : Colors.grey.shade300,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF23981C),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF23981C),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
