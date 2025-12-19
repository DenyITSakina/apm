class PoliModel {
  final int id;
  final String nama;
  final String? kodeBpjs;

  PoliModel({
    required this.id,
    required this.nama,
    this.kodeBpjs,
  });

  factory PoliModel.fromJson(Map<String, dynamic> json) {
    return PoliModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nama: json['poli']?.toString() ??
          json['nama_poli']?.toString() ??
          '',
      kodeBpjs: json['kode_bpjs']?.toString(),
    );
  }
}
