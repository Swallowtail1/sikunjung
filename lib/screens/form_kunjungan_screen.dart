
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/kunjungan.dart';
import '../database/database_helper.dart';
import '../services/location_service.dart';

class FormKunjunganScreen extends StatefulWidget {
  final Kunjungan? kunjungan;

  const FormKunjunganScreen({
    super.key,
    this.kunjungan,
  });

  @override
  State<FormKunjunganScreen> createState() =>
      _FormKunjunganScreenState();
}

class _FormKunjunganScreenState
    extends State<FormKunjunganScreen> {

  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noHpController = TextEditingController();
  final _catatanController = TextEditingController();

  final _locationService = LocationService();

  // STATE
  double? _latitude;
  double? _longitude;

  bool _isLoadingLocation = false;
  bool _isSaving = false;

  bool get _isEditMode => widget.kunjungan != null;

  // COLOR PALETTE
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkText = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color backgroundColor = Color(0xFFF5F7FB);

  // INITIALIZATION
  @override
  void initState() {
    super.initState();

    if (_isEditMode) {
      _namaController.text =
          widget.kunjungan!.namaPelanggan;

      _alamatController.text =
          widget.kunjungan!.alamat;

      _noHpController.text =
          widget.kunjungan!.noHp;

      _catatanController.text =
          widget.kunjungan!.catatan;

      _latitude = widget.kunjungan!.latitude;
      _longitude = widget.kunjungan!.longitude;
    }
  }

  // INPUT DECORATION
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(
        fontSize: 13,
        color: Color(0xFF94A3B8),
      ),

      prefixIcon: Icon(
        icon,
        size: 20,
        color: secondaryText,
      ),

      filled: true,
      fillColor: const Color(0xFFF8FAFC),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: primaryBlue,
          width: 1.4,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.4,
        ),
      ),
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

  // FIELD LABEL
  Widget _fieldLabel(String label, {bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: darkText,
            ),
          ),

          if (optional) ...[
            const SizedBox(width: 6),

            const Text(
              '(Opsional)',
              style: TextStyle(
                fontSize: 10,
                color: secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // GET CURRENT LOCATION
  Future<void> _ambilLokasiTerkini() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position =
      await _locationService.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi berhasil didapatkan!'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  // SAVE DATA
  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harap ambil lokasi GPS terlebih dahulu!',
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    // CURRENT DATE
    final tanggalSekarang =
    DateFormat('dd MMM yyyy, HH:mm')
        .format(DateTime.now());

    // VISIT DATA
    final kunjunganData = Kunjungan(
      id: _isEditMode
          ? widget.kunjungan!.id
          : null,

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
        await DatabaseHelper.instance
            .updateKunjungan(kunjunganData);
      } else {
        await DatabaseHelper.instance
            .insertKunjungan(kunjunganData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Data kunjungan berhasil diperbarui'
                  : 'Data kunjungan berhasil disimpan',
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan data'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    final bool hasLocation =
        _latitude != null && _longitude != null;

    return Scaffold(
      backgroundColor: backgroundColor,

      // APP BAR
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,

        toolbarHeight: 72,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode
                  ? 'Edit Kunjungan'
                  : 'Tambah Kunjungan',

              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Sistem Informasi Kunjungan',
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

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // INTRODUCTION CARD
              Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(17),
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons.assignment_add,
                      color: primaryBlue,
                      size: 30,
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditMode
                                ? 'Perbarui Data Kunjungan'
                                : 'Buat Data Kunjungan',

                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            _isEditMode
                                ? 'Pastikan informasi pelanggan sudah benar.'
                                : 'Lengkapi informasi pelanggan dan lokasi kunjungan.',

                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: secondaryText,
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
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    // SECTION TITLE
                    _sectionHeader(
                      icon: Icons.business_rounded,
                      title: 'Informasi Pelanggan',
                      subtitle: 'Masukkan detail pelanggan yang dikunjungi.',
                    ),

                    const SizedBox(height: 24),

                    // CUSTOMER NAME
                    _fieldLabel('Nama Pelanggan'),

                    TextFormField(
                      controller: _namaController,

                      textCapitalization:
                      TextCapitalization.words,

                      textInputAction: TextInputAction.next,

                      decoration: _inputDecoration(
                        hint: 'Masukkan nama pelanggan',
                        icon: Icons.person_outline_rounded,
                      ),

                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ADDRESS
                    _fieldLabel('Alamat'),

                    TextFormField(
                      controller: _alamatController,

                      maxLines: 3,
                      minLines: 2,

                      textCapitalization:
                      TextCapitalization.sentences,

                      decoration: _inputDecoration(
                        hint: 'Masukkan alamat lengkap',
                        icon: Icons.location_on_outlined,
                      ),

                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // PHONE NUMBER
                    _fieldLabel('Nomor HP'),

                    TextFormField(
                      controller: _noHpController,

                      keyboardType: TextInputType.phone,

                      textInputAction: TextInputAction.next,

                      decoration: _inputDecoration(
                        hint: 'Contoh: 081234567890',
                        icon: Icons.phone_outlined,
                      ),

                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'No. HP tidak boleh kosong';
                        }

                        if (!RegExp(r'^[0-9]+$')
                            .hasMatch(value.trim())) {
                          return 'No. HP hanya boleh berisi angka';
                        }

                        if (value.trim().length < 10) {
                          return 'No. HP minimal 10 digit';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // NOTES
                    _fieldLabel(
                      'Catatan',
                      optional: true,
                    ),

                    TextFormField(
                      controller: _catatanController,

                      maxLines: 4,
                      minLines: 3,

                      textCapitalization:
                      TextCapitalization.sentences,

                      decoration: _inputDecoration(
                        hint: 'Tambahkan catatan jika diperlukan...',
                        icon: Icons.notes_rounded,
                      ),
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
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    // LOCATION HEADER
                    _sectionHeader(
                      icon: Icons.location_on_rounded,
                      title: 'Lokasi Kunjungan',
                      subtitle: 'Ambil koordinat GPS lokasi pelanggan.',
                    ),

                    const SizedBox(height: 20),

                    // LOCATION STATUS
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: hasLocation
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFF8FAFC),

                        borderRadius: BorderRadius.circular(13),

                        border: Border.all(
                          color: hasLocation
                              ? const Color(0xFFBBF7D0)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          // STATUS
                          Row(
                            children: [
                              Icon(
                                hasLocation
                                    ? Icons.check_circle_rounded
                                    : Icons.info_outline_rounded,

                                size: 17,

                                color: hasLocation
                                    ? const Color(0xFF16A34A)
                                    : secondaryText,
                              ),

                              const SizedBox(width: 7),

                              Text(
                                hasLocation
                                    ? 'Lokasi berhasil diperoleh'
                                    : 'Lokasi belum diambil',

                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,

                                  color: hasLocation
                                      ? const Color(0xFF16A34A)
                                      : secondaryText,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // COORDINATES
                          if (hasLocation) ...[
                            _coordinateRow(
                              'Latitude',
                              _latitude!.toStringAsFixed(6),
                            ),

                            const SizedBox(height: 8),

                            _coordinateRow(
                              'Longitude',
                              _longitude!.toStringAsFixed(6),
                            ),
                          ] else
                            const Text(
                              'Tekan tombol di bawah untuk '
                                  'mengambil koordinat lokasi terkini.',

                              style: TextStyle(
                                fontSize: 11,
                                height: 1.5,
                                color: secondaryText,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // GET LOCATION BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 48,

                      child: OutlinedButton.icon(
                        onPressed: _isLoadingLocation
                            ? null
                            : _ambilLokasiTerkini,

                        icon: _isLoadingLocation
                            ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Icon(
                          Icons.my_location_rounded,
                          size: 19,
                        ),

                        label: Text(
                          _isLoadingLocation
                              ? 'Mengambil lokasi...'
                              : hasLocation
                              ? 'Perbarui Lokasi'
                              : 'Ambil Lokasi GPS',
                        ),

                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryBlue,

                          side: const BorderSide(
                            color: primaryBlue,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // SAVE BUTTON
              SizedBox(
                height: 54,

                child: ElevatedButton(
                  onPressed: _isSaving ? null : _simpanData,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                    primaryBlue.withOpacity(0.6),

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  child: _isSaving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isEditMode
                            ? Icons.save_rounded
                            : Icons.add_task_rounded,
                        size: 20,
                      ),

                      const SizedBox(width: 10),

                      Text(
                        _isEditMode
                            ? 'SIMPAN PERUBAHAN'
                            : 'SIMPAN KUNJUNGAN',

                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              const Center(
                child: Text(
                  'Pastikan seluruh informasi sudah benar sebelum menyimpan.',
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
      ),
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
            fontSize: 11,
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

  // DISPOSE
  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    _catatanController.dispose();

    super.dispose();
  }
}
