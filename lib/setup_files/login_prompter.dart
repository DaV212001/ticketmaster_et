import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/prefs/routes.dart';

import '../prefs/error_card.dart';
import '../prefs/error_data.dart';

class LoginPrompter extends StatelessWidget {
  const LoginPrompter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ErrorCard(
                errorData: ErrorData(
                    title: 'Login required',
                    body: 'You need to log in to use this feature',
                    image: 'assets/images/errors/not_verified.svg',
                    buttonText: 'Login to continue'),
                refresh: () => Get.toNamed(Routes.loginRoute),
              ),
            )
          ],
        ),
      ),
    );
  }
}
