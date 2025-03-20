import 'package:badges/badges.dart' as badges;
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';
import 'package:ticketmaster_et/main.dart';
import 'package:ticketmaster_et/screens/category/category_tab.dart';
import 'package:ticketmaster_et/screens/home/cart/cart_screen.dart';
import 'package:ticketmaster_et/screens/home/home_tab.dart';
import 'package:ticketmaster_et/screens/profile_screen.dart';
import 'package:ticketmaster_et/screens/user_tickets.dart';
import 'package:ticketmaster_et/utils/update_enforcer.dart';

class MainLayoutController extends GetxController {
  static String tag = "MainLayoutController";
  final selectedIndex = 0.obs;
}

class TicketMatserHomePage extends StatefulWidget {
  const TicketMatserHomePage({super.key, required this.title});

  final String title;

  @override
  State<TicketMatserHomePage> createState() => _TicketMatserHomePageState();
}

class _TicketMatserHomePageState extends State<TicketMatserHomePage> {
  MainLayoutController mainLayoutController =
      Get.put(MainLayoutController(), tag: MainLayoutController.tag);
  CartController cartController =
      Get.put(CartController(), tag: CartController.tag);
  // final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  @override
  void initState() {
    print("TicketMatserHomePage");
    UpdateChecker().checkForUpdates(fromStartUp: true);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF23981C), // Change this to your desired color
      statusBarIconBrightness: Brightness.light, // For light icons
      statusBarBrightness: Brightness.dark, // For iOS status bar
    ));
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = screenWidth / 4; // Since we have 4 items

    return SafeArea(
      child: DeepLinkHandler(
        child: Scaffold(
          body: Obx(
            () => IndexedStack(
              index: mainLayoutController.selectedIndex.value,
              children: [
                const HomeTab(),
                CategoryTab(),
                UserOrders(),
                ProfileWidget()
              ],
            ),
          ),
          bottomNavigationBar: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                    border: BorderDirectional(
                        top: BorderSide(
                            color:
                                Theme.of(context).colorScheme.onBackground))),
                child: Obx(() => SlidingClippedNavBar(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      onButtonPressed: (index) {
                        // setState(() {
                        mainLayoutController.selectedIndex.value = index;
                        // });
                      },
                      iconSize: 30,
                      activeColor: Theme.of(context).primaryColor,
                      selectedIndex: mainLayoutController.selectedIndex.value,
                      barItems: [
                        BarItem(
                          icon: Icons.home,
                          title: 'home'.tr,
                        ),
                        BarItem(
                          icon: Icons.category,
                          title: 'category'.tr,
                        ),
                        BarItem(
                            title: 'cart'.tr,
                            icon: EneftyIcons.shopping_cart_outline),
                        BarItem(
                          icon: Icons.person,
                          title: 'profile'.tr,
                        ),
                      ],
                    )),
              ),
              Obx(() => cartController.numberOfItemsInCart.value > 0
                  ? Positioned(
                      bottom: 35, // Adjust as needed to align with the icon
                      left: itemWidth * 2 +
                          (itemWidth / 2), // Center over 3rd item
                      child: badges.Badge(
                        badgeContent: Text(
                          cartController.numberOfItemsInCart.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                        badgeStyle: const badges.BadgeStyle(
                          badgeColor: Colors.red,
                        ),
                      ),
                    )
                  : const SizedBox.shrink())
            ],
          ),
        ),
      ),
    );
  }
}
