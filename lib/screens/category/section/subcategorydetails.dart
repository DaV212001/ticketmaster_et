import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chapa_unofficial/chapa_unofficial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/functions/functions.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/user_tickets.dart';

import '../../../controllers/theme_controller.dart';
import '../../../provider/loginpersistence.dart';
import '../../review/sub_category/add_review_sub_cat_screen.dart';
import '../../signup.dart';

class FoodDetail extends StatefulWidget {
  const FoodDetail({
    super.key,
  });
  @override
  State<FoodDetail> createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light));
    return Scaffold(backgroundColor: Colors.white, body: TabBarAndTabViews());
  }
}

class TabPair {
  final Tab tab;
  final Widget view;
  TabPair({required this.tab, required this.view});
}

class TabBarController extends GetxController
    with SingleGetTickerProviderMixin {
  var isLoading = false.obs;
  var hasError = false.obs;
  var food = Food().obs;
  var foodPortions = <FoodPortions>[].obs;
  var coverImages = <CoverImage>[].obs;
  var mealTypes = <MealType>[].obs;
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    updateEvents();
  }

  Future<void> updateEvents() async {
    isLoading.value = true;
    try {
      var foodFromAPI = await getFoodbyID(
          Get.arguments['id'], ThemeModeController.languageCode.value);
      food.value = foodFromAPI;
      var coverImage = await getCoverImagesbySubCatID(
          Get.arguments['id'], ThemeModeController.languageCode.value);
      coverImages.assignAll(coverImage);
      var events = await getEventsBySubCategoryId(
          Get.arguments['id'], ThemeModeController.languageCode.value);
      foodPortions.assignAll(events);
      var mealTypesFromAPI = await getMealTypes();
      mealTypes.assignAll(mealTypesFromAPI);
      hasError.value = false;
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  var isPaying = false.obs;
  var mealType = '1'.obs;

  Future<void> payForPortion(
      BuildContext context, String location, int index) async {
    if (location.isEmpty) {
      Get.snackbar('error'.tr, 'please_enter_location'.tr);
      return;
    }
    if (mealType.value.isEmpty) {
      Get.snackbar('error'.tr, 'please_select_meal_type'.tr);
      return;
    }
    isPaying.value = true;
    try {
      final loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
      final accountProvider = Get.find<LoginDataProvider>(tag: 'login');
      String? phone =
          accountProvider.loginData?.phone?.replaceFirst("251", "0");
      String txRef = TxRefRandomGenerator.generate(prefix: 'ticketmaster');
      String storedTxRef = TxRefRandomGenerator.gettxRef;

      if (loginDataProvider.loginData != null ||
          await loginDataProvider.isUserRegistered == true) {
        await Chapa.getInstance.startPayment(
          context: context,
          onInAppPaymentSuccess: (successMsg) async {
            BookingResponse l;
            isPaying.value = true;
            l = await bookEvent(
              Booking(
                customerId: loginDataProvider.loginData?.id,
                foodId: foodPortions[index].foodId,
                foodPortionId: foodPortions[index].id,
                mealTypeId: mealType.value,
                location: location,
                date: DateTime.now().toIso8601String(),
              ),
            );
            isPaying.value = false;

            if (l.error == null) {
              Get.dialog(AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: Text("food_purchase_successful".tr),
                content:
                    Text("${foodPortions[0].price!} Birr ${"paid_enjoy".tr}"),
                actions: [
                  TextButton(
                    child: Text("ok".tr),
                    onPressed: () {
                      Get.back();
                      Get.back();
                    },
                  ),
                ],
              ));
              if (Get.isRegistered<UserOrdersController>()) {
                Get.find<UserOrdersController>().updateCategories();
              }
            } else {
              Get.snackbar("error".tr, "error_ordering_food".tr);
            }
          },
          amount: '${foodPortions[0].price!}',
          currency: 'ETB',
          txRef: storedTxRef,
          firstName: accountProvider.loginData?.firstName ?? '',
          lastName: accountProvider.loginData?.lastName ?? '',
          phoneNumber: phone ?? '',
          onInAppPaymentError: (errorMsg) {
            Get.snackbar("payment_failure".tr, "try_again".tr);
          },
        );
      } else {
        Get.to(() => const SignupScreen());
      }
    } catch (e, s) {
      Logger().t(e, stackTrace: s);
      Get.snackbar("error".tr, "error_ordering_food".tr);
    } finally {
      isPaying.value = false;
    }
  }
}

class TabBarAndTabViews extends StatelessWidget {
  TabBarAndTabViews({super.key});

