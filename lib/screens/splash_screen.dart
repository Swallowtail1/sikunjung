
import 'package:flutter/material.dart';

import '../database/auth_storage.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  static const Color primaryBlue = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // CHECK SESSION AND NAVIGATE
  Future<void> _initializeApp() async {
    final stopwatch = Stopwatch()..start();

    String? sessionToken;

    try {
      final authStorage = AuthStorage();
      sessionToken = await authStorage.getSession();
    } catch (e) {
      sessionToken = null;
    }

    // Minimal display duration: 2 seconds
    final remaining =
        const Duration(seconds: 2) - stopwatch.elapsed;

    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (!mounted) return;

    // Determine initial screen
    final Widget nextScreen =
    sessionToken != null && sessionToken.isNotEmpty
        ? const DashboardScreen()
        : const LoginScreen();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => nextScreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        width: double.infinity,
        height: double.infinity,

        // RESTORE BLUE GRADIENT BACKGROUND
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1D4ED8),
              Color(0xFF2563EB),
              Color(0xFF60A5FA),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Stack(
          children: [

            // BACKGROUND DECORATION
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              bottom: -120,
              left: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // CENTERED MAIN CONTENT
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),

                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 420,
                    ),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [

                        // APP LOGO
                        Container(
                          width: 105,
                          height: 105,

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),

                          child: const Icon(
                            Icons.map_rounded,
                            size: 55,
                            color: Color(0xFF2563EB),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // APP NAME
                        const Text(
                          'SiKunjung',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // APP DESCRIPTION
                        const Text(
                          'Sistem Informasi Kunjungan Lapangan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            letterSpacing: 0.3,
                          ),
                        ),

                        const SizedBox(height: 45),

                        // LOADING INDICATOR
                        const SizedBox(
                          width: 27,
                          height: 27,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Menyiapkan aplikasi...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // FOOTER
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,

              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 16,
                    right: 16,
                  ),

                  child: const Text(
                    'SiKunjung • Version 1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white60,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
