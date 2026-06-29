import 'package:apm/Blog/antrian_apm_bloc.dart';
import 'package:apm/dialog/top_toast.dart';
import 'package:apm/func/open_aplikasi_bpjsDaftar.dart';
import 'package:apm/theme/Style/format_tgl.dart';
import 'package:apm/theme/format_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../dialog/konfirmasi.dart';
import '../../dialog/sukses.dart';
import '../../models/apm_antrian_model.dart';

class CekinBpjsDataPage extends StatelessWidget {
  final String noBpjs;
  final ApmAntrianModel data;
  final String jenisPasien;

  const CekinBpjsDataPage({
    super.key,
    required this.noBpjs,
    required this.data,
    required this.jenisPasien,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AntrianApmBloc, AntrianApmState>(
      listener: (context, state) {
        if (state is AntrianApmPrinted) {
          showSuccessDialog(context, "Sukses: ${state.message}");
        } else if (state is AntrianApmPrinting) {
          showSuccessDialog(context, "Sukses");
        } else if (state is AntrianApmError) {
          TopToast.error(context, state.pesan);
        } else if (state is AntrianApmBlocked) {
          TopToast.warning(context, state.message);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context);
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF7F9),
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
            children: [
              Image.asset(
                'assets/images/logo_sakina.png',
                height: 45,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                "DATA PASIEN BPJS",
                style: GoogleFonts.oswald(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // _logoHeader(),
              // const SizedBox(height: 20),
              _buildCardData(),
              const SizedBox(height: 30),
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // Logo RSU Sakina di atas
  Widget _logoHeader() {
    return Center(
      child: Column(
        children: [
          Image.asset('assets/images/logo_sakina.png', height: 80, color: null),
          const SizedBox(height: 12),
          Text(
            "RSU Sakina Idaman",
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardData() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D8AAE), Color(0xFF0ABF68)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Text(
              "DATA PASIEN BPJS",
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildInfoRow("Nama Pasien", formatNama(data.pasien)),
                _buildInfoRow(
                  "Tanggal Lahir",
                  formatTglBlnTahun(data.tglLahir),
                ),
                _buildInfoRow("Alamat", formatNama(data.alamatDomisili)),
                _buildInfoRow("Nomor RM", data.rm ?? "-"),
                _buildInfoRow("No. Booking", data.noBooking ?? "-"),
                _buildInfoRow("No. BPJS", data.noPeserta),
                _buildInfoRow("No. Nik", data.noIdentitas),
                _buildInfoRow("Nama Poli", data.namaPoli),
                _buildInfoRow("Nama Dokter", data.namaDokter),

                _buildInfoRow("Jenis Pasien", "BPJS"),
                const SizedBox(height: 20),
                // Container(
                //   padding: const EdgeInsets.all(12),
                //   decoration: BoxDecoration(
                //     color: Colors.teal.shade50,
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: Text(
                //     "Silahkan pilih POLI atau Loket untuk melanjutkan check-in.",
                //     textAlign: TextAlign.center,
                //     style: GoogleFonts.poppins(
                //       fontSize: 14,
                //       fontWeight: FontWeight.w500,
                //       color: Colors.teal.shade900,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "$title:",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.teal.shade700,
                height: 1.2,
              ),
            ),
          ),
          Expanded(
            flex: 25,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.teal.shade900,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return BlocBuilder<AntrianApmBloc, AntrianApmState>(
      builder: (context, state) {
        final isLoadingPoli = state is AntrianApmLoading;
        final isLoadingLoket = state is AntrianApmPrinting;

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: isLoadingPoli
                            ? null
                            : () async {
                                final nomor = data.noIdentitas?.trim() ?? '';
                                if (nomor.isEmpty) {
                                  TopToast.error(
                                    context,
                                    "Nomor Nik tidak ditemukan!",
                                  );
                                  return;
                                }
                                if (nomor.length != 16) {
                                  TopToast.error(
                                    context,
                                    "Nomor harus 16 digit!",
                                  );
                                  return;
                                }

                                final sukses = await openExeFromMap(context, {
                                  "nomor": nomor,
                                });

                                // Validasi sukses/gagal: jika gagal, tombol tidak lanjut ke poli.
                                if (sukses != true) {
                                  TopToast.error(
                                    context,
                                    "Gagal membuka aplikasi BPJS/menyiapkan input. Silakan coba lagi.",
                                  );
                                  return;
                                }

                                ConfirmationDialog.show(
                                  context,
                                  title: "Menuju Poli",
                                  message:
                                      "Anda yakin ingin melanjutkan ke pelayanan POLI?",
                                  onConfirm: () {
                                    context.read<AntrianApmBloc>().add(
                                      LanjutKePoliEvent(
                                        noRm: data.rm,
                                        jenisAntrian: jenisPasien.toLowerCase(),
                                      ),
                                    );
                                  },
                                );
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0ABF68), Color(0xFF089E59)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: isLoadingPoli
                                ? LoadingAnimationWidget.fourRotatingDots(
                                    color: Colors.white,
                                    size: 15,
                                  )
                                : Text(
                                    "LANJUT PILIH KE POLI",
                                    style: GoogleFonts.oswald(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Keterangan untuk tombol POLI
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user,
                              size: 12,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Nomor BPJS: ${data.noPeserta?.substring(0, 4)}...${data.noPeserta?.substring(data.noPeserta!.length - 4)}",
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green.shade800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Konsultasi dengan dokter / Langsung tunggu di Poli",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Tombol LOKET
                Expanded(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: isLoadingLoket
                            ? null
                            : () {
                                ConfirmationDialog.show(
                                  context,
                                  title: "Menuju Loket",
                                  message:
                                      "Anda yakin ingin melanjutkan ke pelayanan LOKET?",
                                  onConfirm: () {
                                    context.read<AntrianApmBloc>().add(
                                      LanjutKeLoketEvent(
                                        apmData: data,
                                        jenisAntrian: jenisPasien.toLowerCase(),
                                        noBooking: data.noBooking ?? '',
                                      ),
                                    );
                                  },
                                );
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0D8AAE), Color(0xFF0ABF68)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: isLoadingLoket
                                ? LoadingAnimationWidget.fourRotatingDots(
                                    color: Colors.white,
                                    size: 15,
                                  )
                                : Text(
                                    "PILIH KE LOKET",
                                    style: GoogleFonts.oswald(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Keterangan untuk tombol LOKET
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt,
                              size: 12,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Administrasi & pendaftaran",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Administrasi & pendaftaran",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Info tambahan di bawah kedua tombol
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade50, Colors.orange.shade50],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_rounded,
                      size: 16,
                      color: Colors.amber.shade800,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Informasi",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Pilih Poli langsung menuju poli yang di pilih lalu tunggu no antrian di panggil.\nPilih Loket jika ingin memerlukan bantuan silahkan menuju fo (front office).",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.amber.shade900,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tampilkan nomor BPJS jika ada
            if (data.noPeserta != null && data.noPeserta!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.credit_card,
                      size: 14,
                      color: Colors.purple.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "No. BPJS: ${data.noPeserta}",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
