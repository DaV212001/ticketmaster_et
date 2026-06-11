import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../controllers/theme_controller.dart';
import '../functions/functions.dart';
import '../models/newmodels.dart';
import '../prefs/language_selector.dart';
import '../prefs/routes.dart';
import '../provider/loginpersistence.dart';
import '../provider/settings_provider.dart';
import 'otp_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // form fields
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _promo = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  final obscure = true.obs;
  final obscureConf = true.obs;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _promo.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    final loginProvider = Get.find<LoginDataProvider>(tag: 'login');
    String? languageCode = ThemeModeController.languageCode.value == 'es'
        ? 'tg'
        : ThemeModeController.languageCode.value == 'it'
            ? 'or'
            : ThemeModeController.languageCode.value == 'fr'
                ? 'so'
                : ThemeModeController.languageCode.value;
    final signupData = Signup(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text.trim(),
      password: _password.text.trim(),
      confirmPassword: _confirmPassword.text.trim(),
      cityid: '',
      phoneNumber: '251${_phone.text.trim()}',
      promoCode: _promo.text.trim(),
      language: languageCode,
    );

    // bool? verified = await Get.to<bool>(() => OtpScreen(
    //       fromSignUp: true,
    //       phone: _phone.text.trim(),
    //     ));
    // if (verified == true) {
    final response = await signupResponse(signupData, '${baseUrlFunc}register');

    if (response.message == "User registered successfully") {
      final log = LoginData(
        firstName: _firstName.text,
        lastName: _lastName.text,
        email: _email.text,
        phone: '251${_phone.text}',
      );
      // await loginProvider.setLoginData(log);
      loginProvider.setUserRegistered(true);
      setState(() => _isLoading = false);
      var data = response.data as Map<String, dynamic>;

      // Get.offNamed(Routes.loginRoute);
      await Get.to<bool>(() => OtpScreen(
            fromSignUp: true,
            phone: _phone.text.trim(),
            userId: data['id'],
          ));
    } else {
      loginProvider.setUserRegistered(false);
      setState(() => _isLoading = false);
      final errorMsg = buildErrorMessage(response.error);
      _showErrorDialog(errorMsg);
    }

    setState(() => _isLoading = false);
    // } else {
    // setState(() {
    //   _isLoading = false;
    // });
    // }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(
          message,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  String buildErrorMessage(ErrorDataS? error) {
    if (error == null) return "Error signing up";
    String msg = '';
    if (error.name != null) msg += errorMessageConcatenator(error.name!);
    if (error.email != null) msg += errorMessageConcatenator(error.email!);
    if (error.password != null) {
      msg += errorMessageConcatenator(error.password!);
    }
    if (error.phonenumber != null) {
      msg += errorMessageConcatenator(error.phonenumber!);
    }
    return msg.isEmpty ? "Error signing up" : msg;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF23981C),
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[100]),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/login_backg.png',
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: LanguageSelectorButton(onChange: () {}),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/hello_mesa_string.png',
                                width: MediaQuery.of(context).size.width * 0.5,
                              ),
                              const SizedBox(height: 20),
                              InputField(
                                controller: _firstName,
                                hint: 'first_name'.tr,
                                validator: (v) =>
                                    v!.length < 2 ? 'name_short_long' : null,
                              ),
                              InputField(
                                controller: _lastName,
                                hint: 'last_name'.tr,
                                validator: (v) =>
                                    v!.length < 2 ? 'name_short_long' : null,
                              ),
                              InputField(
                                controller: _phone,
                                hint: '9xxxxxxxx',
                                prefix: const Padding(
                                  padding: EdgeInsets.only(top: 16.0),
                                  child: Text('+251 '),
                                ),
                                validator: (v) => v!.length != 9
                                    ? 'phone number invalid'
                                    : null,
                              ),
                              InputField(
                                controller: _promo,
                                hint: 'promocode'.tr,
                              ),
                              InputField(
                                controller: _email,
                                hint: 'email'.tr,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return null;
                                  if (!GetUtils.isEmail(v)) {
                                    return 'invalid_email'.tr;
                                  }
                                  return null;
                                },
                              ),
                              Obx(() => InputField(
                                    controller: _password,
                                    hint: 'password'.tr,
                                    obscure: obscure.value,
                                    suffixIcon: IconButton(
                                      icon: Icon(obscure.value
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: obscure.toggle,
                                    ),
                                    validator: (v) => v!.length < 6
                                        ? 'password too short'
                                        : null,
                                  )),
                              Obx(() => InputField(
                                    controller: _confirmPassword,
                                    hint: 'confirm_pass'.tr,
                                    obscure: obscureConf.value,
                                    suffixIcon: IconButton(
                                      icon: Icon(obscureConf.value
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: obscureConf.toggle,
                                    ),
                                    validator: (v) => v != _password.text
                                        ? "passwords don't match"
                                        : null,
                                  )),
                              const SizedBox(height: 20),
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : GestureDetector(
                                      onTap: _submitForm,
                                      child: Image.asset(
                                        'assets/images/sign_up_but.png',
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.09,
                                      ),
                                    ),
                              const SizedBox(height: 25),
                              Column(
                                children: [
                                  Text(
                                    'alr_hv_acc'.tr,
                                    style: const TextStyle(
                                      color: Color(0xFFFF9100),
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Get.toNamed(Routes.loginRoute),
                                    child: Image.asset(
                                      'assets/images/sign_in_but.png',
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.09,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? prefix;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const InputField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.prefix,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/input_backg.png',
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fill,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              controller: controller,
              obscureText: obscure,
              validator: validator,
              decoration: InputDecoration(
                prefixIcon: prefix,
                suffixIcon: suffixIcon,
                hintText: hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
// Container(
//                   //   child: Padding(
//                   //     padding: EdgeInsets.only(
//                   //         top: 15, bottom: 15, right: 30, left: 30),
//                   //     child: Column(
//                   //       children: [
//                   //         _isLoading
//                   //             ? const CircularProgressIndicator()
//                   //             : ElevatedButton(
//                   //                 style: const ButtonStyle(
//                   //                     backgroundColor: MaterialStatePropertyAll(
//                   //                         Colors.green),
//                   //                     foregroundColor: MaterialStatePropertyAll(
//                   //                         Colors.white),
//                   //                     minimumSize: MaterialStatePropertyAll(
//                   //                         Size(double.infinity, 50))),
//                   //                 onPressed: () => {
//                   //                       submitForm(),
//                   //                       // Navigator.push(context,
//                   //                       //     MaterialPageRoute(builder: ((context) {
//                   //                       //   return const VerificationScreen();
//                   //                       // })))
//                   //                     },
//                   //                 child: Row(
//                   //                   mainAxisAlignment: MainAxisAlignment.center,
//                   //                   crossAxisAlignment:
//                   //                       CrossAxisAlignment.center,
//                   //                   children: [
//                   //                     Text(tr('submit')),
//                   //                     Icon(Icons.arrow_forward)
//                   //                   ],
//                   //                 )),
//                   //         const SizedBox(
//                   //           height: 15,
//                   //         ),
//                   //         // Row(
//                   //         //     mainAxisAlignment: MainAxisAlignment.center,
//                   //         //     children: <Widget>[
//                   //         //       // Add a text widget to display "Don't have an account?"
//                   //         //       Padding(
//                   //         //         padding: const EdgeInsets.only(bottom: 8.0),
//                   //         //         child: Text(tr('have_acc'),
//                   //         //             style: TextStyle(
//                   //         //                 color: Colors.grey.shade800,
//                   //         //                 fontWeight: FontWeight.bold)),
//                   //         //       ),
//                   //         //       SizedBox(width: 3,),
//                   //         //       // Add a gesture detector widget to handle the tap event on the link
//                   //         //       GestureDetector(
//                   //         //         onTap: () {
//                   //         //           // Navigate to the RegisterScreen
//                   //         //           Navigator.push(
//                   //         //             context,
//                   //         //             MaterialPageRoute(
//                   //         //               builder: (context) => LoginScreen(),
//                   //         //             ),
//                   //         //           );
//                   //         //         },
//                   //         //         // Add a text widget to display "Register" as a link
//                   //         //         child: Padding(
//                   //         //           padding: const EdgeInsets.only(bottom: 8.0),
//                   //         //           child: Text(tr('login'),
//                   //         //               style: TextStyle(
//                   //         //                   color: Colors.green,
//                   //         //                   fontWeight: FontWeight.bold)),
//                   //         //         ),
//                   //         //       )
//                   //         //     ]),
//                   //       ],
//                   //     ),
//                   //   ),
//                   // )
