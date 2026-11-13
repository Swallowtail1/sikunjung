import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/kunjungan.dart';
import '../database/database_helper.dart';
import '../services/location_service.dart';

class FormKunjunganScreen extends StatefulWidget {
  const FormKunjunganScreen({super.key});

  @override
  State<FormKunjunganScreen> createState() => _FormKunjunganScreenState();
}

class _FormKunjunganScreenState extends State<FormKunjunganScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noHpController = TextEditingController();
  final _catatanController = TextEditingController();

  final _locationService = LocationService();

  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;
  bool _isSaving = false;

  // Fungsi yang dipicu oleh tombol "Ambil Lokasi"[cite: 1]
  Future<void> _ambilLokasiTerkini() async {
    setState(() => _isLoadingLocation = true);

    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokasi berhasil didapatkan!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  // Fungsi untuk menyimpan data ke SQLite[cite: 1]
  Future<void> _simpanData() async {
    // Validasi input form[cite: 1]
    if (!_formKey.currentState!.validate()) return;

    // Validasi tambahan memastikan lokasi sudah diambil
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap ambil lokasi GPS terlebih dahulu!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Ambil tanggal hari ini[cite: 1]
    final tanggalSekarang = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());

    final kunjunganBaru = Kunjungan(
      namaPelanggan: _namaController.text.trim(),
      alamat: _alamatController.text.trim(),
      noHp: _noHpController.text.trim(),
      catatan: _catatanController.text.trim(),
      latitude: _latitude!,
      longitude: _longitude!,
      tanggal: tanggalSekarang,
    );

    try {
      await DatabaseHelper.instance.insertKunjungan(kunjunganBaru);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data kunjungan berhasil disimpan')),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya (Daftar Kunjungan)
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kunjungan'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Pelanggan', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(labelText: 'Alamat', border: OutlineInputBorder()),
                maxLines: 2,
                validator: (value) => value == null || value.isEmpty ? 'Alamat tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _noHpController,
                decoration: const InputDecoration(
                    labelText: 'No. HP',
                    border: OutlineInputBorder(),
                    hintText: 'Contoh: 081234567890'
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'No. HP tidak boleh kosong';
                  }
                  // Validasi hanya angka menggunakan Regular Expression (Regex)
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'No. HP hanya boleh berisi angka';
                  }
                  // Validasi panjang minimal[cite: 1]
                  if (value.length < 10) {
                    return 'No. HP minimal 10 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _catatanController,
                decoration: const InputDecoration(labelText: 'Catatan (Opsional)', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Bagian Pengambilan Lokasi GPS[cite: 1]
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Titik Lokasi (GPS):', style: TextStyle(fontWeight: FontWeight.bold)),
                          ElevatedButton.icon(
                            onPressed: _isLoadingLocation ? null : _ambilLokasiTerkini,
                            icon: _isLoadingLocation
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.location_on),
                            label: const Text('Ambil Lokasi'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _latitude != null && _longitude != null
                            ? 'Lat: $_latitude\nLon: $_longitude'
                            : 'Lokasi belum diambil',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _latitude != null ? Colors.blue : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _isSaving ? null : _simpanData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SIMPAN KUNJUNGAN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    _catatanController.dispose();
    super.dispose();
  }
}