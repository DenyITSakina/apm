class PendaftaranPoliModel {
  final String id;
  final String rm;
  final String nama;
  final String namaPoli;
  final String namaDokter;
  final String idUnit;
  final String idJaminan;
  final String? idAsuransi;
  final String idJadwalDokter;
  final String idDokter;
  final String grupJaminan;
  final String noAntrian;
  final String tglLahir;
  final String noCheckin;
  final String? noBooking;
  final String createdAt;
  final String tglMasuk;
  final String jamMasuk;
  final int umurTahun;
  final String jenisKelamin;

  PendaftaranPoliModel({
    required this.id,
    required this.rm,
    required this.nama,
    required this.namaPoli,
    required this.namaDokter,
    required this.idUnit,
    required this.idJaminan,
    this.idAsuransi,
    required this.idJadwalDokter,
    required this.idDokter,
    required this.grupJaminan,
    required this.noAntrian,
    required this.tglLahir,
    required this.noCheckin,
    this.noBooking,
    required this.createdAt,
    required this.tglMasuk,
    required this.jamMasuk,
    required this.umurTahun,
    required this.jenisKelamin,
  });

  factory PendaftaranPoliModel.fromJson(Map<String, dynamic> json) {
    final nestedData = json['data'] ?? {};

    return PendaftaranPoliModel(
      id: nestedData['id']?.toString() ?? '',
      rm: nestedData['rm']?.toString() ?? '',
      nama: nestedData['nama']?.toString() ?? '',
      idUnit: nestedData['id_unit']?.toString() ?? '',
      idJaminan: nestedData['id_jaminan']?.toString() ?? '',
      idAsuransi: nestedData['id_asuransi']?.toString(),
      idDokter: nestedData['id_dokter']?.toString() ?? '',
      idJadwalDokter: nestedData['id_jadwal_dokter']?.toString() ?? '',
      grupJaminan: nestedData['grup_jaminan']?.toString() ?? '',
      noBooking: nestedData['id_booking']?.toString(),
      createdAt: nestedData['created_at']?.toString() ?? '',
      tglMasuk: nestedData['tgl_masuk']?.toString() ?? '',
      jamMasuk: nestedData['jam_masuk']?.toString() ?? '',
      umurTahun: nestedData['umur_tahun'] as int? ?? 0,
      jenisKelamin: nestedData['jenis_kelamin']?.toString() ?? '',
      namaPoli: json['nama_poli']?.toString() ?? '',
      namaDokter: json['nama_dokter']?.toString() ?? '',
      noAntrian:
          json['no_antrian']?.toString() ??
          nestedData['no_antrian']?.toString() ??
          '',
      tglLahir: nestedData['tgl_lahir']?.toString() ?? '',
      noCheckin:
          json['no_checkin']?.toString() ??
          nestedData['no_checkin']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rm': rm,
      'nama': nama,
      'nama_poli': namaPoli,
      'nama_dokter': namaDokter,
      'id_unit': idUnit,
      'id_jaminan': idJaminan,
      'id_asuransi': idAsuransi,
      'id_jadwal_dokter': idJadwalDokter,
      'id_dokter': idDokter,
      'grup_jaminan': grupJaminan,
      'no_antrian': noAntrian,
      'tgl_lahir': tglLahir,
      'no_checkin': noCheckin,
      'id_booking': noBooking,
      'created_at': createdAt,
      'tgl_masuk': tglMasuk,
      'jam_masuk': jamMasuk,
      'umur_tahun': umurTahun,
      'jenis_kelamin': jenisKelamin,
    };
  }
}
