class PendaftaranPoliModel {
  final String id;
  final String rm;
  final String nama;
  final String namaPoli;
  final String idUnit;
  final String idJaminan;
  final String idJadwalDokter;
  final String idDokter;
  final String grupJaminan;
  final String noAntrian;
  final String createdAt;

  PendaftaranPoliModel({
    required this.id,
    required this.rm,
    required this.nama,
    required this.namaPoli,
    required this.idUnit,
    required this.idJaminan,
    required this.idJadwalDokter,
    required this.idDokter,
    required this.grupJaminan,
    required this.noAntrian,
    required this.createdAt,
  });

  factory PendaftaranPoliModel.fromJson(Map<String, dynamic> json) {
    return PendaftaranPoliModel(
      id: json['id']?.toString() ?? '',
      rm: json['rm']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      namaPoli: json['nama_poli']?.toString() ?? '',
      idUnit: json['id_unit']?.toString() ?? '',
      idJaminan: json['id_jaminan']?.toString() ?? '',
      idDokter: json['id_dokter']?.toString() ?? '',
      idJadwalDokter: json['id_jadwal_dokter']?.toString() ?? '',
      grupJaminan: json['grup_jaminan']?.toString() ?? '',
      noAntrian: json['no_antrian']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
