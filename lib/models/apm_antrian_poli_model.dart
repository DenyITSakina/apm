// class ApmAntrianPoliModel {
//   final String noBooking;
//   final String noAntrianPoli;
//   final String namaPoli;
//   final String nama;
//   final String rm;
//   final String jaminan;
//   final int idDokter;
//   final String idJadwalDokter;
//   final int idLayanan;

//   ApmAntrianPoliModel({
//     required this.noBooking,
//     required this.noAntrianPoli,
//     required this.namaPoli,
//     required this.nama,
//     required this.rm,
//     required this.jaminan,
//     required this.idDokter,
//     required this.idJadwalDokter,
//     required this.idLayanan,
//   });

//   factory ApmAntrianPoliModel.fromJson(Map<String, dynamic> json) {
//     return ApmAntrianPoliModel(
//       noBooking: json['no_booking']?.toString() ?? '',
//       noAntrianPoli: json['no_antrian']?.toString() ?? '',
//       namaPoli: json['nama_poli']?.toString() ?? '',
//       nama: json['nama']?.toString() ?? '',
//       rm: json['rm']?.toString() ?? '',
//       jaminan: json['jaminan']?.toString() ?? '',
//       idDokter: int.tryParse(json['id_dokter']?.toString() ?? '0') ?? 0,
//       idJadwalDokter: json['id_jadwal_dokter']?.toString() ?? '',
//       idLayanan: int.tryParse(json['id_layanan']?.toString() ?? '0') ?? 0,
//     );
//   }
// }

class ApmAntrianPoliModel {
  String noBooking;
  String noAntrianPoli;
  String nama;
  String rm;
  String namaPoli; // mutable agar bisa diisi dari root JSON
  int idDokter;
  String idJadwalDokter;
  int idLayanan;

  ApmAntrianPoliModel({
    required this.noBooking,
    required this.noAntrianPoli,
    required this.nama,
    required this.rm,
    required this.namaPoli,
    required this.idDokter,
    required this.idJadwalDokter,
    required this.idLayanan,
  });

  factory ApmAntrianPoliModel.fromJson(
    Map<String, dynamic> data, {
    String namaPoliRoot = '',
  }) {
    return ApmAntrianPoliModel(
      noBooking: data['id']?.toString() ?? '',
      noAntrianPoli: data['no_antrian']?.toString() ?? '',
      nama: data['nama'] ?? '',
      rm: data['rm']?.toString() ?? '',
      namaPoli: namaPoliRoot.isNotEmpty ? namaPoliRoot : '',
      idDokter: int.tryParse(data['id_dokter']?.toString() ?? '0') ?? 0,
      idJadwalDokter: data['id_jadwal_dokter']?.toString() ?? '',
      idLayanan: int.tryParse(data['id_layanan']?.toString() ?? '0') ?? 0,
    );
  }
}
