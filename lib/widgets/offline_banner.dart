import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final bool isOffline;

  const OfflineBanner({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    // Jika sedang online, kembalikan widget kosong (tidak memakan tempat)
    if (!isOffline) return const SizedBox.shrink();

    // Jika offline, tampilkan banner merah[cite: 1]
    return Container(
      width: double.infinity,
      color: Colors.redAccent,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: const Text(
        'Anda sedang Offline. Beberapa fitur (Peta) mungkin tidak tersedia.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}