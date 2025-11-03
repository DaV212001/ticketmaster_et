import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/models/newmodels.dart';

import '../controllers/cart_controller.dart';
import '../screens/home/section/home_screen_tab/home_screen_categories.dart';
import '../utils/cached_image_widget_wrapper.dart';
import 'food_portion_checkout_card.dart';

class FoodSummary extends StatelessWidget {
  FoodSummary({
    super.key,
    required this.groupedProducts,
    // required this.calculateStoreDeliveryFee,
    required this.storeNameById,
    required this.calculateTotalQuantityOfProductsFromStore,
  });

  final Map<String, List<Food>> groupedProducts;
  final String? Function(String storeId) storeNameById;
  // final String Function(String storeId) calculateStoreDeliveryFee;
  final int Function(String storeId) calculateTotalQuantityOfProductsFromStore;
  final CartController cartController = Get.find<CartController>(tag: 'cart');
  @override
  Widget build(BuildContext context) {
    var maincolor = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: ListView.builder(
        itemCount: groupedProducts.keys.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, storeIndex) {
          String storeId = groupedProducts.keys.elementAt(storeIndex);
          List<Category> categories =
              Get.find<HomeCategoryController>(tag: HomeCategoryController.tag)
                  .categories;
          Food store = Food();
          for (var category in categories) {
            if (category.foods != null) {
              for (var food in category.foods!) {
                if (food.id.toString() == storeId) {
                  store = food;
                  break;
                }
              }
            }
          }
          List<Food> storeProducts = groupedProducts[storeId]!;
          double storeTotalPrice = storeProducts.fold(
              0, (sum, product) => sum + num.parse(product.totalPrice()));
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                    side: BorderSide(color: maincolor)),
                collapsedBackgroundColor: maincolor.withValues(alpha: 0.2),
                collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7)),
                initiallyExpanded: false,
                childrenPadding:
                    const EdgeInsets.only(left: 16.0, bottom: 16.0),
                leading: cachedNetworkImageWrapper(
                  imageUrl: store.image!,
                  imageBuilder: (context, imageProvider) => Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: maincolor.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        store.image!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholderBuilder: (context, path) => Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: const SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  errorWidgetBuilder: (context, path, object) => Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: maincolor,
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  (storeNameById(storeId) ?? "Unknown Store").trim(),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: maincolor),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "total_birr".trParams(
                          {'total': storeTotalPrice.toStringAsFixed(2)}),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                children: [
                  Divider(
                    color: maincolor,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: storeProducts.length,
                      itemBuilder: (context, index) {
                        Food product = storeProducts[index];
                        return ProductCheckOutCard(product: product);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
// cartController.orderType.value == OrderType.delivery ? ((storeTotalPrice + double.parse(calculateStoreDeliveryFee(storeId))).toStringAsFixed(2))
// :
// if (cartController.orderType.value == OrderType.delivery)
//                   //   Padding(
//                   //     padding: const EdgeInsets.only(left: 8.0),
//                   //     child: Text(
//                   //         'Delivery fee for this store: ${store.deliveryFee} Birr'),
//                   //   ),
//                   // if (cartController.orderType.value == OrderType.delivery)
//                   //   Padding(
//                   //     padding: const EdgeInsets.only(left: 8.0),
//                   //     child: Row(
//                   //       children: [
//                   //         Text(
//                   //             'Delivery charge: ${calculateStoreDeliveryFee(storeId)} Birr'),
//                   //         Padding(
//                   //           padding: const EdgeInsets.only(left: 4.0),
//                   //           child: GestureDetector(
//                   //             onTap: () {
//                   //               showDialog(
//                   //                 context: context,
//                   //                 builder: (BuildContext context) {
//                   //                   var numberOfProductsFromStoreInCart =
//                   //                       calculateTotalQuantityOfProductsFromStore(
//                   //                           storeId);
//                   //                   var numberOfBatches =
//                   //                       (numberOfProductsFromStoreInCart / 3)
//                   //                           .ceil();
//                   //                   return AlertDialog(
//                   //                     title:
//                   //                         const Text("Delivery Charge Info"),
//                   //                     content: Text(
//                   //                       "The delivery fee is charged for every batch of 3 products in your cart. In this case, ${store.deliveryFee} Birr per batch from this store. You have a total of $numberOfProductsFromStoreInCart ${numberOfProductsFromStoreInCart > 1 ? 'products' : 'product'} from ${store.name} in your cart, which amounts to $numberOfBatches ${numberOfBatches > 1 ? 'batches' : 'batch'}, and thus you are charged with ${calculateStoreDeliveryFee(storeId)} Birr ",
//                   //                     ),
//                   //                     actions: [
//                   //                       TextButton(
//                   //                         child: const Text("OK"),
//                   //                         onPressed: () {
//                   //                           Navigator.of(context).pop();
//                   //                         },
//                   //                       ),
//                   //                     ],
//                   //                   );
//                   //                 },
//                   //               );
//                   //             },
//                   //             child: Icon(
//                   //               Icons.info_outline,
//                   //               color: maincolor,
//                   //             ),
//                   //           ),
//                   //         ),
//                   //       ],
//                   //     ),
//                   //   ),
