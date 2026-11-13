
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

import '../models/kunjungan.dart';
import '../services/location_service.dart';

class DetailKunjunganScreen extends StatefulWidget {
  final Kunjungan kunjungan;

  const DetailKunjunganScreen({
    super.key,
    required this.kunjungan,
  });

  @override
  State<DetailKunjunganScreen> createState() =>
      _DetailKunjunganScreenState();
}

class _DetailKunjunganScreenState
    extends State<DetailKunjunganScreen> {

  final LocationService _locationService = LocationService();

  double? _jarakMeter;
  bool _isLoadingJarak = true;
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
    _hitungJarak();
  }

  // CALCULATE DISTANCE
  Future<void> _hitungJarak() async {
    try {
      final currentPos =
      await _locationService.getCurrentLocation();

      final distance = Geolocator.distanceBetween(
        currentPos.latitude,
        currentPos.longitude,
        widget.kunjungan.latitude,
        widget.kunjungan.longitude,
      );

      if (!mounted) return;

      setState(() {
        _jarakMeter = distance;
        _isLoadingJarak = false;
        _errorMessage = '';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
        'Gagal mengambil lokasi saat ini.';
        _isLoadingJarak = false;
      });
    }
  }

  // FORMAT DISTANCE
  String _formatJarak(double meter) {
    if (meter < 1000) {
      return '${meter.toStringAsFixed(0)} meter';
    }

    return '${(meter / 1000).toStringAsFixed(2)} km';
  }

  // OPEN GOOGLE MAPS
  Future<void> _bukaNavigasi() async {
    final lat = widget.kunjungan.latitude;
    final lng = widget.kunjungan.longitude;

    final url = Uri.https(
      'www.google.com',
      '/maps/dir/',
      {
        'api': '1',
        'destination': '$lat,$lng',
      },
    );

    try {
      final success = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tidak dapat membuka aplikasi Google Maps.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Terjadi kesalahan saat membuka navigasi.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // INFORMATION ROW
  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: primaryBlue,
            size: 19,
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
                  fontSize: 11,
                  color: secondaryText,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: darkText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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

  // COORDINATE ROW
  Widget _coordinateRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: secondaryText,
          ),
        ),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: darkText,
            ),
          ),
        ),
      ],
    );
  }

  // DISTANCE INFORMATION
  Widget _buildDistanceInfo() {
    if (_isLoadingJarak) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(13),
        ),

        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: primaryBlue,
              ),
            ),

            SizedBox(width: 12),

            Expanded(
              child: Text(
                'Menghitung jarak dari lokasi Anda...',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryText,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(13),
        ),

        child: Row(
          children: [
            const Icon(
              Icons.location_off_rounded,
              color: Color(0xFFEF4444),
              size: 20,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                _errorMessage,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFDC2626),
                ),
              ),
            ),

            IconButton(
              onPressed: () {
                setState(() {
                  _isLoadingJarak = true;
                  _errorMessage = '';
                });

                _hitungJarak();
              },
              tooltip: 'Coba lagi',
              icon: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFBBF7D0),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.near_me_rounded,
              color: Color(0xFF16A34A),
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jarak dari posisi Anda',
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryText,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _formatJarak(_jarakMeter!),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF16A34A),
            size: 22,
          ),
        ],
      ),
    );
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    final k = widget.kunjungan;

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
              'Detail Kunjungan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),

            SizedBox(height: 4),

            Text(
              'Informasi lengkap pelanggan',
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
          20, 12, 20, 32,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // CUSTOMER HEADER
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF3B82F6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),

              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.business_rounded,
                      color: Colors.white,
                      size: 29,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PELANGGAN',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          k.namaPelanggan,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // CUSTOMER INFORMATION CARD
            Container(
              padding: const EdgeInsets.all(18),

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

                  _sectionHeader(
                    icon: Icons.person_outline_rounded,
                    title: 'Informasi Pelanggan',
                    subtitle: 'Detail data kunjungan pelanggan.',
                  ),

                  const SizedBox(height: 22),

                  _infoRow(
                    icon: Icons.location_on_outlined,
                    title: 'Alamat',
                    value: k.alamat,
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(
                      height: 1,
                      color: Color(0xFFEAEFF5),
                    ),
                  ),

                  _infoRow(
                    icon: Icons.phone_outlined,
                    title: 'Nomor HP',
                    value: k.noHp,
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(
                      height: 1,
                      color: Color(0xFFEAEFF5),
                    ),
                  ),

                  _infoRow(
                    icon: Icons.notes_rounded,
                    title: 'Catatan',
                    value: k.catatan.isEmpty ? '-' : k.catatan,
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(
                      height: 1,
                      color: Color(0xFFEAEFF5),
                    ),
                  ),

                  _infoRow(
                    icon: Icons.calendar_today_rounded,
                    title: 'Waktu Kunjungan',
                    value: k.tanggal,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // LOCATION CARD
            Container(
              padding: const EdgeInsets.all(18),

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

                  _sectionHeader(
                    icon: Icons.map_outlined,
                    title: 'Lokasi Kunjungan',
                    subtitle: 'Informasi koordinat dan jarak lokasi.',
                  ),

                  const SizedBox(height: 20),

                  // COORDINATES
                  Container(
                    padding: const EdgeInsets.all(15),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(13),
                    ),

                    child: Column(
                      children: [
                        _coordinateRow(
                          'Latitude',
                          k.latitude.toStringAsFixed(6),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            height: 1,
                            color: Color(0xFFE2E8F0),
                          ),
                        ),

                        _coordinateRow(
                          'Longitude',
                          k.longitude.toStringAsFixed(6),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // DISTANCE
                  _buildDistanceInfo(),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // GOOGLE MAPS BUTTON
            SizedBox(
              height: 54,

              child: ElevatedButton.icon(
                onPressed: _bukaNavigasi,

                icon: const Icon(
                  Icons.directions_rounded,
                  size: 21,
                ),

                label: const Text(
                  'NAVIGASI KE LOKASI',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

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
