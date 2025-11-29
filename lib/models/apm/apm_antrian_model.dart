//  MODEL : ANTRIAN APM

class ApmAntrianModel {
  final String id;
  final String idJadwalDokter;
  final String pasien;
  final String alamat;
  final String noBooking;
  final String? rm;
  final String? noPeserta;
  final String? jenisBooking;
  final String noAntrian;
  final String? noIdentitas;
  final String tglLahir;
  final String namaPoli;
  final String? batalBooking;

  ApmAntrianModel({
    required this.id,
    required this.idJadwalDokter,
    required this.pasien,
    required this.alamat,
    required this.tglLahir,
    required this.namaPoli,
    required this.noAntrian,
    required this.noBooking,
    this.rm,
    this.noPeserta,
    this.jenisBooking,
    this.noIdentitas,
    this.batalBooking,
  });

  factory ApmAntrianModel.fromJson(Map<String, dynamic> json) {
    return ApmAntrianModel(
      id: json['id']?.toString() ?? '',
      idJadwalDokter: json['id_jadwal_dokter']?.toString() ?? '',
      pasien: json['pasien'] ?? '',
      alamat: json['alamat_domisili'] ?? '',
      tglLahir: json['tgl_lahir'] ?? '',
      namaPoli: json['nama_poli'] ?? '',
      noBooking: json['no_booking'] ?? '',
      rm: json['rm'],
      noPeserta: json['no_peserta'],
      jenisBooking: json['jenis_booking'],
      noAntrian: json['no_antrian'] ?? '',
      noIdentitas: json['no_identitas'],
      batalBooking: json['batal_booking']?.toString(),
    );
  }

  bool get isDibatalkan => batalBooking == '1';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_jadwal_dokter': idJadwalDokter,
      'pasien': pasien,
      'alamat_domisili': alamat,
      'tgl_lahir': tglLahir,
      'nama_poli': namaPoli,
      'rm': rm,
      'no_peserta': noPeserta,
      'jenis_booking': jenisBooking,
      'no_antrian': noAntrian,
      'no_identitas': noIdentitas,
      'batal_booking': batalBooking,
    };
  }
}

//  MODEL : ANTRIAN POLI
class ApmAntrianPoliModel {
  final String noBooking;
  final String noAntrianPoli;
  final String namaPoli; 
  final String namaPasien;
  final String rmPoli;
  final String jaminan;
  final int idDokter;
  final String idJadwalDokter;
  final int idLayanan;

  ApmAntrianPoliModel({
    required this.noBooking,
    required this.noAntrianPoli,
    required this.namaPoli,
    required this.namaPasien,
    required this.rmPoli,
    required this.jaminan,
    required this.idDokter,
    required this.idJadwalDokter,
    required this.idLayanan,
  });

  factory ApmAntrianPoliModel.fromJson(Map<String, dynamic> json) {
    return ApmAntrianPoliModel(
      noBooking: json['no_booking']?.toString() ?? '',
      noAntrianPoli: json['no_antrian']?.toString() ?? '',
      namaPoli: json['nama_poli']?.toString() ?? '',
      namaPasien: json['nama_pasien']?.toString() ?? '',
      rmPoli: json['rm']?.toString() ?? '',
      jaminan: json['jaminan']?.toString() ?? '',
      idDokter: int.tryParse(json['id_dokter']?.toString() ?? '0') ?? 0,
      idJadwalDokter: json['id_jadwal_dokter']?.toString() ?? '',
      idLayanan: int.tryParse(json['id_layanan']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no_booking': noBooking,
      'no_antrian': noAntrianPoli,
      'nama_poli': namaPoli,
      'nama_pasien': namaPasien,
      'rm': rmPoli,
      'jaminan': jaminan,
      'id_dokter': idDokter,
      'id_jadwal_dokter': idJadwalDokter,
      'id_layanan': idLayanan,
    };
  }
}


//  MODEL : POLI
// class PoliModel {
//   final String id;
//   final String poli;

//   PoliModel({
//     required this.id,
//     required this.poli,
//   });

//   factory PoliModel.fromJson(Map<String, dynamic> json) {
//     return PoliModel(
//       id: json['id']?.toString() ?? '',
//       poli: json['poli'] ?? json['nama_poli'] ?? '',
//     );
//   }
// }

class PoliModel {
  final int id;
  final String poli;
  final String? kodeBpjs;

