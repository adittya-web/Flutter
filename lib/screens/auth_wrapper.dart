import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'loading_success_screen.dart';

class AuthWrapper extends StatelessWidget {
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingSuccessScreen(user: null);
        }

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          return HomeScreen(user: {
            'name': user.displayName ?? 'Pengguna',
            'email': user.email ?? 'email@example.com',
            'avatar': user.photoURL,
          });
        }

        
        return const LoginScreen();
      },
    );
  }
}
