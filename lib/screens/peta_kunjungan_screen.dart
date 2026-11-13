import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/kunjungan.dart';
import '../database/database_helper.dart';
import '../services/location_service.dart';

class PetaKunjunganScreen extends StatefulWidget {
  const PetaKunjunganScreen({super.key});

  @override
  State<PetaKunjunganScreen> createState() => _PetaKunjunganScreenState();
}

class _PetaKunjunganScreenState extends State<PetaKunjunganScreen> {
  final LocationService _locationService = LocationService();

  List<Kunjungan> _semuaKunjungan = [];
  Position? _posisiPetugas;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataDanLokasi();
  }

  Future<void> _loadDataDanLokasi() async {
    try {
      // 1. Ambil semua data kunjungan dari SQLite
      final data = await DatabaseHelper.instance.getAllKunjungan();

      // 2. Ambil posisi petugas saat ini menggunakan Geolocator
      final posisi = await _locationService.getCurrentLocation();

      if (mounted) {
        setState(() {
          _semuaKunjungan = data;
          _posisiPetugas = posisi;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat peta: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Lokasi Kunjungan'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posisiPetugas == null
          ? const Center(child: Text('Gagal mendapatkan lokasi saat ini.'))
          : FlutterMap(
        options: MapOptions(
          // Pusatkan peta di posisi petugas saat aplikasi dibuka
          initialCenter: LatLng(_posisiPetugas!.latitude, _posisiPetugas!.longitude),
          initialZoom: 13.0,
        ),
        children: [
          // Layer Peta OpenStreetMap (Gratis & Sesuai Dokumen MUK)[cite: 1]
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.sikunjung',
          ),
          MarkerLayer(
            markers: [
              // Marker 1: Posisi Petugas Saat Ini (Warna Biru)[cite: 1]
              Marker(
                point: LatLng(_posisiPetugas!.latitude, _posisiPetugas!.longitude),
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
              // Marker 2: Seluruh Lokasi Pelanggan (Warna Merah)[cite: 1]
              ..._semuaKunjungan.map((kunjungan) {
                return Marker(
                  point: LatLng(kunjungan.latitude, kunjungan.longitude),
                  width: 50,
                  height: 50,
                  child: GestureDetector(
                    onTap: () {
                      // Tampilkan nama pelanggan jika marker diklik
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Pelanggan: ${kunjungan.namaPelanggan}\n${kunjungan.alamat}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}