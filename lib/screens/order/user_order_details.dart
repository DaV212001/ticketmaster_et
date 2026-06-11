import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/controllers/theme_controller.dart';
import 'package:ticketmaster_et/controllers/time_controller.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/order/order_summary_view.dart';

import '../../controllers/order_detail_controller.dart';
import '../../controllers/payment_controller.dart';
import 'order_status_timeline.dart';

String paymentTypeConverter(int? type) {
  switch (type) {
    case 4:
      return 'Paid with Chapa';
    case 3:
      return 'Paid with Wallet';
    case 1:
      return 'Paid with Cash';
    default:
      return 'unknown'.tr;
  }
}

String paymentStatusConverter(int? status) {
  return status == 1 ? 'paid'.tr : 'not_paid'.tr;
}

class UserOrderDetails extends StatefulWidget {
  const UserOrderDetails({super.key});

  @override
  State<UserOrderDetails> createState() => _UserOrderDetailsState();
}

class _UserOrderDetailsState extends State<UserOrderDetails>
    with SingleTickerProviderStateMixin {
  late final Order orderPassed = Get.arguments['order'];
  final PaymentController paymentController = Get.put(PaymentController());
  final OrderDetailController orderDetailController =
      Get.put(OrderDetailController());

  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (orderPassed.id != null) {
      orderDetailController.fetchOrderItems(orderPassed);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF23981C),
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: ThemeModeController.isDark.value
          ? Theme.of(context).scaffoldBackgroundColor
          : Theme.of(context).cardColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF23981C),
        elevation: 0,
        title: Text(
          'order_details'.tr,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'reorder') {
                // Ensure order items are loaded
                if (orderDetailController.orderItems.isEmpty) {
                  await orderDetailController.fetchOrderItems(orderPassed);
                  orderDetailController.order.value.orderItems =
                      orderDetailController.orderItems.toList();
                } else {
                  orderDetailController.order.value.orderItems =
                      orderDetailController.orderItems.toList();
                }

                orderDetailController.reorder(orderPassed, context);
              }

              // ✅ Handle Cancel Order
              else if (value == 'cancel') {
                await orderDetailController.showCancelDialog(orderPassed);
              } else if (value == 'refresh') {
                await orderDetailController.fetchOrderItems(orderPassed);
              }
            },
            itemBuilder: (context) {
              final List<PopupMenuEntry<String>> menuItems = [
                if ((orderDetailController.order.value.status ?? 0) > 3 &&
                    !Get.find<TimeController>(tag: TimeController.tag)
                        .closedHours
                        .value)
                  PopupMenuItem(
                    value: 'reorder',
                    child: Row(
                      children: [
                        const Icon(EneftyIcons.shopping_bag_bold,
                            color: Color(0xFF23981C)),
                        const SizedBox(width: 8),
                        Text("reorder".tr),
                      ],
                    ),
                  ),
              ];
              menuItems.add(
                PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      const Icon(Icons.refresh, color: Colors.green),
                      const SizedBox(width: 8),
                      Text("refresh".tr),
                    ],
                  ),
                ),
              );
              if ((orderDetailController.order.value.status ?? 0) <= 3) {
                if ((orderDetailController.order.value.status ?? 0) < 3) {
                  menuItems.add(
                    PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          const Icon(Icons.cancel, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Text("cancel_order".tr),
                        ],
                      ),
                    ),
                  );
                }
              }

              return menuItems;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF23981C),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                Tab(text: "details".tr),
                Tab(text: "foods".tr),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildOrderDetailsView(context), // existing details UI extracted
                buildOrderItemsView(), // new items tab
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrderDetailsView(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🖼 Image Header
          // Obx(
          //   () => orderDetailController.isLoading.value
          //       ? Shimmer.fromColors(
          //           baseColor: Theme.of(context)
          //               .colorScheme
          //               .primary
          //               .withValues(alpha: 0.7),
          //           highlightColor: Theme.of(context)
          //               .colorScheme
          //               .primary
          //               .withValues(alpha: 0.5),
          //           child: Container(
          //             height: MediaQuery.of(context).size.height * 0.3,
          //             width: double.infinity,
          //             color: Colors.green,
          //           ),
          //         )
          //       : SizedBox(
          //           height: MediaQuery.of(context).size.height * 0.3,
          //           width: MediaQuery.of(context).size.width,
          //           child: OrderImageGrid(
          //               items: orderDetailController.orderItems)),
          // ),
          // ClipRRect(
          //   borderRadius: const BorderRadius.only(
          //     bottomLeft: Radius.circular(30),
          //     bottomRight: Radius.circular(30),
          //   ),
          //   child: CachedNetworkImage(
          //     imageUrl: order.image?.trim() ?? '',
          //     height: 220,
          //     width: double.infinity,
          //     fit: BoxFit.cover,
          //     errorWidget: (context, url, error) => Image.asset(
          //       'assets/images/THICKET_MASTER_LOGO.png',
          //       height: 220,
          //       width: double.infinity,
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'order_details'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Obx(
                          () => _detailItem(
                            icon: Icons.attach_money,
                            title: 'priceo'.tr,
                            value:
                                '${'etb'.tr} ${orderDetailController.order.value.price?.toStringAsFixed(2) ?? '0.00'}',
                          ),
                        ),
                      ),
                      Expanded(
                          child: Obx(
                        () => _detailItem(
                          icon: EneftyIcons.hashtag_2_outline,
                          title: 'order_id'.tr,
                          value: orderDetailController.order.value.id
                                  ?.toString() ??
                              '-',
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Obx(() => _detailItem(
                        icon: Icons.confirmation_number_outlined,
                        title: 'payment_status'.tr,
                        value: paymentStatusConverter(
                            orderDetailController.order.value.paymentStatus ==
                                    true
                                ? 1
                                : 0),
                      )),
                  const SizedBox(height: 10),
                  Obx(() => _detailItem(
                        icon: int.parse(orderDetailController
                                        .order.value.organizationId ??
                                    '0') !=
                                0
                            ? EneftyIcons.more_2_bold
                            : Icons.location_on_outlined,
                        title: int.parse(orderDetailController
                                        .order.value.organizationId ??
                                    '0') !=
                                0
                            ? 'desc'.tr
                            : 'location'.tr,
                        value: orderDetailController.order.value.location ?? "",
                      )),
                ],
              ),
            ),
          ),
          Obx(() => orderDetailController.order.value.paymentStatus != true
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Obx(() {
                        if (paymentController.isLoading.value) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'complete_payment'.tr,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            // 💰 Wallet Balance
                            Row(
                              children: [
                                const Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: Color(0xFF23981C)),
                                const SizedBox(width: 8),
                                paymentController.loadingBalance.value
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : Text(
                                        "${'wallet_balance'.tr}: ${paymentController.balance.value} Pts",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
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
                                    if (paymentController
                                            .selectedMethod.value ==
                                        "chapa") {
                                      await paymentController.payWithChapa(
                                          orderDetailController.order.value);
                                    } else {
                                      paymentController.selectedMethod.value =
                                          "chapa";
                                      await paymentController.payWithChapa(
                                          orderDetailController.order.value);
                                    }
                                  },
                                ),
                                _buildPaymentOption(
                                  label: "pay_with_wallet".tr,
                                  icon: Icons.account_balance_wallet_outlined,
                                  method: "wallet",
                                  controller: paymentController,
                                  onTap: () async {
                                    if (paymentController
                                            .selectedMethod.value ==
                                        "wallet") {
                                      await paymentController.payWithWallet(
                                          orderDetailController.order.value);
                                    } else {
                                      paymentController.selectedMethod.value =
                                          "wallet";
                                      await paymentController.payWithWallet(
                                          orderDetailController.order.value);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                )
              : const SizedBox.shrink()),

          const SizedBox(height: 20),

          // 🚚 Order Status Timeline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'order_status'.tr,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => _buildStatusTimeline(
                      orderDetailController.order.value.status ?? 0)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
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
                    color: Colors.green.withValues(alpha: 0.2),
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

  Widget buildOrderItemsView() {
    return Obx(() {
      if (orderDetailController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (orderDetailController.orderItems.isEmpty) {
        return const Center(child: Text("No items found for this order."));
      }

      return OrderSummary(orderItems: orderDetailController.orderItems);
    });
  }

  Widget _detailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F8),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(icon, color: const Color(0xFF23981C), size: 22),
            ))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimeline(int currentIndex) {
    final steps = [
      'waiting_acceptance'.tr,
      'order_accepted'.tr,
      'order_preparing'.tr,
      'man_on_the_way'.tr,
      'order_delivered'.tr,
      'order_rejected'.tr,
    ];

    return Obx(() => OrderStatusTimeline(
          shimmering: orderDetailController.isLoading.value,
          steps: steps,
          currentIndex: orderDetailController.order.value.status ?? 0,
        ));
  }
}
