import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Untuk bantuan penggunaan aplikasi:\n\n1. Klik menu Booking untuk memesan layanan laundry.\n2. Lihat riwayat di tab Riwayat.\n3. Untuk pertanyaan lain, hubungi kami di help@laundryapp.com',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
