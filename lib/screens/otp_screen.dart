import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/widgets/phone_input_field.dart';

import '../controllers/otp_controller.dart';
import '../prefs/language_selector.dart';
import '../provider/settings_provider.dart';

class OtpScreen extends StatelessWidget {
  final OtpController controller = Get.put(OtpController());
  final TextEditingController phoneController;
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();

  OtpScreen({super.key, this.fromSignUp, this.phone, this.userId})
      : phoneController = TextEditingController(text: phone);
  final bool? fromSignUp;
  final String? phone;
  final int? userId;

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
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/hello_mesa_string.png',
                              width: MediaQuery.of(context).size.width * 0.5,
                            ),
                            const SizedBox(height: 20),
                            Obx(() {
                              return Column(
                                children: [
                                  if (!controller.isOtpSent.value)
                                    Column(
                                      children: [
                                        StyledPhoneInputField(
                                          initialValue: phone,
                                          controller: phoneController,
                                        ),
                                        const SizedBox(height: 20),
                                        controller.isLoading.value
                                            ? const CircularProgressIndicator()
                                            : ElevatedButton(
                                                onPressed: () {
                                                  final phone = phoneController
                                                      .text
                                                      .trim();
                                                  if (phone.isEmpty) {
                                                    Get.snackbar('error'.tr,
                                                        'error_fill_phone'.tr,
                                                        backgroundColor:
                                                            Colors.red,
                                                        colorText:
                                                            Colors.white);
                                                    return;
                                                  }
                                                  controller.sendOtp(phone);
                                                },
                                                child: Text('send_otp'.tr),
                                              ),
                                      ],
                                    ),
                                  if (controller.isOtpSent.value &&
                                      !controller.isOtpVerified.value)
                                    Column(
                                      children: [
                                        Pinput(
                                          controller: otpController,
                                          length: 4,
                                          defaultPinTheme: PinTheme(
                                            width: 56,
                                            height: 56,
                                            textStyle: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        controller.isLoading.value
                                            ? const CircularProgressIndicator()
                                            : ElevatedButton(
                                                onPressed: () {
                                                  final phone = phoneController
                                                      .text
                                                      .trim();
                                                  final otp =
                                                      otpController.text.trim();
                                                  if (otp.isEmpty) {
                                                    Get.snackbar('error'.tr,
                                                        'error_fill_otp'.tr,
                                                        backgroundColor:
                                                            Colors.red,
                                                        colorText:
                                                            Colors.white);
                                                    return;
                                                  }
                                                  controller.verifyOtp(
                                                      phone, otp,
                                                      userId: userId ?? 0,
                                                      fromSignUp:
                                                          fromSignUp ?? false);
                                                },
                                                child: Text('verify_otp'.tr),
                                              ),
                                      ],
                                    ),
                                  if (controller.isOtpVerified.value)
                                    ResetPasswordForm(
                                        passwordController: passwordController,
                                        passwordConfirmationController:
                                            passwordConfirmationController,
                                        controller: controller,
                                        phoneController: phoneController),
                                ],
                              );
                            }),
                          ],
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

class ResetPasswordForm extends StatelessWidget {
  ResetPasswordForm({
    super.key,
    required this.passwordController,
    required this.passwordConfirmationController,
    required this.controller,
    required this.phoneController,
  });

  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;
  final OtpController controller;
  final TextEditingController phoneController;

  final obscure = true.obs;
  final obscureConf = true.obs;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => InputField(
              controller: passwordController,
              hint: 'new_password'.tr,
              obscure: obscure.value,
              suffixIcon: IconButton(
                icon: Icon(
                    obscure.value ? Icons.visibility_off : Icons.visibility),
                onPressed: obscure.toggle,
              ),
            )),
        Obx(() => InputField(
              controller: passwordConfirmationController,
              hint: 'confirm_new_password'.tr,
              obscure: obscureConf.value,
              suffixIcon: IconButton(
                icon: Icon(obscureConf.value
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: obscureConf.toggle,
              ),
            )),
        const SizedBox(height: 20),
        Obx(() {
          return controller.isLoading.value
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () {
                    final phone = phoneController.text.trim();
                    final password = passwordController.text.trim();
                    final passwordConfirmation =
                        passwordConfirmationController.text.trim();

                    if (password.isEmpty || passwordConfirmation.isEmpty) {
                      Get.snackbar('error'.tr, 'please_fill_all'.tr,
                          backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }

                    if (password != passwordConfirmation) {
                      Get.snackbar('error'.tr, 'pass_not_match'.tr,
                          backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }

                    controller.resetPassword(
                        phone, password, passwordConfirmation);
                  },
                  child: Text('reset_password'.tr),
                );
        }),
      ],
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

class StyledPhoneInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;

  const StyledPhoneInputField({
    super.key,
    this.controller,
    this.initialValue,
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
            padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
            child: PhoneInputField(
              height: 65,
              styled: true,
              initialValue: initialValue,
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}
