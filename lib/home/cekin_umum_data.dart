import 'package:apm/dialog/sukses.dart';
import 'package:apm/dialog/top_toast.dart';
import 'package:apm/theme/Style/format_tgl.dart';
import 'package:apm/theme/format_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/apm_antrian_model.dart';
import '../Blog/antrian_apm_bloc.dart';
import '../dialog/konfirmasi.dart';

class CekinUmumDataPage extends StatelessWidget {
  final String noRm;
  final ApmAntrianModel data;
  final String jenisPasien;

  const CekinUmumDataPage({
    super.key,
    required this.noRm,
    required this.data,
    required this.jenisPasien,
  });

  String _getTitle() {
    switch (jenisPasien.toLowerCase()) {
      case 'umum':
        return 'DATA PASIEN UMUM';
      case 'bpjs':
        return 'DATA PASIEN BPJS';
      default:
        return 'DATA PASIEN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _getTitle();

    return BlocListener<AntrianApmBloc, AntrianApmState>(
      listener: (context, state) {
        if (state is AntrianApmPrinted || state is AntrianApmPrinting) {
          final message = state is AntrianApmPrinted
              ? "Sukses: ${state.message}"
              : "Sukses";
          showSuccessDialog(context, message);
          return;
        }

        if (state is AntrianApmError) {
          TopToast.error(context, state.pesan);
        } else if (state is AntrianApmBlocked) {
          TopToast.warning(context, state.message);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context);
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F9FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF0D8AAE),
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
                title,
                style: GoogleFonts.oswald(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
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
              _logoHeader(),
              const SizedBox(height: 20),
              _buildCardData(),
              const SizedBox(height: 30),
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

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
          // HEADER CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D8AAE), Color(0xFF0ABF68)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.person_pin_rounded, size: 38, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  _getTitle(),
                  style: GoogleFonts.oswald(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // BODY CARD
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.confirmation_number,
                  "No. RM",
                  data.rm ?? "-",
                ),
                _buildInfoRow(
                  Icons.person,
                  "Nama Pasien",
                  formatNama(data.pasien),
                ),
                _buildInfoRow(
                  Icons.cake,
                  "Tanggal Lahir",
                  formatTglBlnTahun(data.tglLahir),
                ),
                _buildInfoRow(
                  Icons.home,
                  "Alamat",
                  formatNama(data.alamatDomisili),
                ),
                _buildInfoRow(
                  Icons.local_hospital,
                  "Poli",
                  formatNama(data.poli),
                ),
                _buildInfoRow(
                  Icons.book_online,
                  "No. Booking",
                  data.noBooking ?? "-",
                ),
                _buildInfoRow(
                  Icons.badge,
                  "Jenis Pasien",
                  jenisPasien.toUpperCase() == "UMUM" ? "UMUM" : "BPJS",
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Silahkan melanjutkan ke proses pemilihan poli atau loket untuk check-in.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.teal.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.teal.shade700),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              "$title:",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Colors.teal.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 25,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: Colors.teal.shade900,
                height: 1.4,
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
              children: [
                Expanded(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: isLoadingPoli
                            ? null
                            : () {
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
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "PILIH POLI",
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
                      const SizedBox(height: 6),
                      Text(
                        "Konsultasi dengan dokter / Langsung tunggu di Poli",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
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
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "PILIH LOKET",
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
                      const SizedBox(height: 6),
                      Text(
                        "Administrasi & pendaftaran",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Info tambahan di bawah (opsional)
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    size: 16,
                    color: Colors.amber.shade800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Pasien baru: Pilih LOKET terlebih dahulu untuk pendaftaran.\nPasien lama: Bisa langsung pilih POLI atau LOKET.",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
