// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth_wrapper.dart';
// import 'pages/login_page.dart'; // Comment ini dulu jika ingin pakai Firebase auth

void main() async {
  // PENTING: Panggil ini sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laundry App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // Gunakan AuthWrapper sebagai home untuk auto-detect auth state
      home: AuthWrapper(),

      // Optional: Jika ingin tetap pakai LoginPage existing
      // home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
