
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SensorNetworkScreen extends StatefulWidget {
  const SensorNetworkScreen({super.key});

  @override
  State<SensorNetworkScreen> createState() =>
      _SensorNetworkScreenState();
}

class _SensorNetworkScreenState
    extends State<SensorNetworkScreen> {

  // COLOR PALETTE
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkText = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color backgroundColor = Color(0xFFF5F7FB);

  // NETWORK VARIABLES
  List<ConnectivityResult> _connectionStatus = [
    ConnectivityResult.none,
  ];

  StreamSubscription<List<ConnectivityResult>>?
  _connectivitySubscription;

  bool _isCheckingNetwork = true;

  // SENSOR VARIABLES
  AccelerometerEvent? _accelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;
  MagnetometerEvent? _magnetometerEvent;

  // COMPASS VARIABLES
  double _compassHeading = 0.0;
  String _compassDirection = '-';

  // SENSOR SUBSCRIPTIONS
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<MagnetometerEvent>? _magnetoSub;

  // INITIALIZATION
  @override
  void initState() {
    super.initState();

    _initNetwork();
    _initSensors();
  }

  // INITIALIZE NETWORK MONITORING
  Future<void> _initNetwork() async {
    final connectivity = Connectivity();

    try {
      final initialStatus =
      await connectivity.checkConnectivity();

      if (!mounted) return;

      setState(() {
        _connectionStatus = initialStatus;
        _isCheckingNetwork = false;
      });

      _connectivitySubscription =
          connectivity.onConnectivityChanged.listen(
                (List<ConnectivityResult> results) {
              if (!mounted) return;

              setState(() {
                _connectionStatus = results;
              });
            },
          );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCheckingNetwork = false;
      });
    }
  }

  // INITIALIZE SENSOR MONITORING
  void _initSensors() {

    // ACCELEROMETER
    _accelSub = accelerometerEventStream().listen((event) {
      if (!mounted) return;

      setState(() {
        _accelerometerEvent = event;
      });
    });

    // GYROSCOPE
    _gyroSub = gyroscopeEventStream().listen((event) {
      if (!mounted) return;

      setState(() {
        _gyroscopeEvent = event;
      });
    });

    // MAGNETOMETER
    _magnetoSub = magnetometerEventStream().listen((event) {
      if (!mounted) return;

      setState(() {
        _magnetometerEvent = event;
        _hitungKompas(event);
      });
    });
  }

  // CALCULATE COMPASS HEADING
  void _hitungKompas(MagnetometerEvent event) {
    double heading = atan2(event.y, event.x);

    // RADIAN TO DEGREE
    heading = heading * 180 / pi;

    // NORMALIZE 0-360
    if (heading < 0) {
      heading += 360;
    }

    // COMPASS DIRECTION
    String direction = 'Utara (N)';

    if (heading >= 22.5 && heading < 67.5) {
      direction = 'Timur Laut (NE)';
    } else if (heading >= 67.5 && heading < 112.5) {
      direction = 'Timur (E)';
    } else if (heading >= 112.5 && heading < 157.5) {
      direction = 'Tenggara (SE)';
    } else if (heading >= 157.5 && heading < 202.5) {
      direction = 'Selatan (S)';
    } else if (heading >= 202.5 && heading < 247.5) {
      direction = 'Barat Daya (SW)';
    } else if (heading >= 247.5 && heading < 292.5) {
      direction = 'Barat (W)';
    } else if (heading >= 292.5 && heading < 337.5) {
      direction = 'Barat Laut (NW)';
    }

    _compassHeading = heading;
    _compassDirection = direction;
  }

  // CHECK NETWORK STATUS
  bool get _isOffline {
    return _connectionStatus.isEmpty ||
        _connectionStatus.contains(ConnectivityResult.none);
  }

  String _getNetworkString() {
    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return 'Wi-Fi Terhubung';
    }

    if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return 'Data Seluler';
    }

    if (_isOffline) {
      return 'Tidak Ada Koneksi';
    }

    return 'Jaringan Terhubung';
  }

  // NETWORK ICON
  IconData _getNetworkIcon() {
    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return Icons.wifi_rounded;
    }

    if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return Icons.signal_cellular_alt_rounded;
    }

    if (_connectionStatus.contains(ConnectivityResult.ethernet)) {
      return Icons.lan_rounded;
    }

    if (_isOffline) {
      return Icons.signal_wifi_off_rounded;
    }

    return Icons.network_check_rounded;
  }

  // NETWORK COLOR
  Color get _networkColor {
    if (_isOffline) {
      return const Color(0xFFEF4444);
    }

    return const Color(0xFF16A34A);
  }

  // SECTION HEADER
  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primaryBlue,
            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // NETWORK STATUS CARD
  Widget _buildNetworkCard() {
    final color = _isCheckingNetwork
        ? primaryBlue
        : _networkColor;

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEAEFF5),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,

            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),

            child: _isCheckingNetwork
                ? const Padding(
              padding: EdgeInsets.all(17),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: primaryBlue,
              ),
            )
                : Icon(
              _getNetworkIcon(),
              size: 30,
              color: color,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Koneksi',
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryText,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _isCheckingNetwork
                      ? 'Memeriksa jaringan...'
                      : _getNetworkString(),

                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _isCheckingNetwork
                      ? 'Mengambil status jaringan perangkat'
                      : _isOffline
                      ? 'Perangkat sedang offline'
                      : 'Pemantauan jaringan aktif',

                  style: const TextStyle(
                    fontSize: 10,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),

            decoration: BoxDecoration(
              color: _isCheckingNetwork
                  ? const Color(0xFFEFF6FF)
                  : _isOffline
                  ? const Color(0xFFFEE2E2)
                  : const Color(0xFFDCFCE7),

              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              _isCheckingNetwork
                  ? 'CHECK'
                  : _isOffline
                  ? 'OFFLINE'
                  : 'ONLINE',

              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,

                color: _isCheckingNetwork
                    ? primaryBlue
                    : _isOffline
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF16A34A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // COMPASS CARD
  Widget _buildCompassCard() {
    final bool hasCompassData =
        _magnetometerEvent != null;

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEAEFF5),
        ),
      ),

      child: Column(
        children: [

          // COMPASS DIAL
          SizedBox(
            width: 210,
            height: 210,

            child: Stack(
              alignment: Alignment.center,
              children: [

                // OUTER CIRCLE
                Container(
                  width: 190,
                  height: 190,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 2,
                    ),
                  ),
                ),

                // INNER CIRCLE
                Container(
                  width: 145,
                  height: 145,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFEAEFF5),
                    ),
                  ),
                ),

                // NORTH
                const Positioned(
                  top: 8,
                  child: Text(
                    'N',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                      fontSize: 14,
                    ),
                  ),
                ),

                // SOUTH
                const Positioned(
                  bottom: 8,
                  child: Text(
                    'S',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ),

                // EAST
                const Positioned(
                  right: 12,
                  child: Text(
                    'E',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ),

                // WEST
                const Positioned(
                  left: 12,
                  child: Text(
                    'W',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ),

                // COMPASS NEEDLE
                Transform.rotate(
                  angle: _compassHeading * pi / 180,

                  child: Icon(
                    Icons.navigation_rounded,
                    size: 54,
                    color: primaryBlue.withOpacity(0.9),
                  ),
                ),

                // CENTER DOT
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // HEADING VALUE
          Text(
            hasCompassData
                ? '${_compassHeading.toStringAsFixed(1)}°'
                : '--.-°',

            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),

          const SizedBox(height: 5),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 7,
            ),

            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              hasCompassData
                  ? _compassDirection
                  : 'Menunggu data kompas',

              style: const TextStyle(
                color: primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Data arah diperbarui secara real-time '
                'menggunakan magnetometer.',

            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // SENSOR DATA CARD

  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String unit,
    required double? x,
    required double? y,
    required double? z,
  }) {
    final hasData = x != null && y != null && z != null;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEAEFF5),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // SENSOR HEADER
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: primaryBlue,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 10,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: hasData
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 5),

                  Text(
                    hasData ? 'LIVE' : 'WAIT',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: hasData
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // SENSOR AXES
          Row(
            children: [
              Expanded(child: _buildAxisValue('X', x)),
              const SizedBox(width: 8),
              Expanded(child: _buildAxisValue('Y', y)),
              const SizedBox(width: 8),
              Expanded(child: _buildAxisValue('Z', z)),
            ],
          ),
        ],
      ),
    );
  }


  // AXIS VALUE
  Widget _buildAxisValue(String axis, double? value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(11),
      ),

      child: Column(
        children: [
          Text(
            axis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: secondaryText,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value != null
                ? value.toStringAsFixed(2)
                : '--',

            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
        ],
      ),
    );
  }

  // DISPOSE
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _magnetoSub?.cancel();

    super.dispose();
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // APP BAR
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 72,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sensor & Jaringan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),

            SizedBox(height: 4),

            Text(
              'Monitoring kondisi perangkat',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.normal,
                color: secondaryText,
              ),
            ),
          ],
        ),
      ),

      // BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20, 12, 20, 30,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            // NETWORK SECTION
            _sectionHeader(
              icon: Icons.wifi_rounded,
              title: 'Status Jaringan',
              subtitle: 'Kondisi konektivitas perangkat.',
            ),

            const SizedBox(height: 14),

            _buildNetworkCard(),

            const SizedBox(height: 28),

            // COMPASS SECTION
            _sectionHeader(
              icon: Icons.explore_rounded,
              title: 'Kompas Digital',
              subtitle: 'Arah mata angin berdasarkan magnetometer.',
            ),

            const SizedBox(height: 14),

            _buildCompassCard(),

            const SizedBox(height: 28),

            // SENSOR SECTION
            _sectionHeader(
              icon: Icons.developer_board_rounded,
              title: 'Data Sensor Perangkat',
              subtitle: 'Nilai sensor dalam satuan real-time.',
            ),

            const SizedBox(height: 6),

            const Text(
              'Data diperbarui otomatis mengikuti pergerakan perangkat.',
              style: TextStyle(
                fontSize: 10,
                color: secondaryText,
              ),
            ),

            const SizedBox(height: 14),

            // ACCELEROMETER
            _buildSensorCard(
              icon: Icons.speed_rounded,
              title: 'Accelerometer',
              unit: 'Percepatan (m/s²)',
              x: _accelerometerEvent?.x,
              y: _accelerometerEvent?.y,
              z: _accelerometerEvent?.z,
            ),

            const SizedBox(height: 13),

            // GYROSCOPE
            _buildSensorCard(
              icon: Icons.rotate_right_rounded,
              title: 'Gyroscope',
              unit: 'Kecepatan sudut (rad/s)',
              x: _gyroscopeEvent?.x,
              y: _gyroscopeEvent?.y,
              z: _gyroscopeEvent?.z,
            ),

            const SizedBox(height: 13),

            // MAGNETOMETER
            _buildSensorCard(
              icon: Icons.explore_rounded,
              title: 'Magnetometer',
              unit: 'Medan magnet (µT)',
              x: _magnetometerEvent?.x,
              y: _magnetometerEvent?.y,
              z: _magnetometerEvent?.z,
            ),

            const SizedBox(height: 25),

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
    );
  }
}
