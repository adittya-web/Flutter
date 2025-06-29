import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'payment_page.dart';

class TrackingPage extends StatefulWidget {
  final int bookingId;

  const TrackingPage({super.key, required this.bookingId});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  String status = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStatus();
  }

  Future<void> fetchStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(
        'http://172.20.10.5/kelompok_mobile/public/api/bookings/${widget.bookingId}',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        status = data['data']['status'];
        isLoading = false;
      });
    } else {
      setState(() {
        status = 'Gagal mengambil status';
        isLoading = false;
      });
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

  Future<void> navigateToPaymentWithAnimation() async {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (_, __, ___) => const FullscreenLottieScreen(),
    ));

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pop(); // tutup layar animasi
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentPage(bookingId: widget.bookingId),
        ),
      );
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
          title: const Text('Pelacakan Booking'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: navigateBackWithAnimation,
          ),
        ),
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Status: $status',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    if (status == "Pending" || status == "Menunggu Konfirmasi")
                      ElevatedButton(
                        onPressed: navigateToPaymentWithAnimation,
                        child: const Text('Upload Bukti Pembayaran'),
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
