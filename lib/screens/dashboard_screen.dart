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
          // Banner Peringatan Offline (J.612000.025.01)
          if (_isOffline)
            Container(
              width: double.infinity,
              color: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Text(
                'Anda sedang Offline. Beberapa fitur (Peta) mungkin tidak tersedia.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),

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
                      _buildMenuCard(
                        context,
                        icon: Icons.list_alt,
                        title: 'Daftar\nKunjungan',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DaftarKunjunganScreen()),
                          ).then((_) => _loadDataDashboard()); // Refresh total saat kembali
                        },
                      ),
                      _buildMenuCard(
                        context,
                        icon: Icons.map,
                        title: 'Peta\nLokasi',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const PetaKunjunganScreen()));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sedang memuat Halaman Peta...')));
                        },
                      ),
                      _buildMenuCard(
                        context,
                        icon: Icons.sensors,
                        title: 'Sensor &\nJaringan',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SensorNetworkScreen()));
                        },
                      ),
                      _buildMenuCard(
                        context,
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

  // Reusable Widget untuk Menu Card
  Widget _buildMenuCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}