
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../database/database_helper.dart';
import '../database/auth_storage.dart';

import 'login_screen.dart';
import 'daftar_kunjungan_screen.dart';
import 'peta_kunjungan_screen.dart';
import 'sensor_network_screen.dart';
import 'info_perangkat_screen.dart';

import '../widgets/offline_banner.dart';
import '../widgets/menu_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  int _jumlahKunjungan = 0;
  bool _isOffline = false;
  String? _namaPengguna;

  late StreamSubscription<List<ConnectivityResult>>
  _connectivitySubscription;

  // INITIALIZATION
  @override
  void initState() {
    super.initState();

    _loadDataDashboard();
    _loadNamaPengguna();
    _initNetworkMonitoring();
  }

  // MENGAMBIL JUMLAH DATA KUNJUNGAN
  Future<void> _loadDataDashboard() async {
    final data =
    await DatabaseHelper.instance.getAllKunjungan();

    if (!mounted) return;

    setState(() {
      _jumlahKunjungan = data.length;
    });
  }

  // MENGAMBIL USERNAME
  Future<void> _loadNamaPengguna() async {
    final authStorage = AuthStorage();
    final nama = await authStorage.getLastUser();

    if (!mounted) return;

    setState(() {
      _namaPengguna = nama;
    });
  }

  // MONITORING JARINGAN
  void _initNetworkMonitoring() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(
              (List<ConnectivityResult> results) {
            if (!mounted) return;

            setState(() {
              _isOffline =
                  results.contains(ConnectivityResult.none);
            });
          },
        );
  }

  // DISPOSE
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // LOGOUT
  Future<void> _logout() async {
    final authStorage = AuthStorage();
    await authStorage.deleteSession();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {

    final String nama = _namaPengguna?.trim() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // APP BAR
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        scrolledUnderElevation: 0,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SiKunjung',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 21,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              'Sistem Informasi Kunjungan',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _logout,
              tooltip: 'Logout',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout_rounded),
            ),
          ),
        ],
      ),

      // BODY
      body: Column(
        children: [

          // OFFLINE BANNER
          OfflineBanner(isOffline: _isOffline),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDataDashboard,
              color: const Color(0xFF2563EB),

              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20, 20, 20, 28,
                ),

                children: [



// WELCOME + STATISTICS CARD
                  Container(
                    padding: const EdgeInsets.all(22),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2563EB),
                          Color(0xFF3B82F6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),

                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // WELCOME GREETING
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nama.isEmpty
                                        ? 'Selamat Datang!'
                                        : 'Selamat Datang,',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    nama.isEmpty ? 'Di SiKunjung!' : '$nama!',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.25),
                        ),

                        const SizedBox(height: 7),


                        // STATISTICS HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL KUNJUNGAN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: Colors.white70,
                              ),
                            ),

                            const Icon(
                              Icons.assignment_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ],
                        ),

                        // TOTAL DATA
                        Text(
                          '$_jumlahKunjungan',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Data kunjungan lapangan tersimpan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),


                  // MENU HEADER
                  const Text(
                    'Menu Utama',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Akses fitur SiKunjung dengan mudah.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // MENU GRID
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics:
                    const NeverScrollableScrollPhysics(),

                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,

                    childAspectRatio: 1.05,

                    children: [

                      // DAFTAR KUNJUNGAN
                      MenuCard(
                        icon: Icons.assignment_rounded,
                        title: 'Daftar Kunjungan',
                        subtitle: 'Lihat dan kelola data kunjungan.',


                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const DaftarKunjunganScreen(),
                            ),
                          ).then((_) => _loadDataDashboard());
                        },
                      ),

                      // PETA LOKASI
                      MenuCard(
                        icon: Icons.map_rounded,
                        title: 'Peta Lokasi',
                        subtitle: 'Lihat sebaran lokasi kunjungan.',


                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const PetaKunjunganScreen(),
                            ),
                          );
                        },
                      ),

                      // SENSOR & JARINGAN
                      MenuCard(
                        icon: Icons.sensors_rounded,
                        title: 'Sensor & Jaringan',
                        subtitle: 'Pantau sensor dan status jaringan.',


                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const SensorNetworkScreen(),
                            ),
                          );
                        },
                      ),

                      // INFO PERANGKAT
                      MenuCard(
                        icon: Icons.phone_android_rounded,
                        title: 'Info Perangkat',
                        subtitle: 'Lihat informasi perangkat anda.',

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const InfoPerangkatScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // FOOTER
                  const Center(
                    child: Text(
                      'SiKunjung • Sistem Informasi Kunjungan Lapangan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
