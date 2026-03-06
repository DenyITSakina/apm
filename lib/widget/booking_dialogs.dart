import 'package:apm/Blog/blog_booking_pasien_baru.dart';
import 'package:apm/Blog/booking_pasien_lama_bloc.dart';
import 'package:apm/home/pendaftaran_pasien_baru_page.dart';
import 'package:apm/home/pendaftaran_pasien_lama_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class DialogConstants {
  static const Color primaryStart = Color(0xFF0D8AAE);
  static const Color primaryEnd = Color(0xFF0ABF68);
  static const List<Color> primaryGradient = [primaryStart, primaryEnd];

  static const double borderRadiusLarge = 32;
  static const double borderRadiusMedium = 20;
  static const double borderRadiusSmall = 12;

  static const Duration snackBarDuration = Duration(seconds: 2);

  static const EdgeInsets dialogPadding = EdgeInsets.fromLTRB(24, 16, 24, 24);
  static const EdgeInsets optionPadding = EdgeInsets.all(20);
}

void showRekamMedisDialog(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) => _RekamMedisDialogContent(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
    ),
  );
}

class _RekamMedisDialogContent extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const _RekamMedisDialogContent({
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DialogConstants.borderRadiusLarge),
      ),
      elevation: 8,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.9,
          maxHeight: screenHeight * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: DialogConstants.dialogPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildTitle(),
                const SizedBox(height: 12),
                _buildDescription(),
                const SizedBox(height: 28),
                _buildActionButtons(context),
                const SizedBox(height: 16),
                _buildInfoBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: DialogConstants.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        Positioned(
          top: 12,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              splashRadius: 24,
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 24,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_ind_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                "Verifikasi Pasien",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return const Text(
      "Apakah Anda sudah memiliki Nomor Rekam Medis?",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(DialogConstants.borderRadiusSmall),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        "Untuk melanjutkan proses booking, silakan konfirmasi status Rekam Medis Anda. Data yang valid akan mempercepat proses pendaftaran.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildSudahPunyaButton(context)),
        const SizedBox(width: 12),
        Expanded(child: _buildBelumPunyaButton(context)),
      ],
    );
  }

  Widget _buildSudahPunyaButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DialogConstants.borderRadiusMedium),
        gradient: const LinearGradient(colors: DialogConstants.primaryGradient),
        boxShadow: [
          BoxShadow(
            color: DialogConstants.primaryStart.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              DialogConstants.borderRadiusMedium,
            ),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
          _showJenisBookingDialog(context, isPasienLama: true);
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 20),
            SizedBox(width: 8),
            Text(
              "Sudah Punya RM",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBelumPunyaButton(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: const BorderSide(color: DialogConstants.primaryStart, width: 1.5),
        foregroundColor: DialogConstants.primaryStart,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            DialogConstants.borderRadiusMedium,
          ),
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
        _showJenisBookingDialog(context, isPasienLama: false);
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, size: 20),
          SizedBox(width: 8),
          Text(
            "Belum Punya RM",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(DialogConstants.borderRadiusSmall),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Nomor Rekam Medis biasanya terdapat di kartu berobat atau kartu BPJS Anda",
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showJenisBookingDialog(
  BuildContext context, {
  required bool isPasienLama,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) =>
        _JenisBookingDialogContent(isPasienLama: isPasienLama),
  );
}

class _JenisBookingDialogContent extends StatelessWidget {
  final bool isPasienLama;

  const _JenisBookingDialogContent({required this.isPasienLama});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogHeader(context),
            const SizedBox(height: 24),
            _buildUmumOption(context),
            const SizedBox(height: 12),
            _buildBpjsOption(context),
            const SizedBox(height: 16),
            _buildCancelButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: DialogConstants.primaryGradient),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPasienLama ? Icons.event_available : Icons.person_add,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPasienLama ? 'Pilih Jenis Booking' : 'Pasien Baru',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                isPasienLama
                    ? 'Pilih tipe layanan yang diinginkan'
                    : 'Lengkapi data untuk pasien baru',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUmumOption(BuildContext context) {
    return _BookingOption(
      title: 'UMUM',
      subtitle: 'Booking untuk pasien umum',
      icon: Icons.person,
      color: Colors.teal,
      onTap: () => _handleOptionTap(context, jenisBooking: 1),
    );
  }

  Widget _buildBpjsOption(BuildContext context) {
    return _BookingOption(
      title: 'BPJS',
      subtitle: 'Booking untuk pasien BPJS',
      icon: Icons.health_and_safety,
      color: Colors.blue,
      onTap: () => _handleOptionTap(context, jenisBooking: 2),
    );
  }

  void _handleOptionTap(BuildContext context, {required int jenisBooking}) {
    Navigator.pop(context);
    _navigateToBookingPage(
      context,
      jenisBooking: jenisBooking,
      isPasienLama: isPasienLama,
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.red.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              DialogConstants.borderRadiusSmall,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        ),
        child: Text(
          'Batal',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _BookingOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final MaterialColor color;
  final VoidCallback onTap;

  const _BookingOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DialogConstants.borderRadiusMedium),
      child: Container(
        padding: DialogConstants.optionPadding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.shade50, color.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(
            DialogConstants.borderRadiusMedium,
          ),
          border: Border.all(color: color.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.shade100.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 16),
            Expanded(child: _buildTextContent()),
            _buildArrowIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: color.shade700, size: 28),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildArrowIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.arrow_forward, color: color.shade700, size: 18),
    );
  }
}

void _navigateToBookingPage(
  BuildContext context, {
  required int jenisBooking,
  required bool isPasienLama,
}) {
  if (isPasienLama) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => BookingPasienLamaBloc(),
          child: BookingPasienLamaPage(initialJenisBooking: jenisBooking),
        ),
      ),
    ).then((result) => _handleNavigationResult(context, result));
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => BookingPasienBaruBloc(),
          child: BookingPasienBaruPage(initialJenisBooking: jenisBooking),
        ),
      ),
    ).then((result) => _handleNavigationResult(context, result));
  }
}

void _handleNavigationResult(BuildContext context, dynamic result) {
  if (result == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Booking berhasil dibuat!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: DialogConstants.snackBarDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            DialogConstants.borderRadiusSmall,
          ),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

void showBookingDialog(BuildContext context) {
  showRekamMedisDialog(context);
}
