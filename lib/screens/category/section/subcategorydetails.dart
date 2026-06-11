import 'package:badges/badges.dart' as badge;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/functions/functions.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/review/sub_category/add_review_sub_cat_screen.dart';

import '../../../controllers/cart_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../controllers/time_controller.dart';
import '../../../prefs/routes.dart';

class FoodDetail extends StatefulWidget {
  const FoodDetail({super.key});

  @override
  State<FoodDetail> createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  final CartController cartController =
      Get.find<CartController>(tag: CartController.tag);
  final FoodDetailController controller = Get.put(FoodDetailController());

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: // ======== FLOATING TOTAL BAR ========
          Obx(() {
        if (cartController.cart
            .where((food) => food.id == controller.food.value.id)
            .toList()
            .isEmpty) {
          return const SizedBox.shrink(); // hide if empty
        }
        return _buildFloatingTotalBar(context);
      }),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return Center(child: Text('error_fetching_data'.tr));
        }

        final food = controller.food.value;
        final coverImages = controller.coverImages;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                  bottom: 120), // to avoid overlap with bottom bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ======== COVER IMAGES CAROUSEL ========
                  CoverImageCarousel(
                    coverimages: coverImages,
                    deviceheight: MediaQuery.of(context).size.height,
                    devicewidth: MediaQuery.of(context).size.width,
                    isLoading: controller.isLoading.value,
                    subCategory: food,
                  ),

                  const SizedBox(height: 20),
                  if (!Get.find<TimeController>(tag: TimeController.tag)
                      .closedHours
                      .value)
                    // ======== ORDER NOW BUTTON OR QUANTITY CONTROL ========
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Obx(() {
                        final inCart = cartController.cart
                            .any((foodItem) => foodItem.id == food.id);
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: inCart
                              ? _buildQuantityControl(food, context)
                              : _buildOrderNowButton(context, food),
                        );
                      }),
                    ),

                  const SizedBox(height: 20),
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                    child: Row(
                      children: [
                        Text('${controller.food.value.rating ?? 3.5}'),
                        RatingBarIndicator(
                          itemSize: 20,
                          // initialRating: 3,
                          // minRating: 1,
                          direction: Axis.horizontal,
                          rating:
                              (controller.food.value.rating ?? 3.5).toDouble(),
                          // allowHalfRating: true,
                          itemCount: 5,
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          // onRatingUpdate: (rating) {
                          //   print(rating);
                          //   setState(() {
                          //     ratingController = rating.round();
                          //   });
                          //   print("ratingController = $ratingController");
                          // },
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.dialog(
                              Dialog(
                                alignment: AlignmentGeometry.center,
                                insetPadding: const EdgeInsets.all(
                                    16), // Adds margin around dialog
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: FoodReview(food: food),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.add_circle_outline,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ======== DESCRIPTION ========
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      food.name ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      food.desc ?? 'no_description_found'.tr,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ======== REVIEWS ========
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  //   child: Text(
                  //     'review'.tr,
                  //     style: TextStyle(
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.bold,
                  //       color: Theme.of(context).colorScheme.primary,
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 8),
                  // FoodReview(food: food),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // ============================ WIDGETS ============================

  Widget _buildOrderNowButton(BuildContext context, Food food) {
    return ElevatedButton(
      onPressed:
          (Get.find<TimeController>(tag: TimeController.tag).closedHours.value)
              ? null
              : () {
                  cartController.addProductToCart(food);
                },
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: Colors.grey,
        backgroundColor: Theme.of(context).primaryColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        'order_now'.tr,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _buildQuantityControl(Food food, BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              if (food.amount! > 1) {
                cartController.removeProductAmount(food);
              } else {
                cartController.removeProductFromCart(food);
              }
            },
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
          ),
          Text(
            '${food.amount ?? 1}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => cartController.addProductAmount(food),
            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingTotalBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            const Color(0xFF44CC5F),
            Theme.of(context).primaryColor
          ]),
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
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Theme.of(context).cardColor),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Obx(() {
                    Food food = cartController.cart.firstWhere(
                        (food) => food.id == controller.food.value.id);

                    return badge.Badge(
                      showBadge: cartController.numberOfItemsInCart.value > 0,
                      badgeContent: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Text(
                          food.amount.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      child: const Icon(
                        EneftyIcons.shopping_cart_bold,
                        size: 35,
                      ),
                    );
                  })),
            ),
            Obx(() => Text(
                  'total_birr'.trParams({
                    'total': cartController.totalProductPrice.toStringAsFixed(2)
                  }),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                )),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Get.toNamed(Routes.cartRoute),
              child: Text(
                'buy_now'.tr,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FoodDetailController extends GetxController {
  var isLoading = false.obs;
  var hasError = false.obs;
  var food = Food().obs;
  var coverImages = <CoverImage>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final id = Get.arguments['id'];
      final lang = ThemeModeController.languageCode.value;

      final foodData = await getFoodbyID(id, lang);
      food.value = foodData;

      final cover = await getCoverImagesbySubCatID(id, lang);
      coverImages.assignAll(cover);

      hasError.value = false;
    } catch (e, s) {
      Logger().e('Error loading food detail', error: e, stackTrace: s);
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}

class CoverImageCarousel extends StatelessWidget {
  const CoverImageCarousel({
    super.key,
    required this.coverimages,
    required this.deviceheight,
    required this.devicewidth,
    required bool isLoading,
    required this.subCategory,
  }) : _isLoading = isLoading;

  final List<CoverImage> coverimages;
  final double? deviceheight;
  final double? devicewidth;
  final bool _isLoading;
  final Food subCategory;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      CarouselSlider.builder(
        options: CarouselOptions(
            disableCenter: true,
            viewportFraction: 1,
            enlargeCenterPage: false,
            autoPlay: true,
            height: deviceheight! * 0.3),
        itemBuilder: (BuildContext context, int index, pageViewIndex) {
          if (coverimages.isNotEmpty) {
            return SizedBox(
              height: deviceheight! * 0.3,
              width: devicewidth,
              child: CachedNetworkImage(
                imageUrl: coverimages[index].coverimage!.trim(),
                fit: BoxFit.cover,
                height: deviceheight! * 0.3,
                width: devicewidth,
                placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
                errorWidget: (context, url, error) =>
                    Image.asset('assets/images/na_logo.jpg', fit: BoxFit.cover),
              ),
            );
          } else {
            return Image.asset('assets/images/na_logo.jpg', fit: BoxFit.cover);
          }
        },
        itemCount: coverimages.isEmpty ? 1 : coverimages.length,
      ),
      Container(
        height: deviceheight! * 0.3,
        width: devicewidth,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black54, Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                _isLoading ? '' : subCategory.name ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: devicewidth! * 0.045,
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
