import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ticketmaster_et/screens/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var imageUrls = [
    "assets/images/splash_screens/food-04.png",
    "assets/images/splash_screens/food-03.png",
    "assets/images/splash_screens/food-02.png",
  ];
  int currentIndex = 0;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      setState(() {
        if (currentIndex < imageUrls.length - 1) {
          currentIndex++;
        } else {
          timer.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        child: FadeTransition(
          key: ValueKey<int>(currentIndex),
          opacity: const AlwaysStoppedAnimation<double>(1.0),
          child: Image.asset(
            imageUrls[currentIndex],
            key: ValueKey<int>(currentIndex),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
