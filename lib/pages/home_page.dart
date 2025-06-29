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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff4E73DF), Color(0xffa4b0ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar & Welcome
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Icon(Icons.local_laundry_service, size: 40, color: Color(0xff4E73DF)),
            ),
            const SizedBox(height: 16),
            Text(
              'Hai, ${user['name']}!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selamat datang di Aplikasi Laundry',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 30),

            // Menu Cards
            Expanded(
              child: ListView(
                children: [
                  MenuButton(
                    title: 'Tambah Booking',
                    icon: Icons.add_box,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BookingPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  MenuButton(
                    title: 'Lihat Riwayat Booking',
                    icon: Icons.history,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BookingListPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  MenuButton(
                    title: 'Riwayat Pembayaran',
                    icon: Icons.payment,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaymentHistoryPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 28, color: Color(0xff4E73DF)),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
