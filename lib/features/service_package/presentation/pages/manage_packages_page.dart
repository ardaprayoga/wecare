import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManagePackagesPage extends StatefulWidget {
  const ManagePackagesPage({super.key});

  @override
  State<ManagePackagesPage> createState() => _ManagePackagesPageState();
}

class _ManagePackagesPageState extends State<ManagePackagesPage> {
  Future<List<dynamic>> _getPackages() async {
    final response = await http.get(Uri.parse('http://10.0.2.2/mycare_api/get_packages.php'));
    if (response.statusCode == 200) return json.decode(response.body)['data'];
    throw Exception("Gagal memuat paket");
  }

  void _showPackageForm([Map<String, dynamic>? package]) {
    final nameCtrl = TextEditingController(text: package?['package_name']);
    final descCtrl = TextEditingController(text: package?['description']);
    final priceCtrl = TextEditingController(text: package?['base_price']?.toString());
    final durCtrl = TextEditingController(text: package?['duration_minutes']?.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(package == null ? "Tambah Paket Baru" : "Edit Paket", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nama Paket", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Deskripsi", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Harga", border: OutlineInputBorder()))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: durCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Menit", border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final response = await http.post(
                  Uri.parse('http://10.0.2.2/mycare_api/upsert_package.php'),
                  body: {
                    if (package != null) 'id': package['id'].toString(),
                    'package_name': nameCtrl.text,
                    'description': descCtrl.text,
                    'base_price': priceCtrl.text,
                    'duration_minutes': durCtrl.text,
                  },
                );
                if (json.decode(response.body)['success']) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("SIMPAN PAKET"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Paket Layanan")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPackageForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _getPackages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final packages = snapshot.data ?? [];
          return ListView.builder(
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final pkg = packages[index];
              return ListTile(
                title: Text(pkg['package_name']),
                subtitle: Text("Rp ${pkg['base_price']} | ${pkg['duration_minutes']} Menit"),
                trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _showPackageForm(pkg)),
              );
            },
          );
        },
      ),
    );
  }
}
