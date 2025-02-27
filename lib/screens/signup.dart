import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../functions/functions.dart';
import '../models/newmodels.dart';
import '../prefs/language_selector.dart';
import '../prefs/routes.dart';
import '../provider/loginpersistence.dart';
import '../provider/settings_provider.dart';

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
      final signupProvider = Get.find<LoginDataProvider>(tag: 'login');
      LoginData? log = LoginData();
      log.firstName = _firstName;
      log.lastName = _lastName;
      log.email = _email;
      log.password = _password;
      await signupResponse(
              Signup(
                  confirmPassword: "$_confirmPassword",
                  cityid: _cityid ?? '',
                  email: _email,
                  firstName: _firstName,
                  lastName: _lastName,
                  password: _password,
                  phoneNumber: "251$_phoneNumber",
                  promoCode: _promoCode),
              '${baseUrlFunc}register')
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
            Get.offNamed(Routes.loginRoute);
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

  var obscure = true.obs;
  var obscureConf = true.obs;
  @override
  Widget build(BuildContext context) {
    final languageChange = Provider.of<SettingsProvider>(context);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF23981C), // Change this to your desired color
      statusBarIconBrightness: Brightness.light, // For light icons
      statusBarBrightness: Brightness.dark, // For iOS status bar
    ));
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100]),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Image.asset(
                'assets/images/login_backg.png',
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
                            color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: LanguageSelectorButton(onChange: () {}),
                        ),
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
                              Center(
                                child: Image(
                                  image: AssetImage(
                                      'assets/images/hello_mesa_string.png'),
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          child: Image.asset(
                                            'assets/images/input_backg.png',
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
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
                                                    } else if (value.length >
                                                            40 ||
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
                                                  // style:
                                                  //     TextStyle(color: Colors.white),
                                                  decoration: InputDecoration(
                                                    hintText: 'first_name'.tr,
                                                    // hintStyle: TextStyle(
                                                    //     color: Colors.white),
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
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          child: Image.asset(
                                            'assets/images/input_backg.png',
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
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
                                                  // style:
                                                  //     TextStyle(color: Colors.white),
                                                  key: const ValueKey("name"),
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return "name_empty";
                                                    } else if (value.length >
                                                            40 ||
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
                                                    hintText: 'last_name'.tr,
                                                    // hintStyle: TextStyle(
                                                    //     color: Colors.white),
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

                                    SizedBox(
                                      height: 10,
                                    ),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          child: Image.asset(
                                            'assets/images/input_backg.png',
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Row(
                                            children: [
                                              Text("+251",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                  // ?.copyWith(color: Colors.white),
                                                  ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                      color: Colors
                                                          .transparent, // Background color
                                                    ),
                                                    child: TextFormField(
                                                      // style: TextStyle(
                                                      //     color: Colors.white),
                                                      key: const ValueKey(
                                                          "phone"),
                                                      validator: (value) {
                                                        if (value!.isEmpty) {
                                                          return "phone empty";
                                                        } else if (value
                                                                    .length >
                                                                9 ||
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
                                                        fillColor:
                                                            Colors.transparent,
                                                        filled: true,
                                                        hintText: "9xxxxxxxx",
                                                        // hintStyle: TextStyle(
                                                        //     color: Colors.white),
                                                        border:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.all(
                                                                16.0),
                                                      ),
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          child: Image.asset(
                                            'assets/images/input_backg.png',
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
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
                                                  // style:
                                                  //     TextStyle(color: Colors.white),
                                                  key: const ValueKey(
                                                      "promocode"),
                                                  onSaved: (newValue) {
                                                    _promoCode = newValue;
                                                  },
                                                  onChanged: (value) {
                                                    _promoCode = value;
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: "Promo code",
                                                    // hintStyle: TextStyle(
                                                    //     color: Colors.white),
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
                                    SizedBox(
                                      height: 10,
                                    ),
                                    // Stack(
                                    //   alignment: Alignment.center,
                                    //   children: [
                                    //     Container(
                                    //       child: Image.asset(
                                    //         'assets/images/input_backg.png',
                                    //         width: MediaQuery.of(context).size.width,
                                    //       ),
                                    //     ),
                                    //     Padding(
                                    //       padding: const EdgeInsets.symmetric(
                                    //           horizontal: 16.0),
                                    //       child: Row(
                                    //         children: [
                                    //           Expanded(
                                    //             child: Padding(
                                    //               padding: const EdgeInsets.all(8.0),
                                    //               child: DropdownButton(
                                    //                   // dropdownColor:
                                    //                   //     Color(0xFF207D36),
                                    //                   // style: TextStyle(
                                    //                   //     color: Colors.white),
                                    //                   hint: Text(
                                    //                     'city'.tr,
                                    //                     // style: TextStyle(
                                    //                     //     color: Colors.white),
                                    //                   ),
                                    //                   isExpanded: true,
                                    //                   underline: Container(
                                    //                     color: Colors.transparent,
                                    //                   ),
                                    //                   icon: Icon(
                                    //                     Icons.expand_circle_down,
                                    //                     color: Colors.white,
                                    //                   ),
                                    //                   value: _cityid,
                                    //                   items: const [
                                    //                     DropdownMenuItem(
                                    //                         value: '1',
                                    //                         child:
                                    //                             Text('Addis Ababa')),
                                    //                     DropdownMenuItem(
                                    //                         value: '2',
                                    //                         child: Text('Hawassa')),
                                    //                   ],
                                    //                   onChanged: (String? value) {
                                    //                     setState(() {
                                    //                       _cityid = value;
                                    //                     });
                                    //                   }),
                                    //             ),
                                    //           ),
                                    //         ],
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          child: Image.asset(
                                            'assets/images/input_backg.png',
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
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
                                                  // style:
                                                  //     TextStyle(color: Colors.white),
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
                                                    } else if (value.length >
                                                            50 ||
                                                        value.length < 6 ||
                                                        !value.contains('@')) {
                                                      return "email invalid";
                                                    }
                                                    return null;
                                                  },
                                                  decoration: InputDecoration(
                                                    hintText: 'email'.tr,
                                                    // hintStyle: TextStyle(
                                                    //     color: Colors.white),
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          child: Image.asset(
                                            'assets/images/input_backg.png',
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
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
                                                child: Obx(
                                                  () => TextFormField(
                                                    // style:
                                                    //     TextStyle(color: Colors.white),
                                                    key: const ValueKey(
                                                        "password"),
                                                    validator: (value) {
                                                      if (value!.isEmpty) {
                                                        return "password empty";
                                                      } else if (value.length >
                                                              40 ||
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
                                                    obscureText: obscure.value,
                                                    decoration: InputDecoration(
                                                      suffixIcon:
                                                          GestureDetector(
                                                        onTap: () {
                                                          obscure.toggle();
                                                        },
                                                        child: Obx(() => obscure
                                                                .value
                                                            ? const Icon(Icons
                                                                .visibility_off)
                                                            : const Icon(Icons
                                                                .visibility)),
                                                      ),
                                                      hintText: 'password'.tr,
                                                      // hintStyle: TextStyle(
                                                      //     color: Colors.white),
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.all(16.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          child: Image.asset(
                                            'assets/images/input_backg.png',
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
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
                                                child: Obx(
                                                  () => TextFormField(
                                                    // style:
                                                    //     TextStyle(color: Colors.white),
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
                                                      _confirmPassword =
                                                          newValue;
                                                    },
                                                    onChanged: (value) {
                                                      _confirmPassword = value;
                                                    },
                                                    obscureText:
                                                        obscureConf.value,
                                                    decoration: InputDecoration(
                                                      suffixIcon:
                                                          GestureDetector(
                                                        onTap: () {
                                                          obscureConf.toggle();
                                                        },
                                                        child: Obx(() => obscureConf
                                                                .value
                                                            ? const Icon(Icons
                                                                .visibility_off)
                                                            : const Icon(Icons
                                                                .visibility)),
                                                      ),
                                                      hintText:
                                                          'confirm_pass'.tr,
                                                      // hintStyle: TextStyle(
                                                      //     color: Colors.white),
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
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
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.09,
                                            ),
                                          ),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                    Column(
                                      children: [
                                        Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              // Add a text widget to display "Don't have an account?"
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 0.0),
                                                child: Text(
                                                  'alr_hv_acc'.tr,
                                                  style: const TextStyle(
                                                      color: Color(0xFFFF9100),
                                                      fontSize: 19,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 3,
                                              ),
                                              // Add a gesture detector widget to handle the tap event on the link
                                              GestureDetector(
                                                onTap: () {
                                                  Get.toNamed(
                                                      Routes.loginRoute);
                                                },
                                                // Add a text widget to display "Register" as a link
                                                child: Image.asset(
                                                  'assets/images/sign_in_but.png',
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.09,
                                                ),
                                              )
                                            ]),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
