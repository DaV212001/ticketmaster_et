import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';
import 'package:ticketmaster_et/main.dart';
import 'package:ticketmaster_et/screens/category/category_tab.dart';
import 'package:ticketmaster_et/screens/home/home_tab.dart';
import 'package:ticketmaster_et/screens/profile_screen.dart';
import 'package:ticketmaster_et/screens/user_tickets.dart';

class TicketMatserHomePage extends StatefulWidget {
  const TicketMatserHomePage({super.key, required this.title});

  final String title;

  @override
  State<TicketMatserHomePage> createState() => _TicketMatserHomePageState();
}

class _TicketMatserHomePageState extends State<TicketMatserHomePage> {
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  @override
  void initState() {
    print("TicketMatserHomePage");
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
    return SafeArea(
      child: DeepLinkHandler(
        child: Scaffold(
          body: IndexedStack(
            index: selectedIndex.value,
            children: [
              HomeTab(selectedIndex: selectedIndex),
              CategoryTab(
                selectedIndex: selectedIndex,
              ),
              UserTickets(),
              ProfileWidget()
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
                border: BorderDirectional(
                    top: BorderSide(
                        color: Theme.of(context).colorScheme.onBackground))),
            child: SlidingClippedNavBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              onButtonPressed: (index) {
                setState(() {
                  selectedIndex.value = index;
                });
              },
              iconSize: 30,
              activeColor: Theme.of(context).primaryColor,
              selectedIndex: selectedIndex.value,
              barItems: [
                BarItem(
                  icon: Icons.home,
                  title: 'home'.tr,
                ),
                BarItem(
                  icon: Icons.category,
                  title: 'category'.tr,
                ),
                BarItem(title: 'mytickets'.tr, icon: Icons.no_food_rounded),
                BarItem(
                  icon: Icons.person,
                  title: 'profile'.tr,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
