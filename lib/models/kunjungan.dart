class Kunjungan {
  int? id;
  String namaPelanggan;
  String alamat;
  String noHp;
  String catatan;
  double latitude;
  double longitude;
  String tanggal;

  Kunjungan({
    this.id,
    required this.namaPelanggan,
    required this.alamat,
    required this.noHp,
    required this.catatan,
    required this.latitude,
    required this.longitude,
    required this.tanggal,
  });

  // Konversi dari Object ke Map (untuk Insert/Update SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_pelanggan': namaPelanggan,
      'alamat': alamat,
      'no_hp': noHp,
      'catatan': catatan,
      'latitude': latitude,
      'longitude': longitude,
      'tanggal': tanggal,
    };
  }

  // Konversi dari Map SQLite ke Object Kunjungan
  factory Kunjungan.fromMap(Map<String, dynamic> map) {
    return Kunjungan(
      id: map['id'],
      namaPelanggan: map['nama_pelanggan'],
      alamat: map['alamat'],
      noHp: map['no_hp'],
      catatan: map['catatan'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      tanggal: map['tanggal'],
    );
  }
}