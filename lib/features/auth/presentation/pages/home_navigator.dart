import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/api_constants.dart';

// Import fitur lain
import '../../../service_package/presentation/pages/manage_packages_page.dart';
import '../../../order/presentation/pages/order_history_page.dart';
import '../../../order/presentation/pages/order_form_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../domain/entities/user_entity.dart';

// ==========================================
// 1. ADMIN DASHBOARD
// ==========================================
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Future<Map<String, dynamic>> _getStats() async {
    final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/get_admin_stats.php'));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception("Gagal memuat statistik");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));

          final data = snapshot.data!;
          final userCounts = data['user_counts'] as Map;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Ringkasan Bisnis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard("Pesanan Selesai", "${data['total_orders']}", Colors.blue),
                    const SizedBox(width: 8),
                    _buildStatCard("Total Omzet", "Rp ${data['total_revenue']}", Colors.green),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ManagePackagesPage()));
                  },
                  icon: const Icon(Icons.settings_suggest),
                  label: const Text("KELOLA PAKET LAYANAN"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse('${ApiConstants.baseUrl}/export_orders.php');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text("UNDUH LAPORAN EXCEL (CSV)"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text("Pengguna Terdaftar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard("Pelanggan", "${userCounts['pelanggan'] ?? 0}", Colors.orange),
                    const SizedBox(width: 8),
                    _buildStatCard("Mitra", "${userCounts['mitra'] ?? 0}", Colors.teal),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(side: BorderSide(color: color), borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: color, fontSize: 12)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. MITRA DASHBOARD
// ==========================================
class MitraDashboardPage extends StatefulWidget {
  final UserEntity user;
  const MitraDashboardPage({super.key, required this.user});

  @override
  State<MitraDashboardPage> createState() => _MitraDashboardPageState();
}

class _MitraDashboardPageState extends State<MitraDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mitra Panel"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Tugas Baru", icon: Icon(Icons.assignment_outlined)),
            Tab(text: "Pekerjaan Aktif", icon: Icon(Icons.directions_run)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingList(),
          _buildActiveJobsList(),
        ],
      ),
    );
  }

  Widget _buildPendingList() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchData('get_pending_orders.php'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final orders = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              child: ListTile(
                title: Text(order['package_name']),
                subtitle: Text("${order['address']}\nJadwal: ${order['service_date']}"),
                trailing: ElevatedButton(
                  onPressed: () => _acceptOrder(order['id']), 
                  child: const Text("AMBIL")
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActiveJobsList() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchData('get_active_jobs.php?mitra_id=${widget.user.id}'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final orders = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              child: ListTile(
                title: Text(order['package_name']),
                subtitle: Text("Customer: ${order['customer_name']}\nStatus: ${order['status']}"),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _fetchData(String endpoint) async {
    final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/$endpoint'));
    return json.decode(res.body)['data'];
  }

  void _acceptOrder(dynamic id) async {
    await http.post(
      Uri.parse('${ApiConstants.baseUrl}/accept_order.php'), 
      body: {'order_id': id.toString(), 'mitra_id': widget.user.id.toString()}
    );
    setState(() {});
  }
}

// ==========================================
// 3. CUSTOMER HOME
// ==========================================
class CustomerHomePage extends StatefulWidget {
  final UserEntity user;
  const CustomerHomePage({super.key, required this.user});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Kita hapus Scaffold di dalam children untuk menghindari nested Scaffold
    final List<Widget> children = [
      _HomeTab(user: widget.user),
      OrderHistoryPage(userId: widget.user.id),
      ProfilePage(user: widget.user),
    ];

    return Scaffold(
      body: children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}

// Widget terpisah untuk isi tab Home agar kode tidak menumpuk
class _HomeTab extends StatelessWidget {
  final UserEntity user;
  const _HomeTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Halo, ${user.name}"),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: http.get(Uri.parse('${ApiConstants.baseUrl}/get_packages.php')).then((res) => json.decode(res.body)['data']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          
          final packages = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final pkg = packages[index];
              return Card(
                child: ListTile(
                  title: Text(pkg['package_name']),
                  subtitle: Text(pkg['description']),
                  trailing: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OrderFormPage(package: pkg, userId: user.id))),
                    child: const Text("Pesan"),
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
