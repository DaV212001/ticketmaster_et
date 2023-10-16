import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Terms and Conditions', style: TextStyle(
            color:
            Colors.black,
            fontWeight:
            FontWeight.w700,
            fontSize:
            20),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Introduction', style :TextStyle(color :Colors.black, fontWeight :FontWeight.bold)),
              SizedBox(height :8.0),
              Text('These terms and conditions govern your use of our app; by using our app, you accept these terms and conditions in full. If you disagree with these terms and conditions or any part of these terms and conditions, you must not use our app.', style :TextStyle(color :Colors.black)),
              SizedBox(height :16.0),
              Text('Data Collection', style :TextStyle(color :Colors.black, fontWeight :FontWeight.bold)),
              SizedBox(height :8.0),
              Text('We collect information from you when you register on our app, submit an audition, or fill out a form. When registering on our app, as appropriate, you may be asked to enter your name, email address, phone number or other details to help you with your experience.\n\nWe also collect information about your use of our app, such as the pages you visit and the actions you take within the app. This information is used to improve our app and provide a better user experience.', style :TextStyle(color :Colors.black)),
              SizedBox(height :16.0),
              Text('Use of Data', style :TextStyle(color :Colors.black, fontWeight :FontWeight.bold)),
              SizedBox(height :8.0),
              Text('Any of the information we collect from you may be used in one of the following ways:\n\n- To personalize your experience\n- To improve our app\n- To improve customer service\n- To process transactions\n- To send periodic emails\n\nYour information, whether public or private, will not be sold, exchanged, transferred, or given to any other company for any reason whatsoever, without your consent, other than for the express purpose of delivering the purchased product or service requested.\n\nWe may also use your information to contact you about updates to our app or to provide you with information about products or services that may be of interest to you.', style :TextStyle(color :Colors.black)),
              SizedBox(height :16.0),
              Text('Data Protection', style :TextStyle(color :Colors.black, fontWeight :FontWeight.bold)),
              SizedBox(height :8.0),
              Text('We implement a variety of security measures to maintain the safety of your personal information when you enter, submit, or access your personal information.\n\nWe offer the use of a secure server. All supplied sensitive/credit information is transmitted via Secure Socket Layer (SSL) technology and then encrypted into our payment gateway providers database only to be accessible by those authorized with special access rights to such systems and are required to keep the information confidential.\n\nAfter a transaction, your private information (credit cards, social security numbers, financials, etc.) will not be stored on our servers.', style :TextStyle(color :Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}
