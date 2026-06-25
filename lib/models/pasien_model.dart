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
    Map<String, dynamic> pesertaJson = {};

    if (json['peserta'] != null) {
      pesertaJson = Map<String, dynamic>.from(json['peserta'] as Map);
      if (json['rujukan'] != null) {
        pesertaJson['rujukan'] = json['rujukan'];
      }
      if (json['poliRujukan'] != null) {
        pesertaJson['poliRujukan'] = json['poliRujukan'];
      }
      if (json['kodePoliRujukan'] != null) {
        pesertaJson['kodePoliRujukan'] = json['kodePoliRujukan'];
      }
    } else {
      final rujukan = json['rujukan'] as Map<String, dynamic>?;
      final bpjs = rujukan?['bpjs'] as Map<String, dynamic>?;
      final rujukanList = bpjs?['rujukan'] as List?;

      if (rujukanList != null && rujukanList.isNotEmpty) {
        final rujukanData = rujukanList[0] as Map<String, dynamic>;
        final pesertaRujukan = rujukanData['peserta'] as Map<String, dynamic>?;
        if (pesertaRujukan != null) {
          pesertaJson = Map<String, dynamic>.from(pesertaRujukan);
          pesertaJson['rujukan'] = rujukan;
          if (rujukanData['poliRujukan'] != null) {
            pesertaJson['poliRujukan'] = rujukanData['poliRujukan'];
          }
          if (rujukanData['noKunjungan'] != null) {
            pesertaJson['noKunjungan'] = rujukanData['noKunjungan'];
          }
        }
      }
    }

    PasienBpjsData? peserta;
    if (pesertaJson.isNotEmpty) {
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
  final String? noKunjungan;

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
    this.noKunjungan,
  });

  factory PasienBpjsData.fromJson(Map<String, dynamic> json) {
    final noPeserta =
        json['no_peserta']?.toString() ?? json['noKartu']?.toString() ?? '';
    final nama = json['nama']?.toString() ?? '';
    final nik = json['nik']?.toString() ?? '';
    final tglLahir = json['tglLahir']?.toString();

    final jenisKelaminRaw = json['sex']?.toString();
    String? jenisKelamin;
    if (jenisKelaminRaw == 'P') {
      jenisKelamin = 'Perempuan';
    } else if (jenisKelaminRaw == 'L') {
      jenisKelamin = 'Laki-laki';
    }

    String? noTelp;
    final mr = json['mr'] as Map<String, dynamic>?;
    if (mr != null) {
      noTelp = mr['noTelepon']?.toString();
    }

    String? poliRujukan;
    String? kodePoliRujukan;
    String? noKunjungan;

    if (json['poliRujukan'] != null) {
      final poli = json['poliRujukan'] as Map<String, dynamic>;
      poliRujukan = poli['nama']?.toString();
      kodePoliRujukan = poli['kode']?.toString();
    }

    if (json['kodePoliRujukan'] != null) {
      kodePoliRujukan = json['kodePoliRujukan']?.toString();
    }

    final rujukan = json['rujukan'] as Map<String, dynamic>?;
    final bpjs = rujukan?['bpjs'] as Map<String, dynamic>?;
    final rujukanList = bpjs?['rujukan'] as List?;

    if (rujukanList != null && rujukanList.isNotEmpty) {
      final rujukanData = rujukanList[0] as Map<String, dynamic>;

      noKunjungan = rujukanData['noKunjungan']?.toString();

      final poli = rujukanData['poliRujukan'] as Map<String, dynamic>?;
      if (poli != null) {
        poliRujukan ??= poli['nama']?.toString();
        kodePoliRujukan ??= poli['kode']?.toString();
      }
    }

    if (noKunjungan == null && json['noKunjungan'] != null) {
      noKunjungan = json['noKunjungan']?.toString();
    }

    return PasienBpjsData(
      noPeserta: noPeserta,
      nama: nama,
      nik: nik,
      noTelp: noTelp,
      jenisKelamin: jenisKelamin,
      tglLahir: tglLahir,
      alamat: json['alamat']?.toString(),
      email: json['email']?.toString(),
      poliRujukan: poliRujukan,
      kodePoliRujukan: kodePoliRujukan,
      noKunjungan: noKunjungan,
    );
  }
}
