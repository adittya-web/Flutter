import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'loading_success_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Pendaftaran Gagal"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  Future<void> _proceedWithRegister() async {
    final url = Uri.parse(
      "http://10.234.134.244/kelompok_mobile/public/api/users",
    );

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          'name': nameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'password_confirmation': confirmPasswordController.text,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final user = data['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(user));

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoadingSuccessScreen(user: user)),
        );
      } else if (response.statusCode == 422) {
        final errorMsg =
            data['errors']?.values.first?.first ??
            data['message'] ??
            'Validasi gagal.';
        _showErrorDialog(errorMsg);
      } else {
        _showErrorDialog('Gagal mendaftar. ${data['message'] ?? ''}');
      }
    } catch (e) {
      _showErrorDialog("Kesalahan jaringan: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _startSignupFlow() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showErrorDialog("Semua field wajib diisi.");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showErrorDialog("Password dan konfirmasi tidak cocok.");
      return;
    }

    setState(() => isLoading = true);

    await _proceedWithRegister();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Akun")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _startSignupFlow,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Daftar"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Sudah punya akun? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
