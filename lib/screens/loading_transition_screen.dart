import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingTransitionScreen extends StatefulWidget {
  final Widget targetPage;
  final String animationAsset;

  const LoadingTransitionScreen({
    Key? key,
    required this.targetPage,
    this.animationAsset = 'assets/lottie/Animation - 1751188217430.json',
  }) : super(key: key);

  @override
  State<LoadingTransitionScreen> createState() => _LoadingTransitionScreenState();
}

class _LoadingTransitionScreenState extends State<LoadingTransitionScreen> {
  @override
  void initState() {
    super.initState();
    _goToTarget();
  }

  Future<void> _goToTarget() async {
    await Future.delayed(const Duration(seconds: 3)); // 3 detik loading
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => widget.targetPage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          widget.animationAsset,
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
