
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const SiKunjungApp());
}

class SiKunjungApp extends StatelessWidget {
  const SiKunjungApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiKunjung',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),

      home: const SplashScreen(),
    );
  }
}
