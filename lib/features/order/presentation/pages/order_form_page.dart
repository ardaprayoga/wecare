import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderFormPage extends StatefulWidget {
  final Map<String, dynamic> package;
  final int userId;

  const OrderFormPage({super.key, required this.package, required this.userId});

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _paymentMethod = 'cash';
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitOrder() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alamat wajib diisi")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/mycare_api/create_order.php'),
        body: {
          'customer_id': widget.userId.toString(),
          'package_id': widget.package['id'].toString(),
          'address': _addressController.text,
          'service_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
          'service_time': '${_selectedTime.hour}:${_selectedTime.minute}:00',
          'total_price': widget.package['base_price'].toString(),
          'payment_method': _paymentMethod,
          'additional_notes': _notesController.text,
        },
      );

      final data = json.decode(response.body);

      if (!mounted) return;

      if (data['success']) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Berhasil"),
            content: const Text("Pesanan Anda telah berhasil dibuat. Silakan tunggu konfirmasi dari mitra."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to Home
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membuat pesanan: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Form Pemesanan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.package['package_name'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Estimasi Harga: Rp ${widget.package['base_price']}"),
            const Divider(height: 32),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Alamat Lengkap",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text("Tanggal Layanan"),
              subtitle: Text(DateFormat('EEEE, d MMMM yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text("Jam Layanan"),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(
                labelText: "Metode Pembayaran",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text("Tunai (Cash)")),
                DropdownMenuItem(value: 'transfer', child: Text("Transfer Bank")),
                DropdownMenuItem(value: 'ewallet', child: Text("E-Wallet")),
              ],
              onChanged: (val) => setState(() => _paymentMethod = val!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: "Catatan Tambahan (Opsional)",
                border: OutlineInputBorder(),
                hintText: "Contoh: Ada kucing, bawa tangga, dll.",
              ),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitOrder,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("KONFIRMASI PESANAN"),
                  ),
          ],
        ),
      ),
    );
  }
}
