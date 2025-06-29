import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart';

class LoadingSuccessScreen extends StatefulWidget {
  final dynamic user;

  const LoadingSuccessScreen({super.key, required this.user});

  @override
  State<LoadingSuccessScreen> createState() => _LoadingSuccessScreenState();
}

class _LoadingSuccessScreenState extends State<LoadingSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
  context,
  PageRouteBuilder(
    pageBuilder: (_, __, ___) => HomeScreen(
      user: widget.user ?? {
        'name': 'Pengguna',
        'email': 'email@example.com',
        'avatar': null,
      },
    ),
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
);

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/lottie/Animation - 1751188217430.json',
          width: 200,
          repeat: false,
          onLoaded: (composition) {
            debugPrint('Animation Loaded: Duration - \${composition.duration}');
          },
        ),
      ),
    );
  }
}