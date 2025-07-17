import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/screens/otp_screen.dart';

import '../constants/endpoints.dart';
import '../functions/functions.dart';
import '../models/newmodels.dart';
import '../prefs/language_selector.dart';
import '../prefs/routes.dart';
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
      final loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
      await loginResponse(
        Endpoints.loginEndpoint(),
        Login(password: _password, phoneNumber: "251$_phoneNumber"),
      ).then((value) async {
        // Add async here
        setState(() {
          _isLoading = true;
        });
        if (value.responseData != null) {
          await loginDataProvider
              .setLoginData(value.responseData!); // Use await here
          loginDataProvider.setUserLoggedIn(true); // Set user as logged in
          debugPrint('${loginDataProvider.loginData!.id!}');
          Get.offAllNamed(Routes.mainLayoutRoute);
        } else if (value.error != null) {
          setState(() {
            _isLoading = false;
          });
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

  var obscure = true.obs;
  @override
  Widget build(BuildContext context) {
    final loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
    final accountProvider = Get.find<LoginDataProvider>(tag: 'login');
    final languageChange = Provider.of<SettingsProvider>(context);
    Icon icon = Icon(Icons.visibility);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF23981C), // Change this to your desired color
      statusBarIconBrightness: Brightness.light, // For light icons
      statusBarBrightness: Brightness.dark, // For iOS status bar
    ));
    return Container(
      color: Colors.grey[100],
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
              ListView(scrollDirection: Axis.vertical, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: LanguageSelectorButton(onChange: () {}),
                        ),
                      ),
                    ),
                  ],
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Center(
                        child: Image(
                          image:
                              AssetImage('assets/images/hello_mesa_string.png'),
                          width: MediaQuery.of(context).size.width * 0.5,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      child: Image.asset(
                                        'assets/images/input_backg.png',
                                        width:
                                            MediaQuery.of(context).size.width,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            "+251",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
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
                                                      BorderRadius.circular(
                                                          15.0),
                                                  color: Colors
                                                      .transparent, // Background color
                                                ),
                                                child: TextFormField(
                                                  key: const ValueKey("phone"),
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return "phone empty";
                                                    } else if (value.length >
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
                                        'assets/images/input_backg.png',
                                        width:
                                            MediaQuery.of(context).size.width,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Obx(() => TextFormField(
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
                                                    suffixIcon: GestureDetector(
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
                                                    fillColor:
                                                        Colors.transparent,
                                                    hintText: 'password'.tr,
                                                    border:
                                                        const OutlineInputBorder(),
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                  ),
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                        onTap: () {
                                          Get.to(OtpScreen());
                                        },
                                        child: Text('forgot_pass'.tr))),
                                const SizedBox(
                                  height: 5,
                                ),
                                _isLoading
                                    ? const CircularProgressIndicator()
                                    : GestureDetector(
                                        onTap: () {
                                          submitForm();
                                        },
                                        child: Image.asset(
                                          'assets/images/sign_in_but.png',
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.09,
                                        ),
                                      ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
                            ),
                            Column(
                              children: [
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      // Add a text widget to display "Don't have an account?"
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 0.0),
                                        child: Text(
                                          'no_acc'.tr,
                                          style: const TextStyle(
                                              color: Color(0xFFFF9100),
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 3,
                                      ),
                                      // Add a gesture detector widget to handle the tap event on the link
                                      GestureDetector(
                                        onTap: () {
                                          Get.toNamed(Routes.signUpRoute);
                                        },
                                        // Add a text widget to display "Register" as a link
                                        child: Image.asset(
                                          'assets/images/sign_up_but.png',
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.09,
                                        ),
                                      )
                                    ]),
                                // Align(
                                //     alignment: Alignment.centerRight,
                                //     child: MaterialButton(
                                //         onPressed: () {
                                //           Navigator.push(
                                //               context,
                                //               MaterialPageRoute(
                                //                   builder: (context) =>
                                //                       ForgetPassword0()));
                                //         },
                                //         child: Text(tr("forgot_password"))))
                              ],
                            )
                          ],
                        ),
                      ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     image: DecorationImage(image: AssetImage('assets/images/THICKET_MASTER_PATERN_04.png'),
                      //         fit: BoxFit.cover)
                      //   ),
                      // ),
                      // Container(
                      //   width: MediaQuery.of(context).size.width,
                      //   height: 250,
                      //   alignment: Alignment.topCenter,
                      //   padding: EdgeInsets.all(0),
                      //   transformAlignment: Alignment.topCenter,
                      //   child: Image(
                      //       image: AssetImage(
                      //           'assets/images/THICKET_MASTER_PATERN_04.png'),
                      //       width: MediaQuery.of(context).size.width,
                      //       fit: BoxFit.fill, // Set the desired width
                      //       height: MediaQuery.of(context)
                      //           .size
                      //           .height // Set the desired height
                      //       ),
                      // )
                    ],
                  ),
                )
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
