class ApmAntrianModel {
  final String id;
  final String pasien;
  final String alamatDomisili;
  final String tglLahir;
  final String poli;
  final String noCheckinPoli;

  final String? rm;
  final String noPeserta;
  final String? jenisBooking;
  final String? noIdentitas;
  final String? noBooking;
  final String? idDokter;
  final String? idJadwalDokter;
  final String? idLayanan;
  final String? namaDokter;

  final String noAntrian;
  final int? statusBooking;

  ApmAntrianModel({
    required this.id,
    required this.pasien,
    required this.alamatDomisili,
    required this.tglLahir,
    required this.poli,
    required this.noAntrian,
    required this.noCheckinPoli,
    this.rm,
    required this.noPeserta,
    this.jenisBooking,
    this.noIdentitas,
    this.noBooking,
    this.idDokter,
    this.idJadwalDokter,
    this.idLayanan,
    this.statusBooking,
    this.namaDokter,
  });

  factory ApmAntrianModel.fromJson(Map<String, dynamic> json) {
    return ApmAntrianModel(
      id: json['id']?.toString() ?? '',
      pasien: json['nama_pasien'] ?? json['pasien'] ?? '',
      alamatDomisili: json['alamat_domisili'] ?? json['alamat'] ?? '',
      tglLahir: json['tgl_lahir']?.toString() ?? '',
      poli: json['nama_poli']?.toString() ?? '',
      noCheckinPoli: json['no_checkin']?.toString() ?? '',
      noAntrian: json['no_antrian']?.toString() ?? '',
      rm: json['rm']?.toString(),
      noPeserta: json['no_peserta']?.toString() ?? '',
      jenisBooking: json['jaminan'] ?? json['jenis_booking']?.toString() ?? '',
      noIdentitas: json['no_identitas']?.toString(),
      noBooking: json['no_booking']?.toString() ?? json['id']?.toString() ?? '',
      idDokter: json['id_dokter']?.toString(),
      idJadwalDokter: json['id_jadwal_dokter']?.toString(),
      idLayanan: json['id_layanan']?.toString(),
      statusBooking: int.tryParse(json['status_booking']?.toString() ?? ''),
      namaDokter: json['nama_dokter']?.toString() ?? '',
    );
  }

  bool get isDibatalkan => statusBooking == 3 || statusBooking == 4;
}
