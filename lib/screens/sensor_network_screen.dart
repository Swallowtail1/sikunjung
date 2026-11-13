import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SensorNetworkScreen extends StatefulWidget {
  const SensorNetworkScreen({super.key});

  @override
  State<SensorNetworkScreen> createState() => _SensorNetworkScreenState();
}

class _SensorNetworkScreenState extends State<SensorNetworkScreen> {
  // Variabel Jaringan
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // Variabel Sensor
  AccelerometerEvent? _accelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;
  MagnetometerEvent? _magnetometerEvent;

  double _compassHeading = 0.0;
  String _compassDirection = '-';

  // Subscriptions
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<MagnetometerEvent>? _magnetoSub;

  @override
  void initState() {
    super.initState();
    _initNetwork();
    _initSensors();
  }

  // Inisialisasi Pemantauan Jaringan (J.612000.025.01)
  Future<void> _initNetwork() async {
    // 1. Cek status jaringan saat detik ini juga (hanya sekali)
    final initialStatus = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _connectionStatus = initialStatus;
      });
    }

    // 2. Pantau perubahan jaringan selanjutnya (Stream)
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (mounted) {
        setState(() {
          _connectionStatus = results;
        });
      }
    });
  }

  // Inisialisasi Pemantauan Sensor (J.612000.022.01)
  void _initSensors() {
    _accelSub = accelerometerEventStream().listen((event) {
      if (mounted) setState(() => _accelerometerEvent = event);
    });

    _gyroSub = gyroscopeEventStream().listen((event) {
      if (mounted) setState(() => _gyroscopeEvent = event);
    });

    _magnetoSub = magnetometerEventStream().listen((event) {
      if (mounted) {
        setState(() {
          _magnetometerEvent = event;
          _hitungKompas(event);
        });
      }
    });
  }

  // Logika Menghitung Arah Kompas dari Magnetometer
  void _hitungKompas(MagnetometerEvent event) {
    // Menggunakan arctangent dari sumbu Y dan X
    double heading = atan2(event.y, event.x);

    // Konversi radian ke derajat
    heading = heading * 180 / pi;

    // Normalisasi ke 0-360 derajat
    if (heading < 0) {
      heading += 360;
    }

    // Tentukan Arah Mata Angin
    String direction = 'Utara (N)';
    if (heading >= 22.5 && heading < 67.5) direction = 'Timur Laut (NE)';
    else if (heading >= 67.5 && heading < 112.5) direction = 'Timur (E)';
    else if (heading >= 112.5 && heading < 157.5) direction = 'Tenggara (SE)';
    else if (heading >= 157.5 && heading < 202.5) direction = 'Selatan (S)';
    else if (heading >= 202.5 && heading < 247.5) direction = 'Barat Daya (SW)';
    else if (heading >= 247.5 && heading < 292.5) direction = 'Barat (W)';
    else if (heading >= 292.5 && heading < 337.5) direction = 'Barat Laut (NW)';

    _compassHeading = heading;
    _compassDirection = direction;
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _magnetoSub?.cancel();
    super.dispose();
  }

  // Helper untuk menampilkan status jaringan ke teks bahasa Indonesia
  String _getNetworkString() {
    if (_connectionStatus.contains(ConnectivityResult.wifi)) return 'WiFi Terhubung';
    if (_connectionStatus.contains(ConnectivityResult.mobile)) return 'Data Seluler (3G/4G/5G)';
    if (_connectionStatus.contains(ConnectivityResult.none)) return 'Offline (Tidak ada koneksi)';
    return 'Status Tidak Diketahui';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor & Jaringan'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // KARTU STATUS JARINGAN
            const Text('Status Jaringan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              color: _connectionStatus.contains(ConnectivityResult.none)
                  ? Colors.red.shade100
                  : Colors.green.shade100,
              child: ListTile(
                leading: Icon(
                  _connectionStatus.contains(ConnectivityResult.wifi) ? Icons.wifi
                      : _connectionStatus.contains(ConnectivityResult.mobile) ? Icons.signal_cellular_4_bar
                      : Icons.signal_wifi_off,
                  size: 40,
                  color: _connectionStatus.contains(ConnectivityResult.none) ? Colors.red : Colors.green,
                ),
                title: Text(
                  _getNetworkString(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: const Text('Real-time network monitoring'),
              ),
            ),

            const SizedBox(height: 24),

            // KARTU KOMPAS
            const Text('Arah Kompas (Magnetometer)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.explore, size: 60, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(
                      '${_compassHeading.toStringAsFixed(1)}°',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _compassDirection,
                      style: const TextStyle(fontSize: 18, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // KARTU DATA SENSOR REAL-TIME
            const Text('Data Sensor Perangkat (Real-time)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSensorRow(
                        'Accelerometer (m/s²)',
                        _accelerometerEvent != null
                            ? 'X: ${_accelerometerEvent!.x.toStringAsFixed(2)}\nY: ${_accelerometerEvent!.y.toStringAsFixed(2)}\nZ: ${_accelerometerEvent!.z.toStringAsFixed(2)}'
                            : 'Sensor tidak terdeteksi'
                    ),
                    const Divider(),
                    _buildSensorRow(
                        'Gyroscope (rad/s)',
                        _gyroscopeEvent != null
                            ? 'X: ${_gyroscopeEvent!.x.toStringAsFixed(2)}\nY: ${_gyroscopeEvent!.y.toStringAsFixed(2)}\nZ: ${_gyroscopeEvent!.z.toStringAsFixed(2)}'
                            : 'Sensor tidak terdeteksi'
                    ),
                    const Divider(),
                    _buildSensorRow(
                        'Magnetometer (µT)',
                        _magnetometerEvent != null
                            ? 'X: ${_magnetometerEvent!.x.toStringAsFixed(2)}\nY: ${_magnetometerEvent!.y.toStringAsFixed(2)}\nZ: ${_magnetometerEvent!.z.toStringAsFixed(2)}'
                            : 'Sensor tidak terdeteksi'
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable widget untuk baris data sensor
  Widget _buildSensorRow(String title, String data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 1,
          child: Text(data, textAlign: TextAlign.right),
        ),
      ],
    );
  }
}