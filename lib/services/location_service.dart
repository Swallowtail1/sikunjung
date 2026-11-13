import 'package:geolocator/geolocator.dart';

class LocationService {
  // Fungsi untuk meminta izin dan mengambil posisi GPS
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah GPS perangkat menyala
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi dinonaktifkan. Harap nyalakan GPS.');
    }

    // Cek izin (Permission) aplikasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); // Minta izin runtime
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak pengguna.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Izin lokasi ditolak secara permanen. Buka pengaturan aplikasi.');
    }

    // Ambil koordinat dengan akurasi tinggi
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}