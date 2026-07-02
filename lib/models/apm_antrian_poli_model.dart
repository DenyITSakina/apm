class ApmAntrianPoliModel {
  String noBooking;
  String noAntrianPoli;
  String nama;
  String rm;
  String noChekinPoli;
  String namaPoli;
  int idDokter;
  String tanggalLahir;
  String tanggalBooking;
  String jamBooking;
  String idJadwalDokter;
  int idLayanan;

  ApmAntrianPoliModel({
    required this.noBooking,
    required this.noAntrianPoli,
    required this.noChekinPoli,
    required this.nama,
    required this.rm,
    required this.namaPoli,
    required this.idDokter,
    required this.tanggalLahir,
    required this.jamBooking,
    required this.tanggalBooking,

    required this.idJadwalDokter,
    required this.idLayanan,
  });

  //   factory ApmAntrianPoliModel.fromJson(
  //     Map<String, dynamic> data, {
  //     String namaPoliRoot = '',
  //   }) {
  //     return ApmAntrianPoliModel(
  //       noBooking: data['id']?.toString() ?? '',
  //       noAntrianPoli: data['no_antrian']?.toString() ?? '',
  //       noChekinPoli: data['no_checkin']?.toString() ?? '',
  //       nama: data['nama'] ?? '',
  //       rm: data['rm']?.toString() ?? '',
  //       namaPoli:
  //           data['nama_unit']?.toString() ??
  //           data['nama_poli']?.toString() ??
  //           namaPoliRoot,
  //       idDokter: int.tryParse(data['id_dokter']?.toString() ?? '0') ?? 0,
  //       idJadwalDokter: data['id_jadwal_dokter']?.toString() ?? '',
  //       idLayanan: int.tryParse(data['id_layanan']?.toString() ?? '0') ?? 0,
  //     );
  //   }
  // }

  factory ApmAntrianPoliModel.fromJson(Map<String, dynamic> json) {
    // API sekarang bentuknya:
    // json['data']['data'] = payload utama
    // json['data']['no_checkin'] = nilai root tambahan
    final rootData = (json['data'] as Map<String, dynamic>?) ?? {};
    final data = (rootData['data'] as Map<String, dynamic>?) ?? rootData;

    return ApmAntrianPoliModel(
      noBooking: data['id']?.toString() ?? '',
      noAntrianPoli: data['no_antrian']?.toString() ?? '',
      noChekinPoli: rootData['no_checkin']?.toString() ?? '',
      nama: data['nama'] ?? '',
      rm: data['rm']?.toString() ?? '',
      namaPoli: data['nama_poli'] ?? '',
      idDokter: int.tryParse(data['id_dokter']?.toString() ?? '0') ?? 0,
      idJadwalDokter: data['id_jadwal_dokter']?.toString() ?? '',
      idLayanan: int.tryParse(data['id_unit']?.toString() ?? '0') ?? 0,
      tanggalLahir: data['tanggal_lahir']?.toString() ?? '',
      tanggalBooking: data['tanggal_booking']?.toString() ?? '',
      jamBooking: data['jam_booking']?.toString() ?? '',
    );
  }
}
