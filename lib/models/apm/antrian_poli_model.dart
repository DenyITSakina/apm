class AntrianPoliModel {
  final String id;
  final String pasien;
  final String no;
  final int idUnit;
  final String poli;
  final String dokter;
  final int statusPanggilan;

  AntrianPoliModel({
    required this.id,
    required this.pasien,
    required this.no,
    required this.idUnit,
    required this.poli,
    required this.dokter,
    required this.statusPanggilan,
  });

  factory AntrianPoliModel.fromJson(Map<String, dynamic> json) {
    return AntrianPoliModel(
      id: json['id']?.toString() ?? '',
      pasien: json['nama']?.toString() ?? '',
      no: json['no_antrian']?.toString() ?? '',
      idUnit: int.tryParse(json['id_unit']?.toString() ?? '') ?? 0,
      poli: json['nm_layanan']?.toString() ?? '',
      dokter: json['nm_dokter']?.toString() ?? '',
      statusPanggilan: int.tryParse(json['status_panggilan']?.toString() ?? '') ?? 0,
    );
  }

  /// ➕ Supaya bisa dipakai seperti `item['id']`
  dynamic operator [](String key) {
    switch (key) {
      case 'id':
        return id;
      case 'pasien':
        return pasien;
      case 'no':
        return no;
      case 'id_unit':
        return idUnit;
      case 'poli':
        return poli;
      case 'dokter':
        return dokter;
      case 'status_panggilan':
        return statusPanggilan;
      default:
        return null;
    }
  }

  /// (Opsional) untuk debugging
  Map<String, dynamic> toJson() => {
        'id': id,
        'pasien': pasien,
        'no': no,
        'id_unit': idUnit,
        'poli': poli,
        'dokter': dokter,
        'status_panggilan': statusPanggilan,
      };
}
