import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import '../../../../screens/home_screen.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final weightController = TextEditingController();
  final pickupDateController = TextEditingController();
  final addressController = TextEditingController();

  List services = [];
  String? selectedServiceId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    final response = await http.get(
      Uri.parse('http://172.20.10.5/kelompok_mobile/public/api/services'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        services = data['data'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat layanan')),
      );
    }
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      pickupDateController.text = picked.toIso8601String().split('T')[0];
    }
  }

  Future<void> navigateBackWithAnimation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const FullscreenLottieScreen(),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pop(); // tutup dialog
      Navigator.of(context).pop(); // kembali
    }
  }

  Future<void> submitBooking() async {
    if (selectedServiceId == null ||
        weightController.text.isEmpty ||
        pickupDateController.text.isEmpty ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('http://172.20.10.5/kelompok_mobile/public/api/bookings'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'service_id': selectedServiceId,
        'weight': weightController.text,
        'pickup_date': pickupDateController.text,
        'address': addressController.text,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 201) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const FullscreenLottieScreen(),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } else {
      final data = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${data['message'] ?? 'Terjadi kesalahan'}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Booking Laundry'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: navigateBackWithAnimation,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              'Isi detail booking Anda di bawah ini:',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            services.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: selectedServiceId,
                    decoration: InputDecoration(
                      labelText: 'Pilih Layanan',
                      prefixIcon: const Icon(Icons.local_laundry_service),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    isExpanded: true,
                    items: services
                        .where((s) => s['id'] != null && s['nama'] != null)
                        .map<DropdownMenuItem<String>>((service) {
                      return DropdownMenuItem<String>(
                        value: service['id'].toString(),
                        child: Text(service['nama']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedServiceId = value;
                      });
                    },
                  ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              decoration: InputDecoration(
                labelText: 'Berat Cucian (kg)',
                prefixIcon: const Icon(Icons.monitor_weight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pickupDateController,
              decoration: InputDecoration(
                labelText: 'Tanggal Penjemputan',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              readOnly: true,
              onTap: selectDate,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Alamat Penjemputan',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: submitBooking,
                    icon: const Icon(Icons.send),
                    label: const Text('Kirim Booking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
          ],
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
