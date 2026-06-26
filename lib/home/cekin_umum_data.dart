import 'package:apm/dialog/sukses.dart';
import 'package:apm/dialog/top_toast.dart';
import 'package:apm/theme/Style/format_tgl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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

  String get _title {
    switch (jenisPasien.toLowerCase()) {
      case 'umum':
        return 'DATA PASIEN UMUM';
      case 'bpjs':
        return 'DATA PASIEN BPJS';
      default:
        return 'DATA PASIEN';
    }
  }

  bool get _isDataValid => data.isValid;

  @override
  Widget build(BuildContext context) {
    if (!_isDataValid) {
      return _buildErrorPage(context);
    }

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
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildLogoHeader(),
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

  Widget _buildErrorPage(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FA),
      appBar: _buildAppBar(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Data pasien tidak ditemukan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan cek kembali nomor RM atau booking',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D8AAE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF0D8AAE),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
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
            _title,
            style: GoogleFonts.oswald(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Center(
      child: Column(
        children: [
          Image.asset('assets/images/logo_sakina.png', height: 80),
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
    final infoItems = [
      _InfoItem(Icons.confirmation_number, "No. RM", data.rm),
      _InfoItem(Icons.person, "Nama Pasien", data.pasien),
      _InfoItem(
        Icons.cake,
        "Tanggal Lahir",
        DateFormatter.format(data.tglLahir),
      ),
      _InfoItem(Icons.home, "Alamat", data.alamatDomisili),
      _InfoItem(Icons.local_hospital, "Poli", data.poli),
      _InfoItem(Icons.book_online, "No. Booking", data.noBooking),
      _InfoItem(Icons.badge, "Jenis Pasien", _getJenisPasienText()),
      _InfoItem(Icons.info_outline, "Status", data.statusText),
    ];

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
          _buildCardHeader(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ...infoItems.map((item) => _buildInfoRow(item)),
                const SizedBox(height: 20),
                _buildInfoNote(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getJenisPasienText() {
    return jenisPasien.toUpperCase() == "UMUM" ? "UMUM" : "BPJS";
  }

  Widget _buildCardHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D8AAE), Color(0xFF0ABF68)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_pin_rounded, size: 38, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            _title,
            style: GoogleFonts.oswald(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 22, color: Colors.teal.shade700),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              "${item.label}:",
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
              _getDisplayValue(item.value),
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

  String _getDisplayValue(String value) {
    return value.isEmpty ? '-' : value;
  }

  Widget _buildInfoNote() {
    return Container(
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
                Expanded(child: _buildPoliButton(context, isLoadingPoli)),
                const SizedBox(width: 16),
                Expanded(child: _buildLoketButton(context, isLoadingLoket)),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoTips(),
          ],
        );
      },
    );
  }

  Widget _buildPoliButton(BuildContext context, bool isLoading) {
    return Column(
      children: [
        GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  ConfirmationDialog.show(
                    context,
                    title: "Menuju Poli",
                    message: "Anda yakin ingin melanjutkan ke pelayanan POLI?",
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
              child: isLoading
                  ? LoadingAnimationWidget.fourRotatingDots(
                      color: Colors.white,
                      size: 15,
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
    );
  }

  Widget _buildLoketButton(BuildContext context, bool isLoading) {
    return Column(
      children: [
        GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  ConfirmationDialog.show(
                    context,
                    title: "Menuju Loket",
                    message: "Anda yakin ingin melanjutkan ke pelayanan LOKET?",
                    onConfirm: () {
                      context.read<AntrianApmBloc>().add(
                        LanjutKeLoketEvent(
                          apmData: data,
                          jenisAntrian: jenisPasien.toLowerCase(),
                          noBooking: data.noBooking,
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
              child: isLoading
                  ? LoadingAnimationWidget.fourRotatingDots(
                      color: Colors.white,
                      size: 15,
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
    );
  }

  Widget _buildInfoTips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.tips_and_updates, size: 16, color: Colors.amber.shade800),
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
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem(this.icon, this.label, this.value);
}