  PoliModel({
    required this.id,
    required this.poli,
    this.kodeBpjs,
  });

  factory PoliModel.fromJson(Map<String, dynamic> json) {
    return PoliModel(
      id: int.tryParse(json['id'].toString()) ?? 0, // Pastikan ini aman
      poli: json['poli']?.toString() ?? '',
      kodeBpjs: json['kode_bpjs']?.toString(),
    );
  }
}



//  MODEL : DOKTER


// class DokterModel {
//   final String id;
//   final int idDokter;
//   final String namaDokter;
//   final String namaPoli;
//   final String? tipe;

//   DokterModel({
//     required this.id,
//     required this.idDokter,
//     required this.namaDokter,
//     required this.namaPoli,
//     this.tipe,
//   });

//   factory DokterModel.fromJson(Map<String, dynamic> json) {
//     return DokterModel(
//       id: json['id_jadwal_dokter']?.toString() ?? '',
//       idDokter: json['id_dokter'] != null
//           ? int.tryParse(json['id_dokter'].toString()) ?? 0
//           : 0,
//       namaDokter: json['nama_dokter'] ??
//           json['namadokter'] ??
//           '',
//       namaPoli: json['nama_poli'] ??
//           json['namapoli'] ??
//           '',
//       tipe: json['tipe'],
//     );
//   }
// }

class DokterModel {
  final String id;
  final int idDokter;
  final String namaDokter;
  final String namaPoli;
  final String? tipe;

  DokterModel({
    required this.id,
    required this.idDokter,
    required this.namaDokter,
    required this.namaPoli,
    this.tipe,
  });

  factory DokterModel.fromJson(Map<String, dynamic> json) {
    return DokterModel(
      id: json['id']?.toString() ?? '',
      idDokter: int.tryParse(json['id_dokter'].toString()) ?? 0,
      namaDokter: json['namadokter']?.toString() ?? '',
      namaPoli: json['namapoli']?.toString() ?? '',
      tipe: json['tipe']?.toString(),
    );
  }
}


//  MODEL : PENDAFTARAN POLI

class PendaftaranPoliModel {
  final String id;
  final String rm;
  final String nama;
  final String namaPoli;
  final String idUnit;
  final String idJaminan;
  final String idJadwalDokter;
  final String idDokter;
  final String grupJaminan;
  final String noAntrian;
  final String createdAt;

  PendaftaranPoliModel({
    required this.id,
    required this.rm,
    required this.nama,
    required this.namaPoli,
    required this.idUnit,
    required this.idJaminan,
    required this.idJadwalDokter,
    required this.idDokter,
    required this.grupJaminan,
    required this.noAntrian,
    required this.createdAt,
  });

  factory PendaftaranPoliModel.fromJson(Map<String, dynamic> json) {
    return PendaftaranPoliModel(
      id: json['id']?.toString() ?? '',
      rm: json['rm']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      namaPoli: json['nama_poli']?.toString() ?? '',
      idUnit: json['id_unit']?.toString() ?? '',
      idJaminan: json['id_jaminan']?.toString() ?? '',
      idDokter: json['id_dokter']?.toString() ?? '',
      idJadwalDokter: json['id_jadwal_dokter']?.toString() ?? '',
      grupJaminan: json['grup_jaminan']?.toString() ?? '',
      noAntrian: json['no_antrian']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
  
}

class JadwalDokterModel {
  final String idJadwalDokter;
  final int idDokter;
  final String namaDokter;
  final String namaPoli;
  final String tanggal;
  final String jamMulai;
  final String jamSelesai;
  final String status;

  JadwalDokterModel({
    required this.idJadwalDokter,
    required this.idDokter,
    required this.namaDokter,
    required this.namaPoli,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.status,
  });

  factory JadwalDokterModel.fromJson(Map<String, dynamic> json) {
    return JadwalDokterModel(
      idJadwalDokter: json['id_jadwal_dokter']?.toString() ?? '',
      idDokter: int.tryParse(json['id_dokter']?.toString() ?? '0') ?? 0,
      namaDokter: json['nama_dokter']?.toString() ?? '',
      namaPoli: json['nama_poli']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? '',
      jamMulai: json['jam_mulai']?.toString() ?? '',
      jamSelesai: json['jam_selesai']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}