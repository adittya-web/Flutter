import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class PaymentPage extends StatefulWidget {
  final int bookingId;

  const PaymentPage({super.key, required this.bookingId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  File? _image;
  bool isLoading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadPayment() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gambar terlebih dahulu')),
      );
      return;
    }

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.24.88/admin_app/public/api/payments'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['booking_id'] = widget.bookingId.toString();
    request.fields['payment_method'] = 'Transfer';

    final mimeType = lookupMimeType(_image!.path)?.split('/');
    final mediaType =
        mimeType != null
            ? MediaType(mimeType[0], mimeType[1])
            : MediaType('image', 'jpeg');

    request.files.add(
      await http.MultipartFile.fromPath(
        'proof_image',
        _image!.path,
        contentType: mediaType,
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    setState(() => isLoading = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bukti pembayaran berhasil diupload')),
      );
      Navigator.pop(context); // kembali setelah sukses
    } else {
      print('Status code: ${response.statusCode}');
      print('Response body: $responseBody');
      print(request.fields);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload bukti pembayaran: $responseBody')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Bukti Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : const Text('Belum ada gambar'),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text('Pilih Gambar'),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: uploadPayment,
                  child: const Text('Kirim Bukti Pembayaran'),
                ),
          ],
        ),
      ),
    );
  }
}
