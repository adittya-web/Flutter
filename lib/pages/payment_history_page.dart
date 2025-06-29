import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  List payments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://172.20.10.5/kelompok_mobile/public/api/payments'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        payments = data['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat riwayat pembayaran')),
      );
    }
  }

  Future<void> navigateBackWithAnimation() async {
    // Tampilkan layar putih fullscreen dengan animasi Lottie
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: navigateBackWithAnimation,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: payment['proof_image_url'] != null
                        ? SizedBox(
                            width: 60,
                            height: 60,
                            child: Image.network(
                              payment['proof_image_url'],
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.image_not_supported),
                    title: Text('Metode: ${payment['payment_method']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${payment['payment_status']}'),
                        Text('Tanggal: ${payment['paid_at'] ?? 'Belum dibayar'}'),
                      ],
                    ),
                  ),
                );
              },
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
