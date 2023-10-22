import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticketmaster_et/screens/forget_password2.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main_layout_screen.dart';
import '../models/newmodels.dart';
import '../provider/settings_provider.dart';

class ForgetPassword1 extends StatefulWidget {
  String phone;
  ForgetPassword1({super.key, required this.phone});

  @override
  State<ForgetPassword1> createState() => _ForgetPassword1State();
}

class _ForgetPassword1State extends State<ForgetPassword1> {
  final otpController = TextEditingController();
  final formKey = GlobalKey<FormState>(); //key for form
  bool passwordToggle = true;
  bool _isLoading = false;
  int pressed = 3;

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
              onPressed: (){
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
                      color: Colors.transparent
                  ),
                  child:  DropdownButton(
                      value: languageChange.languageCode,
                      items: const [
                        DropdownMenuItem(
                            value: 'en', child: Text('English')),
                        DropdownMenuItem(
                            value: 'am', child: Text('Amharic')),
                        DropdownMenuItem(
                            value: 'en-AU', child: Text('Afaan Oromo')),

                      ],
                      onChanged: (String? value) {
                        setState(() async {
                          languageChange.languageCode = value!;
                          List<String> codes = languageChange.languageCode.split('-');
                          String langCode = codes[0];
                          String countryCode = codes.length > 1 ? codes[1] : '';

                          // Save langCode and countryCode in shared preferences
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString('langCode', langCode);
                          if (countryCode.isNotEmpty) {
                            await prefs.setString('countryCode', countryCode);
                          } else {
                            await prefs.remove('countryCode');
                          }

                          // Set locale for EasyLocalization
                          if (countryCode.isNotEmpty) {
                            EasyLocalization.of(context)!.setLocale(Locale(langCode, countryCode));
                          } else {
                            EasyLocalization.of(context)!.setLocale(Locale(langCode));
                          }
                        });
                      }
                  ),
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
                      image: AssetImage('assets/images/THICKET_MASTER_LOGO.png'),
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
                            tr('please_enter_the_5_digit_code_sent_to_your_phone_number'),
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(tr('code'), style: TextStyle(color: Colors.black, fontSize: 18))),
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
                            controller: otpController,
                            key: const ValueKey("code"),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "otp empty";
                              } else if (value.length == 5) {
                                return "OTP must be 5 digit";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: tr('xxxxx'),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16.0),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        _isLoading?
                        CircularProgressIndicator():
                        OutlinedButton(
                            style: const ButtonStyle(
                                backgroundColor:
                                MaterialStatePropertyAll(Colors.green),
                                foregroundColor:
                                MaterialStatePropertyAll(Colors.white),
                                minimumSize: MaterialStatePropertyAll(
                                    Size(double.infinity, 50))),
                            onPressed: () async {
                              setState(() {
                                pressed--;
                              });

                              print("pressed");
                              final SharedPreferences shared = await SharedPreferences.getInstance();
                              var otp = shared.getString(
                                  'otp');
                              print(otp);
                              if(otpController.text == otp){
                                setState(() {
                                  _isLoading = true;
                                });
                                print("Correct");
                                await shared.remove('otp');
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ForgetPassword2(phone: widget.phone)));
                              }else{
                                setState(() {
                                  _isLoading = false;
                                });
                                if(pressed>0){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(

                                      content: Text(tr("chances_left" +" "+ pressed.toString())),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }else if(pressed == 0){
                                  await shared.remove('otp');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(tr("enter_your_phone_number_again_please")),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                  Navigator.pop(context);

                                }
                              }
                            },
                            child: Text(
                              tr('submit'),
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
                        image: AssetImage('assets/images/THICKET_MASTER_PATERN_04.png'),
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,// Set the desired width
                        height: MediaQuery.of(context).size.height // Set the desired height
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
