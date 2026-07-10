import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/api_constants.dart';

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

  void _submitOrder() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Alamat wajib diisi")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/create_order.php'),
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
      if (data['success']) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pesanan berhasil dibuat!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Form Pemesanan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(widget.package['package_name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: _addressController, maxLines: 3, decoration: const InputDecoration(labelText: "Alamat", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            // ... (sisa UI form tetap sama)
            ElevatedButton(onPressed: _submitOrder, child: const Text("KONFIRMASI PESANAN")),
          ],
        ),
      ),
    );
  }
}
