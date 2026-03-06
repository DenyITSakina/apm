class BookingRequestModel {
  final String? nama;
  final String nik;
  final String nohp;
  final String? jenisKelamin;
  final String? tempatLahir;
  final String? tglLahir;
  final String? alamat;
  final int idUnit;
  final int idDokter;
  final String tanggalperiksa;
  final String? jadwal;
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
  final int? pasienBaru;

  BookingRequestModel({
    this.nama,
    required this.nik,
    required this.nohp,
    this.jenisKelamin,
    this.tempatLahir,
    this.tglLahir,
    this.alamat,
    required this.idUnit,
    required this.idDokter,
    required this.tanggalperiksa,
    this.jadwal,
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
    this.pasienBaru,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'nik': nik,
      'nohp': nohp,
      'id_unit': idUnit,
      'id_dokter': idDokter,
      'tanggalperiksa': tanggalperiksa,
      'id_jadwal_dokter': idJadwalDokter,
      'kapasitaspasien': kapasitaspasien,
      'jenis_booking': jenisBooking,
    };

    if (nama != null) map['nama'] = nama;
    if (jenisKelamin != null) map['jenis_kelamin'] = jenisKelamin;
    if (tempatLahir != null) map['tempat_lahir'] = tempatLahir;
    if (tglLahir != null) map['tgl_lahir'] = tglLahir;
    if (alamat != null) map['alamat'] = alamat;

    if (jenisBooking == 2) {
      if (jadwal != null && jadwal!.isNotEmpty) {
        map['jadwal'] = jadwal;
      }

      if (nomorkartu != null) map['nomorkartu'] = nomorkartu;
      if (noReferensi != null) map['no_referensi'] = noReferensi;
      if (kodepoli != null) map['kodepoli'] = kodepoli;
      if (namapoli != null) map['namapoli'] = namapoli;
      if (kodedokter != null) map['kodedokter'] = kodedokter;
      if (namadokter != null) map['namadokter'] = namadokter;
      if (jeniskunjungan != null) map['jeniskunjungan'] = jeniskunjungan;
      map['pasien_baru'] = pasienBaru ?? 1;
    }

    return map;
  }
}

class BookingResponseModel {
  final bool success;
  final String message;
  final BookingData? data;

  BookingResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory BookingResponseModel.fromJson(Map<String, dynamic> json) {
    return BookingResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null ? BookingData.fromJson(json['data']) : null,
    );
  }
}

class BookingData {
  final String? rm;
  final String? idSosial;
  final String? noAntrian;
  final String? kodeBooking;
  final String? jenisBooking;

  BookingData({
    this.rm,
    this.idSosial,
    this.noAntrian,
    this.kodeBooking,
    this.jenisBooking,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      rm: json['rm']?.toString(),
      idSosial: json['id_sosial']?.toString(),
      noAntrian: json['no_antrian']?.toString(),
      kodeBooking: json['kode_booking']?.toString(),
      jenisBooking: json['jenis_booking']?.toString(),
    );
  }
}
