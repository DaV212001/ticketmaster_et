import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/models/newmodels.dart';

import '../functions/functions.dart';
import '../provider/settings_provider.dart';

class UserTicketDetails extends StatefulWidget {
  final Ticket ticket;

  UserTicketDetails({super.key, required this.ticket});

  @override
  State<UserTicketDetails> createState() => _UserTicketDetailsState();
}

class _UserTicketDetailsState extends State<UserTicketDetails> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: widget.ticket !=null ?ListView(
              scrollDirection: Axis.vertical,
              children: [
                Container(
                  height: 200,
                  width: double.infinity * 0.9,
                  padding: const EdgeInsets.all(8.0),
                  child: widget.ticket.eventImage !=null?  Image.network(
                      widget.ticket.eventImage!
                  ):ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image(
                        image: AssetImage('assets/images/THICKET_MASTER_LOGO.png'),
                        width: 170.0, // Set the desired width
                        height: 170.0, // Set the desired height
                      )

                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 15.0, left:12.0),
                    child: Text(
                      widget.ticket !=null ?
                      widget.ticket.eventName!: '',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    )
                ),

                Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(

                          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                          child: ticketDetailsWidget(
                              'Place', widget.ticket.eventPlace!, 'Date', widget.ticket.eventDate!),
                        ),
                        ticketDetailsWidget('Ticket', widget.ticket.eventTime!, 'Time', widget.ticket.ticket_number!),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ticketDetailsWidget('Phone number', widget.ticket.phone!, 'Price', widget.ticket.price!),
                        )
                      ],
                    )

                )]
          ): Column(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image(
                    image: AssetImage('assets/images/THICKET_MASTER_LOGO.png'),
                    width: 170.0, // Set the desired width
                    height: 170.0, // Set the desired height
                  )

              ),
              CircularProgressIndicator()
            ],
          )
      ),
    );
  }
  Widget ticketDetailsWidget(String firstTitle, String firstDesc,
      String secondTitle, String secondDesc) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  firstTitle,
                  style: const TextStyle(color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    firstDesc,
                    style: const TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  secondTitle,
                  style: const TextStyle(color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    secondDesc,
                    style: const TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          )
        ],
      );
  }
}
