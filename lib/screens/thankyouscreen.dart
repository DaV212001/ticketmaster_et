// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ticketmaster_et/main_layout_screen.dart';

import '../models/newmodels.dart';

class ThankYouScreen extends StatefulWidget {
  final Event event;
  const ThankYouScreen({super.key, required this.event});

  @override
  State<ThankYouScreen> createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset('assets/images/THICKET_MASTER_LOGO.png'),
          ),
          Text(
            'Thank you for buying the ${widget.event.title} ticket! \n Enjoy The Event',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return TicketMatserHomePage();
                  }));
                },
                style: ButtonStyle(
                    minimumSize: MaterialStatePropertyAll(
                        Size(MediaQuery.of(context).size.width * 0.9, 50))),
                child: Text('Go Back Home')),
          )
        ],
      ),
    );
  }
}
