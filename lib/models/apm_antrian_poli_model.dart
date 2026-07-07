class ApmAntrianPoliModel {
  String noBooking;
  String noAntrianPoli;
  String nama;
  String rm;
  String noChekinPoli;
  String namaPoli;
  int idDokter;
  String namadokter;
  String tanggalLahir;
  String tanggalBooking;
  String jamBooking;
  String idJadwalDokter;
  int idLayanan;

  ApmAntrianPoliModel({
    required this.noBooking,
    required this.noAntrianPoli,
    required this.noChekinPoli,
    required this.nama,
    required this.rm,
    required this.namaPoli,
    required this.idDokter,
    required this.namadokter,
    required this.tanggalLahir,
    required this.jamBooking,
    required this.tanggalBooking,

    required this.idJadwalDokter,
    required this.idLayanan,
  });

  factory ApmAntrianPoliModel.fromJson(Map<String, dynamic> json) {
    final rootData = (json['data'] as Map<String, dynamic>?) ?? {};
    final data = (rootData['data'] as Map<String, dynamic>?) ?? rootData;
    final poliFromKey =
        data['namapoli']?.toString() ?? data['nama_poli']?.toString();
    final poliFromNested =
        (data['polyclinic'] as Map<String, dynamic>?)?['nama']?.toString();
    final namaPoliFinal = (poliFromKey ?? poliFromNested ?? '').toString();

    final dokterFromKey =
        data['namadokter']?.toString() ?? data['nama_dokter']?.toString();
    final dokterFromNested =
        (data['doctor'] as Map<String, dynamic>?)?['namadokter']?.toString();
    final namadokterFinal = (dokterFromKey ?? dokterFromNested ?? '')
        .toString();

    return ApmAntrianPoliModel(
      noBooking: data['id']?.toString() ?? '',
      noAntrianPoli: data['no_antrian']?.toString() ?? '',
      noChekinPoli: rootData['no_checkin']?.toString() ?? '',
      nama: data['nama']?.toString() ?? '',
      rm: data['rm']?.toString() ?? '',
      namaPoli: namaPoliFinal.isNotEmpty ? namaPoliFinal : '-',
      idDokter: int.tryParse(data['id_dokter']?.toString() ?? '0') ?? 0,
      namadokter: namadokterFinal,
      idJadwalDokter: data['id_jadwal_dokter']?.toString() ?? '',
      idLayanan: int.tryParse(data['id_unit']?.toString() ?? '0') ?? 0,
      tanggalLahir: data['tgl_lahir']?.toString() ?? '',
      tanggalBooking: data['tgl_booking']?.toString() ?? '',
      jamBooking: data['jam_booking']?.toString() ?? '',
    );
  }
}
