import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Aplikasi Laundry ini dibuat untuk memudahkan pengguna dalam melakukan booking dan melihat riwayat layanan laundry.\n\nVersi: 1.0.0\nDikembangkan oleh: Tim LaundryApp',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
