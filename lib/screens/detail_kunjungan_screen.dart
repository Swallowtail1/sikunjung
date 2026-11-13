import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../models/kunjungan.dart';
import '../services/location_service.dart';

class DetailKunjunganScreen extends StatefulWidget {
  final Kunjungan kunjungan;

  const DetailKunjunganScreen({super.key, required this.kunjungan});

  @override
  State<DetailKunjunganScreen> createState() => _DetailKunjunganScreenState();
}

class _DetailKunjunganScreenState extends State<DetailKunjunganScreen> {
  final LocationService _locationService = LocationService();

  double? _jarakMeter;
  bool _isLoadingJarak = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _hitungJarak();
  }

  // Menghitung jarak dari posisi saat ini ke lokasi pelanggan (J.612000.006.01)
  Future<void> _hitungJarak() async {
    try {
      final currentPos = await _locationService.getCurrentLocation();

      final distance = Geolocator.distanceBetween(
        currentPos.latitude,
        currentPos.longitude,
        widget.kunjungan.latitude,
        widget.kunjungan.longitude,
      );

      if (mounted) {
        setState(() {
          _jarakMeter = distance;
          _isLoadingJarak = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal mengambil lokasi saat ini';
          _isLoadingJarak = false;
        });
      }
    }
  }

  // Membuka navigasi ke Google Maps (J.612000.006.01)
  Future<void> _bukaNavigasi() async {
    final lat = widget.kunjungan.latitude;
    final lng = widget.kunjungan.longitude;

    // URL Scheme universal untuk membuka rute di Google Maps
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi Google Maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kunjungan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kunjungan'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kartu Informasi Pelanggan
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama Pelanggan', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(k.namaPelanggan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const Divider(height: 24),

                    Text('Alamat', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(k.alamat, style: const TextStyle(fontSize: 16)),
                    const Divider(height: 24),

                    Text('Nomor HP', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(k.noHp, style: const TextStyle(fontSize: 16)),
                    const Divider(height: 24),

                    Text('Catatan', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(k.catatan.isEmpty ? '-' : k.catatan, style: const TextStyle(fontSize: 16)),
                    const Divider(height: 24),

                    Text('Waktu Kunjungan', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(k.tanggal, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Kartu Lokasi & Jarak
            Card(
              elevation: 2,
              color: Theme.of(context).colorScheme.surfaceVariant,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.location_on, size: 40, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text('Koordinat: ${k.latitude}, ${k.longitude}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Indikator Jarak
                    _isLoadingJarak
                        ? const CircularProgressIndicator()
                        : _errorMessage.isNotEmpty
                        ? Text(_errorMessage, style: const TextStyle(color: Colors.red))
                        : Text(
                      'Jarak dari posisi Anda: ${(_jarakMeter! / 1000).toStringAsFixed(2)} km',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Navigasi
            ElevatedButton.icon(
              onPressed: _bukaNavigasi,
              icon: const Icon(Icons.directions),
              label: const Text('NAVIGASI KE LOKASI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}