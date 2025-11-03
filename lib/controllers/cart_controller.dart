import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

import '../models/newmodels.dart';
import '../screens/home/section/home_screen_tab/home_screen_categories.dart';
import '../utils/calculator_helper.dart';
import '../widgets/animated_undo_button.dart';

class CartController extends GetxController {
  static String tag = 'cart';
  static String donationTag = 'donation_cart';
  var listOfSelectedProductsInCart = <Food>[].obs;
  var totalProductPrice = 0.00.obs;
  var cart = <Food>[].obs;
  var numberOfItemsInCart = 0.obs;
  RxMap<String, List<Food>> groupedItemsCache = RxMap<String, List<Food>>({});

  void updateProductAmount(Food item, int amount) {
    final cartItem = cart.firstWhere((c) => c.id == item.id);
    cartItem.amount = amount;
    cart.refresh();
  }

  Map<String, List<Food>> groupCartItemsByStore() {
    // if (groupItems.value) {
    Map<String, List<Food>> groupedCart = {};

    for (var product in cart) {
      // If the storeId key exists, append the product to that store's list
      if (groupedCart.containsKey(product.id.toString())) {
        groupedCart[product.id.toString()]!.add(product);
      } else {
        // Otherwise, create a new list for that store
        groupedCart[product.id!.toString()] = [product];
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
      Logger().i(savedCart.map((e) => Food.fromJson(e)).toList());
      cart.value = savedCart.map((e) => Food.fromJson(e)).toList();
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

  void addProductToCart(Food product) {
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

  void toggleSelectionInCart(Food product) {
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

  void removeProductAmount(Food product) {
    if (product.amount! > 0) {
      product.amount = product.amount! - 1;
    }
    cart.refresh();
    saveCartToStorage();
  }

  // Expose the helper methods via the same method names
  String calculateSpecificProductPrice(Food product) {
    return CalculationHelper.calculateSpecificProductPrice(product);
  }

  void addProductAmount(Food product) {
    product.amount = product.amount! + 1;
    cart.refresh();
    saveCartToStorage();
  }

  void removeProductFromCart(Food product,
      {bool fromCartList = false, fromBottomSheet = false}) {
    // Find the index of the product to be removed
    int removedProductIndex = cart.indexWhere((element) => element == product);
    // Remove the product from the cart
    if (removedProductIndex != -1) {
      // Ensure the product exists
      Food removedProduct = cart.removeAt(removedProductIndex);
      numberOfItemsInCart.value = cart.length;
      numberOfItemsInCart.refresh();
      cart.refresh();
      calculateTotalProductPrice();
      saveCartToStorage();
      if (fromCartList) {
        // Show SnackBar with Undo button and countdown
        Get.snackbar(
          'order_removed'.tr,
          'has_been_rem'.trParams({'name': '${product.name}'}),
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

  void removeProductsFromCart(List<Food> products,
      {bool fromCartList = false, fromBottomSheet = false}) {
    // Store removed products and their indices
    List<Map<String, dynamic>> removedProducts = [];

    for (Food product in products) {
      // Find the index of the product to be removed
      int removedProductIndex =
          cart.indexWhere((element) => element == product);

      // Remove the product from the cart and store it for undo action
      if (removedProductIndex != -1) {
        // Ensure the product exists and store the removed product with its index
        Food removedProduct = cart.removeAt(removedProductIndex);
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
              Food product = removedItem['product'];
              int index = removedItem['index'];
              cart.insert(index, product); // Reinsert at original position
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
