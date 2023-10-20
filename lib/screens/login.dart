import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticketmaster_et/main_layout_screen.dart';
import 'package:ticketmaster_et/screens/signup.dart';

import '../components/fields.dart';
import '../constants/app_constants.dart';
import '../constants/endpoints.dart';
import '../functions/functions.dart';
import '../models/newmodels.dart';
import '../provider/loginpersistence.dart';
import '../provider/settings_provider.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {


  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _phoneNumber, _password;
  Future submitForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      final loginDataProvider = Provider.of<LoginDataProvider>(context, listen: false);
      await loginResponse(
        Endpoints.loginEndpoint(),
        Login(password: _password, phoneNumber: "251$_phoneNumber"),
      ).then((value) async { // Add async here
        setState(() {
          _isLoading = true;
        });
        if (value.responseData != null) {

          await loginDataProvider.setLoginData(value.responseData!); // Use await here
          loginDataProvider.setUserLoggedIn(true); // Set user as logged in
          debugPrint('${loginDataProvider.loginData!.id!}');
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return TicketMatserHomePage(title: 'title');
          }));
        } else if (value.error != null) {
          print(value.error);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(value.error!)));
        }
      });
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final languageChange = Provider.of<SettingsProvider>(context);
    Icon icon = Icon(Icons.visibility);
    bool obscure = true;
    return Container(
      color: Colors.grey[100],
      child: SafeArea(
          child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
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
                body: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [

                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Center(
                              child: Image(
                                image: AssetImage('assets/images/THICKET_MASTER_LOGO.png'),
                                width: 200.0, // Set the desired width
                                height: 200.0, // Set the desired height
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    tr('login'),
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                InputHeader(headerName: tr('phone')),
                                const SizedBox(
                                  height: 10,
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
                                          padding:
                                          const EdgeInsets.symmetric(horizontal: 16.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15.0),
                                            color: Colors.grey[200], // Background color
                                          ),
                                          child: TextFormField(
                                            key: const ValueKey("phone"),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "phone empty";
                                              } else if (value.length > 9 ||
                                                  value.length < 9) {
                                                return "phone number invalid";
                                              }
                                              return null;
                                            },
                                            onSaved: (newValue) {
                                              _phoneNumber = newValue;
                                            },
                                            onChanged: (value) {
                                              _phoneNumber = value;
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
                                  height: 15,
                                ),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(tr('password'), style: kTextStyle)),
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
                                    obscureText: obscure,
                                    key: const ValueKey("password"),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "password empty";
                                      } else if (value.length > 40 || value.length < 3) {
                                        return "password too short or too long";
                                      }
                                      return null;
                                    },
                                    onSaved: (newValue) {
                                      _password = newValue;
                                    },
                                    onChanged: (value) {
                                      _password = value;
                                    },
                                    decoration: InputDecoration(
                                      hintText: tr('password'),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(16.0),
                                      // suffixIcon: IconButton(
                                      //     onPressed: () {
                                      //       setState(() {
                                      //         if (obscure == true) {
                                      //           setState(() {
                                      //             obscure = false;
                                      //             icon = Icon(Icons.visibility_off);
                                      //           });
                                      //         } else {
                                      //           setState(() {
                                      //             obscure = true;
                                      //             icon = Icon(Icons.visibility);
                                      //           });
                                      //         }
                                      //       });
                                      //     },
                                      //     icon: icon
                                      // ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 25,
                                ),
                                _isLoading
                                    ? const CircularProgressIndicator()
                                    : OutlinedButton(
                                    style: const ButtonStyle(
                                        backgroundColor:
                                        MaterialStatePropertyAll(Colors.green),
                                        foregroundColor:
                                        MaterialStatePropertyAll(Colors.white),
                                        minimumSize: MaterialStatePropertyAll(
                                            Size(double.infinity, 50))),
                                    onPressed: () {
                                      submitForm();
                                    },
                                    child: Text(
                                      tr('submit'),
                                      style: TextStyle(fontSize: 20),
                                    )),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      // Add a text widget to display "Don't have an account?"
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 0.0),
                                        child: Text(tr('no_acc'),
                                            style: TextStyle(
                                                color: Colors.grey.shade800,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      SizedBox(width: 3,),
                                      // Add a gesture detector widget to handle the tap event on the link
                                      GestureDetector(
                                        onTap: () {
                                          // Navigate to the RegisterScreen
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SignupScreen(),
                                            ),
                                          );
                                        },
                                        // Add a text widget to display "Register" as a link
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 0.0),
                                          child: Text(tr('signup'),
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      )
                                    ]),

                              ],
                            ),
                          ),
                          // Container(
                          //   decoration: BoxDecoration(
                          //     image: DecorationImage(image: AssetImage('assets/images/THICKET_MASTER_PATERN_04.png'),
                          //         fit: BoxFit.cover)
                          //   ),
                          // ),
                          Image(
                            image: AssetImage('assets/images/THICKET_MASTER_PATERN_04.png'),
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,// Set the desired width
                            height: 200.0, // Set the desired height
                          )
                        ],
                      ),
                    )]

                ),
              ),

      ),
    );
  }
}
