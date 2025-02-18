import 'package:bio_signal/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_splash/flutter_animated_splash.dart';

class FlashScreen extends StatelessWidget {
  const FlashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplash(
      type: Transition.rightToLeftWithFade,
      navigator: HomeScreen(),
      curve: Curves.easeInOut,
      durationInSeconds: 2,
      child: Image.asset("assets/img/logo-no-bg.png"),
    );
  }
}
