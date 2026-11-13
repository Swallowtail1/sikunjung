
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../widgets/kunjungan_card.dart';
import '../models/kunjungan.dart';
import '../database/database_helper.dart';

import 'form_kunjungan_screen.dart';
import 'detail_kunjungan_screen.dart';

class DaftarKunjunganScreen extends StatefulWidget {
  const DaftarKunjunganScreen({super.key});

  @override
  State<DaftarKunjunganScreen> createState() =>
      _DaftarKunjunganScreenState();
}

class _DaftarKunjunganScreenState
    extends State<DaftarKunjunganScreen> {

  // DATA
  List<Kunjungan> _semuaKunjungan = [];
  List<Kunjungan> _kunjunganTampil = [];

  String _searchQuery = '';

  StreamSubscription<AccelerometerEvent>?
  _accelerometerSubscription;

  DateTime _lastShakeTime = DateTime.now();

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF5F7FB);
  static const Color darkText = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);

  // INITIALIZATION
  @override
  void initState() {
    super.initState();

    _loadData();
    _initShakeToRefresh();
  }

  // LOAD DATA FROM SQLITE
  Future<void> _loadData() async {
    final data =
    await DatabaseHelper.instance.getAllKunjungan();

    if (!mounted) return;

    final query = _searchQuery.toLowerCase();

    final filteredData = query.isEmpty
        ? data
        : data.where((k) {
      return k.namaPelanggan
          .toLowerCase()
          .contains(query) ||
          k.alamat.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _semuaKunjungan = data;
      _kunjunganTampil = filteredData;
    });
  }

  // SEARCH FILTER
  void _filterKunjungan(String query) {
    final normalizedQuery = query.toLowerCase();

    setState(() {
      _searchQuery = query;

      _kunjunganTampil = _semuaKunjungan.where((k) {
        return k.namaPelanggan
            .toLowerCase()
            .contains(normalizedQuery) ||
            k.alamat
                .toLowerCase()
                .contains(normalizedQuery);
      }).toList();
    });
  }

  // SHAKE TO REFRESH
  void _initShakeToRefresh() {
    _accelerometerSubscription =
        accelerometerEventStream().listen(
              (AccelerometerEvent event) {
            final acceleration = sqrt(
              event.x * event.x +
                  event.y * event.y +
                  event.z * event.z,
            );

            if (acceleration > 15) {
              final now = DateTime.now();

              if (now.difference(_lastShakeTime).inSeconds > 2) {
                _lastShakeTime = now;

                _loadData();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Daftar kunjungan berhasil diperbarui.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            }
          },
        );
  }

  // DELETE CONFIRMATION
  void _konfirmasiHapus(Kunjungan kunjungan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        title: const Text(
          'Hapus Kunjungan?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),

        content: Text(
          'Apakah Anda yakin ingin menghapus data kunjungan '
              'ke ${kunjungan.namaPelanggan}?',
          style: const TextStyle(
            color: secondaryText,
            height: 1.5,
          ),
        ),

        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: secondaryText),
            ),
          ),

          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);

              await DatabaseHelper.instance
                  .deleteKunjungan(kunjungan.id!);

              await _loadData();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil dihapus'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // ADD VISIT
  void _tambahKunjungan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormKunjunganScreen(),
      ),
    ).then((_) => _loadData());
  }

  // OPEN DETAIL
  void _bukaDetail(Kunjungan item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailKunjunganScreen(
          kunjungan: item,
        ),
      ),
    );
  }

  // EDIT VISIT
  void _editKunjungan(Kunjungan item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormKunjunganScreen(
          kunjungan: item,
        ),
      ),
    ).then((_) => _loadData());
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  // EMPTY STATE
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(25),
              ),

              child: Icon(
                icon,
                color: primaryBlue,
                size: 40,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BUILD CARD
  Widget _buildKunjunganCard(Kunjungan item) {
    return KunjunganCard(
      kunjungan: item,
      onTap: () => _bukaDetail(item),
      onEdit: () => _editKunjungan(item),
      onDelete: () => _konfirmasiHapus(item),
    );
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation ==
            Orientation.landscape;

    return Scaffold(
      backgroundColor: backgroundColor,

      // APP BAR
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,

        toolbarHeight: 75,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Daftar Kunjungan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),

            SizedBox(height: 4),

            Text(
              'Kelola data kunjungan lapangan',
              style: TextStyle(
                fontSize: 11,
                color: secondaryText,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),

      // ADD BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahKunjungan,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,

        icon: const Icon(Icons.add_rounded),

        label: const Text(
          'Tambah Kunjungan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // BODY
      body: Column(
        children: [

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20, 12, 20, 20,
            ),

            child: TextField(
              onChanged: _filterKunjungan,

              decoration: InputDecoration(
                hintText: 'Cari nama pelanggan atau alamat...',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                ),

                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: secondaryText,
                ),

                filled: true,
                fillColor: Colors.white,

                contentPadding: const EdgeInsets.symmetric(
                  vertical: 17,
                  horizontal: 16,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color(0xFFEAEFF5),
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: primaryBlue,
                    width: 1.3,
                  ),
                ),
              ),
            ),
          ),

          // SECTION HEADER
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Data Kunjungan',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    '${_kunjunganTampil.length} Data',

                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // SHAKE REFRESH INFORMATION
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.vibration_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),

                const SizedBox(width: 6),

                Text(
                  'Goyangkan perangkat untuk memperbarui data',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // DATA LIST
          Expanded(
            child: Builder(
              builder: (context) {

                if (_semuaKunjungan.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.folder_open_rounded,
                    title: 'Belum Ada Kunjungan',
                    description:
                    'Data kunjungan belum tersedia. '
                        'Tambahkan kunjungan baru untuk mulai mengisi daftar.',
                  );
                }

                if (_kunjunganTampil.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Data Tidak Ditemukan',
                    description:
                    'Coba gunakan kata kunci lain untuk '
                        'menemukan data kunjungan.',
                  );
                }

                // LANDSCAPE GRID
                if (isLandscape) {
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      20, 4, 20, 100,
                    ),

                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),

                    itemCount: _kunjunganTampil.length,

                    itemBuilder: (context, index) {
                      final item = _kunjunganTampil[index];
                      return _buildKunjunganCard(item);
                    },
                  );
                }

                // PORTRAIT LIST
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    20, 4, 20, 100,
                  ),

                  itemCount: _kunjunganTampil.length,

                  itemBuilder: (context, index) {
                    final item = _kunjunganTampil[index];

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 14,
                      ),

                      child: _buildKunjunganCard(item),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
