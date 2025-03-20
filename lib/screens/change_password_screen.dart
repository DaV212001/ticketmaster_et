import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/change_password_controller.dart';

class ChangePasswordScreen extends StatelessWidget {
  final ChangePasswordController controller =
      Get.put(ChangePasswordController());
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();

  ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF23981C),
        title: Text('change_pass'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: passwordController,
              // obscureText: true,
              decoration: InputDecoration(
                labelText: 'password'.tr,
                // border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordConfirmationController,
              // obscureText: true,
              decoration: InputDecoration(
                labelText: 'confirm_pass'.tr,
                // border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              return ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        final password = passwordController.text.trim();
                        final confirmPassword =
                            passwordConfirmationController.text.trim();

                        if (password.isEmpty || confirmPassword.isEmpty) {
                          Get.snackbar('error'.tr, 'please_fill_all'.tr);
                          return;
                        }

                        if (password != confirmPassword) {
                          Get.snackbar('error'.tr, 'pass_not_match'.tr);
                          return;
                        }

                        controller.changePassword(password, confirmPassword);
                      },
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text('change_pass'.tr),
              );
            }),
          ],
        ),
      ),
    );
  }
}
