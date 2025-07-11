import 'package:flutter/material.dart';
import '../pages/booking_page.dart';
import '../pages/booking_list_page.dart';
import '../pages/payment_history_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import 'auth_wrapper.dart';
import '../screens/loading_transition_screen.dart';
import '../screens/setting_screen.dart';
import '../screens/about_screen.dart';
import '../screens/help_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const HomeScreen({Key? key, this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final FirebaseAuthService _authService = FirebaseAuthService();
  int _selectedIndex = 0;

  late AnimationController _controller1;
  late Animation<Offset> _offset1;
  late Animation<double> _fade1;

  late AnimationController _controller2;
  late Animation<Offset> _offset2;
  late Animation<double> _fade2;

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _offset1 = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller1, curve: Curves.easeOut));
    _fade1 = Tween<double>(begin: 0.0, end: 1.0).animate(_controller1);

    _controller2 = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _offset2 = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller2, curve: Curves.easeOut));
    _fade2 = Tween<double>(begin: 0.0, end: 1.0).animate(_controller2);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        _controller1.forward(from: 0.0);
        Future.delayed(const Duration(milliseconds: 200), () {
          _controller2.forward(from: 0.0);
        });
      }
    });
  }

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

  Widget _buildAnimatedCard({
    required Animation<Offset> slide,
    required Animation<double> fade,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: slide,
      builder: (context, child) {
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
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
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? firebaseUser = _authService.getCurrentUser();
    final String displayName = widget.user?['name'] ?? firebaseUser?.displayName ?? 'Pengguna';
    final String email = widget.user?['email'] ?? firebaseUser?.email ?? 'email@example.com';
    final String? photoUrl = widget.user?['avatar'] ?? firebaseUser?.photoURL;

    final List<Widget> _pages = [
      HomeTabScreen(displayName: displayName),
      const BookingPage(),
      SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riwayat',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAnimatedCard(
              slide: _offset1,
              fade: _fade1,
              icon: Icons.schedule,
              title: 'Riwayat Booking',
              subtitle: 'Lihat riwayat pesanan Anda',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoadingTransitionScreen(
                      targetPage: const BookingListPage(),
                    ),
                  ),
                );
              },
            ),
            _buildAnimatedCard(
              slide: _offset2,
              fade: _fade2,
              icon: Icons.payment,
              title: 'Riwayat Pembayaran',
              subtitle: 'Lihat histori pembayaran',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoadingTransitionScreen(
                      targetPage: const PaymentHistoryPage(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // PROFIL
      SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 50,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null ? const Icon(Icons.person, size: 50, color: Colors.blue) : null,
              backgroundColor: Colors.blue.shade100,
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    ProfileStat(title: "Booking", value: "8"),
                    ProfileStat(title: "Pembayaran", value: "5"),
                    ProfileStat(title: "Ulasan", value: "3"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Tentang Aplikasi'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Bantuan'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpScreen()),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laundry App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'BERANDA'),
          BottomNavigationBarItem(icon: Icon(Icons.local_laundry_service), label: 'BOOKING'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'RIWAYAT'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFIL'),
        ],
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final String title;
  final String value;

  const ProfileStat({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

class HomeTabScreen extends StatelessWidget {
  final String displayName;

  const HomeTabScreen({Key? key, required this.displayName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang, $displayName!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/banner.jpg',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Layanan Kami',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _menuCard(Icons.local_laundry_service, 'Cuci Kering'),
              _menuCard(Icons.water_damage_outlined, 'Cuci Basah'),
              _menuCard(Icons.iron, 'Setrika'),
              _menuCard(Icons.cleaning_services, 'Dry Clean'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuCard(IconData icon, String label) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: Colors.blue),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
