import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FullscreenLottieScreen extends StatelessWidget {
  const FullscreenLottieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/lottie/Animation - 1751188217430.json', // Ganti dengan nama file animasi kamu
          width: 200,
          height: 200,
          repeat: false,
        ),
      ),
    );
  }
}
