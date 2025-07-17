import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/controllers/theme_controller.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/prefs/routes.dart';
import 'package:ticketmaster_et/screens/home/cart/cart_screen.dart';

import '../functions/functions.dart';
import '../provider/loginpersistence.dart';

class UserOrdersController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var orders = <Order>[].obs;
  var isLoading = true.obs;
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    updateCategories();
    ever(ThemeModeController.languageCode, (_) => updateCategories());
  }

  void updateCategories() async {
    isLoading.value = true;
    String? phone = Get.find<LoginDataProvider>(tag: 'login').loginData?.phone;
    if (phone != null) {
      orders.value =
          await getTickets(phone, ThemeModeController.languageCode.value);
      orders.sort(
          (a, b) => DateTime.parse(b.date!).compareTo(DateTime.parse(a.date!)));
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
        body: Column(
      children: [
        Container(
          color: const Color(0xFF23981C),
          child: TabBar(
              indicatorColor: Colors.white,
              controller: controller.tabController,
              tabs: [
                Tab(
                  text: 'active_orders'.tr,
                ),
                Tab(
                  text: 'past_orders'.tr,
                ),
              ]),
        ),
        Expanded(
          child: TabBarView(controller: controller.tabController, children: [
            CartScreen(
              fromBottomNav: true,
            ),
            PastOrders(controller: controller),
          ]),
        )
      ],
    ));
  }
}

class PastOrders extends StatelessWidget {
  const PastOrders({
    super.key,
    required this.controller,
  });

  final UserOrdersController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : controller.orders.isEmpty
            ? Center(
                child: Column(
                children: [
                  Text('no_orders_found'.tr),
                  ElevatedButton(
                      onPressed: () => controller.updateCategories(),
                      child: Text('try_again'.tr)),
                ],
              ))
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: controller.orders.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.orderDetailRoute,
                          arguments: {'order': controller.orders[index]});
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 3.0, left: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: SizedBox(
                                    width: 130,
                                    height: 130,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: CachedNetworkImage(
                                        imageUrl: controller.orders[index].image
                                                ?.trim() ??
                                            '',
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                                'assets/images/na_logo.jpg',
                                                fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.orders[index].className!,
                                        style: const TextStyle(
                                            fontFamily: 'PoppinsSB',
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      Text(controller.orders[index].status!),
                                      Row(
                                        children: <Widget>[
                                          const Icon(Icons.calendar_month),
                                          Text(
                                            formatOrderDate(DateTime.parse(
                                                    controller.orders[index]
                                                        .eventDate!))
                                                .toString(),
                                          ),
                                        ],
                                      ),
                                      Text(controller.orders[index].mealType ??
                                          ' '),
                                      Text(controller.orders[index]
                                                  .paymentStatus ==
                                              true
                                          ? 'paid'.tr
                                          : 'Not Paid'.tr),
                                    ],
                                  ),
                                )
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
                }));
  }

  String formatOrderDate(DateTime eventDate) {
    final now = DateTime.now();
    final difference = now.difference(eventDate);

    // If the difference is less than a minute
    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    // If the difference is less than an hour
    else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    }
    // If the difference is less than a day
    else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    }
    // If the difference is less than a week
    else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
    // Otherwise, format it as a specific date
    else {
      return DateFormat('yMMMd').format(eventDate);
    }
  }
}
