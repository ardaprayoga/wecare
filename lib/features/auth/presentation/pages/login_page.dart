import 'package:flutter/material.dart';

import 'home_navigator.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_reposiitory_impl.dart';

import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Inisialisasi repository (Idealnya menggunakan GetIt/Dependency Injection)
  final _authRepo = AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSource());

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password tidak boleh kosong")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil repository untuk login
      final user = await _authRepo.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      // Navigasi berdasarkan role
      Widget nextPage;
      switch (user.role) {
        case 'admin':
          nextPage = const AdminDashboardPage();
          break;
        case 'mitra':
          nextPage = MitraDashboardPage(user: user);
          break;
        case 'pelanggan':
        default:
          nextPage = CustomerHomePage(user: user);
          break;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome to We Care",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text("Silakan login untuk memesan jasa kebersihan"),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text("LOGIN"),
                  ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text("Belum punya akun? Daftar sekarang"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
