// ignore_for_file: unused_element, no_leading_underscores_for_local_identifiers

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/controllers/cart_controller.dart';
import 'package:ticketmaster_et/prefs/routes.dart';
import 'package:ticketmaster_et/screens/home/section/home_screen_tab/home_tab_widget.dart';

import '../video_screen.dart';

class HomeTab extends StatefulWidget {
  // final ValueNotifier<int> selectedIndex;

  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  bool isImageZoomed = false;
  late TabController tabController;
  // late SettingsProvider languageChange;
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  void toggleImageZoom() {
    setState(() {
      isImageZoomed = !isImageZoomed;
    });
  }

  // List<Organizer> modifiedOrg = [];
  // late TabController tabController;
  // List<Event> events = [];
  //
  // int times = 50;
  // bool _isLoading = true;
  // @override
  // void initState() {
  //   print("HomeTab 1");
  //   super.initState();
  //   languageChange = Provider.of<SettingsProvider>(context, listen: false);
  //   print("HomeTab 2");
  //   languageChange.addListener(rebuild);
  //   print("HomeTab 3");
  //   // tabController = TabController(length: 2, vsync: this);
  //   print("HomeTab 4");
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     updateCategories();
  //   });
  // }
  //
  // void updateCategories() {
  //   print("updateCategories Called 1");
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   print("updateCategories Called 2");
  //   getOrganizers(
  //           Provider.of<SettingsProvider>(context, listen: false).languageCode)
  //       .then((value) => setState(() {
  //             print("updateCategories Called 3.1");
  //             modifiedOrg = value;
  //             //  print( 'VALUE OF THE EVENTS: $value');
  //             print("updateCategories Called 3.2");
  //           }));
  //   getEvents('$apiUrl/upcoming',
  //           Provider.of<SettingsProvider>(context, listen: false).languageCode)
  //       .then((value) => setState(() {
  //             print("updateCategories Called 3.1");
  //             events = value;
  //             //  print( 'VALUE OF THE EVENTS: $value');
  //             print("updateCategories Called 3.2");
  //           }));
  //   print("updateCategories Called 4");
  //   setState(() {
  //     _isLoading = false;
  //   });
  //   print("updateCategories Called 5");
  // }
  //
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final newLanguageChange = Provider.of<SettingsProvider>(context);
  //   if (languageChange != newLanguageChange) {
  //     languageChange.removeListener(rebuild);
  //     languageChange = newLanguageChange;
  //     languageChange.addListener(rebuild);
  //   }
  //   Provider.of<SettingsProvider>(context).addListener(updateCategories);
  // }
  //
  // @override
  // void dispose() {
  //   if (mounted) {
  //     languageChange.removeListener(rebuild);
  //     Provider.of<SettingsProvider>(context, listen: false)
  //         .removeListener(updateCategories);
  //     super.dispose();
  //   }
  // }

  // void rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Change this to your desired color
      statusBarIconBrightness: Brightness.light, // For light icons
      statusBarBrightness: Brightness.dark, // For iOS status bar
    ));
    // List<Event> modified = [];
    // for (int i = 0; i < times; i++) {
    //   modified.addAll(events);
    // }
    // final Controller controller = Controller()
    //   ..addListener((event) {
    //     _handleCallbackEvent(event.direction, event.success,
    //         currentIndex: event.pageNo);
    //   });

    // super.build(context);
    //   print(tabController.index);
    return
        // HomeTabWidget()
        Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              TabBarView(
                controller: tabController,
                children: [
                  HomeTabWidget(),
                  VideoPromotionScreen(),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .cardColor
                                    .withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TabBar(
                                  indicatorColor:
                                      Theme.of(context).primaryColor,
                                  // dividerColor: Colors.transparent,
                                  controller: tabController,
                                  tabs: [
                                    Tab(
                                      text: 'home'.tr,
                                    ),
                                    Tab(
                                      text: 'video'.tr,
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: CartIcon(),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // @override
  // bool get wantKeepAlive => true;

  // void _handleCallbackEvent(ScrollDirection direction, ScrollSuccess success,
  //     {int? currentIndex}) {
  //   toggleImageZoom();
  //   print(
  //       "Scroll callback received with data: {direction: $direction, success: $success and index: ${currentIndex ?? 'not given'}}");
  //   double scale = 1.0;
  //   double previousScale = 1.0;
  //
  //   void _onScaleStart(ScaleStartDetails details) {
  //     previousScale = scale;
  //     print('scale start');
  //     setState(() {});
  //   }
  //
  //   void _onScaleUpdate(ScaleUpdateDetails details) {
  //     scale = previousScale * details.scale;
  //     print('scale update');
  //     setState(() {});
  //   }
  //
  //   void _onScaleEnd(ScaleEndDetails details) {
  //     previousScale = 1.0;
  //     print('scale end');
  //     setState(() {});
  //   }
  // }
}

class CartIcon extends StatelessWidget {
  CartIcon({
    super.key,
    this.colored,
  });
  final cartController = Get.find<CartController>(tag: CartController.tag);
  final bool? colored;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.cartRoute);
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colored == true
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              alignment: AlignmentGeometry.center,
              clipBehavior: Clip.none,
              children: [
                Icon(
                  EneftyIcons.shopping_cart_outline,
                  color: colored == true
                      ? Colors.white
                      : Theme.of(context).primaryColor,
                ),
                Obx(() {
                  final count = cartController.numberOfItemsInCart.value;
                  if (count <= 0) return const SizedBox.shrink();
                  return Positioned(
                    right: -3,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        count.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
