import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/api_constants.dart';

class ReviewPage extends StatefulWidget {
  final Map<String, dynamic> order;
  const ReviewPage({super.key, required this.order});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  void _submitReview() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/add_review.php'),
        body: {
          'order_id': widget.order['id'].toString(),
          'customer_id': widget.order['customer_id'].toString(),
          'mitra_id': widget.order['mitra_id'].toString(),
          'rating': _rating.toString(),
          'comment': _commentController.text,
        },
      );
      final data = json.decode(response.body);
      if (data['success']) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        Navigator.pop(context); // Kembali ke riwayat
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Beri Ulasan")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text("Bagaimana layanan dari ${widget.order['mitra_name']}?", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(index < _rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 40),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Tulis ulasan Anda (Opsional)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitReview,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text("KIRIM ULASAN"),
                  ),
          ],
        ),
      ),
    );
  }
}
