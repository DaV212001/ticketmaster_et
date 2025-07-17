import 'package:auto_size_text/auto_size_text.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/home/section/home_screen_tab/home_screen_categories.dart';

import '../../../constants/assets.dart';
import '../../../controllers/theme_controller.dart';
import '../../../prefs/error_card.dart';
import '../../../prefs/error_data.dart';
import '../../../prefs/routes.dart';
import '../../../utils/calculator_helper.dart';
import '../../../widgets/animated_undo_button.dart';
import '../../../widgets/cart_item_card.dart';

class CartController extends GetxController {
  static String tag = 'cart';
  var listOfSelectedProductsInCart = <FoodPortions>[].obs;
  var totalProductPrice = 0.00.obs;
  var cart = <FoodPortions>[].obs;
  var numberOfItemsInCart = 0.obs;
  RxMap<String, List<FoodPortions>> groupedItemsCache =
      RxMap<String, List<FoodPortions>>({});
  Map<String, List<FoodPortions>> groupCartItemsByStore() {
    // if (groupItems.value) {
    Map<String, List<FoodPortions>> groupedCart = {};

    for (var product in cart) {
      // If the storeId key exists, append the product to that store's list
      if (groupedCart.containsKey(product.foodId.toString())) {
        groupedCart[product.foodId.toString()]!.add(product);
      } else {
        // Otherwise, create a new list for that store
        groupedCart[product.foodId!.toString()] = [product];
      }
    }
    groupedItemsCache.value = groupedCart;
    // Logger().d(groupedCart);
    return groupedCart;
    // } else {
    //   return groupedItemsCache;
    // }
  }

  int calculateTotalQuantityOfProductsFromSpecificStore(String storeId) {
    return CalculationHelper.calculateTotalQuantityOfProductsFromSpecificStore(
        storeId, cart);
  }

  void saveCartToStorage() {
    final box = GetStorage();
    // final savedCart = box.read<List>('cart') ?? [];
    // savedCart.addAll();
    box.write('cart', cart.map((item) => item.toJson()).toList());
    box.write('cart_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  void loadCartFromStorage() {
    final box = GetStorage();

    // Logger().i(box.read('cart') ?? 'no cart');
    final savedCart = box.read<List>('cart') ?? [];
    final timestamp = box.read<int>('cart_timestamp') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (currentTime - timestamp > 86400000) {
      // 24 hours in milliseconds
      box.remove('cart');
      box.remove('cart_timestamp');
      cart.clear();
    } else {
      Logger().i(savedCart.map((e) => FoodPortions.fromJson(e)).toList());
      cart.value = savedCart.map((e) => FoodPortions.fromJson(e)).toList();
      numberOfItemsInCart.value = cart.length;
      numberOfItemsInCart.refresh();
    }
  }

  @override
  void onInit() {
    loadCartFromStorage();
    calculateTotalProductPrice();
    ever(cart, (_) {
      calculateTotalProductPrice();
    });
    super.onInit();
  }

  void addProductToCart(FoodPortions product) {
    // if (!canAddProductToCart(product)) return;
    if (cart.contains(product)) {
      product.amount = product.amount! + 1;
      cart.refresh();
      calculateTotalProductPrice();
      saveCartToStorage();
      return;
    }
    cart.add(product);
    numberOfItemsInCart.value = cart.length;
    numberOfItemsInCart.refresh();
    cart.refresh();
    calculateTotalProductPrice();
    saveCartToStorage();
  }

  void toggleSelectionInCart(FoodPortions product) {
    if (listOfSelectedProductsInCart.contains(product)) {
      listOfSelectedProductsInCart.remove(product);
      product.isSelected = false;
    } else {
      listOfSelectedProductsInCart.add(product);
      product.isSelected = true;
    }
    listOfSelectedProductsInCart.refresh();
    // if (Get.isRegistered<HomeController>(tag: 'home')) {
    //   Get.find<HomeController>(tag: 'home').filteredProductList.refresh();
    // }
  }

  void removeProductAmount(FoodPortions product) {
    if (product.amount! > 0) {
      product.amount = product.amount! - 1;
    }
    cart.refresh();
    saveCartToStorage();
  }

  // Expose the helper methods via the same method names
  String calculateSpecificProductPrice(FoodPortions product) {
    return CalculationHelper.calculateSpecificProductPrice(product);
  }

  void addProductAmount(FoodPortions product) {
    product.amount = product.amount! + 1;
    cart.refresh();
    saveCartToStorage();
  }

  void removeProductFromCart(FoodPortions product,
      {bool fromCartList = false, fromBottomSheet = false}) {
    // Find the index of the product to be removed
    int removedProductIndex = cart.indexWhere((element) => element == product);
    // Remove the product from the cart
    if (removedProductIndex != -1) {
      // Ensure the product exists
      FoodPortions removedProduct = cart.removeAt(removedProductIndex);
      numberOfItemsInCart.value = cart.length;
      numberOfItemsInCart.refresh();
      cart.refresh();
      calculateTotalProductPrice();
      saveCartToStorage();
      if (fromCartList) {
        // Show SnackBar with Undo button and countdown
        Get.snackbar(
          'order_removed'.tr,
          'has_been_rem'.trParams({
            'name':
                '${storeNameById(product.foodId.toString())}- ${product.name}'
          }),
          duration: const Duration(seconds: 5), // Duration for Snackbar,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          mainButton: AnimatedUndoButton(
              width: 80,
              height: 50,
              buttonText: 'undo'.tr,
              progressColor: Colors.white,
              buttonColor: const Color(0xFF218A36),
              onPressed: () {
                // Reinsert the product at the same index if Undo is pressed
                cart.insert(removedProductIndex, removedProduct);
                numberOfItemsInCart.value = cart.length;
                numberOfItemsInCart.refresh();
                cart.refresh();
                calculateTotalProductPrice();
                saveCartToStorage();
                Get.back();
              },
              child: Text('undo'.tr)),
          snackPosition: SnackPosition.TOP,
          borderRadius: 8,
          margin: const EdgeInsets.all(10),
        );
      }
    }
  }

