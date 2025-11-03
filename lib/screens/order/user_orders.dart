import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/controllers/theme_controller.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/prefs/routes.dart';
import 'package:ticketmaster_et/screens/home/home_tab.dart';
import 'package:ticketmaster_et/screens/order/payment_modal.dart';

import '../../functions/functions.dart';
import '../../provider/loginpersistence.dart';

class UserOrdersController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var activeOrders = <Order>[].obs;
  var pastOrders = <Order>[].obs;
  var isLoading = true.obs;
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    updateOrders();
    ever(ThemeModeController.languageCode, (_) => updateOrders());
  }

  void updateOrders() async {
    isLoading.value = true;
    String? phone = Get.find<LoginDataProvider>(tag: 'login').loginData?.phone;
    if (phone != null) {
      // Fetch both active and past orders concurrently
      final results = await Future.wait([
        getActiveTickets(phone, ThemeModeController.languageCode.value),
        getPastTickets(phone, ThemeModeController.languageCode.value),
      ]);

      activeOrders.value = results[0];
      pastOrders.value = results[1];

      // Sort both lists by date
      activeOrders.sort((a, b) => b.id!.compareTo(a.id!));
      pastOrders.sort((a, b) => b.id!.compareTo(a.id!));
    } else {
      Logger().i('No Phone');
    }
    isLoading.value = false;
  }
}

class UserOrders extends StatelessWidget {
  final UserOrdersController controller = Get.put(UserOrdersController());

  UserOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: SizedBox(
            height: 60,
            width: 60,
            child: CartIcon(
              colored: true,
            )),
        body: Column(
          children: [
            Container(
              color: const Color(0xFF23981C),
              child: Column(
                children: [
                  const SafeArea(
                      child: SizedBox(
                    height: 10,
                  )),
                  TabBar(
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      controller: controller.tabController,
                      tabs: [
                        Tab(
                          text: 'active_orders'.tr,
                        ),
                        Tab(
                          text: 'past_orders'.tr,
                        ),
                      ]),
                ],
              ),
            ),
            Expanded(
              child:
                  TabBarView(controller: controller.tabController, children: [
                ActiveOrders(controller: controller),
                PastOrders(controller: controller),
              ]),
            )
          ],
        ));
  }
}

class ActiveOrders extends StatelessWidget {
  const ActiveOrders({super.key, required this.controller});

  final UserOrdersController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.activeOrders.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('no_orders_found'.tr),
              ElevatedButton(
                onPressed: controller.updateOrders,
                child: Text('refresh'.tr),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => controller.updateOrders(),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: controller.activeOrders.length,
          itemBuilder: (context, index) {
            final order = controller.activeOrders[index];
            return OrderCard(
              order: order,
              className: order.className ?? '',
              imageUrl: order.image?.trim() ?? '',
              status: statusConverter(order.status ?? 0),
              eventDate: DateTime.parse(
                      order.eventDate ?? DateTime.now().toIso8601String())
                  .toLocal(),
              price: order.price ?? 0,
              paymentStatus:
                  (order.paymentStatus ?? false) ? 'Paid' : 'Not Paid',
              totalFoods: order.totalFoods ?? 0,
              onTap: () {
                Get.toNamed(
                  Routes.orderDetailRoute,
                  arguments: {'order': order},
                );
              },
            );
          },
        ),
      );
    });
  }
}

class PastOrders extends StatelessWidget {
  const PastOrders({super.key, required this.controller});

  final UserOrdersController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      } else if (controller.pastOrders.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('no_orders_found'.tr),
              ElevatedButton(
                onPressed: controller.updateOrders,
                child: Text('try_again'.tr),
              ),
            ],
          ),
        );
      } else {
        return RefreshIndicator(
          onRefresh: () async => controller.updateOrders(),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: controller.pastOrders.length,
            itemBuilder: (context, index) {
              final order = controller.pastOrders[index];
              return OrderCard(
                order: order,
                className: order.className ?? '',
                imageUrl: order.image?.trim() ?? '',
                status: statusConverter(order.status ?? 0),
                eventDate: DateTime.parse(
                    order.eventDate ?? DateTime.now().toIso8601String()),
                price: order.price ?? 0,
                paymentStatus:
                    (order.paymentStatus ?? false) ? 'paid'.tr : 'not_paid'.tr,
                totalFoods: order.totalFoods ?? 0,
                onTap: () {
                  Get.toNamed(
                    Routes.orderDetailRoute,
                    arguments: {'order': order},
                  );
                },
              );
            },
          ),
        );
      }
    });
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.className,
    required this.imageUrl,
    required this.status,
    required this.eventDate,
    required this.price,
    required this.paymentStatus,
    required this.totalFoods,
    required this.onTap,
    required this.order,
  });

  final String className;
  final String imageUrl;
  final String status;
  final DateTime eventDate;
  final double price;
  final String paymentStatus;
  final int totalFoods;
  final VoidCallback onTap;
  final Order order;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 3.0, left: 10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 90,
                    height: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl.trim(),
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/na_logo.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          className,
                          style: const TextStyle(
                            fontFamily: 'PoppinsSB',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildBadge(context, status),
                            const SizedBox(width: 6.7),
                            _buildBadge(context, formatOrderDate(eventDate)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Row(
                        //   children: [
                        Text(
                          '${price.toStringAsFixed(2)} ETB, $totalFoods ${totalFoods == 1 ? 'food'.tr : "foods".tr}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(left: 8.0),
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       color: Theme.of(context).primaryColor,
                        //       borderRadius: BorderRadius.circular(5),
                        //     ),
                        //     child: Center(
                        //       child: Padding(
                        //         padding: const EdgeInsets.all(8.0),
                        //         child: Text(
                        //           '$totalFoods ${totalFoods == 1 ? 'Food' : "Foods"}',
                        //           style:
                        //               const TextStyle(color: Colors.white),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // )
                        //   ],
                        // ),
                        const SizedBox(height: 10),
                        if (paymentStatus == 'not_paid'.tr)
                          ElevatedButton(
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16)),
                              ),
                              isScrollControlled: true,
                              builder: (_) => FractionallySizedBox(
                                heightFactor:
                                    0.3, // 👈 limits modal to half screen height
                                child: PaymentModal(order: order),
                              ),
                            ),
                            child: const Text('Pay Now'),
                          )
                        else
                          Text(
                            paymentStatus,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  // const SizedBox(width: 8),
                  // Row(
                  //   children: [
                  //     Text('$totalFoods'),
                  //     Icon(
                  //       EneftyIcons.bag_2_bold,
                  //       color: Theme.of(context).primaryColor,
                  //     ),
                  //   ],
                  // ),
                ],
              ),
              const Divider(
                color: Colors.white54,
                thickness: 1,
                endIndent: 20,
                indent: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: text == 'rejected'.tr
                ? Colors.red
                : Theme.of(context).primaryColor,
            width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          text,
          style: TextStyle(
            color: text == 'rejected'.tr
                ? Colors.red
                : Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String formatOrderDate(DateTime eventDate) {
    final now = DateTime.now();
    final difference = now.difference(eventDate);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hr${difference.inHours > 1 ? 's' : ''} ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
    return DateFormat('yMd').format(eventDate);
  }
}
