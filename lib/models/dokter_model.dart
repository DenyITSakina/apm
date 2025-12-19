class DokterModel {
  final String id;
  final int idDokter;
  final String namaDokter;
  final String namaPoli;
  final String? tipe;

  DokterModel({
    required this.id,
    required this.idDokter,
    required this.namaDokter,
    required this.namaPoli,
    this.tipe,
  });

  factory DokterModel.fromJson(Map<String, dynamic> json) {
    return DokterModel(
      id: json['id']?.toString() ?? '',
      idDokter: int.tryParse(json['id_dokter']?.toString() ?? '0') ?? 0,
      namaDokter: json['namadokter']?.toString() ??
          json['nama_dokter']?.toString() ??
          '',
      namaPoli: json['namapoli']?.toString() ??
          json['nama_poli']?.toString() ??
          '',
      tipe: json['tipe']?.toString(),
    );
  }
}
