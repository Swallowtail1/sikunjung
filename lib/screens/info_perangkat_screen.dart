import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class InfoPerangkatScreen extends StatefulWidget {
  const InfoPerangkatScreen({super.key});

  @override
  State<InfoPerangkatScreen> createState() => _InfoPerangkatScreenState();
}

class _InfoPerangkatScreenState extends State<InfoPerangkatScreen> {
  // Variabel Perangkat
  String _osName = '-';
  String _osVersion = '-';
  String _deviceBrand = '-';
  String _deviceModel = '-';

  // Variabel Aplikasi
  String _appName = '-';
  String _appVersion = '-';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInformation();
  }

  Future<void> _loadInformation() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // Mengambil data aplikasi (package_info_plus)
    _appName = packageInfo.appName.isEmpty ? 'SiKunjung' : packageInfo.appName;
    _appVersion = '${packageInfo.version} (Build ${packageInfo.buildNumber})';

    // Mengambil data perangkat (device_info_plus)
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _osName = 'Android';
      _osVersion = '${androidInfo.version.release} (API Level ${androidInfo.version.sdkInt})';
      _deviceBrand = androidInfo.brand.toUpperCase();
      _deviceModel = androidInfo.model;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _osName = 'iOS';
      _osVersion = iosInfo.systemVersion;
      _deviceBrand = 'Apple';
      _deviceModel = iosInfo.name;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Perangkat'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kartu Info Aplikasi
            const Text('Informasi Aplikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.android, size: 60, color: Colors.green),
                    const SizedBox(height: 16),
                    _buildInfoRow('Nama Aplikasi', _appName),
                    const Divider(),
                    _buildInfoRow('Versi', _appVersion),
                    const Divider(),
                    _buildInfoRow('Bahasa Pemrograman', 'Dart (Flutter SDK)'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Kartu Info Perangkat
            const Text('Informasi Perangkat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.smartphone, size: 60, color: Colors.blueGrey),
                    const SizedBox(height: 16),
                    _buildInfoRow('Sistem Operasi', _osName),
                    const Divider(),
                    _buildInfoRow('Versi OS', _osVersion),
                    const Divider(),
                    _buildInfoRow('Merek', _deviceBrand),
                    const Divider(),
                    _buildInfoRow('Model', _deviceModel),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable widget untuk baris tabel informasi
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}