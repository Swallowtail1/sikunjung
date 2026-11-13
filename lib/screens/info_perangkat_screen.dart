
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class InfoPerangkatScreen extends StatefulWidget {
  const InfoPerangkatScreen({super.key});

  @override
  State<InfoPerangkatScreen> createState() =>
      _InfoPerangkatScreenState();
}

class _InfoPerangkatScreenState
    extends State<InfoPerangkatScreen> {

  // DEVICE VARIABLES
  String _osName = '-';
  String _osVersion = '-';
  String _deviceBrand = '-';
  String _deviceModel = '-';

  // APPLICATION VARIABLES
  String _appName = '-';
  String _appVersion = '-';

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
    _loadInformation();
  }

  // LOAD DEVICE AND APPLICATION INFORMATION
  Future<void> _loadInformation() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      final PackageInfo packageInfo =
      await PackageInfo.fromPlatform();

      String osName = '-';
      String osVersion = '-';
      String deviceBrand = '-';
      String deviceModel = '-';

      // APPLICATION INFORMATION
      final appName = packageInfo.appName.isEmpty
          ? 'SiKunjung'
          : packageInfo.appName;

      final appVersion =
          '${packageInfo.version} (Build ${packageInfo.buildNumber})';

      // ANDROID INFORMATION
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo =
        await deviceInfo.androidInfo;

        osName = 'Android';

        osVersion =
        '${androidInfo.version.release} '
            '(API Level ${androidInfo.version.sdkInt})';

        deviceBrand = androidInfo.brand.toUpperCase();
        deviceModel = androidInfo.model;
      }

      // IOS INFORMATION
      else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo =
        await deviceInfo.iosInfo;

        osName = 'iOS';
        osVersion = iosInfo.systemVersion;
        deviceBrand = 'Apple';
        deviceModel = iosInfo.name;
      }

      if (!mounted) return;

      setState(() {
        _appName = appName;
        _appVersion = appVersion;

        _osName = osName;
        _osVersion = osVersion;
        _deviceBrand = deviceBrand;
        _deviceModel = deviceModel;

        _isLoading = false;
        _errorMessage = '';
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Gagal mengambil informasi perangkat. '
            'Silakan coba kembali.';
      });
    }
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

  // INFORMATION ROW
  Widget _buildInfoRow(
      String title,
      String value, {
        IconData icon = Icons.info_outline_rounded,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: secondaryText,
            size: 19,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: secondaryText,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: darkText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // INFORMATION CARD
  Widget _buildInformationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
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
            icon: icon,
            title: title,
            subtitle: subtitle,
          ),

          const SizedBox(height: 16),

          const Divider(
            height: 1,
            color: Color(0xFFEAEFF5),
          ),

          ...children,
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
            'Mengambil informasi perangkat...',
            style: TextStyle(
              fontSize: 12,
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
                Icons.error_outline_rounded,
                color: Color(0xFFEF4444),
                size: 38,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Gagal Memuat Informasi',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: secondaryText,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });

                _loadInformation();
              },

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

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    final deviceName = '$_deviceBrand $_deviceModel'.trim();

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
              'Info Perangkat',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),

            SizedBox(height: 4),

            Text(
              'Informasi sistem dan perangkat',
              style: TextStyle(
                fontSize: 11,
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
              onPressed: _isLoading
                  ? null
                  : () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });

                _loadInformation();
              },

              tooltip: 'Refresh Informasi',

              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryBlue,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),

      // BODY
      body: _isLoading
          ? _buildLoading()
          : _errorMessage.isNotEmpty
          ? _buildError()
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20, 12, 20, 30,
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,

          children: [

            // DEVICE SUMMARY CARD
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

                borderRadius:
                BorderRadius.circular(20),

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
                    width: 58,
                    height: 58,

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius:
                      BorderRadius.circular(16),
                    ),

                    child: const Icon(
                      Icons.smartphone_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'PERANGKAT AKTIF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          deviceName == ' -' ||
                              deviceName.trim().isEmpty
                              ? 'Perangkat Anda'
                              : deviceName,

                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          '$_osName • $_osVersion',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // APPLICATION INFORMATION
            _buildInformationCard(
              icon: Icons.apps_rounded,
              title: 'Informasi Aplikasi',
              subtitle: 'Detail aplikasi SiKunjung.',

              children: [
                _buildInfoRow(
                  'Nama Aplikasi',
                  _appName,
                  icon: Icons.app_registration_rounded,
                ),

                const Divider(
                  height: 1,
                  color: Color(0xFFEAEFF5),
                ),

                _buildInfoRow(
                  'Versi Aplikasi',
                  _appVersion,
                  icon: Icons.new_releases_outlined,
                ),

                const Divider(
                  height: 1,
                  color: Color(0xFFEAEFF5),
                ),

                _buildInfoRow(
                  'Bahasa Pemrograman',
                  'Dart (Flutter SDK)',
                  icon: Icons.code_rounded,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // DEVICE INFORMATION
            _buildInformationCard(
              icon: Icons.devices_rounded,
              title: 'Informasi Perangkat',
              subtitle: 'Detail perangkat yang digunakan.',

              children: [
                _buildInfoRow(
                  'Sistem Operasi',
                  _osName,
                  icon: Icons.settings_system_daydream_outlined,
                ),

                const Divider(
                  height: 1,
                  color: Color(0xFFEAEFF5),
                ),

                _buildInfoRow(
                  'Versi OS',
                  _osVersion,
                  icon: Icons.system_update_alt_rounded,
                ),

                const Divider(
                  height: 1,
                  color: Color(0xFFEAEFF5),
                ),

                _buildInfoRow(
                  'Merek Perangkat',
                  _deviceBrand,
                  icon: Icons.business_rounded,
                ),

                const Divider(
                  height: 1,
                  color: Color(0xFFEAEFF5),
                ),

                _buildInfoRow(
                  'Model Perangkat',
                  _deviceModel,
                  icon: Icons.phone_android_rounded,
                ),
              ],
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
