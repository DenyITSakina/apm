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

  /// Data peserta BPJS dari blok `data.bpjs` endpoint validasi.
  final bool punyaDataBpjs;
  final bool bpjsAktif;
  final String bpjsStatusPeserta;
  final String bpjsStatusKode;
  final String bpjsHakKelas;
  final String bpjsJenisPeserta;
  final String bpjsNoKartu;
  final String bpjsNik;
  final String bpjsTglSep;

  /// Rujukan BPJS terbaru (dipakai otomatis sebagai `diag_awal` SEP).
  final bool adaRujukan;
  final String rujukanKode;
  final String rujukanNama;
  final String rujukanNoKunjungan;
  final String rujukanTglKunjungan;
  final String rujukanFaskesNama;
  final String rujukanFaskesKode;

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
    this.punyaDataBpjs = false,
    this.bpjsAktif = false,
    this.bpjsStatusPeserta = '',
    this.bpjsStatusKode = '',
    this.bpjsHakKelas = '',
    this.bpjsJenisPeserta = '',
    this.bpjsNoKartu = '',
    this.bpjsNik = '',
    this.bpjsTglSep = '',
    this.adaRujukan = false,
    this.rujukanKode = '',
    this.rujukanNama = '',
    this.rujukanNoKunjungan = '',
    this.rujukanTglKunjungan = '',
    this.rujukanFaskesNama = '',
    this.rujukanFaskesKode = '',
  });

  factory ApmAntrianModel.fromJson(Map<String, dynamic> json) {
    final data = _extractData(json);
    final bpjs = _parseBpjs(json);

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
      punyaDataBpjs: bpjs.punyaDataBpjs,
      bpjsAktif: bpjs.aktif,
      bpjsStatusPeserta: bpjs.statusPeserta,
      bpjsStatusKode: bpjs.statusKode,
      bpjsHakKelas: bpjs.hakKelas,
      bpjsJenisPeserta: bpjs.jenisPeserta,
      bpjsNoKartu: bpjs.noKartu,
      bpjsNik: bpjs.nik,
      bpjsTglSep: bpjs.tglSep,
      adaRujukan: bpjs.adaRujukan,
      rujukanKode: bpjs.rujukanKode,
      rujukanNama: bpjs.rujukanNama,
      rujukanNoKunjungan: bpjs.rujukanNoKunjungan,
      rujukanTglKunjungan: bpjs.rujukanTglKunjungan,
      rujukanFaskesNama: bpjs.rujukanFaskesNama,
      rujukanFaskesKode: bpjs.rujukanFaskesKode,
    );
  }

  /// Blok `bpjs` bersebelahan dengan `data` pada response validasi.
  static _BpjsInfo _parseBpjs(Map<String, dynamic> json) {
    final bpjs = _asMap(_asMap(json['data'])['bpjs']);
    if (bpjs.isEmpty) {
      return const _BpjsInfo();
    }

    final rujukan = _rujukanTerbaru(_asMap(bpjs['rujukan']));
    final diagnosa = _asMap(rujukan['diagnosa']);
    final faskes = _asMap(rujukan['provPerujuk']);

    return _BpjsInfo(
      punyaDataBpjs: true,
      aktif: _toBool(bpjs['aktif']),
      statusPeserta: _toString(bpjs, 'status_peserta'),
      statusKode: _toString(bpjs, 'status_kode'),
      hakKelas: _toString(bpjs, 'hak_kelas'),
      jenisPeserta: _toString(bpjs, 'jenis_peserta'),
      noKartu: _toString(bpjs, 'no_kartu'),
      nik: _toString(bpjs, 'nik'),
      tglSep: _toString(bpjs, 'tgl_sep'),
      adaRujukan: rujukan.isNotEmpty,
      rujukanKode: _toString(diagnosa, 'kode'),
      rujukanNama: _toString(diagnosa, 'nama'),
      rujukanNoKunjungan: _toString(rujukan, 'noKunjungan'),
      rujukanTglKunjungan: _toString(rujukan, 'tglKunjungan'),
      rujukanFaskesNama: _toString(faskes, 'nama'),
      rujukanFaskesKode: _toString(faskes, 'kode'),
    );
  }

  /// Rujukan dengan `tglKunjungan` terbaru, sama seperti kolom `rujukan` backend.
  static Map<String, dynamic> _rujukanTerbaru(Map<String, dynamic> wrapper) {
    var daftar = wrapper['data'];
    if (daftar is Map) {
      daftar = daftar['rujukan'];
    }
    if (daftar is! List || daftar.isEmpty) {
      return <String, dynamic>{};
    }

    final items = daftar.map(_asMap).where((item) => item.isNotEmpty).toList()
      ..sort(
        (a, b) => (b['tglKunjungan']?.toString() ?? '').compareTo(
          a['tglKunjungan']?.toString() ?? '',
        ),
      );

    return items.first;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    return <String, dynamic>{};
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    final text = value?.toString().toLowerCase().trim();
    return text == 'true' || text == '1' || text == 'yes';
  }

  static Map<String, dynamic> _extractData(Map<String, dynamic> json) {
    if (json['data'] != null && json['data']['data'] != null) {
      return json['data']['data'] as Map<String, dynamic>;
    }
    if (json['data'] != null) {
      return json['data'] as Map<String, dynamic>;
    }
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

  /// Diagnosis awal SEP diambil otomatis dari diagnosa rujukan BPJS terbaru.
  /// Backend menolak pembuatan SEP bila nilai ini kosong.
  String get diagAwal => rujukanKode;

  /// Peserta BPJS baru bisa proceeding ke poli bila aktif dan punya rujukan.
  bool get bpjsSiapSep =>
      !punyaDataBpjs || (bpjsAktif && adaRujukan && rujukanKode.isNotEmpty);

  String get bpjsStatusText {
    if (!punyaDataBpjs) return '-';
    if (!bpjsAktif) {
      return bpjsStatusPeserta.isNotEmpty
          ? bpjsStatusPeserta.toUpperCase()
          : 'TIDAK AKTIF';
    }
    return bpjsStatusPeserta.isNotEmpty
        ? bpjsStatusPeserta.toUpperCase()
        : 'AKTIF';
  }

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

/// Hasil parsing blok `data.bpjs` beserta rujukan terbaru.
class _BpjsInfo {
  final bool punyaDataBpjs;
  final bool aktif;
  final String statusPeserta;
  final String statusKode;
  final String hakKelas;
  final String jenisPeserta;
  final String noKartu;
  final String nik;
  final String tglSep;
  final bool adaRujukan;
  final String rujukanKode;
  final String rujukanNama;
  final String rujukanNoKunjungan;
  final String rujukanTglKunjungan;
  final String rujukanFaskesNama;
  final String rujukanFaskesKode;

  const _BpjsInfo({
    this.punyaDataBpjs = false,
    this.aktif = false,
    this.statusPeserta = '',
    this.statusKode = '',
    this.hakKelas = '',
    this.jenisPeserta = '',
    this.noKartu = '',
    this.nik = '',
    this.tglSep = '',
    this.adaRujukan = false,
    this.rujukanKode = '',
    this.rujukanNama = '',
    this.rujukanNoKunjungan = '',
    this.rujukanTglKunjungan = '',
    this.rujukanFaskesNama = '',
    this.rujukanFaskesKode = '',
  });
}
