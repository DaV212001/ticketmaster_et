import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/controllers/theme_controller.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/prefs/routes.dart';

import '../functions/functions.dart';
import '../provider/loginpersistence.dart';

class UserOrdersController extends GetxController {
  var orders = <Order>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    updateCategories();
    ever(ThemeModeController.languageCode, (_) => updateCategories());
  }

  void updateCategories() async {
    isLoading.value = true;
    String? phone = Get.find<LoginDataProvider>(tag: 'login').loginData?.phone;
    if (phone != null) {
      orders.value =
          await getTickets(phone, ThemeModeController.languageCode.value);
    } else {
      Logger().i('No Phone');
    }
    isLoading.value = false;
  }
}

class UserTickets extends StatelessWidget {
  final UserOrdersController controller = Get.put(UserOrdersController());

  UserTickets({super.key});

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
                                              controller
                                                  .orders[index].eventDate!,
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins')),
                                        ],
                                      ),
                                      Text(controller.orders[index].mealType ??
                                          ' '),
                                      Text(controller
                                              .orders[index].ticket_number ??
                                          ' '),
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
}
