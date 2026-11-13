
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
  State<PetaKunjunganScreen> createState() =>
      _PetaKunjunganScreenState();
}

class _PetaKunjunganScreenState
    extends State<PetaKunjunganScreen> {

  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();

  List<Kunjungan> _semuaKunjungan = [];

  Position? _posisiPetugas;

  bool _isLoading = true;
  String _errorMessage = '';

  // COLOR PALETTE
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkText = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color backgroundColor = Color(0xFFF5F7FB);

  // INITIALIZATION
  @override
  void initState() {
    super.initState();
    _loadDataDanLokasi();
  }

  // LOAD DATABASE AND CURRENT LOCATION
  Future<void> _loadDataDanLokasi() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 1. GET VISIT DATA FROM SQLITE
      final data =
      await DatabaseHelper.instance.getAllKunjungan();

      // 2. GET CURRENT STAFF LOCATION
      final posisi =
      await _locationService.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        _semuaKunjungan = data;
        _posisiPetugas = posisi;
        _isLoading = false;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Gagal mendapatkan data atau lokasi saat ini.';
      });
    }
  }

  // CENTER MAP TO CURRENT STAFF LOCATION
  void _pusatkanLokasi() {
    if (_posisiPetugas == null) return;

    _mapController.move(
      LatLng(
        _posisiPetugas!.latitude,
        _posisiPetugas!.longitude,
      ),
      15,
    );
  }

  // SHOW CUSTOMER INFORMATION
  void _tampilkanInfoKunjungan(Kunjungan kunjungan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: false,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),

      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // SHEET HANDLE
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // HEADER
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.business_rounded,
                        color: primaryBlue,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Pelanggan',
                            style: TextStyle(
                              fontSize: 11,
                              color: secondaryText,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            kunjungan.namaPelanggan,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ADDRESS
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 19,
                      color: secondaryText,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        kunjungan.alamat,
                        style: const TextStyle(
                          fontSize: 13,
                          color: secondaryText,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // COORDINATES
                Row(
                  children: [
                    const Icon(
                      Icons.my_location_rounded,
                      size: 19,
                      color: secondaryText,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        '${kunjungan.latitude.toStringAsFixed(6)}, '
                            '${kunjungan.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // VISIT DATE
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: secondaryText,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        kunjungan.tanggal,
                        style: const TextStyle(
                          fontSize: 12,
                          color: secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),
              ],
            ),
          ),
        );
      },
    );
  }

  // CURRENT LOCATION MARKER
  Marker _buildStaffMarker() {
    return Marker(
      point: LatLng(
        _posisiPetugas!.latitude,
        _posisiPetugas!.longitude,
      ),

      width: 58,
      height: 58,

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: primaryBlue,
            width: 2,
          ),

          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.20),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: const Icon(
          Icons.navigation_rounded,
          color: primaryBlue,
          size: 29,
        ),
      ),
    );
  }

  // CUSTOMER MARKER
  Marker _buildCustomerMarker(Kunjungan kunjungan) {
    return Marker(
      point: LatLng(
        kunjungan.latitude,
        kunjungan.longitude,
      ),

      width: 48,
      height: 52,

      child: GestureDetector(
        onTap: () {
          _tampilkanInfoKunjungan(kunjungan);
        },

        child: const Icon(
          Icons.location_on_rounded,
          color: Color(0xFFEF4444),
          size: 42,
          shadows: [
            Shadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  // MAP INFORMATION PANEL
  Widget _buildMapInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              const Icon(
                Icons.map_rounded,
                color: primaryBlue,
                size: 20,
              ),

              const SizedBox(width: 9),

              const Expanded(
                child: Text(
                  'Informasi Peta',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  '${_semuaKunjungan.length} Titik',

                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: primaryBlue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // CURRENT LOCATION
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 9),

              const Expanded(
                child: Text(
                  'Lokasi petugas saat ini',
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          // CUSTOMER LOCATION
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 9),

              const Expanded(
                child: Text(
                  'Lokasi pelanggan',
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // LOADING STATE
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: primaryBlue,
          ),

          SizedBox(height: 16),

          Text(
            'Memuat data dan lokasi...',
            style: TextStyle(
              fontSize: 13,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // ERROR STATE
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(22),
              ),

              child: const Icon(
                Icons.location_off_rounded,
                color: Color(0xFFEF4444),
                size: 36,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Gagal Memuat Peta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _errorMessage.isEmpty
                  ? 'Tidak dapat mendapatkan lokasi saat ini.'
                  : _errorMessage,

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 12,
                color: secondaryText,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 22),

            ElevatedButton.icon(
              onPressed: _loadDataDanLokasi,

              icon: const Icon(Icons.refresh_rounded),

              label: const Text('Coba Lagi'),

              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              'Peta Lokasi Kunjungan',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),

            SizedBox(height: 4),

            Text(
              'Pantau lokasi pelanggan secara geografis',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.normal,
                color: secondaryText,
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),

            child: IconButton(
              onPressed:
              _isLoading ? null : _loadDataDanLokasi,

              tooltip: 'Refresh Peta',

              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              icon: const Icon(
                Icons.refresh_rounded,
              ),
            ),
          ),
        ],
      ),

      // MAP BODY
      body: _isLoading
          ? _buildLoading()
          : _posisiPetugas == null
          ? _buildError()
          : Stack(
        children: [

          // MAP
          FlutterMap(
            mapController: _mapController,

            options: MapOptions(
              initialCenter: LatLng(
                _posisiPetugas!.latitude,
                _posisiPetugas!.longitude,
              ),

              initialZoom: 14,
              maxZoom: 19,
              minZoom: 3,
            ),

            children: [

              // OPENSTREETMAP TILE LAYER
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                userAgentPackageName:
                'com.example.sikunjung',
              ),

              // MARKERS
              MarkerLayer(
                markers: [
                  // STAFF LOCATION
                  _buildStaffMarker(),

                  // CUSTOMER LOCATIONS
                  ..._semuaKunjungan.map(
                        (kunjungan) =>
                        _buildCustomerMarker(kunjungan),
                  ),
                ],
              ),

              // MAP ATTRIBUTION
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    '© OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),

          // TOP INFORMATION PANEL
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: _buildMapInfoPanel(),
          ),

        ],
      ),

      // RECENTER BUTTON
      floatingActionButton:
      !_isLoading && _posisiPetugas != null
          ? FloatingActionButton(
        onPressed: _pusatkanLokasi,

        backgroundColor: Colors.white,
        foregroundColor: primaryBlue,
        elevation: 4,

        tooltip: 'Pusatkan ke lokasi petugas',

        child: const Icon(
          Icons.my_location_rounded,
        ),
      )
          : null,
    );
  }
}
