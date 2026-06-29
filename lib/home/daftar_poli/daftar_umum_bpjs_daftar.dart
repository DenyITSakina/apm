import 'package:apm/api/booking_api_service.dart';
import 'package:apm/dialog/sukses.dart';
import 'package:apm/dialog/top_toast.dart';
import 'package:apm/func/open_aplikasi_bpjsDaftar.dart';
import 'package:apm/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../theme/format_text.dart';
import '../../../models/poli_model.dart';
import '../../../models/dokter_model.dart';
import '../../../models/pasien_model.dart';
import '../../Blog/antrian_apm_bloc.dart';

class DaftarUmumBpjsDaftar extends StatefulWidget {
  final Map<String, dynamic> data;

  const DaftarUmumBpjsDaftar({super.key, required this.data});

  @override
  State<DaftarUmumBpjsDaftar> createState() => _DaftarUmumBpjsDaftarState();
}

class _DaftarUmumBpjsDaftarState extends State<DaftarUmumBpjsDaftar> {
  String? selectedTipe;
  PoliModel? selectedPoli;
  DokterModel? selectedDokter;
  final TextEditingController tglController = TextEditingController();
  final TextEditingController bpjsController = TextEditingController();

  // Untuk validasi input BPJS
  bool get isBpjsValid {
    if (selectedTipe != "BPJS") return true;
    final nomor = bpjsController.text.trim();
    return nomor.length == 13 && nomor.isNotEmpty;
  }

  Map<String, dynamic>? pasienData;
  bool _isCheckingBpjs = false;
  PasienBpjsResponse? _bpjsCheckResult;
  List<PoliModel> _poliList = [];

