import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
        'http://192.168.24.88/admin_app/public/api/bookings/${widget.bookingId}',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept':
            'application/json', // sangat penting agar Laravel kembalikan JSON
      },
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pelacakan Booking')),
      body: Center(
        child:
            isLoading
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      PaymentPage(bookingId: widget.bookingId),
                            ),
                          );
                        },
                        child: const Text('Upload Bukti Pembayaran'),
                      ),
                  ],
                ),
      ),
    );
  }
}
