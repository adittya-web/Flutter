import 'package:flutter/material.dart';

class BookingCard extends StatelessWidget {
  final String serviceName;
  final String status;
  final String date; // ✅ Tambahkan parameter date
  final VoidCallback onTrack;

  const BookingCard({
    super.key,
    required this.serviceName,
    required this.status,
    required this.date, // ✅ Tambahkan ke constructor
    required this.onTrack,
  });

  Icon _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'proses':
        return const Icon(Icons.sync, color: Colors.orange);
      case 'selesai':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'batal':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.info, color: Colors.grey);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'proses':
        return Colors.orange.shade100;
      case 'selesai':
        return Colors.green.shade100;
      case 'batal':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _statusColor(status),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: _statusIcon(status),
        ),
        title: Text(
          serviceName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $status'),
            Text('Tanggal: $date'), // ✅ Tampilkan tanggal di subtitle
          ],
        ),
        trailing: ElevatedButton.icon(
          onPressed: onTrack,
          icon: const Icon(Icons.location_on, size: 16),
          label: const Text('Lacak'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
