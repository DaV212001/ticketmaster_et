import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';
import 'package:ticketmaster_et/screens/category/category_tab.dart';
import 'package:ticketmaster_et/screens/home/home_tab.dart';
import 'package:ticketmaster_et/screens/profile_screen.dart';
import 'package:ticketmaster_et/screens/signup.dart';
import 'package:ticketmaster_et/screens/user_tickets.dart';

import 'provider/loginpersistence.dart';

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

    return SafeArea(
      child: Scaffold(
        body:IndexedStack(
          index: selectedIndex.value,
          children:  [
            HomeTab(selectedIndex: selectedIndex),
             CategoryTab(selectedIndex: selectedIndex,),
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
                title: tr('home'),
              ),
              BarItem(
                icon: Icons.category,
                title: tr('category'),
              ),
              BarItem(title: tr('mytickets'), icon: Icons.airplane_ticket),
              BarItem(
                icon: Icons.person,
                title: tr('profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
