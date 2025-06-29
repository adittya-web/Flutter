import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'tracking_page.dart';
import '../screens/loading_transition_screen.dart';

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  List bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('http://172.20.10.5/kelompok_mobile/public/api/bookings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          bookings = data['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat data booking');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Booking'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LoadingTransitionScreen(
                  targetPage: const BackToPreviousScreen(),
                  animationAsset: 'assets/lottie/Animation - 1751188217430.json',
                ),
              ),
            );
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? const Center(child: Text('Belum ada data booking.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final serviceName = booking['service']['nama'] ?? '-';
                    final status = booking['status'] ?? '-';
                    final date = booking['created_at']?.toString().substring(0, 10) ?? '-';

                    return BookingCard(
                      serviceName: serviceName,
                      status: status,
                      date: date,
                      onTrack: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoadingTransitionScreen(
                              targetPage: TrackingPage(bookingId: booking['id']),
                              animationAsset: 'assets/lottie/Animation - 1751188217430.json',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

// === BookingCard Widget ===
class BookingCard extends StatelessWidget {
  final String serviceName;
  final String status;
  final String date;
  final VoidCallback onTrack;

  const BookingCard({
    super.key,
    required this.serviceName,
    required this.status,
    required this.date,
    required this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Layanan: $serviceName',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Tanggal Booking: $date'),
            Text('Status: $status', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                onPressed: onTrack,
                icon: const Icon(Icons.track_changes),
                label: const Text('Lacak'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// === Widget untuk transisi kembali ===
class BackToPreviousScreen extends StatefulWidget {
  const BackToPreviousScreen({super.key});

  @override
  State<BackToPreviousScreen> createState() => _BackToPreviousScreenState();
}

class _BackToPreviousScreenState extends State<BackToPreviousScreen> {
  @override
  void initState() {
    super.initState();
    _delayedBack();
  }

  Future<void> _delayedBack() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Navigator.pop(context); // kembali ke halaman sebelumnya
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}