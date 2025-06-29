import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_auth_service.dart';
import 'loading_success_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool isLoading = false;
  bool isGoogleLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    final url = Uri.parse("http://172.20.10.5/kelompok_mobile/public/api/login");

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          'email': emailController.text,
          'password': passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final user = data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user', jsonEncode(user));

        if (!mounted) return;
        _navigateToLoadingScreen(user);
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      _showErrorDialog();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> loginWithGoogle() async {
    setState(() => isGoogleLoading = true);
    try {
      final userCredential = await _authService.signInWithGoogle();
      final user = userCredential?.user;
      if (user == null) return;

      final userData = {
        'name': user.displayName,
        'email': user.email,
        'avatar': user.photoURL ?? '',
        'provider': 'google'
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', 'GOOGLE_FIREBASE_TOKEN');
      await prefs.setString('user', jsonEncode(userData));

      if (!mounted) return;
      _navigateToLoadingScreen(userData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal login dengan Google')),
        );
      }
    } finally {
      if (mounted) setState(() => isGoogleLoading = false);
    }
  }

  void _navigateToLoadingScreen(dynamic user) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LoadingSuccessScreen(user: user),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Login Gagal"),
        content: const Text("Email atau password salah."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // pastikan true
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.local_laundry_service, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                Text(
                  'Laundry App',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Masuk ke akun Anda',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login"),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: isGoogleLoading ? null : loginWithGoogle,
                  icon: isGoogleLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Image.asset('assets/google.png', height: 24),
                  label: Text(
                    isGoogleLoading ? 'Masuk...' : 'Login dengan Google',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                // Tambahkan SizedBox bawah supaya ada spasi bawah scroll
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
