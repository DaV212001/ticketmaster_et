import 'package:flutter/material.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';
import 'package:ticketmaster_et/constants/theme.dart';
import 'package:ticketmaster_et/screens/home_tab.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: const [HomeTab(), Text('datab'), Text('datac')],
      ),
      bottomNavigationBar: SlidingClippedNavBar(
        backgroundColor: Colors.white,
        onButtonPressed: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        iconSize: 30,
        activeColor: Styles.themeData().secondaryHeaderColor,
        selectedIndex: selectedIndex,
        barItems: [
          BarItem(
            icon: Icons.home,
            title: 'Home',
          ),
          BarItem(
            icon: Icons.category,
            title: 'Category',
          ),
          BarItem(
            icon: Icons.person,
            title: 'Profile',
          ),
        ],
      ),
    );
  }
}
