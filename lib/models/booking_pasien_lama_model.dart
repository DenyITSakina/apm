class BookingPasienLamaRequest {
  final String rm;
  final int idUnit;
  final int idDokter;
  final String tanggalperiksa;
  final String jadwal;
  final String idJadwalDokter;
  final int kapasitaspasien;
  final int jenisBooking;

  final String? nomorkartu;
  final String? noReferensi;
  final String? kodepoli;
  final String? namapoli;
  final String? kodedokter;
  final String? namadokter;
  final int? jeniskunjungan;

  BookingPasienLamaRequest({
    required this.rm,
    required this.idUnit,
    required this.idDokter,
    required this.tanggalperiksa,
    required this.jadwal,
    required this.idJadwalDokter,
    required this.kapasitaspasien,
    required this.jenisBooking,
    this.nomorkartu,
    this.noReferensi,
    this.kodepoli,
    this.namapoli,
    this.kodedokter,
    this.namadokter,
    this.jeniskunjungan,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'rm': rm,
      'id_unit': idUnit,
      'id_dokter': idDokter,
      'tanggalperiksa': tanggalperiksa,
      'jadwal': jadwal,
      'id_jadwal_dokter': idJadwalDokter,
      'kapasitaspasien': kapasitaspasien,
      'jenis_booking': jenisBooking,
    };

    if (jenisBooking == 2) {
      if (nomorkartu != null) map['nomorkartu'] = nomorkartu;
      if (noReferensi != null) map['no_referensi'] = noReferensi;
      if (kodepoli != null) map['kodepoli'] = kodepoli;
      if (namapoli != null) map['namapoli'] = namapoli;
      if (kodedokter != null) map['kodedokter'] = kodedokter;
      if (namadokter != null) map['namadokter'] = namadokter;
      if (jeniskunjungan != null) map['jeniskunjungan'] = jeniskunjungan;
    }

    return map;
  }
}

class CekPasienResponse {
  final bool success;
  final String message;
  final CekPasienData? data;

  CekPasienResponse({required this.success, required this.message, this.data});

  factory CekPasienResponse.fromJson(Map<String, dynamic> json) {
    return CekPasienResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null ? CekPasienData.fromJson(json['data']) : null,
    );
  }
}

class CekPasienData {
  final String rm;
  final String nama;
  final String nik;
  final String noTelp;
  final String jenisKelamin;
  final String tempatLahir;
  final String tglLahir;
  final String alamat;
  final String? noPeserta;

  CekPasienData({
    required this.rm,
    required this.nama,
    required this.nik,
    required this.noTelp,
    required this.jenisKelamin,
    required this.tempatLahir,
    required this.tglLahir,
    required this.alamat,
    this.noPeserta,
  });

  factory CekPasienData.fromJson(Map<String, dynamic> json) {
    return CekPasienData(
      rm: json['rm']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      nik: json['no_identitas']?.toString() ?? '',
      noTelp: json['no_telp']?.toString() ?? '',
      jenisKelamin: json['jenis_kelamin']?.toString() ?? '',
      tempatLahir: json['tempat_lahir']?.toString() ?? '',
      tglLahir: json['tgl_lahir']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
      noPeserta: json['no_peserta']?.toString(),
    );
  }
}

class BookingLamaResponse {
  final bool success;
  final String message;
  final BookingLamaData? data;

  BookingLamaResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory BookingLamaResponse.fromJson(Map<String, dynamic> json) {
    return BookingLamaResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? BookingLamaData.fromJson(json['data'])
          : null,
    );
  }
}

class BookingLamaData {
  final String? rm;
  final String? noAntrian;
  final String? kodeBooking;
  final String? jenisBooking;

  BookingLamaData({
    this.rm,
    this.noAntrian,
    this.kodeBooking,
    this.jenisBooking,
  });

  factory BookingLamaData.fromJson(Map<String, dynamic> json) {
    return BookingLamaData(
      rm: json['rm']?.toString(),
      noAntrian: json['no_antrian']?.toString(),
      kodeBooking: json['kode_booking']?.toString(),
      jenisBooking: json['jenis_booking']?.toString(),
    );
  }
}
