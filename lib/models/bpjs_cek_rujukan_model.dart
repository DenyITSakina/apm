// ignore_for_file: public_member_api_docs, sort_constructors_first

class BpjsCekRujukanResponse {
  final bool? status;
  final String? source;
  final Peserta? peserta;
  final Rujukan? rujukan;

  const BpjsCekRujukanResponse({
    this.status,
    this.source,
    this.peserta,
    this.rujukan,
  });

  factory BpjsCekRujukanResponse.fromJson(Map<String, dynamic> json) {
    return BpjsCekRujukanResponse(
      status: json['status'] as bool?,
      source: json['source']?.toString(),
      peserta: json['peserta'] is Map<String, dynamic>
          ? Peserta.fromJson(json['peserta'] as Map<String, dynamic>)
          : null,
      rujukan: json['rujukan'] is Map<String, dynamic>
          ? Rujukan.fromJson(json['rujukan'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Peserta {
  final String? noPeserta;
  final String? noKartu;
  final String? nama;
  final String? nik;
  final String? kelas;

  const Peserta({
    this.noPeserta,
    this.noKartu,
    this.nama,
    this.nik,
    this.kelas,
  });

  factory Peserta.fromJson(Map<String, dynamic> json) {
    return Peserta(
      noPeserta: json['no_peserta']?.toString(),
      noKartu: json['no_kartu']?.toString(),
      nama: json['nama']?.toString(),
      nik: json['nik']?.toString(),
      kelas: json['kelas']?.toString(),
    );
  }
}

class Rujukan {
  final bool? success;
  final int? code;
  final String? message;
  final BpjsRujukan? bpjs;

  const Rujukan({this.success, this.code, this.message, this.bpjs});

  factory Rujukan.fromJson(Map<String, dynamic> json) {
    return Rujukan(
      success: json['success'] as bool?,
      code: json['code'] is int
          ? json['code'] as int
          : int.tryParse(json['code']?.toString() ?? ''),
      message: json['message']?.toString(),
      bpjs: json['bpjs'] is Map<String, dynamic>
          ? BpjsRujukan.fromJson(json['bpjs'] as Map<String, dynamic>)
          : null,
    );
  }
}

class BpjsRujukan {
  final String? asalFaskes;
  final List<RujukanItem>? rujukan;

  const BpjsRujukan({this.asalFaskes, this.rujukan});

  factory BpjsRujukan.fromJson(Map<String, dynamic> json) {
    return BpjsRujukan(
      asalFaskes: json['asalFaskes']?.toString(),
      rujukan: json['rujukan'] is List
          ? (json['rujukan'] as List)
                .whereType<Map<String, dynamic>>()
                .map((e) => RujukanItem.fromJson(e))
                .toList()
          : null,
    );
  }
}

class RujukanItem {
  final String? noKunjungan;
  final String? tglKunjungan;
  final Provider? provPerujuk;
  final PesertaItem? peserta;
  final Diagnosa? diagnosa;
  final String? keluhan;
  final Provider? poliRujukan;
  final Pelayanan? pelayanan;

  const RujukanItem({
    this.noKunjungan,
    this.tglKunjungan,
    this.provPerujuk,
    this.peserta,
    this.diagnosa,
    this.keluhan,
    this.poliRujukan,
    this.pelayanan,
  });

  factory RujukanItem.fromJson(Map<String, dynamic> json) {
    return RujukanItem(
      noKunjungan: json['noKunjungan']?.toString(),
      tglKunjungan: json['tglKunjungan']?.toString(),
      provPerujuk: json['provPerujuk'] is Map<String, dynamic>
          ? Provider.fromJson(json['provPerujuk'] as Map<String, dynamic>)
          : null,
      peserta: json['peserta'] is Map<String, dynamic>
          ? PesertaItem.fromJson(json['peserta'] as Map<String, dynamic>)
          : null,
      diagnosa: json['diagnosa'] is Map<String, dynamic>
          ? Diagnosa.fromJson(json['diagnosa'] as Map<String, dynamic>)
          : null,
      keluhan: json['keluhan']?.toString(),
      poliRujukan: json['poliRujukan'] is Map<String, dynamic>
          ? Provider.fromJson(json['poliRujukan'] as Map<String, dynamic>)
          : null,
      pelayanan: json['pelayanan'] is Map<String, dynamic>
          ? Pelayanan.fromJson(json['pelayanan'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Provider {
  final String? kode;
  final String? nama;

  const Provider({this.kode, this.nama});

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      kode: json['kode']?.toString(),
      nama: json['nama']?.toString(),
    );
  }
}

class PesertaItem {
  final String? noKartu;
  final String? nik;
  final String? nama;
  final String? pisa;
  final String? sex;
  final Mr? mr;
  final String? tglLahir;
  final StatusPeserta? statusPeserta;
  final Provider? provUmum;
  final Provider? jenisPeserta;
  final Provider? hakKelas;

  const PesertaItem({
    this.noKartu,
    this.nik,
    this.nama,
    this.pisa,
    this.sex,
    this.mr,
    this.tglLahir,
    this.statusPeserta,
    this.provUmum,
    this.jenisPeserta,
    this.hakKelas,
  });

  factory PesertaItem.fromJson(Map<String, dynamic> json) {
    return PesertaItem(
      noKartu: json['noKartu']?.toString(),
      nik: json['nik']?.toString(),
      nama: json['nama']?.toString(),
      pisa: json['pisa']?.toString(),
      sex: json['sex']?.toString(),
      mr: json['mr'] is Map<String, dynamic>
          ? Mr.fromJson(json['mr'] as Map<String, dynamic>)
          : null,
      tglLahir: json['tglLahir']?.toString(),
      statusPeserta: json['statusPeserta'] is Map<String, dynamic>
          ? StatusPeserta.fromJson(
              json['statusPeserta'] as Map<String, dynamic>,
            )
          : null,
      provUmum: json['provUmum'] is Map<String, dynamic>
          ? Provider.fromJson(json['provUmum'] as Map<String, dynamic>)
          : null,
      jenisPeserta: json['jenisPeserta'] is Map<String, dynamic>
          ? Provider.fromJson(json['jenisPeserta'] as Map<String, dynamic>)
          : null,
      hakKelas: json['hakKelas'] is Map<String, dynamic>
          ? Provider.fromJson(json['hakKelas'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Mr {
  final String? noMR;
  final String? noTelepon;

  const Mr({this.noMR, this.noTelepon});

  factory Mr.fromJson(Map<String, dynamic> json) {
    return Mr(
      noMR: json['noMR']?.toString(),
      noTelepon: json['noTelepon']?.toString(),
    );
  }
}

class StatusPeserta {
  final String? kode;
  final String? keterangan;

  const StatusPeserta({this.kode, this.keterangan});

  factory StatusPeserta.fromJson(Map<String, dynamic> json) {
    return StatusPeserta(
      kode: json['kode']?.toString(),
      keterangan: json['keterangan']?.toString(),
    );
  }
}

class Diagnosa {
  final String? kode;
  final String? nama;

  const Diagnosa({this.kode, this.nama});

  factory Diagnosa.fromJson(Map<String, dynamic> json) {
    return Diagnosa(
      kode: json['kode']?.toString(),
      nama: json['nama']?.toString(),
    );
  }
}

class Pelayanan {
  final String? kode;
  final String? nama;

  const Pelayanan({this.kode, this.nama});

  factory Pelayanan.fromJson(Map<String, dynamic> json) {
    return Pelayanan(
      kode: json['kode']?.toString(),
      nama: json['nama']?.toString(),
    );
  }
}
