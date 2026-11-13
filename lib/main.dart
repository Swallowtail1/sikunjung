import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'database/auth_storage.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  // Wajib ditambahkan jika ada proses 'await' (async) sebelum runApp berjalan
  WidgetsFlutterBinding.ensureInitialized();

  // Mengecek apakah ada sesi login yang tersimpan
  final authStorage = AuthStorage();
  final String? sessionToken = await authStorage.getSession();

  // Menentukan halaman awal berdasarkan status sesi
  final Widget initialScreen = (sessionToken != null)
      ? const DashboardScreen() // Nanti diganti jadi DashboardScreen() jika sudah login
      : const LoginScreen();

  runApp(SiKunjungApp(initialScreen: initialScreen));
}

class SiKunjungApp extends StatelessWidget {
  final Widget initialScreen;

  const SiKunjungApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiKunjung',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: initialScreen,
    );
  }
}