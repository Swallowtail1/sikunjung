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
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadDataDashboard();
    _initNetworkMonitoring();
  }

  // Menghitung total data kunjungan dari SQLite
  Future<void> _loadDataDashboard() async {
    final data = await DatabaseHelper.instance.getAllKunjungan();
    setState(() {
      _jumlahKunjungan = data.length;
    });
  }

  // Memantau status jaringan seluler/WiFi secara real-time (J.612000.025.01)
  void _initNetworkMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      setState(() {
        // Jika tidak ada koneksi internet sama sekali
        _isOffline = results.contains(ConnectivityResult.none);
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Fitur Logout (J.612000.008.01)
  Future<void> _logout() async {
    final authStorage = AuthStorage();
    await authStorage.deleteSession(); // Hapus sesi terenkripsi

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          )
        ],
      ),
      body: Column(
        children: [
          // Banner Peringatan Offline
          OfflineBanner(isOffline: _isOffline),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDataDashboard,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Ringkasan Jumlah Kunjungan
                  Card(
                    color: Theme.of(context).colorScheme.primary,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Text(
                            'Total Kunjungan Lapangan',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_jumlahKunjungan',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Menu Utama',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Grid Menu
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      MenuCard(
                        icon: Icons.list_alt,
                        title: 'Daftar\nKunjungan',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DaftarKunjunganScreen()),
                          ).then((_) => _loadDataDashboard());
                        },
                      ),
                      MenuCard(
                        icon: Icons.map,
                        title: 'Peta\nLokasi',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const PetaKunjunganScreen()));
                        },
                      ),
                      MenuCard(
                        icon: Icons.sensors,
                        title: 'Sensor &\nJaringan',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SensorNetworkScreen()));
                        },
                      ),
                      MenuCard(
                        icon: Icons.phone_android,
                        title: 'Info\nPerangkat',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const InfoPerangkatScreen()));
                        },
                      ),
                    ],
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