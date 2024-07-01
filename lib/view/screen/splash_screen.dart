import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:chit_chat/view/screen/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen(
      splashScreenBody: Center(
        child: Lottie.asset(
          'assets/animated_mobile_chating.json',
          width: MediaQuery.of(context).size.width * 0.4,
          fit: BoxFit.cover,
        ),
      ),
      backgroundColor: Colors.white,
      nextScreen: const AuthPage(),
    );
  }
}
