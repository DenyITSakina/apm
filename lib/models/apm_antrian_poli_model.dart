class ApmAntrianPoliModel {
  String noBooking;
  String noAntrianPoli;
  String nama;
  String rm;
  String noChekinPoli;
  String namaPoli;
  int idDokter;
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
    final data = json['data'] ?? {};

    return ApmAntrianPoliModel(
      noBooking: data['id']?.toString() ?? '',
      noAntrianPoli: data['no_antrian']?.toString() ?? '',
      noChekinPoli: json['no_checkin']?.toString() ?? '', // ambil dari root
      nama: data['nama'] ?? '',
      rm: data['rm']?.toString() ?? '',
      namaPoli: data['nama_poli'] ?? '',
      idDokter: int.tryParse(data['id_dokter']?.toString() ?? '0') ?? 0,
      idJadwalDokter: data['id_jadwal_dokter']?.toString() ?? '',
      idLayanan: int.tryParse(data['id_unit']?.toString() ?? '0') ?? 0,
    );
  }
}
