import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:tugaskelompok/screens/home_screen.dart';
import 'package:lottie/lottie.dart';

class PaymentPage extends StatefulWidget {
  final int bookingId;

  const PaymentPage({super.key, required this.bookingId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  File? _image;
  bool isLoading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada gambar yang dipilih')),
      );
    }
  }

  Future<void> uploadPayment() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login ulang')),
      );
      return;
    }

    try {
      final uri = Uri.parse('http://172.20.10.5:8000/api/payments');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['booking_id'] = widget.bookingId.toString();

      if (_image != null) {
        final mimeType = lookupMimeType(_image!.path)!.split('/');
        final file = await http.MultipartFile.fromPath(
          'proof_image',
          _image!.path,
          contentType: MediaType(mimeType[0], mimeType[1]),
        );
        request.files.add(file);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      setState(() => isLoading = false);

      if (response.statusCode == 201) {
        // Tampilkan animasi Lottie fullscreen
        Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          barrierDismissible: false,
          pageBuilder: (_, __, ___) => const FullscreenLottieScreen(),
        ));

        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        Navigator.of(context).pop(); // tutup layar animasi

        final userString = prefs.getString('user');
        final user = userString != null ? jsonDecode(userString) : {};

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload: $responseBody')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kesalahan: $e')),
      );
    }
  }

  Future<void> navigateBackWithAnimation() async {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (_, __, ___) => const FullscreenLottieScreen(),
    ));

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pop(); // tutup layar animasi
      Navigator.of(context).pop(); // kembali ke halaman sebelumnya
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await navigateBackWithAnimation();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Upload Pembayaran'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: navigateBackWithAnimation,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _image != null
                  ? Image.file(_image!, height: 200)
                  : const Text('Belum ada gambar'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: pickImage,
                child: const Text('Pilih Gambar'),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: uploadPayment,
                      child: const Text('Kirim Pembayaran'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullscreenLottieScreen extends StatelessWidget {
  const FullscreenLottieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/lottie/Animation - 1751188217430.json',
          width: 200,
          height: 200,
          repeat: false,
        ),
      ),
    );
  }
}
