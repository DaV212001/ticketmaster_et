import 'package:auto_size_text/auto_size_text.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ticketmaster_et/controllers/home_category_controller.dart';
import 'package:ticketmaster_et/models/delivery_address.dart';
import 'package:ticketmaster_et/widgets/location_choice.dart';
import 'package:ticketmaster_et/widgets/order_summary.dart';

import '../../../controllers/cart_controller.dart';
import '../../../controllers/checkout_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../models/newmodels.dart';

var gak =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55bmFtZSI6IkhlbGxvIE1lc2EiLCJkZXNjcmlwdGlvbiI6IjgxZjBkZjk5LTg1YmUtNDQ0ZC1hOGE1LWQ3YmI3NDk4OWU3OCIsImlkIjoiMzVmZjA5MWEtOWQ4ZC00OTdmLTlmMmEtMzVkNjNjZTRmZGI0IiwiaXNzdWVkX2F0IjoxNzY1MjE0NTQ1LCJpc3N1ZXIiOiJodHRwczovL21hcGFwaS5nZWJldGEuYXBwIiwiand0X2lkIjoiMCIsInNjb3BlcyI6WyJGRUFUVVJFX0FMTCJdLCJ1c2VybmFtZSI6Im5lYmlsaW1hbTgzQGdtYWlsLmNvbSJ9.uqJ5JIfXw6L7ZiuBg9wSyFbzF_qg6nsmhcYGeH9kMnY';

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({super.key});
  final CartController cartController = Get.find<CartController>(
      tag: Get.arguments == true
          ? CartController.donationTag
          : CartController.tag);
  final HomeCategoryController homeCategoryController =
      Get.find<HomeCategoryController>(tag: HomeCategoryController.tag);
  final CheckoutController controller =
      Get.put(CheckoutController(fromDonation: Get.arguments));

  @override
  Widget build(BuildContext context) {
    Map<String, List<Food>> groupedProducts =
        cartController.groupCartItemsByStore();
    var extraFoods = homeCategoryController.categories
        .firstWhere((cat) => cat.id == 20)
        .foods;
    return PopScope(
      onPopInvokedWithResult: (c, s) {
        if (controller.orderIdString.value.isNotEmpty) {
          cartController.cart.clear();
          cartController.numberOfItemsInCart.value = 0;
          cartController.numberOfItemsInCart.refresh();
          cartController.cart.refresh();
          GetStorage().erase();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF23981C),
          title: Text(
            'checkout'.tr,
            style: const TextStyle(color: Colors.white),
          ),
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          actions: [
            Obx(() => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: ThemeModeController.isCurrentlyLight()
                                ? Colors.grey.withValues(alpha: 0.3)
                                : Colors.black38,
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: AutoSizeText(
                            'total_birr'.trParams({
                              'total': cartController.totalProductPrice
                                  .toStringAsFixed(2)
                            }),
                            maxLines: 1,
                            minFontSize: 11,
                            maxFontSize: 16,
                            textAlign: TextAlign.center,
                            stepGranularity: 0.5,
                            overflow: TextOverflow.visible,
                            style: const TextStyle(
                                color: Color(0xFF23981C),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ),
                ))
          ],
        ),
        body: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                  child: Text(
                    'order_summary'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                FoodSummary(
                    groupedProducts: groupedProducts,
                    storeNameById: cartController.storeNameById,
                    calculateTotalQuantityOfProductsFromStore: cartController
                        .calculateTotalQuantityOfProductsFromSpecificStore),
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
                //   child: Text(
                //     'additional'.tr,
                //     style: const TextStyle(
                //       fontSize: 16,
                //       fontWeight: FontWeight.w600,
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 8.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GestureDetector(
                      //     onTap: () {
                      //       Get.dialog(
                      //         Dialog(
                      //           child: SizedBox(
                      //             height:
                      //                 MediaQuery.of(context).size.height * 0.5,
                      //             width: MediaQuery.of(context).size.width,
                      //             child: LocationPicker(
                      //                 apiKey: gak,
                      //                 onLocationPicked: (latlng) {
                      //                   Logger().i(latlng);
                      //                   Get.back();
                      //                   controller.location.value =
                      //                       '${latlng.latitude.toStringAsFixed(4)},${latlng.longitude.toStringAsFixed(4)}';
                      //                 }),
                      //           ),
                      //         ),
                      //       );
                      //     },
                      //     child: Container(
                      //       decoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(7),
                      //         border: Border.all(color: Colors.green, width: 2),
                      //       ),
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(15.0),
                      //         child: Row(
                      //           children: [
                      //             Obx(() => Text(controller.location.value == ''
                      //                 ? 'enter_location'.tr
                      //                 : controller.location.value))
                      //           ],
                      //         ),
                      //       ),
                      //     )
                      //     // TextField(
                      //     //   onChanged: (val) {
                      //     //     controller.location.value = val;
                      //     //   },
                      //     //   decoration: InputDecoration(
                      //     //     hintText: Get.arguments == true
                      //     //         ? 'desc'.tr
                      //     //         : 'enter_location'.tr,
                      //     //     enabledBorder: const OutlineInputBorder(
                      //     //         borderRadius:
                      //     //             BorderRadius.all(Radius.circular(8)),
                      //     //         borderSide:
                      //     //             BorderSide(color: Colors.green, width: 2)),
                      //     //     focusedBorder: const OutlineInputBorder(
                      //     //         borderRadius:
                      //     //             BorderRadius.all(Radius.circular(8)),
                      //     //         borderSide:
                      //     //             BorderSide(color: Colors.green, width: 2)),
                      //     //     border: const OutlineInputBorder(
                      //     //         borderRadius:
                      //     //             BorderRadius.all(Radius.circular(8)),
                      //     //         borderSide:
                      //     //             BorderSide(color: Colors.green, width: 2)),
                      //     //   ),
                      //     // ),
                      //     ),
                      // if (Get.arguments != true)
                      //   Text(
                      //     'delivery_address'.tr,
                      //     style: const TextStyle(fontWeight: FontWeight.bold),
                      //   ),
                      if (Get.arguments != true) const SizedBox(height: 6),
                      if (Get.arguments != true)
                        CurrentLocationSelector(onSelected: (address) {
                          controller.deliveryAddress.value =
                              address ?? DeliveryAddress();
                        }),
                      const SizedBox(
                        height: 5,
                      ),

                      TextField(
                        onChanged: (val) {
                          controller.location.value = val;
                        },
                        decoration: InputDecoration(
                          hintText: Get.arguments == true
                              ? 'desc'.tr
                              : 'enter_location'.tr,
                          enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              borderSide:
                                  BorderSide(color: Colors.green, width: 2)),
                          focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              borderSide:
                                  BorderSide(color: Colors.green, width: 2)),
                          border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              borderSide:
                                  BorderSide(color: Colors.green, width: 2)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        homeCategoryController.categories
                                .firstWhere((cat) => cat.id == 20)
                                .name ??
                            '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Obx(() => SizedBox(
                            height: cartController.cart.any(
                                    (cartItem) => cartItem.categoryId == 20)
                                ? 100
                                : 70,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: extraFoods?.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      var cartContainsTheExtra = cartController
                                          .cart
                                          .any((cartElement) =>
                                              cartElement.id ==
                                              extraFoods![index].id);
                                      if (cartContainsTheExtra) {
                                        cartController.removeProductFromCart(
                                            extraFoods![index]);
                                        return;
                                      }
                                      cartController
                                          .addProductToCart(extraFoods![index]);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Obx(() {
                                        var cartContainsTheExtra =
                                            cartController.cart.any(
                                                (cartElement) =>
                                                    cartElement.id ==
                                                    extraFoods![index].id);
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            border: Border.all(
                                                color: cartContainsTheExtra
                                                    ? Colors.green
                                                    : Colors.transparent,
                                                width: 2),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Column(
                                              children: [
                                                Row(children: [
                                                  CircleAvatar(
                                                    backgroundColor: Colors.green,
                                                    radius: 20,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            extraFoods![index]
                                                                    .image ??
                                                                ''),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                      extraFoods![index].name ??
                                                          ''),
                                                ]),
                                                if (cartContainsTheExtra)
                                                  Row(children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (extraFoods[index]
                                                                  .amount ==
                                                              1) {
                                                            cartController
                                                                .removeProductFromCart(
                                                                    extraFoods[
                                                                        index],
                                                                    fromCartList:
                                                                        true);
                                                          } else {
                                                            cartController
                                                                .removeProductAmount(
                                                                    extraFoods[
                                                                        index]);
                                                          }
                                                        },
                                                        child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: extraFoods[
                                                                              index]
                                                                          .amount
                                                                          .toString() !=
                                                                      '1'
                                                                  ? Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                  : Colors.red,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(3.0),
                                                              child: extraFoods[
                                                                              index]
                                                                          .amount
                                                                          .toString() !=
                                                                      '1'
                                                                  ? const Icon(
                                                                      Icons
                                                                          .remove,
                                                                      color: Colors
                                                                          .white,
                                                                    )
                                                                  : const Icon(
                                                                      EneftyIcons
                                                                          .trash_outline,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                            )),
                                                      ),
                                                    ),
                                                    Text(extraFoods[index]
                                                        .amount
                                                        .toString()),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: GestureDetector(
                                                        onTap: () =>
                                                            cartController
                                                                .addProductAmount(
                                                                    extraFoods[
                                                                        index]),
                                                        child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child:
                                                                const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(3.0),
                                                              child: Icon(
                                                                Icons.add,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            )),
                                                      ),
                                                    ),
                                                  ])
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  );
                                }),
                          )),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: SizedBox(
                      //         height: 50,
                      //         child: Obx(
                      //           () => ShimmerWrapper(
                      //             isEnabled: controller.isLoading.value,
                      //             child: Container(
                      //               decoration: BoxDecoration(
                      //                   borderRadius: const BorderRadius.all(
                      //                       Radius.circular(8)),
                      //                   border: Border.all(
                      //                       color: Colors.green, width: 2)),
                      //               child: Padding(
                      //                 padding: const EdgeInsets.all(8.0),
                      //                 child: Obx(() => DropdownButton(
                      //                       value: int.parse(
                      //                           controller.mealType.value),
                      //                       isExpanded: true,
                      //                       hint: Text('meal_type'.tr),
                      //                       borderRadius:
                      //                           const BorderRadius.all(
                      //                               Radius.circular(8)),
                      //                       items: controller.mealTypes
                      //                           .map((e) => DropdownMenuItem(
                      //                               value: e.id,
                      //                               child:
                      //                                   Text(e.name ?? '')))
                      //                           .toList(),
                      //                       onChanged: (v) {
                      //                         controller.mealType.value =
                      //                             v.toString();
                      //                       },
                      //                     )),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // )
                    ],
                  ),
                ),
                // if (Get.arguments != true)
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 8.0, left: 16.0, top: 16),
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
                // if (Get.arguments != true)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Row(
                    children: [
                      if (Get.arguments != true)
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                controller.onDelivery.value = true;
                                controller.walletPay.value = false;
                              },
                              child: Obx(
                                () => Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: controller.onDelivery.value
                                          ? Colors.green
                                          : Colors.grey,
                                      width:
                                          controller.onDelivery.value ? 3 : 1,
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
                                                  controller.onDelivery.value
                                                      ? 2
                                                      : 1,
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
                                            color: !controller
                                                        .onDelivery.value &&
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
                                            color: !controller
                                                        .onDelivery.value &&
                                                    !controller.walletPay.value
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          Text('pay_with_chapa'.tr)
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
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Obx(
                        () => ElevatedButton(
                            onPressed:
                                // controller.location.value.isEmpty ||
                                controller.mealType.value.isEmpty
                                    ? null
                                    : controller.isPaying.value
                                        ? () {}
                                        : () =>
                                            controller.payForPortion(context),
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: controller.isPaying.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(Get.arguments == true
                                    ? 'pay_and_order'.tr
                                    : 'place_order'.tr)),
                      )),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
