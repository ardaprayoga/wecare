import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/api_constants.dart';

import 'review_page.dart';

class OrderHistoryPage extends StatefulWidget {
  final int userId;
  const OrderHistoryPage({super.key, required this.userId});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  Future<List<dynamic>> _getHistory() async {
    final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/get_customer_orders.php?customer_id=${widget.userId}'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    }
    throw Exception("Gagal memuat riwayat");
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'on_way': return Colors.teal;
      case 'in_progress': return Colors.indigo;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Pesanan Saya")),
      body: FutureBuilder<List<dynamic>>(
        future: _getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) return const Center(child: Text("Belum ada riwayat pesanan."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(order['package_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order['status']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: _getStatusColor(order['status'])),
                            ),
                            child: Text(
                              order['status'].toString().toUpperCase(),
                              style: TextStyle(color: _getStatusColor(order['status']), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Tanggal: ${order['service_date']} | ${order['service_time']}"),
                      Text("Total: Rp ${order['total_price']}"),
                      const Divider(),
                      if (order['mitra_name'] != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text("Mitra: ${order['mitra_name']}"),
                          ],
                        ),
                        Text("Telp: ${order['mitra_phone']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ] else ...[
                        const Text("Status: Mencari mitra...", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.orange)),
                      ],
                      if (order['status'] == 'completed') ...[
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ReviewPage(order: order)),
                            );
                          },
                          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 35)),
                          child: const Text("BERI ULASAN"),
                        )
                      ]
                    ],
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
