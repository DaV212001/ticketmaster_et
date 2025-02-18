import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/endpoints.dart';
import '../functions/functions.dart';
import '../models/newmodels.dart';
import '../provider/loginpersistence.dart';
import '../provider/settings_provider.dart';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _firstName,
      _lastName,
      _phoneNumber,
      _promoCode,
      _email,
      _password,
      _confirmPassword;
  String? _cityid;

  Future submitForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      final signupProvider =
          Provider.of<LoginDataProvider>(context, listen: false);
      LoginData? log = LoginData();
      log.firstName = _firstName;
      log.lastName = _lastName;
      log.email = _email;
      log.password = _password;
      await signupResponse(
              Signup(
                  confirmPassword: "$_confirmPassword",
                  cityid: _cityid,
                  email: _email,
                  firstName: _firstName,
                  lastName: _lastName,
                  password: _password,
                  phoneNumber: "251$_phoneNumber",
                  promoCode: _promoCode),
              Endpoints.signupEndpoint())
          .then((value) async {
        // Add async here
        if (value.message != null) {
          if (value.message == "User registered successfully") {
            log.firstName = _firstName;
            log.lastName = _lastName;
            log.email = _email;
            log.phone = '251$_phoneNumber';
            signupProvider.setUserRegistered(true);
            await signupProvider.setLoginData(log); // Use await here
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return LoginScreen();
            }));
          }
        } else {
          signupProvider.setUserRegistered(false);
          String errorMessage = "Error Signing in";
          if (value.error!.name != null) {
            errorMessage = errorMessageConcatenator(value.error!.name!);
          }
          if (value.error!.email != null) {
            errorMessage = errorMessageConcatenator(value.error!.email!);
          }
          if (value.error!.password != null) {
            errorMessage = errorMessageConcatenator(value.error!.password!);
          }
          if (value.error!.phonenumber != null) {
            errorMessage = errorMessageConcatenator(value.error!.phonenumber!);
          }

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.green),
                ),
              );
            },
          );
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
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100]),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Image.asset(
                'assets/images/sign_up_backg.png',
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fill,
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.transparent),
                        child: DropdownButton(
                            value: languageChange.languageCode,
                            style: TextStyle(color: Colors.white),
                            dropdownColor: Color(0xFF207D36),
                            items: const [
                              DropdownMenuItem(
                                  value: 'en', child: Text('English')),
                              DropdownMenuItem(
                                  value: 'am', child: Text('Amharic')),
                              DropdownMenuItem(
                                  value: 'en-AU', child: Text('Afaan Oromo')),
                              DropdownMenuItem(
                                  value: 'es', child: Text('Somali')),
                              DropdownMenuItem(
                                  value: 'fr', child: Text('Tigrinya')),
                            ],
                            onChanged: (String? value) {
                              setState(() async {
                                languageChange.languageCode = value!;
                                List<String> codes =
                                    languageChange.languageCode.split('-');
                                String langCode = codes[0];
                                String countryCode =
                                    codes.length > 1 ? codes[1] : '';

                                // Save langCode and countryCode in shared preferences
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString('langCode', langCode);
                                if (countryCode.isNotEmpty) {
                                  await prefs.setString(
                                      'countryCode', countryCode);
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
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Image(
                                image: AssetImage(
                                    'assets/images/sign_up_backg_sec.png'),
                                width: 170.0, // Set the desired width
                                height: 170.0, // Set the desired height
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    child: Image.asset(
                                      'assets/images/sign_up_input_backg.png',
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: TextFormField(
                                            key: const ValueKey("name"),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "name_empty";
                                              } else if (value.length > 40 ||
                                                  value.length < 2) {
                                                return "name_short_long";
                                              }
                                              return null;
                                            },
                                            onSaved: (newValue) {
                                              _firstName = newValue;
                                            },
                                            onChanged: (value) {
                                              _firstName = value;
                                            },
                                            style:
                                                TextStyle(color: Colors.white),
                                            decoration: InputDecoration(
                                              hintText: tr('first_name'),
                                              hintStyle: TextStyle(
                                                  color: Colors.white),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.all(16.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    child: Image.asset(
                                      'assets/images/sign_up_input_backg.png',
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: TextFormField(
                                            style:
                                                TextStyle(color: Colors.white),
                                            key: const ValueKey("name"),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "name_empty";
                                              } else if (value.length > 40 ||
                                                  value.length < 2) {
                                                return "name_short_long";
                                              }
                                              return null;
                                            },
                                            onSaved: (newValue) {
                                              _lastName = newValue;
                                            },
                                            onChanged: (value) {
                                              _lastName = value;
                                            },
                                            decoration: InputDecoration(
                                              hintText: tr('last_name'),
                                              hintStyle: TextStyle(
                                                  color: Colors.white),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.all(16.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    child: Image.asset(
                                      'assets/images/sign_up_input_backg.png',
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          "+251",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(color: Colors.white),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                            flex: 4,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                color: Colors
                                                    .transparent, // Background color
                                              ),
                                              child: TextFormField(
                                                style: TextStyle(
                                                    color: Colors.white),
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
                                                decoration:
                                                    const InputDecoration(
                                                  fillColor: Colors.transparent,
                                                  filled: true,
                                                  hintText: "9xxxxxxxx",
                                                  hintStyle: TextStyle(
                                                      color: Colors.white),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.all(16.0),
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    child: Image.asset(
                                      'assets/images/sign_up_input_backg.png',
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: TextFormField(
                                            style:
                                                TextStyle(color: Colors.white),
                                            key: const ValueKey("promocode"),
                                            onSaved: (newValue) {
                                              _promoCode = newValue;
                                            },
                                            onChanged: (value) {
                                              _promoCode = value;
                                            },
                                            decoration: const InputDecoration(
                                              hintText: "Promo code",
                                              hintStyle: TextStyle(
                                                  color: Colors.white),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.all(16.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    child: Image.asset(
                                      'assets/images/sign_up_input_backg.png',
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: DropdownButton(
                                                dropdownColor:
                                                    Color(0xFF207D36),
                                                style: TextStyle(
                                                    color: Colors.white),
                                                hint: Text(
                                                  tr('city'),
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                isExpanded: true,
                                                underline: Container(
                                                  color: Colors.transparent,
                                                ),
                                                icon: Icon(
                                                  Icons.expand_circle_down,
                                                  color: Colors.white,
                                                ),
                                                value: _cityid,
                                                items: const [
                                                  DropdownMenuItem(
                                                      value: '1',
                                                      child:
                                                          Text('Addis Ababa')),
                                                  DropdownMenuItem(
                                                      value: '2',
                                                      child: Text('Hawassa')),
                                                ],
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    _cityid = value;
                                                  });
                                                }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    child: Image.asset(
                                      'assets/images/sign_up_input_backg.png',
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: TextFormField(
                                            style:
                                                TextStyle(color: Colors.white),
                                            key: const ValueKey("email"),
                                            onSaved: (newValue) {
                                              _email = newValue;
                                            },
                                            onChanged: (value) {
                                              _email = value;
                                            },
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "email empty";
                                              } else if (value.length > 50 ||
                                                  value.length < 6 ||
                                                  !value.contains('@')) {
                                                return "email invalid";
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              hintText: tr('email'),
                                              hintStyle: TextStyle(
                                                  color: Colors.white),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  const EdgeInsets.all(16.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    child: Image.asset(
                                      'assets/images/sign_up_input_backg.png',
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: TextFormField(
                                            style:
                                                TextStyle(color: Colors.white),
                                            key: const ValueKey("password"),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "password empty";
                                              } else if (value.length > 40 ||
                                                  value.length < 3) {
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
                                              hintStyle: TextStyle(
                                                  color: Colors.white),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.all(16.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    child: Image.asset(
                                      'assets/images/sign_up_input_backg.png',
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: TextFormField(
                                            style:
                                                TextStyle(color: Colors.white),
                                            key: const ValueKey(
                                                "password_confirm"),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "password empty";
                                              } else if (_password !=
                                                  _confirmPassword) {
                                                return "passwords don't match";
                                              }
                                              return null;
                                            },
                                            onSaved: (newValue) {
                                              _confirmPassword = newValue;
                                            },
                                            onChanged: (value) {
                                              _confirmPassword = value;
                                            },
                                            decoration: InputDecoration(
                                              hintText: tr('confirm_pass'),
                                              hintStyle: TextStyle(
                                                  color: Colors.white),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.all(16.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : GestureDetector(
                                      onTap: () => {
                                        submitForm(),
                                        // Navigator.push(context,
                                        //     MaterialPageRoute(builder: ((context) {
                                        //   return const VerificationScreen();
                                        // })))
                                      },
                                      child: Image.asset(
                                        'assets/images/sign_up_but.png',
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.09,
                                      ),
                                    ),
                              const SizedBox(
                                height: 25,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Image(
                      image: AssetImage('assets/images/hello_mesa_string.png'),
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                  ),

                  // Container(
                  //   child: Padding(
                  //     padding: EdgeInsets.only(
                  //         top: 15, bottom: 15, right: 30, left: 30),
                  //     child: Column(
                  //       children: [
                  //         _isLoading
                  //             ? const CircularProgressIndicator()
                  //             : ElevatedButton(
                  //                 style: const ButtonStyle(
                  //                     backgroundColor: MaterialStatePropertyAll(
                  //                         Colors.green),
                  //                     foregroundColor: MaterialStatePropertyAll(
                  //                         Colors.white),
                  //                     minimumSize: MaterialStatePropertyAll(
                  //                         Size(double.infinity, 50))),
                  //                 onPressed: () => {
                  //                       submitForm(),
                  //                       // Navigator.push(context,
                  //                       //     MaterialPageRoute(builder: ((context) {
                  //                       //   return const VerificationScreen();
                  //                       // })))
                  //                     },
                  //                 child: Row(
                  //                   mainAxisAlignment: MainAxisAlignment.center,
                  //                   crossAxisAlignment:
                  //                       CrossAxisAlignment.center,
                  //                   children: [
                  //                     Text(tr('submit')),
                  //                     Icon(Icons.arrow_forward)
                  //                   ],
                  //                 )),
                  //         const SizedBox(
                  //           height: 15,
                  //         ),
                  //         // Row(
                  //         //     mainAxisAlignment: MainAxisAlignment.center,
                  //         //     children: <Widget>[
                  //         //       // Add a text widget to display "Don't have an account?"
                  //         //       Padding(
                  //         //         padding: const EdgeInsets.only(bottom: 8.0),
                  //         //         child: Text(tr('have_acc'),
                  //         //             style: TextStyle(
                  //         //                 color: Colors.grey.shade800,
                  //         //                 fontWeight: FontWeight.bold)),
                  //         //       ),
                  //         //       SizedBox(width: 3,),
                  //         //       // Add a gesture detector widget to handle the tap event on the link
                  //         //       GestureDetector(
                  //         //         onTap: () {
                  //         //           // Navigate to the RegisterScreen
                  //         //           Navigator.push(
                  //         //             context,
                  //         //             MaterialPageRoute(
                  //         //               builder: (context) => LoginScreen(),
                  //         //             ),
                  //         //           );
                  //         //         },
                  //         //         // Add a text widget to display "Register" as a link
                  //         //         child: Padding(
                  //         //           padding: const EdgeInsets.only(bottom: 8.0),
                  //         //           child: Text(tr('login'),
                  //         //               style: TextStyle(
                  //         //                   color: Colors.green,
                  //         //                   fontWeight: FontWeight.bold)),
                  //         //         ),
                  //         //       )
                  //         //     ]),
                  //       ],
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
