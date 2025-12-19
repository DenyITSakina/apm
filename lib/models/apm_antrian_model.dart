class ApmAntrianModel {
  final String id; // id pasienBooking → bisa dipakai noBooking
  final String pasien;
  final String alamatDomisili;
  final String tglLahir;
  final String namaPoli;

  final String? rm;
  final String? noPeserta;
  final String? jenisBooking;
  final String? noIdentitas;
  final String? noBooking; // <- baru
  final String? idDokter;
  final String? idJadwalDokter;
  final String? idLayanan;

  final String noAntrian;
  final int? statusBooking;

  ApmAntrianModel({
    required this.id,
    required this.pasien,
    required this.alamatDomisili,
    required this.tglLahir,
    required this.namaPoli,
    required this.noAntrian,
    this.rm,
    this.noPeserta,
    this.jenisBooking,
    this.noIdentitas,
    this.noBooking,
    this.idDokter,
    this.idJadwalDokter,
    this.idLayanan,
    this.statusBooking,
  });

  factory ApmAntrianModel.fromJson(Map<String, dynamic> json) {
    return ApmAntrianModel(
      id: json['id']?.toString() ?? '',
      pasien: json['nama_pasien'] ?? json['pasien'] ?? '',
      alamatDomisili: json['alamat_domisili'] ?? json['alamat'] ?? '',
      tglLahir: json['tgl_lahir']?.toString() ?? '',
      namaPoli: json['nama_poli'] ?? '',
      noAntrian: json['no_antrian']?.toString() ?? '',
      rm: json['rm']?.toString(),
      noPeserta: json['no_peserta']?.toString(),
      jenisBooking: json['jaminan'] ?? json['jenis_booking']?.toString(),
      noIdentitas: json['no_identitas']?.toString(),
      noBooking: json['no_booking']?.toString() ?? json['id']?.toString(),
      idDokter: json['id_dokter']?.toString(),
      idJadwalDokter: json['id_jadwal_dokter']?.toString(),
      idLayanan: json['id_layanan']?.toString(),
      statusBooking: int.tryParse(json['status_booking']?.toString() ?? ''),
    );
  }

  bool get isDibatalkan => statusBooking == 3 || statusBooking == 4;
}
