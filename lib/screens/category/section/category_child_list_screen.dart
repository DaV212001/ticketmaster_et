import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart' as badge;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/models/newmodels.dart';

import '../../../controllers/cart_controller.dart';
import '../../../prefs/routes.dart';

class CategoryChildList extends StatefulWidget {
  const CategoryChildList(
      {required this.subCategories, super.key, this.fromDonation});
  final List<Food> subCategories;
  final bool? fromDonation;

  @override
  State<CategoryChildList> createState() => _CategoryChildListState();
}

class _CategoryChildListState extends State<CategoryChildList> {
  CartController get cartController => Get.find(
      tag: widget.fromDonation == true
          ? CartController.donationTag
          : CartController.tag);

  @override
  Widget build(BuildContext context) {
    // final ScrollController scrollController = ScrollController();

    return Stack(
      children: [
        widget.subCategories.isNotEmpty
            ? ListView.builder(
                // controller: scrollController,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.subCategories.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  final subCategory = widget.subCategories[index];
                  return CategoryFoodCard(
                    fromDonation: widget.fromDonation ?? false,
                    className: subCategory.name ?? '',
                    cartController: cartController,
                    imageUrl: subCategory.image ?? '',
                    status: subCategory.discountPercentage == 0.0
                        ? ''
                        : '${subCategory.discountPercentage ?? '0'}%',
                    eventDate: subCategory.createdAt ?? DateTime.now(),
                    price: subCategory.price ?? 0.0,
                    paymentStatus: subCategory.desc ?? '',
                    rating: subCategory.rating ?? 0.0,
                    food: subCategory,
                    onTap: () {
                      Get.toNamed(Routes.foodDetailRoute,
                          arguments: {'id': subCategory.id!});
                    },
                  );
                },
              )
            : Center(
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.network(
                      'https://i.postimg.cc/4dyhqLLY/THICKET-MASTER-LOGO.png'),
                ),
              ),
        // ================= FLOATING TOTAL BAR =================
        Obx(() {
          if (cartController.cart.isEmpty) return const SizedBox.shrink();
          return Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: _buildFloatingTotalBar(context),
          );
        }),
      ],
    );
  }

  Widget _buildFloatingTotalBar(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [const Color(0xFF44CC5F), Theme.of(context).primaryColor]),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // CART ICON WITH BADGE
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: Theme.of(context).cardColor),
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(() {
                  final totalQuantity = cartController.cart
                      .fold<int>(0, (sum, item) => sum + (item.amount ?? 0));

                  return badge.Badge(
                    showBadge: totalQuantity > 0,
                    badgeContent: Text(
                      totalQuantity.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    child: const Icon(Icons.shopping_cart, size: 35),
                  );
                })),
          ),
          // TOTAL PRICE
          Expanded(
            child: Obx(() => AutoSizeText(
                  'total_birr'.trParams({
                    'total': cartController.totalProductPrice.toStringAsFixed(2)
                  }),
                  maxLines: 1,
                  minFontSize: 11,
                  maxFontSize: 16,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                )),
          ),
          // BUY NOW BUTTON
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () =>
                Get.toNamed(Routes.cartRoute, arguments: widget.fromDonation),
            child: Text(
              'buy_now'.tr,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}

class CategoryFoodCard extends StatefulWidget {
  const CategoryFoodCard({
    super.key,
    required this.className,
    required this.imageUrl,
    required this.status,
    required this.eventDate,
    required this.price,
    required this.paymentStatus,
    required this.rating,
    required this.onTap,
    required this.food,
    required this.cartController,
    required this.fromDonation, // Add the Food object
  });

  final String className;
  final String imageUrl;
  final String status;
  final DateTime eventDate;
  final double price;
  final String paymentStatus;
  final double rating;
  final VoidCallback onTap;
  final Food food;
  final bool fromDonation;

  final CartController cartController;

  @override
  State<CategoryFoodCard> createState() => _CategoryFoodCardState();
}

class _CategoryFoodCardState extends State<CategoryFoodCard> {
  final Map<int, TextEditingController> _controllers = {};

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
                        imageUrl: widget.imageUrl.trim(),
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
                          widget.className,
                          style: const TextStyle(
                            fontFamily: 'PoppinsSB',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.price.toStringAsFixed(2)} ${'etb'.tr}',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.paymentStatus,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ========== QUANTITY ADD FEATURE ==========
                  Column(
                    children: [
                      Row(
                        children: [
                          Text('${widget.rating}'),
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Obx(() {
                        final inCart = widget.cartController.cart
                            .any((item) => item.id == widget.food.id);
                        if (!inCart) {
                          return IconButton(
                            onPressed: () => widget.cartController
                                .addProductToCart(widget.food),
                            icon: const Icon(Icons.add_circle_outline,
                                color: Colors.green),
                          );
                        }

                        final cartItem = widget.cartController.cart
                            .firstWhere((item) => item.id == widget.food.id);
                        final controller = _controllers.putIfAbsent(
                          cartItem.id!,
                          () => TextEditingController(
                              text: '${cartItem.amount ?? 1}'),
                        );

                        // keep text in sync when value changes externally
                        if (controller.text != '${cartItem.amount ?? 1}') {
                          controller.text = '${cartItem.amount ?? 1}';
                          controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: controller.text.length),
                          );
                        }

                        return Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).scaffoldBackgroundColor,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (cartItem.amount! > 1) {
                                    widget.cartController
                                        .removeProductAmount(cartItem);
                                  } else {
                                    widget.cartController
                                        .removeProductFromCart(cartItem);
                                    _controllers.remove(cartItem.id); // cleanup
                                  }
                                },
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                              ),
                              if (widget.fromDonation == true)
                                SizedBox(
                                  width: 45,
                                  child: TextField(
                                    controller: controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    autofocus: false,
                                    onTap: () {
                                      controller.selection = TextSelection(
                                          baseOffset: 0,
                                          extentOffset: controller.text.length);
                                    },
                                    onSubmitted: (value) {
                                      final newAmount = int.tryParse(value) ??
                                          cartItem.amount ??
                                          1;
                                      if (newAmount > 0) {
                                        widget.cartController
                                            .updateProductAmount(
                                                cartItem, newAmount);
                                      } else {
                                        widget.cartController
                                            .removeProductFromCart(cartItem);
                                        _controllers
                                            .remove(cartItem.id); // cleanup
                                      }
                                    },
                                    onTapOutside: (_) =>
                                        FocusScope.of(context).unfocus(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  '${cartItem.amount ?? 1}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              IconButton(
                                onPressed: () => widget.cartController
                                    .addProductAmount(cartItem),
                                icon: const Icon(Icons.add_circle_outline,
                                    color: Colors.green),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
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
}