  bool get isFormValid {
    // Cek apakah semua field wajib terisi
    if (selectedTipe == null ||
        selectedDokter == null ||
        selectedPoli == null) {
      return false;
    }

    // Jika BPJS, cek validasi nomor BPJS
    if (selectedTipe == "BPJS") {
      final nomor = bpjsController.text.trim();
      if (nomor.length != 13 || nomor.isEmpty) {
        return false;
      }
      // BPJS harus sudah dicek dan valid
      if (_bpjsCheckResult == null || !_bpjsCheckResult!.status) {
        return false;
      }
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    tglController.text = DateTime.now().toString().split(" ")[0];
    context.read<AntrianApmBloc>().add(const FetchPoliListEvent());
    _extractPatientData();
    _loadPoliList();
  }

  void _loadPoliList() async {
    try {
      final poliList = await BookingApiService.getPoliList();
      setState(() {
        _poliList = poliList;
      });
    } catch (e) {
      print('Error loading poli list: $e');
    }
  }

  void _extractPatientData() {
    final rawData = widget.data;

    if (rawData['data'] != null && rawData['data']['data'] != null) {
      pasienData = Map<String, dynamic>.from(rawData['data']['data']);
    } else if (rawData['data'] != null) {
      pasienData = Map<String, dynamic>.from(rawData['data']);
    } else {
      pasienData = Map<String, dynamic>.from(rawData);
    }

    if (pasienData != null) {
      final noBpjs = getField(["no_bpjs", "bpjs", "no_peserta"]);
      if (noBpjs != "-" && noBpjs.trim().isNotEmpty) {
        bpjsController.text = noBpjs.trim();
      }
    }
  }

  String getField(List<String> keys) {
    if (pasienData == null) return '-';

    for (var key in keys) {
      if (pasienData![key] != null &&
          pasienData![key].toString().trim().isNotEmpty) {
        return pasienData![key].toString();
      }
    }
    return "-";
  }

  bool get hasBpjs {
    final noBpjs = getField(["no_bpjs", "bpjs", "no_peserta"]);
    return noBpjs != "-" && noBpjs.trim().isNotEmpty;
  }

  PoliModel? _getPoliByBpjsCode(String kodeBpjs) {
    if (_poliList.isEmpty || kodeBpjs.isEmpty) return null;

    try {
      return _poliList.firstWhere(
        (poli) => poli.kodeBpjs.toUpperCase() == kodeBpjs.toUpperCase(),
        orElse: () => _poliList.firstWhere(
          (poli) =>
              poli.kodeBpjs.toUpperCase().contains(kodeBpjs.toUpperCase()),
          orElse: () => _poliList.firstWhere(
            (poli) => poli.nama.toUpperCase().contains(kodeBpjs.toUpperCase()),
            orElse: () => throw Exception('Not found'),
          ),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  String _getKodePoliRujukan(PasienBpjsResponse result) {
    try {
      final rujukan = result.rujukan;
      if (rujukan == null) return '';

      if (rujukan is Map<String, dynamic>) {
        final bpjs = rujukan['bpjs'];
        if (bpjs is Map<String, dynamic>) {
          final rujukanList = bpjs['rujukan'];
          if (rujukanList is List && rujukanList.isNotEmpty) {
            final firstRujukan = rujukanList[0];
            if (firstRujukan is Map<String, dynamic>) {
              final poliRujukan = firstRujukan['poliRujukan'];
              if (poliRujukan is Map<String, dynamic>) {
                return poliRujukan['kode']?.toString() ?? '';
              }
            }
          }
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  Map<String, dynamic>? _getRujukanData(PasienBpjsResponse result) {
    try {
      final rujukan = result.rujukan;
      if (rujukan == null) return null;

      if (rujukan is Map<String, dynamic>) {
        final bpjs = rujukan['bpjs'];
        if (bpjs is Map<String, dynamic>) {
          final rujukanList = bpjs['rujukan'];
          if (rujukanList is List && rujukanList.isNotEmpty) {
            final firstRujukan = rujukanList[0];
            if (firstRujukan is Map<String, dynamic>) {
              return firstRujukan;
            }
          }
        }
      }
      return null;
    } catch (e) {
      print('Error getting rujukan data: $e');
      return null;
    }
  }

  Future<void> _checkBpjs() async {
    final nomor = bpjsController.text.trim();

    if (nomor.isEmpty) {
      TopToast.error(context, "Silakan masukkan nomor BPJS terlebih dahulu");
      return;
    }

    if (nomor.length != 13) {
      TopToast.error(context, "Nomor BPJS harus 13 digit");
      return;
    }

    setState(() {
      _isCheckingBpjs = true;
      _bpjsCheckResult = null;
    });

    try {
      final result = await BookingApiService.cekPasienBpjs(nomor);

      setState(() {
        _bpjsCheckResult = result;
        _isCheckingBpjs = false;
      });

      if (result.status) {
        String namaPasien = result.peserta?.nama ?? 'Data ditemukan';
        TopToast.success(context, "BPJS Valid: $namaPasien");

        if (result.peserta != null && pasienData != null) {
          setState(() {
            if (result.peserta!.nama.isNotEmpty) {
              pasienData!['nama'] = result.peserta!.nama;
            }
            pasienData!['no_bpjs'] = nomor;
            if (result.peserta!.nik.isNotEmpty) {
              pasienData!['nik'] = result.peserta!.nik;
            }
            if (result.peserta!.tglLahir != null &&
                result.peserta!.tglLahir!.isNotEmpty) {
              pasienData!['tgl_lahir'] = result.peserta!.tglLahir;
            }
            if (result.peserta!.jenisKelamin != null) {
              pasienData!['jenis_kelamin'] =
                  result.peserta!.jenisKelamin == 'Perempuan' ? 'P' : 'L';
            }
          });
        }

        final kodePoliRujukan = _getKodePoliRujukan(result);

        if (kodePoliRujukan.isNotEmpty) {
          final matchedPoli = _getPoliByBpjsCode(kodePoliRujukan);

          if (matchedPoli != null) {
            setState(() {
              selectedPoli = matchedPoli;
            });

            if (selectedTipe != null) {
              context.read<AntrianApmBloc>().add(
                FetchDokterEvent(
                  idLayanan: matchedPoli.id,
                  groupJaminan: selectedTipe == "UMUM" ? 1 : 2,
                ),
              );
            }

            TopToast.success(
              context,
              "Poli otomatis dipilih: ${matchedPoli.nama}",
            );
          } else {
            TopToast.info(
              context,
              "Poli rujukan ($kodePoliRujukan) tidak ditemukan di sistem",
            );
          }
        }
      } else {
        TopToast.error(context, result.message ?? "Nomor BPJS tidak valid");
      }
    } catch (e) {
      setState(() {
        _isCheckingBpjs = false;
      });
      TopToast.error(context, "Gagal mengecek BPJS: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final nama = formatNama(
      getField([
        "pasien",
        "nama",
        "nama_pasien",
        "namaPasien",
        "nama_lengkap",
        "nm_pasien",
      ]),
    );
    final noBpjs = getField(["no_bpjs", "bpjs", "no_peserta"]);
    final nik = getField(["nik", "no_identitas"]);
    final rm = getField(["rm", "rekam_medis", "no_rm"]);
    final alamat = getField(["alamat", "alamat_domisili", "alamat_pasien"]);
    final tglLahir = getField(["tgl_lahir"]);
    final jenisKelamin = getField(["jenis_kelamin"]);

    Map<String, dynamic>? rujukanData;
    bool hasRujukan = false;
    String kodePoliRujukan = '';
    String namaPoliRujukan = '';
    String diagnosa = '';
    String keluhan = '';
    String tglKunjungan = '';

    if (_bpjsCheckResult != null && _bpjsCheckResult!.status) {
      rujukanData = _getRujukanData(_bpjsCheckResult!);
      if (rujukanData != null) {
        hasRujukan = true;
        final poliRujukan = rujukanData['poliRujukan'] as Map<String, dynamic>?;
        if (poliRujukan != null) {
          kodePoliRujukan = poliRujukan['kode']?.toString() ?? '-';
          namaPoliRujukan = poliRujukan['nama']?.toString() ?? '-';
        }
        final diagnosaData = rujukanData['diagnosa'] as Map<String, dynamic>?;
        if (diagnosaData != null) {
          diagnosa = diagnosaData['nama']?.toString() ?? '-';
        }
        keluhan = rujukanData['keluhan']?.toString() ?? '-';
        tglKunjungan = rujukanData['tglKunjungan']?.toString() ?? '-';
      }
    }

    return BlocListener<AntrianApmBloc, AntrianApmState>(
      listener: (context, state) {
        if (state is PendaftaranSuccess) {
          showSuccessDialog(context, state.message);
        }
        if (state is AntrianApmError) {
          TopToast.error(context, state.pesan);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D8AAE),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Image.asset(
                  'assets/images/logo_sakina.png',
                  height: 45,
                  color: Colors.white,
                ),
              ),
              Text(
                "PENDAFTARAN PASIEN",
                style: GoogleFonts.oswald(
                  fontWeight: FontWeight.w600,
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Pasien Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade600, Colors.teal.shade300],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: DefaultTextStyle(
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "DATA PASIEN",
                        style: GoogleFonts.oswald(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Divider(color: Colors.white54),
                      _detail("Nama", nama),
                      _detail("NIK", nik),
                      _detail("No BPJS", noBpjs.isNotEmpty ? noBpjs : '-'),
                      _detail("No RM", rm),
                      _detail("Tgl Lahir", tglLahir),
                      _detail(
                        "Jenis Kelamin",
                        jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan',
                      ),
                      _detail("Alamat", alamat),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Form Pendaftaran",
                style: GoogleFonts.oswald(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pilih Jenis Pendaftaran (silahkan klik salah satu untuk melanjutkan pendaftaran)",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedTipe = "UMUM";
                              selectedPoli = null;
                              selectedDokter = null;
                              _bpjsCheckResult = null;
                              bpjsController.clear();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedTipe == "UMUM"
                                ? Colors.blue
                                : Colors.grey.shade300,
                            foregroundColor: selectedTipe == "UMUM"
                                ? Colors.white
                                : Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "UMUM",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: hasBpjs
                              ? () {
                                  setState(() {
                                    selectedTipe = "BPJS";
                                    selectedPoli = null;
                                    selectedDokter = null;
                                    _bpjsCheckResult = null;
                                    final noBpjs = getField([
                                      "no_bpjs",
                                      "bpjs",
                                      "no_peserta",
                                    ]);
                                    if (noBpjs != "-" &&
                                        noBpjs.trim().isNotEmpty) {
                                      bpjsController.text = noBpjs.trim();
                                    }
                                  });
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedTipe == "BPJS"
                                ? Colors.green
                                : Colors.grey.shade300,
                            foregroundColor: selectedTipe == "BPJS"
                                ? Colors.white
                                : Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            hasBpjs ? "BPJS" : "BPJS (Tidak Aktif)",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (selectedTipe == "BPJS") ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.assignment_ind,
                                color: Colors.green.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Nomor BPJS Pasien",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Row dengan input dan tombol cek
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: bpjsController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 13,
                                  decoration: InputDecoration(
                                    hintText: "Masukkan 13 digit nomor BPJS",
                                    fillColor: Colors.white,
                                    filled: true,
                                    counterText: "",
                                    prefixIcon: Icon(
                                      Icons.numbers,
                                      color: Colors.green.shade700,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color:
                                            _bpjsCheckResult != null &&
                                                _bpjsCheckResult!.status
                                            ? Colors.green.shade300
                                            : _bpjsCheckResult != null &&
                                                  !_bpjsCheckResult!.status
                                            ? Colors.red.shade300
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color:
                                            _bpjsCheckResult != null &&
                                                _bpjsCheckResult!.status
                                            ? Colors.green.shade700
                                            : Colors.grey.shade700,
                                        width: 2,
                                      ),
                                    ),
                                    errorText:
                                        bpjsController.text.isNotEmpty &&
                                            bpjsController.text.trim().length !=
                                                13
                                        ? "Nomor BPJS harus 13 digit"
                                        : null,
                                    errorStyle: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _bpjsCheckResult = null;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Tombol Cek BPJS
                              ElevatedButton(
                                onPressed: _isCheckingBpjs ? null : _checkBpjs,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _bpjsCheckResult != null &&
                                          _bpjsCheckResult!.status
                                      ? Colors.green
                                      : Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: _isCheckingBpjs
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child:
                                            LoadingAnimationWidget.fourRotatingDots(
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _bpjsCheckResult != null &&
                                                    _bpjsCheckResult!.status
                                                ? Icons.check_circle
                                                : Icons.search,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _bpjsCheckResult != null &&
                                                    _bpjsCheckResult!.status
                                                ? "Valid"
                                                : "Cek",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),

                          // Tampilkan status validasi dengan detail data BPJS
                          if (_bpjsCheckResult != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _bpjsCheckResult!.status
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _bpjsCheckResult!.status
                                            ? Icons.check_circle
                                            : Icons.error,
                                        color: _bpjsCheckResult!.status
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _bpjsCheckResult!.status
                                              ? "BPJS Valid"
                                              : "${_bpjsCheckResult!.message ?? 'Nomor BPJS tidak valid'}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: _bpjsCheckResult!.status
                                                ? Colors.green.shade800
                                                : Colors.red.shade800,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (_bpjsCheckResult!.status &&
                                      _bpjsCheckResult!.peserta != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _detailBpjs(
                                            "Nama",
                                            _bpjsCheckResult!.peserta!.nama,
                                          ),
                                          _detailBpjs(
                                            "NIK",
                                            _bpjsCheckResult!.peserta!.nik,
                                          ),
                                          if (_bpjsCheckResult!
                                                  .peserta!
                                                  .tglLahir !=
                                              null)
                                            _detailBpjs(
                                              "Tgl Lahir",
                                              _bpjsCheckResult!
                                                  .peserta!
                                                  .tglLahir!,
                                            ),
                                          if (_bpjsCheckResult!
                                                  .peserta!
                                                  .jenisKelamin !=
                                              null)
                                            _detailBpjs(
                                              "Jenis Kelamin",
                                              _bpjsCheckResult!
                                                  .peserta!
                                                  .jenisKelamin!,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  if (_bpjsCheckResult!.status &&
                                      hasRujukan) ...[
                                    const Divider(color: Colors.grey),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Data Rujukan",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _detailBpjs("Diagnosa", diagnosa),
                                          _detailBpjs("Keluhan", keluhan),
                                          _detailBpjs(
                                            "Poli Rujukan",
                                            "$kodePoliRujukan - $namaPoliRujukan",
                                          ),
                                          if (tglKunjungan != '-')
                                            _detailBpjs(
                                              "Tgl Kunjungan",
                                              tglKunjungan,
                                            ),
                                        ],
                                      ),
                                    ),

                                    if (selectedPoli != null) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.green.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green.shade700,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                "Poli otomatis dipilih: ${selectedPoli!.nama}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green.shade800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 4),
                          Text(
                            "Contoh: 0001234567890",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  const SizedBox(height: 20),

                  TextField(
                    controller: tglController,
                    readOnly: true,
                    decoration: _inputStyle("Tanggal Kunjungan").copyWith(
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  BlocBuilder<AntrianApmBloc, AntrianApmState>(
                    builder: (_, state) {
                      List<PoliModel> poliList = [];
                      if (state is PoliListLoaded) {
                        poliList = state.poliList;
                      } else if (state is DokterLoaded &&
                          selectedPoli != null) {
                        poliList = [selectedPoli!];
                      }

                      if (poliList.isEmpty) {
                        return const SizedBox();
                      }

                      final isDisabled =
                          selectedTipe == "BPJS" &&
                          _bpjsCheckResult?.status == true &&
                          selectedPoli != null &&
                          hasRujukan;

                      return CustomDropdown<PoliModel>(
                        label: isDisabled
                            ? "Poli (Otomatis dari Rujukan)"
                            : "Pilih Poli",
                        value: poliList.contains(selectedPoli)
                            ? selectedPoli
                            : null,
                        items: poliList,
                        display: (p) => p.nama,
                        enabled: !isDisabled,
                        onChanged: (poli) {
                          if (isDisabled) return;

                          setState(() {
                            selectedPoli = poli;
                            selectedDokter = null;
                          });

                          if (poli != null && selectedTipe != null) {
                            context.read<AntrianApmBloc>().add(
                              FetchDokterEvent(
                                idLayanan: poli.id,
                                groupJaminan: selectedTipe == "UMUM" ? 1 : 2,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  BlocBuilder<AntrianApmBloc, AntrianApmState>(
                    builder: (_, state) {
                      if (state is DokterLoaded && selectedPoli != null) {
                        final filteredDokter = state.dokterList.where((dokter) {
                          if (dokter.libur != 0) return false;

                          if (selectedTipe == "UMUM") {
                            return dokter.tipe == null || dokter.tipe == "0";
                          } else {
                            if (dokter.tipe != "1") return false;

                            if ((dokter.kapasitasPasien ?? 0) <= 0)
                              return false;

                            return true;
                          }
                        }).toList();

                        if (filteredDokter.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    selectedTipe == "UMUM"
                                        ? "Tidak ada dokter umum tersedia untuk poli ini"
                                        : "Tidak ada dokter BPJS tersedia untuk poli ini",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Pilih Dokter",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedTipe = null;
                                      selectedPoli = null;
                                      selectedDokter = null;
                                      tglController.text = DateTime.now()
                                          .toString()
                                          .split(" ")[0];
                                      bpjsController.clear();
                                      _bpjsCheckResult = null;
                                    });
                                    context.read<AntrianApmBloc>().add(
                                      const FetchPoliListEvent(),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.teal),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    "ULANG PENGISIAN",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...filteredDokter.map((dokter) {
                              return DokterListItem(
                                dokter: dokter,
                                isSelected: selectedDokter == dokter,
                                onTap: () {
                                  setState(() {
                                    selectedDokter = dokter;
                                  });
                                },
                                selectedTipe: selectedTipe,
                              );
                            }).toList(),
                          ],
                        );
                      }
                      return const SizedBox();
                    },
                  ),

                  const SizedBox(height: 35),

                  // TOMBOL DAFTAR DENGAN VALIDASI
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 60,
                  //   child: ElevatedButton(
                  //     onPressed: isFormValid
                  //         ? () async {
                  //             // Validasi BPJS
                  //             if (selectedTipe == "BPJS") {
                  //               final nomor = bpjsController.text.trim();
                  //               if (nomor.isEmpty || nomor.length != 13) {
                  //                 TopToast.error(
                  //                   context,
                  //                   "Nomor BPJS harus 13 digit!",
                  //                 );
                  //                 return;
                  //               }

                  //               // Pastikan BPJS sudah dicek dan valid
                  //               if (_bpjsCheckResult == null ||
                  //                   !_bpjsCheckResult!.status) {
                  //                 TopToast.error(
                  //                   context,
                  //                   "Silakan cek validitas nomor BPJS terlebih dahulu!",
                  //                 );
                  //                 return;
                  //               }

                  //               // Buka aplikasi BPJS
                  //               final sukses = await openExeFromMap(context, {
                  //                 "nomor": nomor,
                  //               });

                  //               if (sukses == false) return;
                  //             }

                  //             await Future.delayed(
                  //               const Duration(milliseconds: 1500),
                  //             );

                  //             context.read<AntrianApmBloc>().add(
                  //               LanjutKePendaftaranEvent(
                  //                 rm: rm,
                  //                 jaminan: selectedTipe!,
                  //                 idJadwalDokter:
                  //                     selectedDokter!.idJadwalDetail,
                  //                 idDokter: selectedDokter!.idDokter.toString(),
                  //                 idLayanan: selectedPoli!.id.toString(),
                  //                 jenisAntrian: "pendaftaran",
                  //               ),
                  //             );
                  //           }
                  //         : null,
                  //     style:
                  //         ElevatedButton.styleFrom(
                  //           padding: EdgeInsets.zero,
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(20),
                  //           ),
                  //         ).copyWith(
                  //           backgroundColor: MaterialStateProperty.resolveWith(
                  //             (states) =>
                  //                 states.contains(MaterialState.disabled)
                  //                 ? Colors.grey
                  //                 : null,
                  //           ),
                  //         ),
                  //     child: Ink(
                  //       decoration: BoxDecoration(
                  //         gradient: LinearGradient(
                  //           colors: [
                  //             Colors.teal.shade700,
                  //             Colors.teal.shade400,
                  //           ],
                  //         ),
                  //         borderRadius: BorderRadius.circular(20),
                  //       ),
                  //       child: Center(
                  //         child: Text(
                  //           "DAFTAR PASIEN",
                  //           style: GoogleFonts.poppins(
                  //             fontSize: 20,
                  //             fontWeight: FontWeight.bold,
                  //             color: Colors.white,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: isFormValid
                          ? () async {
                              if (selectedTipe == "BPJS") {
                                final nomor = bpjsController.text.trim();

                                if (nomor.isEmpty) {
                                  TopToast.error(
                                    context,
                                    "Nomor BPJS tidak boleh kosong!",
                                  );
                                  return;
                                }

                                if (nomor.length != 13) {
                                  TopToast.error(
                                    context,
                                    "Nomor BPJS harus 13 digit! (saat ini: ${nomor.length} digit)",
                                  );
                                  return;
                                }

                                if (!RegExp(r'^[0-9]+$').hasMatch(nomor)) {
                                  TopToast.error(
                                    context,
                                    "Nomor BPJS hanya boleh terdiri dari angka!",
                                  );
                                  return;
                                }

                                if (_bpjsCheckResult == null) {
                                  TopToast.error(
                                    context,
                                    "Silakan cek validitas nomor BPJS terlebih dahulu!",
                                  );
                                  return;
                                }

                                if (!_bpjsCheckResult!.status) {
                                  TopToast.error(
                                    context,
                                    "Nomor BPJS tidak valid! ${_bpjsCheckResult!.message ?? ''}",
                                  );
                                  return;
                                }

                                if (_bpjsCheckResult!.rujukan == null) {
                                  TopToast.warning(
                                    context,
                                    "Tidak ditemukan data rujukan untuk nomor BPJS ini",
                                  );
                                  return;
                                }

                                final sukses = await openExeFromMap(context, {
                                  "nomor": nomor,
                                });

                                if (sukses == false) {
                                  TopToast.error(
                                    context,
                                    "Gagal membuka aplikasi BPJS",
                                  );
                                  return;
                                }
                              }

                              await Future.delayed(
                                const Duration(milliseconds: 1500),
                              );

                              context.read<AntrianApmBloc>().add(
                                LanjutKePendaftaranEvent(
                                  rm: rm,
                                  jaminan: selectedTipe!,
                                  idJadwalDokter:
                                      selectedDokter!.idJadwalDetail,
                                  idDokter: selectedDokter!.idDokter.toString(),
                                  idLayanan: selectedPoli!.id.toString(),
                                  jenisAntrian: "pendaftaran",
                                ),
                              );
                            }
                          : null,
                      style:
                          ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ).copyWith(
                            backgroundColor: MaterialStateProperty.resolveWith(
                              (states) =>
                                  states.contains(MaterialState.disabled)
                                  ? Colors.grey
                                  : null,
                            ),
                          ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade700,
                              Colors.teal.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            "DAFTAR PASIEN",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (!isFormValid && selectedTipe != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getValidationMessage(),
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getValidationMessage() {
    if (selectedTipe == null) {
      return "Silakan pilih jenis pendaftaran terlebih dahulu";
    }
    if (selectedTipe == "BPJS") {
      final nomor = bpjsController.text.trim();
      if (nomor.isEmpty) {
        return "Silakan masukkan nomor BPJS (13 digit)";
      }
      if (nomor.length != 13) {
        return "Nomor BPJS harus terdiri dari 13 digit";
      }
      if (_bpjsCheckResult == null || !_bpjsCheckResult!.status) {
        return "Silakan cek validitas nomor BPJS terlebih dahulu";
      }
    }
    if (selectedPoli == null) {
      return "Silakan pilih poli tujuan";
    }
    if (selectedDokter == null) {
      return "Silakan pilih dokter yang tersedia";
    }
    return "";
  }

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );

  Widget _detailBpjs(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            "$label:",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );

  InputDecoration _inputStyle(String label) => InputDecoration(
    labelText: label,
    fillColor: Colors.white,
    filled: true,
    labelStyle: GoogleFonts.poppins(),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
  );
}

class DokterListItem extends StatelessWidget {
  final DokterModel dokter;
  final bool isSelected;
  final VoidCallback onTap;
  final String? selectedTipe;

  const DokterListItem({
    super.key,
    required this.dokter,
    required this.isSelected,
    required this.onTap,
    this.selectedTipe,
  });

  @override
  Widget build(BuildContext context) {
    String jamPraktek = '';
    if (dokter.jadwal != null && dokter.jadwal!.isNotEmpty) {
      jamPraktek = dokter.jadwal!;
    } else if (dokter.jamBuka.isNotEmpty && dokter.jamTutup.isNotEmpty) {
      jamPraktek = '${dokter.jamBuka} - ${dokter.jamTutup}';
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.teal.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.teal.withOpacity(0.2)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medical_services_outlined,
                    size: 20,
                    color: isSelected
                        ? Colors.teal.shade700
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dokter.namaDokter,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isSelected
                              ? Colors.teal.shade800
                              : Colors.black87,
                        ),
                      ),
                      if (jamPraktek.isNotEmpty)
                        Text(
                          "🕒 $jamPraktek",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (dokter.kapasitasPasien != null &&
                    dokter.kapasitasPasien! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Sisa: ${dokter.kapasitasPasien}",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),

                if (selectedTipe == "BPJS" &&
                    dokter.kuotaNonJkn != null &&
                    dokter.kuotaNonJkn! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "📋 Kuota: ${dokter.kuotaNonJkn}",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: dokter.libur == 0
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dokter.libur == 0 ? "Tersedia" : "Libur",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: dokter.libur == 0
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
