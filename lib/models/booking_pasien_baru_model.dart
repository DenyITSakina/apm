class BookingRequestModel {
  final String nik;
  final String nohp;
  final int idUnit;
  final int idDokter;
  final String tanggalperiksa;
  final String idJadwalDokter;
  final int jenisBooking;
  final String? nama;
  final String? jenisKelamin;
  final String? tempatLahir;
  final String? tglLahir;
  final String? alamat;
  final String? email;
  final int? idStatusKawin;
  final String? jadwal;
  final String? nomorkartu;
  final String? noReferensi;
  final String? kodepoli;
  final String? namapoli;
  final String? kodedokter;
  final String? namadokter;
  final int? jeniskunjungan;
  final int? pasienBaru;
  final int? kapasitaspasien;

  BookingRequestModel({
    required this.nik,
    required this.nohp,
    required this.idUnit,
    required this.idDokter,
    required this.tanggalperiksa,
    required this.idJadwalDokter,
    required this.jenisBooking,
    this.nama,
    this.jenisKelamin,
    this.tempatLahir,
    this.tglLahir,
    this.alamat,
    this.email,
    this.idStatusKawin,
    this.jadwal,
    this.nomorkartu,
    this.noReferensi,
    this.kodepoli,
    this.namapoli,
    this.kodedokter,
    this.namadokter,
    this.jeniskunjungan,
    this.pasienBaru,
    this.kapasitaspasien,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'nik': nik,
      'nohp': nohp,
      'id_unit': idUnit,
      'id_dokter': idDokter,
      'tanggalperiksa': tanggalperiksa,
      'id_jadwal_dokter': idJadwalDokter,
      'jenis_booking': jenisBooking,
    };

    if (nama != null && nama!.isNotEmpty) map['nama'] = nama;
    if (jenisKelamin != null && jenisKelamin!.isNotEmpty)
      map['jenis_kelamin'] = jenisKelamin;
    if (tempatLahir != null && tempatLahir!.isNotEmpty)
      map['tempat_lahir'] = tempatLahir;
    if (tglLahir != null && tglLahir!.isNotEmpty) map['tgl_lahir'] = tglLahir;
    if (alamat != null && alamat!.isNotEmpty) map['alamat'] = alamat;
    if (email != null && email!.isNotEmpty) map['email'] = email;
    if (idStatusKawin != null) map['id_status_kawin'] = idStatusKawin;
    if (jadwal != null && jadwal!.isNotEmpty) map['jadwal'] = jadwal;
    if (kapasitaspasien != null) map['kapasitaspasien'] = kapasitaspasien;

    if (jenisBooking == 2) {
      if (nomorkartu != null && nomorkartu!.isNotEmpty)
        map['nomorkartu'] = nomorkartu;
      if (noReferensi != null && noReferensi!.isNotEmpty)
        map['no_referensi'] = noReferensi;
      if (kodepoli != null && kodepoli!.isNotEmpty) map['kodepoli'] = kodepoli;
      if (namapoli != null && namapoli!.isNotEmpty) map['namapoli'] = namapoli;
      if (kodedokter != null && kodedokter!.isNotEmpty)
        map['kodedokter'] = kodedokter;
      if (namadokter != null && namadokter!.isNotEmpty)
        map['namadokter'] = namadokter;
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
  final String? idBooking;
  final String? noAntrian;
  final String? kodeBooking;
  final String? jenisBooking;
  final String? tanggalPeriksa;
  final String? namaPasien;
  final String? nik;

  BookingData({
    this.idBooking,
    this.noAntrian,
    this.kodeBooking,
    this.jenisBooking,
    this.tanggalPeriksa,
    this.namaPasien,
    this.nik,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      idBooking: json['id_booking']?.toString(),
      noAntrian: json['no_antrian']?.toString(),
      kodeBooking: json['kode_booking']?.toString(),
      jenisBooking: json['jenis_booking']?.toString(),
      tanggalPeriksa: json['tanggal_periksa']?.toString(),
      namaPasien: json['nama_pasien']?.toString(),
      nik: json['nik']?.toString(),
    );
  }
}
