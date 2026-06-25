class PasienBpjsResponse {
  final bool status;
  final String message;
  final PasienBpjsData? peserta;

  PasienBpjsResponse({
    required this.status,
    required this.message,
    this.peserta,
  });

  factory PasienBpjsResponse.fromJson(Map<String, dynamic> json) {
    return PasienBpjsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      peserta: json['peserta'] != null
          ? PasienBpjsData.fromJson(json['peserta'])
          : null,
    );
  }
}

class PasienBpjsData {
  final String noPeserta;
  final String nama;
  final String nik;
  final String? noTelp;
  final String? jenisKelamin;
  final String? tglLahir;
  final String? alamat;
  final String? email;
  final String? poliRujukan;
  final String? kodePoliRujukan;

  PasienBpjsData({
    required this.noPeserta,
    required this.nama,
    required this.nik,
    this.noTelp,
    this.jenisKelamin,
    this.tglLahir,
    this.alamat,
    this.email,
    this.poliRujukan,
    this.kodePoliRujukan,
  });

  factory PasienBpjsData.fromJson(Map<String, dynamic> json) {
    final rujukan = json['rujukan'] ?? {};
    return PasienBpjsData(
      noPeserta: json['no_peserta']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      nik: json['nik']?.toString() ?? '',
      noTelp: json['no_telp']?.toString(),
      jenisKelamin: json['jenis_kelamin']?.toString(),
      tglLahir: json['tgl_lahir']?.toString(),
      alamat: json['alamat']?.toString(),
      email: json['email']?.toString(),
      poliRujukan: rujukan['poliRujukan']?['nama']?.toString(),
      kodePoliRujukan: rujukan['poliRujukan']?['kode']?.toString(),
    );
  }
}
