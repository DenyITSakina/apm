class PasienBpjsResponse {
  final bool status;
  final String message;
  final String source;
  final PasienBpjsData? peserta;
  final Map<String, dynamic>? rujukan;

  PasienBpjsResponse({
    required this.status,
    required this.message,
    this.source = '',
    this.peserta,
    this.rujukan,
  });

  factory PasienBpjsResponse.fromJson(Map<String, dynamic> json) {
    final source = json['source']?.toString() ?? '';
    Map<String, dynamic>? pesertaJson;

    if (json['peserta'] != null) {
      pesertaJson = json['peserta'] as Map<String, dynamic>;
    } else {
      final rujukan = json['rujukan'] as Map<String, dynamic>?;
      final bpjs = rujukan?['bpjs'] as Map<String, dynamic>?;
      final rujukanList = bpjs?['rujukan'] as List?;

      if (rujukanList != null && rujukanList.isNotEmpty) {
        final rujukanData = rujukanList[0] as Map<String, dynamic>;
        final pesertaRujukan = rujukanData['peserta'] as Map<String, dynamic>?;
        if (pesertaRujukan != null) {
          pesertaJson = pesertaRujukan;
        }
      }
    }

    PasienBpjsData? peserta;
    if (pesertaJson != null) {
      if (json['poliRujukan'] != null) {
        pesertaJson['poliRujukan'] = json['poliRujukan'];
      }
      if (json['kodePoliRujukan'] != null) {
        pesertaJson['kodePoliRujukan'] = json['kodePoliRujukan'];
      }
      peserta = PasienBpjsData.fromJson(pesertaJson);
    }

    return PasienBpjsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      source: source,
      peserta: peserta,
      rujukan: json['rujukan'] as Map<String, dynamic>?,
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
    String? poliRujukan = json['poliRujukan']?['nama']?.toString();
    String? kodePoliRujukan = json['kodePoliRujukan']?.toString();

    if (kodePoliRujukan == null || poliRujukan == null) {
      final rujukan = json['rujukan'] as Map<String, dynamic>?;
      final bpjs = rujukan?['bpjs'] as Map<String, dynamic>?;
      final rujukanList = bpjs?['rujukan'] as List?;

      if (rujukanList != null && rujukanList.isNotEmpty) {
        final rujukanData = rujukanList[0] as Map<String, dynamic>;
        final poli = rujukanData['poliRujukan'] as Map<String, dynamic>?;
        if (poli != null) {
          poliRujukan ??= poli['nama']?.toString();
          kodePoliRujukan ??= poli['kode']?.toString();
        }
      }
    }

    String? noTelp;
    final mr = json['mr'] as Map<String, dynamic>?;
    if (mr != null) {
      noTelp = mr['noTelepon']?.toString();
    }

    String? jenisKelamin = json['sex']?.toString();
    if (jenisKelamin == 'P') {
      jenisKelamin = 'Perempuan';
    } else if (jenisKelamin == 'L') {
      jenisKelamin = 'Laki-laki';
    }

    return PasienBpjsData(
      noPeserta:
          json['no_peserta']?.toString() ?? json['noKartu']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      nik: json['nik']?.toString() ?? '',
      noTelp: noTelp,
      jenisKelamin: jenisKelamin,
      tglLahir: json['tglLahir']?.toString(),
      alamat: json['alamat']?.toString(),
      email: json['email']?.toString(),
      poliRujukan: poliRujukan,
      kodePoliRujukan: kodePoliRujukan,
    );
  }
}
