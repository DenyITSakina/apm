class ApmAntrianPoliModel {
  String noBooking;
  String noAntrianPoli;
  String nama;
  String rm;
  String noChekinPoli;
  String namaPoli;
  int idDokter;
  String namadokter;
  String tanggalLahir;
  String tanggalBooking;
  String jamBooking;
  String idJadwalDokter;
  int idLayanan;
  String idRegistrasi;
  String noRm;

  /// Hasil pembuatan SEP pada blok `data.sep` (hanya alur BPJS).
  final bool sepSuccess;
  final int sepCode;
  final String sepMessage;
  final String noSep;
  final String sepPoli;
  final String sepKelasRawat;
  final String sepDiagnosa;
  final String sepTgl;
  final String printPath;
  final String printRemotePath;
  final String printRemoteError;

  ApmAntrianPoliModel({
    required this.noBooking,
    required this.noAntrianPoli,
    required this.noChekinPoli,
    required this.nama,
    required this.rm,
    required this.namaPoli,
    required this.idDokter,
    required this.namadokter,
    required this.tanggalLahir,
    required this.jamBooking,
    required this.tanggalBooking,

    required this.idJadwalDokter,
    required this.idLayanan,
    required this.idRegistrasi,
    this.noRm = '',
    this.sepSuccess = false,
    this.sepCode = 0,
    this.sepMessage = '',
    this.noSep = '',
    this.sepPoli = '',
    this.sepKelasRawat = '',
    this.sepDiagnosa = '',
    this.sepTgl = '',
    this.printPath = '',
    this.printRemotePath = '',
    this.printRemoteError = '',
  });

  factory ApmAntrianPoliModel.fromJson(Map<String, dynamic> json) {
    final rootData = (json['data'] as Map<String, dynamic>?) ?? {};
    final data = (rootData['data'] as Map<String, dynamic>?) ?? rootData;
    final poliFromKey =
        data['namapoli']?.toString() ?? data['nama_poli']?.toString();
    final poliFromNested =
        (data['polyclinic'] as Map<String, dynamic>?)?['nama']?.toString();
    final namaPoliFinal = (poliFromKey ?? poliFromNested ?? '').toString();

    final dokterFromKey =
        data['namadokter']?.toString() ?? data['nama_dokter']?.toString();
    final dokterFromNested =
        (data['doctor'] as Map<String, dynamic>?)?['namadokter']?.toString();
    final namadokterFinal = (dokterFromKey ?? dokterFromNested ?? '')
        .toString();

    final sep = _asMap(_asMap(json['data'])['sep']);
    final sepDetail = _asMap(sep['sep']);
    final print = _asMap(sep['print']);

    return ApmAntrianPoliModel(
      noBooking: data['id']?.toString() ?? '',
      noAntrianPoli: data['no_antrian']?.toString() ?? '',
      noChekinPoli: rootData['no_checkin']?.toString() ?? '',
      nama: data['nama']?.toString() ?? '',
      rm: data['rm']?.toString() ?? '',
      namaPoli: namaPoliFinal.isNotEmpty ? namaPoliFinal : '-',
      idDokter: int.tryParse(data['id_dokter']?.toString() ?? '0') ?? 0,
      namadokter: namadokterFinal,
      idJadwalDokter: data['id_jadwal_dokter']?.toString() ?? '',
      idLayanan: int.tryParse(data['id_unit']?.toString() ?? '0') ?? 0,
      tanggalLahir: data['tgl_lahir']?.toString() ?? '',
      tanggalBooking: data['tgl_booking']?.toString() ?? '',
      jamBooking: data['jam_booking']?.toString() ?? '',
      idRegistrasi: rootData['id_registrasi']?.toString() ?? '',
      noRm: rootData['no_rm']?.toString() ?? '',
      sepSuccess: _toBool(sep['success']),
      sepCode: int.tryParse(sep['code']?.toString() ?? '0') ?? 0,
      sepMessage: sep['message']?.toString() ?? '',
      noSep: sep['no_sep']?.toString() ?? '',
      sepPoli: sepDetail['poli']?.toString() ?? '',
      sepKelasRawat: sepDetail['kelasRawat']?.toString() ?? '',
      sepDiagnosa: sepDetail['diagnosa']?.toString() ?? '',
      sepTgl: sepDetail['tglSep']?.toString() ?? '',
      printPath: print['path']?.toString() ?? '',
      printRemotePath: print['remote_path']?.toString() ?? '',
      printRemoteError: print['remote_error']?.toString() ?? '',
    );
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
}
