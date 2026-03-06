import 'package:apm/dialog/sukses.dart';
import 'package:apm/dialog/top_toast.dart';
import 'package:apm/func/open_aplikasi_bpjsDaftar.dart';
import 'package:apm/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/format_text.dart';
import '../../models/poli_model.dart';
import '../../models/dokter_model.dart';
import '../Blog/antrian_apm_bloc.dart';

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

  //
  bool get hasBpjs {
    final noBpjs = getField(["no_bpjs", "bpjs", "no_peserta"]);
    return noBpjs != "-" && noBpjs.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    tglController.text = DateTime.now().toString().split(" ")[0];
    context.read<AntrianApmBloc>().add(const FetchPoliListEvent());
  }

  String getField(List<String> keys) {
    for (var key in keys) {
      if (widget.data[key] != null &&
          widget.data[key].toString().trim().isNotEmpty) {
        return widget.data[key].toString();
      }
    }
    return "-";
  }

  bool get isFormValid =>
      selectedTipe != null && selectedDokter != null && selectedPoli != null;

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
                        "🩺 DATA PASIEN",
                        style: GoogleFonts.oswald(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const Divider(color: Colors.white54),
                      _detail("Nama", formatNama(nama)),
                      _detail("NIK", nik),
                      _detail("No BPJS", noBpjs),
                      _detail("No RM", rm),
                      _detail("Alamat", formatNama(alamat)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Form Pendaftaran",
                style: GoogleFonts.oswald(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pilih Jenis Pendaftaran",
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

                      return CustomDropdown<PoliModel>(
                        label: "Pilih Poli",
                        value: poliList.contains(selectedPoli)
                            ? selectedPoli
                            : null,
                        items: poliList,
                        display: (p) => p.nama,
                        onChanged: (poli) {
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

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      // onPressed: isFormValid
                      //     ? () {
                      //         context.read<AntrianApmBloc>().add(
                      //           LanjutKePendaftaranEvent(
                      //             rm: rm,
                      //             jaminan: selectedTipe!,
                      //             idJadwalDokter: selectedDokter!.id.toString(),
                      //             idDokter: selectedDokter!.idDokter.toString(),
                      //             idLayanan: selectedPoli!.id.toString(),
                      //             jenisAntrian: "pendaftaran",
                      //           ),
                      //         );
                      //       }
                      //     : null,
                      onPressed: isFormValid
                          ? () async {
                              if (selectedTipe == "BPJS") {
                                final noBpjs = getField([
                                  "no_bpjs",
                                  "bpjs",
                                  "no_peserta",
                                ]);
                                final nomor = noBpjs.trim();

                                if (nomor == null || nomor.length != 13) {
                                  TopToast.error(
                                    context,
                                    "Nomor BPJS harus 13 digit!",
                                  );
                                  return;
                                }

                                final sukses = await openExeFromMap(context, {
                                  "nomor": nomor,
                                });

                                if (sukses == false) return;
                              }

                              await Future.delayed(
                                const Duration(milliseconds: 1500),
                              );

                              context.read<AntrianApmBloc>().add(
                                LanjutKePendaftaranEvent(
                                  rm: rm,
                                  jaminan: selectedTipe!,
                                  // idJadwalDokter: selectedDokter.toString(),
                                  idJadwalDokter: selectedDokter!.idJadwal,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  InputDecoration _inputStyle(String label) => InputDecoration(
    labelText: label,
    fillColor: Colors.white,
    filled: true,
    labelStyle: GoogleFonts.poppins(),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
  );

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T)? display,
  }) => DropdownButtonFormField<T>(
    key: ValueKey(selectedTipe),
    value: value,
    decoration: _inputStyle(label),
    items: items
        .map(
          (e) => DropdownMenuItem(
            value: e,
            child: Text(
              display != null ? display(e) : e.toString(),
              style: GoogleFonts.poppins(fontSize: 17),
            ),
          ),
        )
        .toList(),
    onChanged: onChanged,
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

            // Informasi tambahan
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                // Kapasitas pasien
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
                      "📊 Sisa: ${dokter.kapasitasPasien}",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),

                // Kuota BPJS
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

                // Status
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
