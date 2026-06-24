class PoliModel {
  final int id;
  final String nama;
  final String kodeBpjs;

  PoliModel({required this.id, required this.nama, required this.kodeBpjs});

  factory PoliModel.fromJson(Map<String, dynamic> json) {
    // Beberapa backend kadang pakai key berbeda untuk kode & nama.
    final nama =
        (json['poli']?.toString() ??
        json['nama_poli']?.toString() ??
        json['nama']?.toString() ??
        json['nama_unit']?.toString() ??
        json['namaPoli']?.toString() ??
        json['nama_poli_bpjs']?.toString() ??
        '');

    // Normalisasi agar string whitespace tidak dianggap nama valid.
    final namaFinal = nama.trim().isNotEmpty ? nama.trim() : '-';

    // Jangan pakai ! karena jika key kodeBpjs tidak ada akan error.
    final kode =
        json['kode_bpjs']?.toString() ??
        json['kode_poli_bpjs']?.toString() ??
        json['kode_poli']?.toString() ??
        json['kode']?.toString() ??
        '';

    return PoliModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nama: namaFinal,
      kodeBpjs: kode,
    );
  }
}
