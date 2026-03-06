// ignore_for_file: file_names

class ApmPasienSosialModel {
  final String rm;
  final String pasien;
  final String alamat;
  final String tglLahir;
  final String? noPeserta;
  final String? noIdentitas;

  ApmPasienSosialModel({
    required this.rm,
    required this.pasien,
    required this.alamat,
    required this.tglLahir,
    this.noPeserta,
    this.noIdentitas,
  });

  factory ApmPasienSosialModel.fromJson(Map<String, dynamic> json) {
    return ApmPasienSosialModel(
      rm: json['rm'] ?? '',
      pasien: json['pasien'] ?? '',
      alamat: json['alamat_domisili'] ?? '',
      tglLahir: json['tgl_lahir'] ?? '',
      noPeserta: json['no_peserta'],
      noIdentitas: json['no_identitas'],
    );
  }
}
