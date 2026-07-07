class ApmAntrianModel {
  final String id;
  final String rm;
  final String pasien;
  final String alamatDomisili;
  final String tglLahir;
  final String poli;
  final String noAntrian;
  final String noCheckinPoli;
  final String noPeserta;
  final String jenisBooking;
  final String noIdentitas;
  final String noBooking;
  final String idDokter;
  final String idJadwalDokter;
  final String idLayanan;
  final String namaDokter;
  final String namaPoli;
  final String jamPraktik;
  final String tglBooking;
  final int statusBooking;
  final int pasienBaru;

  // Constructor dengan default values

  const ApmAntrianModel({
    this.id = '',
    this.rm = '',
    this.pasien = '',
    this.alamatDomisili = '',
    this.tglLahir = '',
    this.poli = '',
    this.noAntrian = '',
    this.noCheckinPoli = '',
    this.noPeserta = '',
    this.jenisBooking = '',
    this.noIdentitas = '',
    this.noBooking = '',
    this.idDokter = '',
    this.idJadwalDokter = '',
    this.idLayanan = '',
    this.namaDokter = '',
    this.namaPoli = '',
    this.jamPraktik = '',
    this.tglBooking = '',
    this.statusBooking = 0,
    this.pasienBaru = 0,
  });

  factory ApmAntrianModel.fromJson(Map<String, dynamic> json) {
    final data = _extractData(json);

    return ApmAntrianModel(
      id: _toString(data, 'id'),
      rm: _toString(data, 'rm'),
      pasien: _toString(data, 'pasien') ?? _toString(data, 'nama') ?? '',
      alamatDomisili:
          _toString(data, 'alamat') ?? _toString(data, 'alamat_domisili') ?? '',
      tglLahir: _toString(data, 'tgl_lahir') ?? '',
      poli: _toString(data, 'nama_poli') ?? '',
      noAntrian: _toString(data, 'no_antrian') ?? '',
      noCheckinPoli: _toString(data, 'no_checkin') ?? '',
      noPeserta: _toString(data, 'no_peserta') ?? '',
      jenisBooking: _toString(data, 'jenis_booking') ?? '',
      noIdentitas: _toString(data, 'no_identitas') ?? '',
      noBooking: _toString(data, 'id') ?? '',
      idDokter: _toString(data, 'id_dokter') ?? '',
      idJadwalDokter: _toString(data, 'id_jadwal_dokter') ?? '',
      idLayanan:
          _toString(data, 'id_unit') ?? _toString(data, 'id_layanan') ?? '',
      namaDokter: _toString(data, 'nama_dokter') ?? '',
      namaPoli: _toString(data, 'nama_poli') ?? '',
      jamPraktik: _toString(data, 'jam_praktik') ?? '',
      tglBooking: _toString(data, 'tgl_booking') ?? '',
      statusBooking: _toInt(data, 'status_booking') ?? 0,
      pasienBaru: _toInt(data, 'pasien_baru') ?? 0,
    );
  }

  // Helper untuk extract data dari nested structure
  static Map<String, dynamic> _extractData(Map<String, dynamic> json) {
    // Handle nested response: {code, message, data: {data: {...}, jenis: ...}}
    if (json['data'] != null && json['data']['data'] != null) {
      return json['data']['data'] as Map<String, dynamic>;
    }
    // Handle standard response: {code, message, data: {...}}
    if (json['data'] != null) {
      return json['data'] as Map<String, dynamic>;
    }
    // Handle direct response: {...}
    return json;
  }

  static String _toString(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value?.toString() ?? '';
  }

  static int? _toInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  bool get isDibatalkan => statusBooking == 3 || statusBooking == 4;
  bool get isValid => rm.isNotEmpty || id.isNotEmpty;
  String get statusText => _getStatusText();

  String _getStatusText() {
    switch (statusBooking) {
      case 0:
        return 'Menunggu Chek In';
      case 1:
        return 'Check-in FO';
      case 2:
        return 'Check-in Mobile';
      case 3:
        return 'Dibatalkan FO';
      case 4:
        return 'Dibatalkan Mobile';
      case 5:
        return 'Check-in APM';
      case 6:
        return 'Proses';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() {
    return 'ApmAntrianModel(id: $id, rm: $rm, pasien: $pasien, poli: $poli)';
  }
}
