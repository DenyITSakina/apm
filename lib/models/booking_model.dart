class BookingRequest {
  final String jenis;
  final String nik;
  final String nohp;
  final int idUnit;
  final int idDokter;
  final String tanggalPeriksa;
  final String idJadwalDokter;
  final String? noBpjs;
  final String? email;

  BookingRequest({
    required this.jenis,
    required this.nik,
    required this.nohp,
    required this.idUnit,
    required this.idDokter,
    required this.tanggalPeriksa,
    required this.idJadwalDokter,
    this.noBpjs,
    this.email,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'nik': nik,
      'nohp': nohp,
      'id_unit': idUnit,
      'id_dokter': idDokter,
      'tanggalperiksa': tanggalPeriksa,
      'id_jadwal_dokter': idJadwalDokter,
    };
    if (email != null) map['email'] = email!;
    if (noBpjs != null) map['no_bpjs'] = noBpjs!;
    return map;
  }
}

class BookingResponse {
  final bool success;
  final String message;
  final BookingData? data;

  BookingResponse({required this.success, required this.message, this.data});

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? BookingData.fromJson(json['data']) : null,
    );
  }
}

class BookingData {
  final String idBooking;
  final String noAntrian;
  final String kodeBooking;
  final String jenisBooking;
  final String tanggalPeriksa;
  final String jamBooking;
  final String namaPasien;
  final String nik;
  final String unit;
  final String dokter;
  final String? poliRujukan;
  final String? kodePoliRujukan;
  final String? noBpjs;

  BookingData({
    required this.idBooking,
    required this.noAntrian,
    required this.kodeBooking,
    required this.jenisBooking,
    required this.tanggalPeriksa,
    required this.jamBooking,
    required this.namaPasien,
    required this.nik,
    required this.unit,
    required this.dokter,
    this.poliRujukan,
    this.kodePoliRujukan,
    this.noBpjs,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    // Ambil rujukan dari dalam json
    final rujukan = json['rujukan'] as Map<String, dynamic>?;

    String? poliRujukanNama;
    String? poliRujukanKode;

    if (rujukan != null) {
      final poliRujukan = rujukan['poliRujukan'] as Map<String, dynamic>?;
      if (poliRujukan != null) {
        poliRujukanNama = poliRujukan['nama']?.toString();
        poliRujukanKode = poliRujukan['kode']?.toString();
      }
    }

    return BookingData(
      idBooking: json['id_booking']?.toString() ?? '',
      noAntrian: json['no_antrian']?.toString() ?? '',
      kodeBooking: json['kode_booking']?.toString() ?? '',
      jenisBooking: json['jenis_booking']?.toString() ?? '',
      tanggalPeriksa: json['tanggal_periksa']?.toString() ?? '',
      jamBooking: json['jam_booking']?.toString() ?? '',
      namaPasien: json['nama_pasien']?.toString() ?? '',
      nik: json['nik']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      dokter: json['dokter']?.toString() ?? '',
      poliRujukan: poliRujukanNama,
      kodePoliRujukan: poliRujukanKode,
      noBpjs: json['no_bpjs']?.toString(),
    );
  }
}
