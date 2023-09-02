import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';
import 'package:ticketmaster_et/constants/theme.dart';
import 'package:ticketmaster_et/screens/category_tab.dart';
import 'package:ticketmaster_et/screens/home_tab.dart';
import 'package:ticketmaster_et/screens/profile_screen.dart';

class TicketMatserHomePage extends StatefulWidget {
  const TicketMatserHomePage({super.key, required this.title});

  final String title;

  @override
  State<TicketMatserHomePage> createState() => _TicketMatserHomePageState();
}

class _TicketMatserHomePageState extends State<TicketMatserHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: IndexedStack(
          index: selectedIndex,
          children: const [HomeTab(), CategoryTab(), ProfileWidget()],
        ),
        bottomNavigationBar: SlidingClippedNavBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          onButtonPressed: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          iconSize: 30,
          activeColor: Theme.of(context).primaryColor,
          selectedIndex: selectedIndex,
          barItems: [
            BarItem(
              icon: Icons.home,
              title: tr('home'),
            ),
            BarItem(
              icon: Icons.category,
              title: tr('category'),
            ),
            BarItem(
              icon: Icons.person,
              title: tr('profile'),
            ),
          ],
        ),
      ),
    );
  }
}
