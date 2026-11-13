import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../widgets/kunjungan_card.dart';
import '../models/kunjungan.dart';
import '../database/database_helper.dart';
import 'form_kunjungan_screen.dart';
import 'detail_kunjungan_screen.dart';

class DaftarKunjunganScreen extends StatefulWidget {
  const DaftarKunjunganScreen({super.key});

  @override
  State<DaftarKunjunganScreen> createState() => _DaftarKunjunganScreenState();
}

class _DaftarKunjunganScreenState extends State<DaftarKunjunganScreen> {
  List<Kunjungan> _semuaKunjungan = [];
  List<Kunjungan> _kunjunganTampil = [];
  String _searchQuery = '';

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime _lastShakeTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
    _initShakeToRefresh();
  }

  // Mengambil data ASLI dari SQLite
  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.getAllKunjungan();
    setState(() {
      _semuaKunjungan = data;
      _filterKunjungan(_searchQuery); // Terapkan filter pencarian jika ada
    });
  }

  // Fitur Pencarian Data
  void _filterKunjungan(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _kunjunganTampil = _semuaKunjungan;
      } else {
        _kunjunganTampil = _semuaKunjungan
            .where((k) => k.namaPelanggan.toLowerCase().contains(query.toLowerCase()) ||
            k.alamat.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Integrasi Sensor Accelerometer untuk fitur "Shake to Refresh" (J.612000.022.01)
  void _initShakeToRefresh() {
    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      double acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      // Ambang batas guncangan keras (> 15 m/s²)
      if (acceleration > 15) {
        final now = DateTime.now();
        // Debounce 2 detik agar tidak me-refresh berkali-kali dalam 1 guncangan
        if (now.difference(_lastShakeTime).inSeconds > 2) {
          _lastShakeTime = now;
          _loadData(); // Tarik ulang data dari database

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Daftar kunjungan diperbarui (Guncangan terdeteksi)')),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  // Dialog konfirmasi hapus data
  void _konfirmasiHapus(Kunjungan kunjungan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data'),
        content: Text('Apakah Anda yakin ingin menghapus kunjungan ke ${kunjungan.namaPelanggan}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseHelper.instance.deleteKunjungan(kunjungan.id!); // Hapus dari SQLite
              _loadData(); // Refresh UI

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data berhasil dihapus')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kunjungan'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke Form Tambah dan refresh list saat kembali[cite: 1]
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormKunjunganScreen()),
          ).then((_) => _loadData());
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Kolom Pencarian
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterKunjungan,
              decoration: InputDecoration(
                hintText: 'Cari nama pelanggan atau alamat...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              ),
            ),
          ),

          Expanded(
            child: Builder(
              builder: (context) {
                if (_semuaKunjungan.isEmpty) {
                  return const Center(child: Text('Belum ada data kunjungan. Silakan tambah data.'));
                }

                if (_kunjunganTampil.isEmpty) {
                  return const Center(child: Text('Data tidak ditemukan.'));
                }

                // Mendeteksi orientasi layar dengan MediaQuery (Lebih akurat daripada LayoutBuilder)[cite: 1]
                bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

                return isLandscape
                    ? GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _kunjunganTampil.length,
                  itemBuilder: (context, index) {
                    final item = _kunjunganTampil[index];
                    return KunjunganCard(
                      kunjungan: item,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => DetailKunjunganScreen(kunjungan: item)));
                      },
                      onEdit: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => FormKunjunganScreen(kunjungan: item))
                        ).then((_) => _loadData()); // Refresh halaman setelah edit
                      },
                      onDelete: () => _konfirmasiHapus(item),
                    );
                  },
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _kunjunganTampil.length,
                  itemBuilder: (context, index) {
                    final item = _kunjunganTampil[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: KunjunganCard(
                        kunjungan: item,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => DetailKunjunganScreen(kunjungan: item)));
                        },
                        onEdit: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => FormKunjunganScreen(kunjungan: item))
                          ).then((_) => _loadData()); // Refresh halaman setelah edit
                        },
                        onDelete: () => _konfirmasiHapus(item),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}