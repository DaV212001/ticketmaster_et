import 'package:flutter/material.dart';
import 'package:ticket_widget/ticket_widget.dart';
import 'package:ticketmaster_et/lib/main.dart'

class EventDetail extends StatelessWidget {
  const EventDetail({super.key});

  @override
  Widget build(BuildContext context) {
    ticketPrice = 300;
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 200,
                width: double.infinity * 0.9,
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                      fit: BoxFit.cover,
                      'https://www.akwaabamusic.com/wp-content/uploads/2018/09/WhatsApp-Image-2018-09-20-at-4.21.12-PM.jpeg'),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                    'Experience the eccentric concert of Rophnan at Millenium Hall!'),
              ),
              const TicketWidget(
                width: 350,
                height: 500,
                isCornerRounded: true,
                padding: EdgeInsets.all(20),
                child: TicketData(),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () {
                     await Chapa.getInstance.startPayment(
                    context: context,
                    onInAppPaymentSuccess: (successMsg) async {
                    
                      print('PAYMENT SUCCESS!');// Handle success events
                     
                      // Show the pop-up card
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: Text("Ticket Purchase Successful!"),
                            content: Text("$ticketPrice Paid! Enjoy the event!"),
                            actions: [
                              TextButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onInAppPaymentError: (errorMsg) {
                     
                      print('PAYMENT FAILURE');// Handle error
                    },
                    amount:ticketPrice,
                    currency: 'ETB',
                    txRef: storedTxRef,
                    firstName: 'Bamlak',
                    lastName: 'Aschalew',
                    phoneNumber: '0944070484',
                  );
                  },
                  child: const Text('PAY 300 BIRR'),
                  style: ButtonStyle(
                      minimumSize: MaterialStatePropertyAll(
                          Size(MediaQuery.of(context).size.width * 0.9, 50)))),
            ],
          ),
        ),
      ),
    );
  }
}

class TicketData extends StatelessWidget {
  const TicketData({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 120.0,
              height: 25.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                border: Border.all(width: 1.0, color: Colors.green),
              ),
              child: const Center(
                child: Text(
                  'Concert',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ),
            const Row(
              children: [
                Text(
                  'Addis Ababa, Ethiopia',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(
            'Rophnan Concert',
            style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                  child: ticketDetailsWidget(
                      'Attenders', 'Abebe Kebede', 'Date', '28-08-2022'),
                ),
                ticketDetailsWidget('Remaining tickets', '368', '', ''),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, right: 52.0),
                  child: ticketDetailsWidget('Ticket', '76836A45', '', ''),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, right: 53.0),
                  child: ticketDetailsWidget('Class', 'VVIP', '', ''),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
          child: Container(
            width: 250.0,
            height: 70.0,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        'https://www.computalabel.com/Images/ITFusAlt22x.png'),
                    fit: BoxFit.cover)),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10.0, left: 75.0, right: 75.0),
          child: Text(
            'Phone number',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
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
        padding: const EdgeInsets.only(right: 20.0),
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
