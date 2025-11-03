import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../controllers/change_password_controller.dart';
import '../prefs/language_selector.dart';
import '../provider/settings_provider.dart';

class ChangePasswordScreen extends StatelessWidget {
  final ChangePasswordController controller =
      Get.put(ChangePasswordController());
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();

  final obscure = true.obs;
  final obscureConf = true.obs;

  ChangePasswordScreen({super.key});

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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BackButton(
                          color: Colors.white,
                        ),
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
                            Obx(() => InputField(
                                  controller: passwordController,
                                  hint: 'password'.tr,
                                  obscure: obscure.value,
                                  suffixIcon: IconButton(
                                    icon: Icon(obscure.value
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: obscure.toggle,
                                  ),
                                )),
                            Obx(() => InputField(
                                  controller: passwordConfirmationController,
                                  hint: 'confirm_pass'.tr,
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
                                        final password =
                                            passwordController.text.trim();
                                        final confirmPassword =
                                            passwordConfirmationController.text
                                                .trim();

                                        if (password.isEmpty ||
                                            confirmPassword.isEmpty) {
                                          Get.snackbar(
                                              'error'.tr, 'please_fill_all'.tr,
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white);
                                          return;
                                        }

                                        if (password != confirmPassword) {
                                          Get.snackbar(
                                              'error'.tr, 'pass_not_match'.tr,
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white);
                                          return;
                                        }

                                        controller.changePassword(
                                            password, confirmPassword);
                                      },
                                      child: Text('change_pass'.tr));
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
