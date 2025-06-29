import 'package:flutter/material.dart';
import '../pages/booking_page.dart';
import '../pages/booking_list_page.dart';
import '../pages/payment_history_page.dart';
import '../pages/tracking_page.dart' as tracking_page;
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../screens/loading_transition_screen.dart'; // <== Tambahkan ini
import 'auth_wrapper.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic>? user;

  HomeScreen({Key? key, this.user}) : super(key: key);

  final FirebaseAuthService _authService = FirebaseAuthService();

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Keluar'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _authService.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => AuthWrapper()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget targetPage,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                LoadingTransitionScreen(targetPage: targetPage), // <== arahkan ke screen loading
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? firebaseUser = _authService.getCurrentUser();

    final String displayName = user?['name'] ?? firebaseUser?.displayName ?? 'Pengguna';
    final String email = user?['email'] ?? firebaseUser?.email ?? 'email@example.com';
    final String? photoUrl = user?['avatar'] ?? firebaseUser?.photoURL;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laundry Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null
                        ? const Icon(Icons.person, size: 40, color: Colors.blue)
                        : null,
                    backgroundColor: Colors.blue.shade100,
                  ),
                  const SizedBox(height: 16),
                  Text(displayName,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(email,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Menu Laundry',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  icon: Icons.local_laundry_service,
                  title: 'Booking',
                  subtitle: 'Buat pesanan laundry',
                  targetPage: const BookingPage(),
                  context: context,
                ),
                _buildMenuCard(
                  icon: Icons.schedule,
                  title: 'Riwayat Booking',
                  subtitle: 'Lihat riwayat pesanan',
                  targetPage: const BookingListPage(),
                  context: context,
                ),
                _buildMenuCard(
                  icon: Icons.payment,
                  title: 'Riwayat Pembayaran',
                  subtitle: 'Lihat pembayaran Anda',
                  targetPage: const PaymentHistoryPage(),
                  context: context,
                ),
                _buildMenuCard(
                  icon: Icons.track_changes,
                  title: 'Lacak Pesanan',
                  subtitle: 'Lihat status pesanan',
                  targetPage: const tracking_page.TrackingPage(bookingId: 1),
                  context: context,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
