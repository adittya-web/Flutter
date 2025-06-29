import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      print('Services loaded: $services');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memuat layanan')));
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
      setState(() {
        pickupDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> submitBooking() async {
    if (selectedServiceId == null ||
        weightController.text.isEmpty ||
        pickupDateController.text.isEmpty ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field wajib diisi')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Booking berhasil dikirim')));
      weightController.clear();
      pickupDateController.clear();
      addressController.clear();
      setState(() {
        selectedServiceId = null;
      });
    } else {
      final data = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: ${data['message'] ?? 'Terjadi kesalahan'}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            services.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                  value: selectedServiceId,
                  decoration: const InputDecoration(labelText: 'Pilih Layanan'),
                  isExpanded: true,
                  hint: const Text('-- Pilih Layanan --'),
                  items:
                      services
                          .where((s) => s['id'] != null && s['nama'] != null)
                          .map<DropdownMenuItem<String>>((service) {
                            return DropdownMenuItem<String>(
                              value: service['id'].toString(),
                              child: Text(service['nama']),
                            );
                          })
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedServiceId = value!;
                    });
                  },
                ),
            const SizedBox(height: 12),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(labelText: 'Berat (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: pickupDateController,
              decoration: const InputDecoration(labelText: 'Tanggal Jemput'),
              readOnly: true,
              onTap: selectDate,
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Alamat Penjemputan',
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: submitBooking,
                  child: const Text('Kirim Booking'),
                ),
          ],
        ),
      ),
    );
  }
}
