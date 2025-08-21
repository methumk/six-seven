import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/pages/home/home_screen.dart';

// Splash Screen for logo
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlameSplashScreen(
        theme: FlameSplashTheme.dark,
        showBefore: (BuildContext context) {
          return Text("Before the logo");
        },
        showAfter: (BuildContext context) {
          return Text("After the logo");
        },
        onFinish: (context) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreenContainer()),
          );
        },
      ),
    );
  }
}
