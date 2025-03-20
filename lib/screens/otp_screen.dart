import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:ticketmaster_et/widgets/phone_input_field.dart';

import '../controllers/otp_controller.dart';

class OtpScreen extends StatelessWidget {
  final OtpController controller = Get.put(OtpController());
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();

  OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF23981C),
        title: Text('reset_password'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!controller.isOtpSent.value)
                Column(
                  children: [
                    PhoneInputField(
                      controller: phoneController,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              final phone = phoneController.text.trim();
                              if (phone.isEmpty) {
                                Get.snackbar('error'.tr, 'error_fill_phone'.tr);
                                return;
                              }
                              controller.sendOtp(phone);
                            },
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('send_otp'.tr),
                    ),
                  ],
                ),
              if (controller.isOtpSent.value && !controller.isOtpVerified.value)
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
                              color: Theme.of(context).primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              final phone = phoneController.text.trim();
                              final otp = otpController.text.trim();
                              if (otp.isEmpty) {
                                Get.snackbar('error'.tr, 'error_fill_otp'.tr);
                                return;
                              }
                              controller.verifyOtp(phone, otp);
                            },
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('verify_otp'.tr),
                    ),
                  ],
                ),
              if (controller.isOtpVerified.value)
                Column(
                  children: [
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'new_password'.tr,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordConfirmationController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'confirm_new_password'.tr,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              final phone = phoneController.text.trim();
                              final password = passwordController.text.trim();
                              final passwordConfirmation =
                                  passwordConfirmationController.text.trim();

                              if (password.isEmpty ||
                                  passwordConfirmation.isEmpty) {
                                Get.snackbar('error'.tr, 'please_fill_all'.tr);
                                return;
                              }

                              if (password != passwordConfirmation) {
                                Get.snackbar('error'.tr, 'pass_not_match'.tr);
                                return;
                              }

                              controller.resetPassword(
                                  phone, password, passwordConfirmation);
                            },
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('reset'.tr),
                    ),
                  ],
                ),
            ],
          );
        }),
      ),
    );
  }
}
