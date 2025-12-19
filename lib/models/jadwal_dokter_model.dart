class JadwalDokterModel {
  final String idJadwalDokter;
  final int idDokter;
  final String namaDokter;
  final String namaPoli;
  final String tanggal;
  final String jamMulai;
  final String jamSelesai;
  final String status;

  JadwalDokterModel({
    required this.idJadwalDokter,
    required this.idDokter,
    required this.namaDokter,
    required this.namaPoli,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.status,
  });

  factory JadwalDokterModel.fromJson(Map<String, dynamic> json) {
    return JadwalDokterModel(
      idJadwalDokter: json['id_jadwal_dokter']?.toString() ?? '',
      idDokter: int.tryParse(json['id_dokter']?.toString() ?? '0') ?? 0,
      namaDokter: json['nama_dokter']?.toString() ?? '',
      namaPoli: json['nama_poli']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? '',
      jamMulai: json['jam_mulai']?.toString() ?? '',
      jamSelesai: json['jam_selesai']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}
