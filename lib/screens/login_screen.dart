import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

import '../database/database_helper.dart';
import '../database/auth_storage.dart';
import '../models/user.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkText = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color backgroundColor = Color(0xFFF5F7FB);

  // Hashing Pass
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Login
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      final hashedPassword = _hashPassword(password);

      final user = await DatabaseHelper.instance.getUser(username);

      if (user != null && user.passwordHash == hashedPassword) {
        // Login berhasil
        final authStorage = AuthStorage();

        // Simpan session
        final sessionToken =
            "token_${user.username}_${DateTime.now().millisecondsSinceEpoch}";

        await authStorage.saveSession(sessionToken);

        // Simpan username untuk dashboard greeting
        await authStorage.saveLastUser(user.username);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login berhasil!'),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DashboardScreen(),
            ),
          );
        }
      } else {
        // Logil gagal
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Username atau password salah!'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Register akun demo
  Future<void> _registerForDemo() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final hashedPassword = _hashPassword(password);

    try {
      await DatabaseHelper.instance.insertUser(
        User(
          username: username,
          passwordHash: hashedPassword,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'User berhasil didaftarkan. Silakan login.',
            ),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username sudah ada!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: Stack(
        children: [
          // Dekorasi BG
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -120,
            left: -90,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF60A5FA)
                    .withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Konten Login
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),

                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 430,
                  ),

                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),

                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E293B)
                              .withOpacity(0.05),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Form(
                      key: _formKey,

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.stretch,

                        children: [
                          // Logo
                          Center(
                            child: Container(
                              width: 70,
                              height: 70,

                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2563EB),
                                    Color(0xFF60A5FA),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),

                                borderRadius:
                                BorderRadius.circular(20),
                              ),

                              child: const Icon(
                                Icons.map_rounded,
                                size: 38,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Nama Aplikasi
                          const Text(
                            'SiKunjung',
                            textAlign: TextAlign.center,

                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: darkText,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            'Sistem Informasi Kunjungan Lapangan',
                            textAlign: TextAlign.center,

                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryText,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Header
                          const Text(
                            'Selamat Datang!',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                            ),
                          ),

                          const SizedBox(height: 7),

                          const Text(
                            'Masuk ke akun Anda untuk melanjutkan '
                            ,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: secondaryText,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // Username
                          const Text(
                            'Username',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: darkText,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Kolom username
                          TextFormField(
                            controller: _usernameController,
                            enabled: !_isLoading,
                            autocorrect: false,
                            textCapitalization:
                            TextCapitalization.none,
                            textInputAction: TextInputAction.next,

                            decoration: InputDecoration(
                              hintText: 'Masukkan username',

                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                              ),

                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),

                              contentPadding:
                              const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),

                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: primaryBlue,
                                  width: 1.5,
                                ),
                              ),
                            ),

                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Username tidak boleh kosong';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Pass
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: darkText,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Kolom Pass
                          TextFormField(
                            controller: _passwordController,
                            enabled: !_isLoading,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,

                            onFieldSubmitted: (_) {
                              if (!_isLoading) _login();
                            },

                            decoration: InputDecoration(
                              hintText: 'Masukkan password',

                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),

                              suffixIcon: IconButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                  setState(() {
                                    _obscurePassword =
                                    !_obscurePassword;
                                  });
                                },

                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),

                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),

                              contentPadding:
                              const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),

                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: primaryBlue,
                                  width: 1.5,
                                ),
                              ),
                            ),

                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }

                              if (value.length < 4) {
                                return 'Password minimal 4 karakter';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 28),

                          // Tombol Login
                          SizedBox(
                            height: 52,

                            child: ElevatedButton(
                              onPressed:
                              _isLoading ? null : _login,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,

                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(14),
                                ),
                              ),

                              child: _isLoading
                                  ? const SizedBox(
                                width: 21,
                                height: 21,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                                  : const Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'MASUK',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                      FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),

                                  SizedBox(width: 10),

                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 19,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Pemisah
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade200,
                                ),
                              ),

                              Padding(
                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'ATAU',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Tombol akun demo
                          TextButton.icon(
                            onPressed: _isLoading
                                ? null
                                : _registerForDemo,

                            icon: const Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 18,
                            ),

                            label: const Text(
                              'Buat Akun (Demo)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            style: TextButton.styleFrom(
                              foregroundColor: primaryBlue,
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Footer
                          const Text(
                            'SiKunjung • Sistem Informasi Kunjungan Lapangan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