  final TabBarController controller = Get.put(TabBarController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.dispose();
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor:
              Color(0xFF23981C), // Change this to your desired color
          statusBarIconBrightness: Brightness.light, // For light icons
          statusBarBrightness: Brightness.dark, // For iOS status bar
        ));
        return true;
      },
      child: SafeArea(
        child: Column(
          children: [
            Obx(() => CoverImageCarousel(
                  coverimages: controller.coverImages,
                  deviceheight: MediaQuery.of(context).size.height,
                  devicewidth: MediaQuery.of(context).size.width,
                  isLoading: controller.isLoading.value,
                  subCategory: controller.food.value,
                )),
            Container(
              height: 45,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0)),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: TabBar(
                  controller: controller.tabController,
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: const Color(0xFF218A36)),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  tabs: [
                    Tab(text: 'portions'.tr),
                    Tab(text: 'desc'.tr),
                    Tab(text: 'review'.tr)
                  ],
                ),
              ),
            ),
            Expanded(
              child: Obx(() => TabBarView(
                    controller: controller.tabController,
                    children: [
                      controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : controller.foodPortions.isNotEmpty
                              ? ListView.builder(
                                  itemCount: controller.foodPortions.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        String location = '';
                                        String mealType = '1';
                                        Get.dialog(
                                          AlertDialog(
                                            backgroundColor: Colors.white,
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  onChanged: (val) {
                                                    location = val;
                                                  },
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'enter_location'.tr,
                                                    enabledBorder:
                                                        const OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .green,
                                                                    width: 2)),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .green,
                                                                    width: 2)),
                                                    border:
                                                        const OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .green,
                                                                    width: 2)),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 50,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .green,
                                                                  width: 2)),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child:
                                                                DropdownButton(
                                                              value: int.parse(
                                                                  controller
                                                                      .mealType
                                                                      .value),
                                                              isExpanded: true,
                                                              hint: Text(
                                                                  'meal_type'
                                                                      .tr),
                                                              items: controller
                                                                  .mealTypes
                                                                  .map((e) => DropdownMenuItem(
                                                                      value:
                                                                          e.id,
                                                                      child: Text(
                                                                          e.name ??
                                                                              '')))
                                                                  .toList(),
                                                              onChanged: (v) {
                                                                controller
                                                                        .mealType
                                                                        .value =
                                                                    v.toString();
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            actions: [
                                              Obx(() => ElevatedButton(
                                                    onPressed: controller
                                                            .isPaying.value
                                                        ? null
                                                        : () async {
                                                            await controller
                                                                .payForPortion(
                                                              context,
                                                              location,
                                                              index,
                                                            );
                                                          },
                                                    child: controller
                                                            .isPaying.value
                                                        ? const CircularProgressIndicator()
                                                        : Text(
                                                            '${'pay'.tr} ${controller.foodPortions[index].price}'),
                                                  )),
                                            ],
                                          ),
                                        );
                                      },
                                      child: PortionCard(
                                          foodPortion:
                                              controller.foodPortions[index]),
                                    );
                                  },
                                )
                              : Center(
                                  child: Text(controller.hasError.value
                                      ? 'error_fetching_data'.tr
                                      : 'no_portions_found'.tr)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                              controller.food.value.desc ??
                                  'no_description_found'.tr,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      FoodReview(food: controller.food.value)
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class PortionCard extends StatelessWidget {
  const PortionCard({
    super.key,
    required this.foodPortion,
  });

  final FoodPortions foodPortion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 100,
                width: 100,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CachedNetworkImage(
                    fadeOutDuration: const Duration(milliseconds: 300),
                    fadeOutCurve: Curves.easeOut,
                    fadeInDuration: const Duration(milliseconds: 700),
                    fadeInCurve: Curves.easeIn,
                    imageUrl: foodPortion.image!.trim(),
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Text(
                      foodPortion.name!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    )),
                    Center(
                        child: Text(
                            '${(foodPortion.price!).toStringAsFixed(2)} Birr')),
                  ],
                ),
              ),
            ],
          ),
          Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(5)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'order'.tr,
                  style: TextStyle(color: Colors.white),
                ),
              ))
        ],
      ),
    );
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
        ),
        itemBuilder: (BuildContext context, int index, pageViewIndex) {
          if (coverimages.isNotEmpty) {
            return SizedBox(
              height: deviceheight! * 0.3,
              width: devicewidth,
              child: CachedNetworkImage(
                fadeOutDuration: const Duration(milliseconds: 300),
                fadeOutCurve: Curves.easeOut,
                fadeInDuration: const Duration(milliseconds: 700),
                fadeInCurve: Curves.easeIn,
                imageUrl: coverimages[index].coverimage!.trim(),
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Image.asset(
              'assets/images/na_logo.jpg',
              fit: BoxFit.cover,
            );
          }
        },
        itemCount: coverimages.isEmpty ? 4 : coverimages.length,
      ),
      Container(
        height: deviceheight! * 0.3,
        width: devicewidth,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          colors: [Colors.black, Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              _isLoading ? '' : subCategory.name!,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: devicewidth! * 0.04),
            ),
          ),
        ),
      )
    ]);
  }
}
