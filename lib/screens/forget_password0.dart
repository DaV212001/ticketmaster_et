import 'dart:convert';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticketmaster_et/screens/forget_password1.dart';

import '../functions/functions.dart';
import '../provider/settings_provider.dart';

class ForgetPassword0 extends StatefulWidget {
  const ForgetPassword0({super.key});

  @override
  State<ForgetPassword0> createState() => _ForgetPassword0State();
}

class _ForgetPassword0State extends State<ForgetPassword0> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final formKey = GlobalKey<FormState>(); //key for form

  bool correct = false;
  bool _isLoading = false;

  Future<http.Response> forgetPassword(String phone1, String otp) async {
    print("forgetPassword = ${phone1}  and  ${otp}");
    String phone = "251" + phone1;
    print("forgetPassword = ${phone1}  and  ${otp}");
    Map<String, dynamic> jsonData = {'phone': phone, 'otp': otp};

    String requestBody = jsonEncode(jsonData);
    var response;
    try {
      print("jsonData $jsonData");
      print("requestBody $requestBody");
      response = http.post(Uri.parse("${baseUrlFunc}send-otp"),
          body: requestBody,
          headers: {
            "Content-type": "application/json",
          });
    } catch (e) {
      print("Error in forgetPassword $e");
    }

    return response;
  }

  String generateRandomNumber() {
    var random = Random();
    int temporaryNumber = random.nextInt(90000) +
        10000; // Generate a random integer between 10000 and 99999
    print(temporaryNumber);
    String randomNumber = temporaryNumber.toString();

    return randomNumber;
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
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
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.transparent),
                  child: DropdownButton(
                      value: languageChange.languageCode,
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'am', child: Text('Amharic')),
                        DropdownMenuItem(
                            value: 'en-AU', child: Text('Afaan Oromo')),
                      ],
                      onChanged: (String? value) {
                        setState(() async {
                          languageChange.languageCode = value!;
                          List<String> codes =
                              languageChange.languageCode.split('-');
                          String langCode = codes[0];
                          String countryCode = codes.length > 1 ? codes[1] : '';

                          // Save langCode and countryCode in shared preferences
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString('langCode', langCode);
                          if (countryCode.isNotEmpty) {
                            await prefs.setString('countryCode', countryCode);
                          } else {
                            await prefs.remove('countryCode');
                          }

                          // Set locale for EasyLocalization
                          if (countryCode.isNotEmpty) {
                            EasyLocalization.of(context)!
                                .setLocale(Locale(langCode, countryCode));
                          } else {
                            EasyLocalization.of(context)!
                                .setLocale(Locale(langCode));
                          }
                        });
                      }),
                ),
              ),
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
                            tr("forgot_password"),
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
                            child: Text(
                              tr("phone"),
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            )),
                        const SizedBox(
                          height: 7,
                        ),
                        Row(
                          children: [
                            Text(
                              "+251",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                                flex: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: Colors.grey[200], // Background color
                                  ),
                                  child: TextFormField(
                                    controller: phoneController,
                                    key: const ValueKey("phone"),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return tr('phone_empty');
                                      } else if (value.length > 9 ||
                                          value.length < 9) {
                                        return tr("phone_number_invalid");
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      hintText: "9xxx66565",
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(16.0),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        const SizedBox(
                          height: 10,
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
                                  if (phoneController.text.length == 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Please enter your phone number"),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  } else if (phoneController.text.length > 9 ||
                                      phoneController.text.length < 9) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Invalid amount"),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    print("pressed 1");
                                    String number = generateRandomNumber();
                                    print("${phoneController.text}" "$number");
                                    var response = await forgetPassword(
                                        phoneController.text, number);
                                    print("pressed 2");
                                    print(response.body);
                                    print(response.statusCode);
                                    var data = jsonDecode(response.body);

                                    // DO NOT CHANGE THE IF STATEMENT CONDITION BECAUSE OF THE TYPING ERROR
                                    //data['message'] == 'OTP sent succesfully'  'succesfully' IS
                                    // THE MESSAGE THAT WE GET FROM THE SERVER

                                    if (data['message'] ==
                                            'OTP sent succesfully' ||
                                        response.statusCode == 201) {
                                      final SharedPreferences shared =
                                          await SharedPreferences.getInstance();
                                      shared.setString('otp', number);
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ForgetPassword1(
                                                      phone: phoneController
                                                          .text)));
                                    } else if (data['message'] ==
                                        'phone number is not found') {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              tr('phone_number_is_not_found')),
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(tr('error')),
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Text(
                                  tr('submit'),
                                  style: TextStyle(fontSize: 20),
                                )),
                        const SizedBox(
                          height: 7,
                        ),
                      ],
                    ),
                  ),
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
