import 'dart:convert';

// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/prefs/language_selector.dart';

import '../functions/functions.dart';
import '../provider/settings_provider.dart';
import 'login.dart';

class ForgetPassword2 extends StatefulWidget {
  String phone;
  ForgetPassword2({super.key, required this.phone});

  @override
  State<ForgetPassword2> createState() => _ForgetPassword2State();
}

class _ForgetPassword2State extends State<ForgetPassword2> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>(); //key for form
  bool passwordToggle = true;
  bool _isLoading = false;

  Future submitPassword(String password) async {
    print("submitPassword = ${password}  and  ${widget.phone}");
    String password_confirmation = password;
    String phone = "251" + widget.phone;
    Map<String, dynamic> jsonData = {
      'phone': phone,
      'password': password,
      'password_confirmation': password_confirmation
    };

    String requestBody = jsonEncode(jsonData);
    var response;
    try {
      print("jsonData $jsonData");
      print("requestBody $requestBody");
      response = http.post(Uri.parse("${baseUrlFunc}change-password"),
          body: requestBody,
          headers: {
            "Content-type": "application/json",
          });
    } catch (e) {
      print("Error in forgetPassword $e");
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    final languageChange = Provider.of<SettingsProvider>(context);
    final ThemeData theme = Theme.of(context);
    return Container(
      color: Colors.grey[100],
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back),
            ),
            toolbarHeight: 27,
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: LanguageSelectorButton(onChange: () {})),
            ],
          ),
          body: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Center(
                    child: Image(
                      image:
                          AssetImage('assets/images/THICKET_MASTER_LOGO.png'),
                      width: 160.0, // Set the desired width
                      height: 160.0, // Set the desired height
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'password'.tr,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text('password'.tr,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18))),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.grey[200], // Background color
                          ),
                          child: TextFormField(
                            controller: passwordController,
                            key: const ValueKey("password"),
                            validator: (value) {
                              if (passwordController.text.isEmpty) {
                                return "password empty";
                              } else if (passwordController.text.length > 40 ||
                                  passwordController.text.length < 3) {
                                return "password too short or too long";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'password'.tr,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16.0),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text('confirm_pass'.tr,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18))),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.grey[200], // Background color
                          ),
                          child: TextFormField(
                            controller: confirmPasswordController,
                            key: const ValueKey("password_confirm"),
                            validator: (value) {
                              if (confirmPasswordController.text.isEmpty) {
                                return "password empty";
                              } else if (passwordController.text !=
                                  confirmPasswordController.text) {
                                return "passwords don't match";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'confirm_pass'.tr,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16.0),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        _isLoading
                            ? CircularProgressIndicator()
                            : OutlinedButton(
                                style: const ButtonStyle(
                                    backgroundColor:
                                        MaterialStatePropertyAll(Colors.green),
                                    foregroundColor:
                                        MaterialStatePropertyAll(Colors.white),
                                    minimumSize: MaterialStatePropertyAll(
                                        Size(double.infinity, 50))),
                                onPressed: () async {
                                  if (passwordController.text.length < 3) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Password should be greater than 3"),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  } else if (passwordController.text !=
                                      confirmPasswordController.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text("Confirm password please"),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  } else if (passwordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Please enter password"),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    var res = await submitPassword(
                                        passwordController.text);
                                    print("Returned");
                                    print(res.body);
                                    print(res);
                                    print("pressed");

                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginScreen()));
                                  }
                                },
                                child: Text(
                                  'submit'.tr,
                                  style: TextStyle(fontSize: 20),
                                )),
                      ],
                    ),
                  ),
                  //   Image(
                  //
                  //   image: AssetImage('assets/images/THICKET_MASTER_PATERN_05.png'),
                  //   width: MediaQuery.of(context).size.width,
                  //   fit: BoxFit.cover,// Set the desired width
                  //   height:  300// Set the desired height
                  // ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.all(0),
                    transformAlignment: Alignment.topCenter,
                    child: Image(
                        image: AssetImage(
                            'assets/images/THICKET_MASTER_PATERN_04.png'),
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill, // Set the desired width
                        height: MediaQuery.of(context)
                            .size
                            .height // Set the desired height
                        ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
