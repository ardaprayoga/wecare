import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
// import 'features/auth/presentation/pages/login_page.dart'; // Uncomment jika file sudah dibuat

import 'features/auth/presentation/pages/login_page.dart';

void main() {
  runApp(const MyCareApp());
}

class MyCareApp extends StatelessWidget {
  const MyCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'We Care',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}
