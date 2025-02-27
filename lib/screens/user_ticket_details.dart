import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/models/newmodels.dart';

class UserOrderDetails extends StatefulWidget {
  const UserOrderDetails({super.key});

  @override
  State<UserOrderDetails> createState() => _UserOrderDetailsState();
}

class _UserOrderDetailsState extends State<UserOrderDetails> {
  Order order = Get.arguments['order'];
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF23981C), // Change this to your desired color
      statusBarIconBrightness: Brightness.light, // For light icons
      statusBarBrightness: Brightness.dark, // For iOS status bar
    ));
    return Scaffold(
      body: Center(
          child: order != null
              ? ListView(scrollDirection: Axis.vertical, children: [
                  Container(
                    height: 200,
                    width: double.infinity * 0.9,
                    padding: const EdgeInsets.all(8.0),
                    child: order.image != null && order.image!.isNotEmpty
                        ? Image.network(order.image!)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: const Image(
                              image: AssetImage(
                                  'assets/images/THICKET_MASTER_LOGO.png'),
                              width: 170.0, // Set the desired width
                              height: 170.0, // Set the desired height
                            )),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 15.0, left: 12.0),
                      child: Text(
                        order.className ?? '',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      )),
                  Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                            child: ticketDetailsWidget('meal_type'.tr,
                                order.mealType!, 'portions'.tr, order.portion!),
                          ),
                          ticketDetailsWidget('date'.tr, order.date!,
                              'status'.tr, order.status!),
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 8.0),
                          //   child: ticketDetailsWidget(
                          //       'Phone number',
                          //       widget.ticket.phone!,
                          //       'Price',
                          //       widget.ticket.price!),
                          // )
                        ],
                      ))
                ])
              : Column(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: const Image(
                          image: AssetImage(
                              'assets/images/THICKET_MASTER_LOGO.png'),
                          width: 170.0, // Set the desired width
                          height: 170.0, // Set the desired height
                        )),
                    const CircularProgressIndicator()
                  ],
                )),
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
