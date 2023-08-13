import 'package:flutter/material.dart';
import 'package:ticketmaster_et/constants/theme.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const TicketMasterET());
}

class TicketMasterET extends StatelessWidget {
  const TicketMasterET({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: Styles.themeData(),
      home: const TicketMatserHomePage(title: 'Ticketmaster ET'),
    );
  }
}
