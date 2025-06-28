import 'package:flutter/material.dart';
import 'booking_page.dart';
import 'booking_list_page.dart';
import 'tracking_page.dart';
import 'payment_history_page.dart';

class HomePage extends StatelessWidget {
  final Map user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Selamat datang, ${user['name']}!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingPage()),
                );
              },
              child: const Text("Tambah Booking"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingListPage()),
                );
              },
              child: const Text("Lihat Riwayat Booking"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentHistoryPage()),
                );
              },
              child: const Text('Riwayat Pembayaran'),
            ),
          ],
        ),
      ),
    );
  }
}