  void removeProductsFromCart(List<FoodPortions> products,
      {bool fromCartList = false, fromBottomSheet = false}) {
    // Store removed products and their indices
    List<Map<String, dynamic>> removedProducts = [];

    for (FoodPortions product in products) {
      // Find the index of the product to be removed
      int removedProductIndex =
          cart.indexWhere((element) => element == product);

      // Remove the product from the cart and store it for undo action
      if (removedProductIndex != -1) {
        // Ensure the product exists and store the removed product with its index
        FoodPortions removedProduct = cart.removeAt(removedProductIndex);
        removedProducts.add({
          'product': removedProduct,
          'index': removedProductIndex,
        });
      }
    }

    // Update the cart state and product count after removal
    numberOfItemsInCart.value = cart.length;
    numberOfItemsInCart.refresh();
    cart.refresh();
    calculateTotalProductPrice();
    saveCartToStorage();

    // If fromCartList is true, show SnackBar with Undo button for bulk removal
    if (fromCartList && removedProducts.isNotEmpty) {
      // Display SnackBar with Undo option
      Get.snackbar(
        'order_removed'.tr,
        'have_been_rem'.trParams({'number': '${removedProducts.length}'}),
        duration: const Duration(seconds: 5), // Duration for Snackbar
        backgroundColor: Colors.green,
        colorText: Colors.white,
        mainButton: AnimatedUndoButton(
          width: 80,
          height: 50,
          buttonText: 'undo'.tr,
          progressColor: Colors.white,
          buttonColor: const Color(0xFF218A36),
          onPressed: () {
            // Reinsert the removed products at their original indices if Undo is pressed
            for (var removedItem in removedProducts) {
              FoodPortions product = removedItem['product'];
              int index = removedItem['index'];
              cart.add(product); // Reinsert at original position
            }
            numberOfItemsInCart.value = cart.length;
            numberOfItemsInCart.refresh();
            cart.refresh();
            calculateTotalProductPrice();
            saveCartToStorage();
            Get.back(); // Close the Snackbar
          },
          child: Text('undo'.tr),
        ),
        snackPosition: SnackPosition.TOP,
        borderRadius: 8,
        margin: const EdgeInsets.all(10),
      );
    }
  }

  String? storeNameById(String storeId) {
    String? storeName = '';
    if (Get.isRegistered<HomeCategoryController>(
        tag: HomeCategoryController.tag)) {
      List<Category> categories =
          Get.find<HomeCategoryController>(tag: HomeCategoryController.tag)
              .categories;
      for (var category in categories) {
        for (Food food in (category.foods ?? [])) {
          if (food.id.toString() == storeId) {
            storeName = food.name;
          }
        }
      }
    }
    return storeName;
  }

  void calculateTotalProductPrice() {
    totalProductPrice.value =
        CalculationHelper.calculateTotalProductPrice(cart);
    totalProductPrice.refresh();
  }
}

class CartScreen extends StatelessWidget {
  final CartController controller =
      Get.find<CartController>(tag: CartController.tag);
  // final HomeController homeController = Get.find<HomeController>(tag: 'home');
  CartScreen({super.key, this.fromBottomNav});
  final bool? fromBottomNav;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF23981C), // Change this to your desired color
      statusBarIconBrightness: Brightness.light, // For light icons
      statusBarBrightness: Brightness.dark, // For iOS status bar
    ));
    var maincolor = Theme.of(context).primaryColor;
    return PopScope(
      onPopInvokedWithResult: (c, s) {
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light));
      },
      child: Scaffold(
        appBar: AppBar(
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
            Obx(() => controller.listOfSelectedProductsInCart.isEmpty
                ? Padding(
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
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() {
              // Group products by store
              Map<String, List<FoodPortions>> groupedCart =
                  controller.groupCartItemsByStore();

              return controller.cart.isEmpty
                  ? Center(
                      child: ErrorCard(
                        errorData: ErrorData(
                            title: 'no_orders'.tr,
                            body: '',
                            // 'Let\'s fill this cart up!',
                            image: Assets.emptyCart),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: groupedCart.keys.length,
                        itemBuilder: (context, storeIndex) {
                          String storeId =
                              groupedCart.keys.elementAt(storeIndex);
                          List<FoodPortions> storeProducts =
                              groupedCart[storeId]!;

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
                                                  '${controller.storeNameById(storeId) ?? ''}- ${product.name!}',
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
                          Get.toNamed(Routes.checkoutRoute);
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
