import 'package:auto_size_text/auto_size_text.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/models/newmodels.dart';

import '../../../constants/assets.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../prefs/error_card.dart';
import '../../../prefs/error_data.dart';
import '../../../prefs/routes.dart';
import '../../../widgets/cart_item_card.dart';

class CartScreen extends StatelessWidget {
  final CartController controller = Get.find<CartController>(
      tag: Get.arguments == true
          ? CartController.donationTag
          : CartController.tag);
  // final HomeController homeController = Get.find<HomeController>(tag: 'home');
  CartScreen({super.key, this.fromBottomNav});
  final bool? fromBottomNav;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Change this to your desired color
      statusBarIconBrightness: Brightness.light, // For light icons
      statusBarBrightness: Brightness.dark, // For iOS status bar
    ));
    var maincolor = Theme.of(context).primaryColor;
    return PopScope(
      onPopInvokedWithResult: (c, s) {
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light));
      },
      child: Scaffold(
        appBar: fromBottomNav != true
            ? AppBar(
                backgroundColor: fromBottomNav != true
                    ? const Color(0xFF23981C)
                    : Theme.of(context).scaffoldBackgroundColor,
                // backgroundColor: ThemeModeController.isCurrentlyLight() == true
                //     ? Colors.white
                //     : Colors.black,
                elevation: fromBottomNav != true ? null : 0,
                leading: fromBottomNav != true
                    ? Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                                child: Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Color(0xFF23981C),
                                size: 16,
                              ),
                            )),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                title: fromBottomNav != true
                    ? Text(
                        'cart'.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.white),
                      )
                    : const SizedBox.shrink(),
                actions: [
                  if (fromBottomNav != true)
                    Obx(() => controller.listOfSelectedProductsInCart.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          ThemeModeController.isCurrentlyLight()
                                              ? Colors.grey
                                                  .withValues(alpha: 0.3)
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
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    child: AutoSizeText(
                                      'total_birr'.trParams({
                                        'total': controller.totalProductPrice
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
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                controller.removeProductsFromCart(
                                    controller.listOfSelectedProductsInCart,
                                    fromCartList: true);
                                controller.listOfSelectedProductsInCart.clear();
                              },
                              child: const Icon(
                                EneftyIcons.trash_bold,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ))
                ],
              )
            : null,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (fromBottomNav == true)
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 200,
                  child: Obx(() => controller
                          .listOfSelectedProductsInCart.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        ThemeModeController.isCurrentlyLight()
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  child: AutoSizeText(
                                    'total_birr'.trParams({
                                      'total': controller.totalProductPrice
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
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              controller.removeProductsFromCart(
                                  controller.listOfSelectedProductsInCart,
                                  fromCartList: true);
                              controller.listOfSelectedProductsInCart.clear();
                            },
                            child: const Icon(
                              EneftyIcons.trash_bold,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        )),
                ),
              ),
            Obx(() {
              // Group products by store
              Map<String, List<Food>> groupedCart =
                  controller.groupCartItemsByStore();

              return controller.cart.isEmpty
                  ? Align(
                      child: Center(
                        child: ErrorCard(
                          errorData: ErrorData(
                              title: 'no_orders'.tr,
                              body: '',
                              // 'Let\'s fill this cart up!',
                              image: Assets.emptyCart),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: groupedCart.keys.length,
                        itemBuilder: (context, storeIndex) {
                          String storeId =
                              groupedCart.keys.elementAt(storeIndex);
                          List<Food> storeProducts = groupedCart[storeId]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       vertical: 8.0, horizontal: 8),
                              //   child: Text(
                              //     '${controller.storeNameById(storeId)}', // Assuming you have a method to get store name
                              //     style: const TextStyle(
                              //       fontWeight: FontWeight.w600,
                              //       fontSize: 14,
                              //     ),
                              //   ),
                              // ),
                              Padding(
                                padding: const EdgeInsets.only(left: 0.0),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: storeProducts.length,
                                  itemBuilder: (context, productIndex) {
                                    var product = storeProducts[productIndex];
                                    // Logger().d(product.desc!);
                                    // var favorited =
                                    //     (product.favorited ?? false).obs;
                                    return Obx(() => GestureDetector(
                                          onTap: () {
                                            // Get.bottomSheet(
                                            //     ProductDetail(product: product));
                                          },
                                          child: Dismissible(
                                            key: UniqueKey(),
                                            onDismissed: (direction) {
                                              controller.removeProductFromCart(
                                                  product,
                                                  fromCartList: true);
                                            },
                                            background:
                                                Container(color: Colors.red),
                                            child: CartItemCard(
                                              // favorited: favorited.value,
                                              onHeartTap: () {
                                                // if (product.favorited!) {
                                                //   homeController
                                                //       .unfavoriteProduct(product);
                                                // } else {
                                                //   homeController
                                                //       .favoriteProduct(product);
                                                // }
                                              },
                                              image: product.image!,
                                              name:
                                                  '${controller.storeNameById(storeId) ?? ''}',
                                              description: product.desc!,
                                              price: controller
                                                  .calculateSpecificProductPrice(
                                                      product),
                                              onAdd: () => controller
                                                  .addProductAmount(product),
                                              // onDuplicate: () => controller
                                              //     .duplicateProductToCart(
                                              //         product),
                                              onRemove: () {
                                                if (product.amount == 1) {
                                                  controller
                                                      .removeProductFromCart(
                                                          product,
                                                          fromCartList: true);
                                                } else {
                                                  controller
                                                      .removeProductAmount(
                                                          product);
                                                }
                                              },
                                              amount: product.amount.toString(),
                                              onImageTap: () {
                                                controller
                                                    .toggleSelectionInCart(
                                                        product);
                                              },
                                              isSelected: controller
                                                  .listOfSelectedProductsInCart
                                                  .contains(product),
                                            ),
                                          ),
                                        ));
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
            }),
            Obx(() => controller.cart.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          // UserController.getWalletBalance();
                          Get.toNamed(Routes.checkoutRoute,
                              arguments: Get.arguments);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'pr_check'.trParams({
                            'pr':
                                controller.totalProductPrice.toStringAsFixed(2)
                          }),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
