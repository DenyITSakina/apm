class DokterModel {
  final String idJadwal;
  final String idJadwalDetail;
  final int idDokter;
  final int idLayanan;
  final String kodePoli;
  final String kodeSubspesialis;
  final String kodeDokter;
  final String namaSubspesialis;
  final String namaDokter;
  final String namaPoli;
  final String? tipe;
  final int status;
  final int idHari;
  final String namaHari;
  final String jamBuka;
  final String jamTutup;
  final String? jadwal;
  final int kapasitasPasien;
  final int kuotaNonJkn;
  final int libur;

  DokterModel({
    required this.idJadwal,
    required this.idJadwalDetail,
    required this.idDokter,
    required this.idLayanan,
    required this.kodePoli,
    required this.kodeSubspesialis,
    required this.kodeDokter,
    required this.namaSubspesialis,
    required this.namaDokter,
    required this.namaPoli,
    this.tipe,
    required this.status,
    required this.idHari,
    required this.namaHari,
    required this.jamBuka,
    required this.jamTutup,
    this.jadwal,
    required this.kapasitasPasien,
    required this.kuotaNonJkn,
    required this.libur,
  });

  factory DokterModel.fromJson(Map<String, dynamic> json) {
    return DokterModel(
      idJadwal: json['id_jadwal']?.toString() ?? '',
      idJadwalDetail: json['id_jadwal_detail']?.toString() ?? '',
      idDokter: int.tryParse(json['id_dokter']?.toString() ?? '0') ?? 0,
      idLayanan: int.tryParse(json['id_layanan']?.toString() ?? '0') ?? 0,
      kodePoli: json['kodepoli']?.toString() ?? '',
      kodeSubspesialis: json['kodesubspesialis']?.toString() ?? '',
      kodeDokter: json['kodedokter']?.toString() ?? '',
      namaSubspesialis: json['namasubspesialis']?.toString() ?? '',
      namaDokter:
          json['namadokter']?.toString() ??
          json['nama_dokter']?.toString() ??
          '',
      namaPoli:
          json['namapoli']?.toString() ?? json['nama_poli']?.toString() ?? '',
      tipe: json['tipe']?.toString(),
      status: int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      idHari: int.tryParse(json['id_hari']?.toString() ?? '0') ?? 0,
      namaHari: json['nama_hari']?.toString() ?? '',
      jamBuka: json['buka']?.toString() ?? '',
      jamTutup: json['tutup']?.toString() ?? '',
      jadwal: json['jadwal']?.toString(),
      kapasitasPasien:
          int.tryParse(json['kapasitaspasien']?.toString() ?? '0') ?? 0,
      kuotaNonJkn: int.tryParse(json['kuotanonjkn']?.toString() ?? '0') ?? 0,
      libur: int.tryParse(json['libur']?.toString() ?? '0') ?? 0,
    );
  }

  String get jadwalLengkap {
    if (jadwal != null && jadwal!.isNotEmpty) {
      return jadwal!;
    }
    if (jamBuka.isNotEmpty && jamTutup.isNotEmpty) {
      return '$jamBuka - $jamTutup';
    }
    return 'Jadwal tidak tersedia';
  }

  bool get isLibur => libur == 1;

  bool get isAktif => status == 1;

  bool isAvailableToday(String currentTime) {
    if (isLibur) return false;
    if (jamTutup.isEmpty) return false;
    return jamTutup.compareTo(currentTime) > 0;
  }

  String get tipeDisplay {
    if (tipe == null || tipe!.isEmpty) return 'UMUM';
    return 'BPJS';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'id_jadwal': idJadwal,
      'id_jadwal_detail': idJadwalDetail,
      'id_dokter': idDokter,
      'id_layanan': idLayanan,
      'kodepoli': kodePoli,
      'kodesubspesialis': kodeSubspesialis,
      'kodedokter': kodeDokter,
      'namasubspesialis': namaSubspesialis,
      'namadokter': namaDokter,
      'namapoli': namaPoli,
      'tipe': tipe,
      'status': status,
      'id_hari': idHari,
      'nama_hari': namaHari,
      'buka': jamBuka,
      'tutup': jamTutup,
      'kapasitaspasien': kapasitasPasien,
      'kuotanonjkn': kuotaNonJkn,
      'libur': libur,
    };

    if (jadwal != null) {
      map['jadwal'] = jadwal;
    }

    return map;
  }
}
