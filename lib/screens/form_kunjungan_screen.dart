import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/kunjungan.dart';
import '../database/database_helper.dart';
import '../services/location_service.dart';

class FormKunjunganScreen extends StatefulWidget {
  final Kunjungan? kunjungan; // Jika null = Tambah Baru, Jika terisi = Update Data

  // Tambahkan opsional parameter kunjungan
  const FormKunjunganScreen({super.key, this.kunjungan});

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

  bool get _isEditMode => widget.kunjungan != null; // Cek apakah sedang mode edit

  @override
  void initState() {
    super.initState();
    // Jika dalam mode Edit, isikan form dengan data pelanggan lama
    if (_isEditMode) {
      _namaController.text = widget.kunjungan!.namaPelanggan;
      _alamatController.text = widget.kunjungan!.alamat;
      _noHpController.text = widget.kunjungan!.noHp;
      _catatanController.text = widget.kunjungan!.catatan;
      _latitude = widget.kunjungan!.latitude;
      _longitude = widget.kunjungan!.longitude;
    }
  }

  Future<void> _ambilLokasiTerkini() async {
    setState(() => _isLoadingLocation = true);
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lokasi berhasil didapatkan!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap ambil lokasi GPS terlebih dahulu!'), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isSaving = true);

    // Gunakan tanggal saat ini ketika disave
    final tanggalSekarang = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());

    final kunjunganData = Kunjungan(
      id: _isEditMode ? widget.kunjungan!.id : null, // Penting! Bawa ID lama jika mode edit
      namaPelanggan: _namaController.text.trim(),
      alamat: _alamatController.text.trim(),
      noHp: _noHpController.text.trim(),
      catatan: _catatanController.text.trim(),
      latitude: _latitude!,
      longitude: _longitude!,
      tanggal: tanggalSekarang,
    );

    try {
      if (_isEditMode) {
        await DatabaseHelper.instance.updateKunjungan(kunjunganData); // Eksekusi operasi UPDATE (J.612000.003.01)
      } else {
        await DatabaseHelper.instance.insertKunjungan(kunjunganData); // Eksekusi operasi INSERT[cite: 1]
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditMode ? 'Data kunjungan berhasil diperbarui' : 'Data kunjungan berhasil disimpan')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan data'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Ubah judul AppBar dinamis
        title: Text(_isEditMode ? 'Edit Kunjungan' : 'Tambah Kunjungan'),
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
                decoration: const InputDecoration(labelText: 'No. HP', border: OutlineInputBorder(), hintText: 'Contoh: 081234567890'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'No. HP tidak boleh kosong';
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'No. HP hanya boleh berisi angka';
                  if (value.length < 10) return 'No. HP minimal 10 digit';
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
                            label: Text(_latitude == null ? 'Ambil Lokasi' : 'Perbarui Lokasi'),
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

              ElevatedButton(
                onPressed: _isSaving ? null : _simpanData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isEditMode ? 'SIMPAN PERUBAHAN' : 'SIMPAN KUNJUNGAN', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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