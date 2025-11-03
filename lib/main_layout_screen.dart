import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:ticketmaster_et/screens/category/category_tab.dart';
import 'package:ticketmaster_et/screens/donation/donation_screen.dart';
import 'package:ticketmaster_et/screens/home/home_tab.dart';
import 'package:ticketmaster_et/screens/order/user_orders.dart';
import 'package:ticketmaster_et/screens/profile_screen.dart';
import 'package:ticketmaster_et/utils/update_enforcer.dart';

import 'controllers/cart_controller.dart';

class MainLayoutController extends GetxController {
  static String tag = "MainLayoutController";
  late PersistentTabController bottomTabController;

  final cartController = Get.put(CartController(), tag: CartController.tag);

  @override
  void onInit() {
    super.onInit();
    bottomTabController = PersistentTabController(initialIndex: 0);
    UpdateChecker().checkForUpdates(fromStartUp: true);
  }

  /// Screens (same as before)
  List<Widget> get screens => [
        const HomeTab(),
        CategoryTab(),
        DonationScreen(),
        UserOrders(),
        ProfileWidget(),
      ];

  /// Helper to build the cart badge widget (used for both icon & inactiveIcon)
  Widget _cartWithBadge(BuildContext context, {required bool active}) {
    final theme = Theme.of(context);
    final baseIcon = Icon(
      active == false
          ? EneftyIcons.shopping_cart_outline
          : EneftyIcons.shopping_cart_bold,
      size: active ? 28 : 24,
      color: active
          ? theme.primaryColor
          : (theme.iconTheme.color?.withValues(alpha: 0.6) ?? Colors.grey),
    );

    return Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentGeometry.center,
      children: [
        baseIcon,
        Obx(() {
          final count = cartController.numberOfItemsInCart.value;
          if (count <= 0) return const SizedBox.shrink();
          return Positioned(
            right: -6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 8),
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Nav items defined in controller (as you requested)
  List<PersistentBottomNavBarItem> navItems(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.primaryColor;
    final inactiveColor =
        theme.iconTheme.color?.withValues(alpha: 0.5) ?? Colors.grey;

    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home, size: 28),
        inactiveIcon: const Icon(Icons.home_outlined, size: 24),
        title: 'home'.tr,
        textStyle: const TextStyle(fontSize: 10),
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inactiveColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.category, size: 28),
        inactiveIcon: const Icon(Icons.category_outlined, size: 24),
        title: 'category'.tr,
        textStyle: const TextStyle(fontSize: 10),
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inactiveColor,
      ),
      // Donation center button (circular green background)
      PersistentBottomNavBarItem(
        icon: Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF23991D),
              border: Border.all(color: Colors.white)),
          padding: const EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset(
              'assets/images/donation.png',
              height: 80,
              width: 80,
            ),
          ),
        ),
        inactiveIcon: Container(
          height: 68,
          width: 58,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF23981C),
          ),
          padding: const EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset(
              'assets/images/donation.png',
              height: 68,
              width: 68,
              fit: BoxFit.fill,
            ),
          ),
        ),
        // no title for center button
        title: ''.tr,
        textStyle: const TextStyle(fontSize: 10),
        activeColorPrimary: Colors.transparent,
        inactiveColorPrimary: Colors.transparent,
      ),
      // Cart / Orders with badge on both active & inactive
      PersistentBottomNavBarItem(
        // icon: _cartWithBadge(context, active: true),
        // inactiveIcon: _cartWithBadge(context, active: false),
        icon: const Icon(Icons.no_food_rounded),
        inactiveIcon: const Icon(Icons.no_food_outlined),
        title: 'mytickets'.tr,
        textStyle: const TextStyle(fontSize: 10),
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inactiveColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person, size: 28),
        inactiveIcon: const Icon(Icons.person_outline, size: 24),
        title: 'profile'.tr,
        textStyle: const TextStyle(fontSize: 10),
        activeColorPrimary: activeColor,
        inactiveColorPrimary: inactiveColor,
      ),
    ];
  }
}

class TicketMatserHomePage extends StatefulWidget {
  const TicketMatserHomePage({super.key});

  @override
  State<TicketMatserHomePage> createState() => _TicketMatserHomePageState();
}

class _TicketMatserHomePageState extends State<TicketMatserHomePage> {
  final mainLayoutController = Get.put(
    MainLayoutController(),
    tag: MainLayoutController.tag,
  );

  @override
  void initState() {
    super.initState();

    // Keep status bar behavior from your original implementation
    mainLayoutController.bottomTabController.addListener(() {
      final index = mainLayoutController.bottomTabController.index;

      if (index == 0) {
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ));
      } else {
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF23981C),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ));
      }
    });

    // initial status bar for index 0
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: PersistentTabView(
        context,
        controller: mainLayoutController.bottomTabController,
        screens: mainLayoutController.screens,
        items: mainLayoutController.navItems(context),
        backgroundColor: theme.scaffoldBackgroundColor,
        confineToSafeArea: true,
        decoration: NavBarDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          colorBehindNavBar: theme.scaffoldBackgroundColor,
        ),
        animationSettings: const NavBarAnimationSettings(
          navBarItemAnimation: ItemAnimationSettings(
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: ScreenTransitionAnimationSettings(
            animateTabTransition: true,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
            screenTransitionAnimationType: ScreenTransitionAnimationType.slide,
          ),
        ),
        navBarHeight: 70,
        navBarStyle: NavBarStyle.style15,
      ),
    );
  }
}
