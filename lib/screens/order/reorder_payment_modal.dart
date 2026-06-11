import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/order_detail_controller.dart';

class ReorderPaymentModal extends StatelessWidget {
  ReorderPaymentModal({super.key});

  final OrderDetailController controller = Get.find<OrderDetailController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 16.0, top: 16),
            child: Text(
              'payment_method'.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8),
            child: Obx(() => controller.loadingBalance.value
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    "${'wallet_balance'.tr}: ${controller.balance.value} Pts",
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        controller.onDelivery.value = true;
                        controller.walletPay.value = false;
                        controller.onDelivery.refresh();
                        controller.walletPay.refresh();
                      },
                      child: Obx(
                        () => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: controller.onDelivery.value
                                  ? Colors.green
                                  : Colors.grey,
                              width: controller.onDelivery.value ? 3 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Column(
                                  children: [
                                    Icon(
                                      Icons.bike_scooter,
                                      color: controller.onDelivery.value
                                          ? Colors.green
                                          : Colors.grey,
                                      weight:
                                          controller.onDelivery.value ? 2 : 1,
                                    ),
                                    Text('on_delivery'.tr)
                                  ],
                                ),
                                if (controller.onDelivery.value)
                                  const Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        controller.onDelivery.value = false;
                        controller.walletPay.value = true;
                        controller.onDelivery.refresh();
                        controller.walletPay.refresh();
                      },
                      child: Obx(
                        () => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: !controller.onDelivery.value &&
                                      controller.walletPay.value
                                  ? Colors.green
                                  : Colors.grey,
                              width: !controller.onDelivery.value &&
                                      controller.walletPay.value
                                  ? 3
                                  : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Column(
                                  children: [
                                    Icon(
                                      EneftyIcons.wallet_2_bold,
                                      color: !controller.onDelivery.value &&
                                              controller.walletPay.value
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    Text('pay_with_wallet'.tr)
                                  ],
                                ),
                                if (!controller.onDelivery.value &&
                                    controller.walletPay.value)
                                  const Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        controller.onDelivery.value = false;
                        controller.walletPay.value = false;
                        controller.onDelivery.refresh();
                        controller.walletPay.refresh();
                      },
                      child: Obx(
                        () => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: !controller.onDelivery.value &&
                                      !controller.walletPay.value
                                  ? Colors.green
                                  : Colors.grey,
                              width: !controller.onDelivery.value &&
                                      !controller.walletPay.value
                                  ? 3
                                  : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Column(
                                  children: [
                                    Icon(
                                      Icons.wallet,
                                      color: !controller.onDelivery.value &&
                                              !controller.walletPay.value
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    Text('Pay with Chapa'.tr)
                                  ],
                                ),
                                if (!controller.onDelivery.value &&
                                    !controller.walletPay.value)
                                  const Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 60,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      Get.back(result: true);
                    },
                    child: const Text(
                      'Pay Now',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
