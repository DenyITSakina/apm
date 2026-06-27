import 'package:apm/blog/booking/booking_bloc.dart';
import 'package:apm/func/open_aplikasi_bpjsDaftar.dart';
import 'package:apm/home/booking_page.dart';
import 'package:apm/home/daftar_umum_bpjs_page.dart';

import '../Blog/antrian_apm_bloc.dart';
import 'package:apm/home/cekin_bpjs_page.dart';

import 'package:apm/home/cekin_umum_page.dart';
import 'package:flutter/material.dart';
import 'package:full_swipe_back_gesture/full_swipe_back_gesture.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widget/responsive.dart';

class DashboardApm extends StatefulWidget {
  const DashboardApm({super.key});

  @override
  State<DashboardApm> createState() => _DashboardApmState();
}

class _DashboardApmState extends State<DashboardApm>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  _animationController.value * 0.5,
                  _animationController.value * 0.3,
                ),
                radius: 1.2,
                colors: const [
                  Color(0xFFE3F2FD),
                  Color(0xFFB3E5FC),
                  Color(0xFFE0F2F1),
                ],
                stops: [0.2, 0.6, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 32 : 24,
                      horizontal: isTablet ? 40 : 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF006064),
                          Color(0xFF00838F),
                          Color(0xFF0097A7),
                          Color(0xFF00ACC1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.1, 0.3, 0.7, 1.0],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.shade800.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.1,
                            child: CustomPaint(
                              painter: MedicalPatternPainter(),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Container(
                            //   decoration: BoxDecoration(
                            //     shape: BoxShape.rectangle,
                            //     boxShadow: [
                            //       BoxShadow(
                            //         color: Colors.white.withOpacity(0.5),
                            //         blurRadius: 10,
                            //         spreadRadius: 10,
                            //       ),
                            //     ],
                            //   ),
                            //   child: Container(
                            //     padding: const EdgeInsets.all(15),
                            //     color: Colors.white,
                            //     child: Image.asset(
                            //       "assets/images/logo_sakina.png",
                            //       height: size.height * 0.15,
                            //       fit: BoxFit.contain,
                            //     ),
                            //   ),
                            // ),
                            // const SizedBox(height: 20),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Colors.white, Color(0xFFE0F7FA)],
                              ).createShader(bounds),
                              child: Text(
                                "RSU SAKINA IDAMAN",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: isTablet ? 36 : 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Peduli Sesama, Sakina Pilihanku",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lora(
                                fontSize: isTablet ? 20 : 16,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.95),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "ANJUNGAN PENDAFTARAN MANDIRI",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    fontSize: isTablet ? 24 : 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            Text(
                              "Selamat Datang",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 32 : 24,
                                fontWeight: FontWeight.w300,
                                color: const Color(0xFF006064).withOpacity(
                                  0.6 + (_pulseController.value * 0.4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Silahkan pilih layanan yang Anda butuhkan",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 20 : 16,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF00838F),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.isMobile(context) ? 12 : 20,
                      ),
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final maxW = constraints.maxWidth;
                            final crossAxisCount = maxW < 420
                                ? 2
                                : (maxW < 700 ? 2 : 4);

                            // Mobile/tablet responsif tanpa scroll horizontal.
                            final childAspectRatio = maxW < 420
                                ? 0.85
                                : (maxW < 700 ? 0.9 : 0.95);

                            return GridView.count(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: childAspectRatio,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              children: [
                                _buildServiceCard(
                                  title: "CEK-IN BPJS",
                                  image: "assets/images/bpjs_logo.png",
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1565C0),
                                      Color(0xFF1E88E5),
                                      Color(0xFF42A5F5),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  icon: Icons.health_and_safety,
                                  description: "Untuk pasien BPJS Kesehatan",
                                  onTap: () => _navigateTo(
                                    context,
                                    BlocProvider(
                                      create: (_) => AntrianApmBloc(),
                                      child: const CekinBpjs(
                                        selectType: "bpjs",
                                      ),
                                    ),
                                  ),
                                ),
                                _buildServiceCard(
                                  title: "CEK-IN UMUM",
                                  image: "assets/images/umum.png",
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2E7D32),
                                      Color(0xFF388E3C),
                                      Color(0xFF4CAF50),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  icon: Icons.people,
                                  description: "Untuk pasien umum",
                                  onTap: () => _navigateTo(
                                    context,
                                    BlocProvider(
                                      create: (_) => AntrianApmBloc(),
                                      child: const CekinUmumPage(
                                        selectType: "umum",
                                      ),
                                    ),
                                  ),
                                ),
                                _buildServiceCard(
                                  title: "DAFTAR POLI HARI INI",
                                  image: "assets/images/daftar.png",
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFB71C1C),
                                      Color(0xFFC62828),
                                      Color(0xFFD32F2F),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  icon: Icons.local_hospital,
                                  description: "Pendaftaran tujuan poli",
                                  onTap: () => _navigateTo(
                                    context,
                                    const PendaftaranPoliPage(
                                      selectType: "pendaftaran",
                                    ),
                                  ),
                                ),
                                _buildServiceCard(
                                  title: "BOOKING",
                                  image: "assets/images/booking.png",
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFBF360C),
                                      Color(0xFFE65100),
                                      Color(0xFFF57C00),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  icon: Icons.calendar_month,
                                  description: "Booking untuk pasien",
                                  onTap: () {
                                    _showBookingTypeDialog(context);
                                  },
                                ),
                                // _buildServiceCard(
                                //   title: "BPJS DAFTAR",
                                //   image: "assets/images/bpjs.png",
                                //   gradient: const LinearGradient(
                                //     colors: [
                                //       Color(0xFF1565C0),
                                //       Color(0xFF1E88E5),
                                //       Color(0xFF42A5F5),
                                //     ],
                                //     begin: Alignment.topLeft,
                                //     end: Alignment.bottomRight,
                                //   ),
                                //   icon: Icons.fingerprint,
                                //   description: "Panggil After.exe otomatis",
                                //   onTap: () async {
                                //     const String nomorBpjs = '0005658974521';

                                //     if (nomorBpjs.isEmpty) {
                                //       if (!context.mounted) return;
                                //       ScaffoldMessenger.of(
                                //         context,
                                //       ).showSnackBar(
                                //         const SnackBar(
                                //           content: Text(
                                //             'Nomor BPJS kosong. Isi nomor BPJS dulu di halaman pendaftaran.',
                                //           ),
                                //         ),
                                //       );
                                //       return;
                                //     }

                                //     final sukses = await openExeFromMap(
                                //       context,
                                //       {"nomor": nomorBpjs},
                                //     );

                                //     if (!sukses && context.mounted) {
                                //       ScaffoldMessenger.of(
                                //         context,
                                //       ).showSnackBar(
                                //         const SnackBar(
                                //           content: Text(
                                //             'Gagal membuka aplikasi BPJS.',
                                //           ),
                                //         ),
                                //       );
                                //     }
                                //   },
                                // ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white12.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header dengan icon peringatan
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "PERHATIAN PENTING",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.red.shade700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),

                        const Divider(
                          color: Colors.red,
                          thickness: 1,
                          height: 20,
                        ),

                        // Informasi 1
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.verified_user,
                                  color: Colors.red.shade600,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Chek in BPJS jika sudah melakukan booking / Sudah ada no booking. tipe pasien BPJS",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Informasi 2
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.access_time,
                                  color: Colors.red.shade600,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Chek in UMUM jika sudah melakukan booking / Sudah ada no booking. Tipe pasien UMUM",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Informasi 3
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.assignment,
                                  color: Colors.red.shade600,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Untuk daftar poli hari ini itu bagi pasien yang akan melaukukan pemeriksaan pada hari ini juga (sekarang)",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.ac_unit_sharp,
                                  color: Colors.red.shade600,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Bawa surat rujukan untuk pasien BPJS",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Informasi 4
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.phone_in_talk,
                                  color: Colors.red.shade600,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Untuk informasi lebih lanjut, hubungi call center 1500-123",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFF00838F).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Baris pertama: Jam operasional dan bantuan
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time,
                              color: const Color(0xFF006064),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Jam Operasional: 24 Jam | UGD",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF006064),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              width: 1,
                              height: 20,
                              color: const Color(0xFF00838F).withOpacity(0.3),
                            ),
                            Icon(
                              Icons.info_outline,
                              color: const Color(0xFF006064),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Butuh bantuan? Hubungi petugas",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF006064),
                              ),
                            ),
                          ],
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "#pedulisesama | #sakinapilihanku",
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF006064),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                width: 1,
                                height: 14,
                                color: const Color(0xFF006064),
                              ),
                              Text(
                                "v1.1.1",
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF006064),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                width: 1,
                                height: 14,
                                color: const Color(0xFF006064),
                              ),
                              Text(
                                "2026",
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF006064),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String image,
    required LinearGradient gradient,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Lebar layout card (dipengaruhi parent Row/scroll)
              final maxW = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.of(context).size.width;
              final cardWidth = maxW < 360
                  ? maxW * 0.92
                  : (maxW < 700 ? 300.0 : 320.0);

              final w = cardWidth;
              final circleSize = w * 0.41; // ~120 pada w~280
              final pad = w * 0.085; // ~24 pada w~280

              final titleSize = (w * 0.075).clamp(18.0, 24.0);
              final descSize = (w * 0.045).clamp(12.0, 14.5);
              final iconDecoSize = (w * 0.33).clamp(72.0, 110.0);
              final arrowSize = (w * 0.055).clamp(14.0, 16.0);

              final radius = (w * 0.11).clamp(26.0, 40.0);

              return SizedBox(
                width: cardWidth,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(radius),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(radius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: (w * 0.05).clamp(10.0, 18.0),
                              offset: const Offset(0, 8),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -20,
                              right: -20,
                              child: Icon(
                                icon,
                                size: iconDecoSize,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(pad),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: circleSize,
                                    width: circleSize,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        image,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.white.withOpacity(
                                                  0.2,
                                                ),
                                                child: Icon(
                                                  icon,
                                                  size: (circleSize * 0.5)
                                                      .clamp(40.0, 70.0),
                                                  color: Colors.white,
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: w * 0.07),
                                  Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: w * 0.028),
                                  Text(
                                    description,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: descSize,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  SizedBox(height: w * 0.055),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w * 0.075,
                                      vertical: w * 0.03,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(
                                        radius,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Pilih",
                                          style: GoogleFonts.poppins(
                                            fontSize: descSize,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: w * 0.028),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                          size: arrowSize,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).push(BackSwipePageRoute(builder: (_) => page));
  }
}

class MedicalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final crossSize = 30.0;
    for (double i = 0; i < size.width; i += 60) {
      for (double j = 0; j < size.height; j += 60) {
        canvas.drawLine(
          Offset(i + crossSize / 2, j),
          Offset(i + crossSize / 2, j + crossSize),
          paint,
        );
        canvas.drawLine(
          Offset(i, j + crossSize / 2),
          Offset(i + crossSize, j + crossSize / 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _showBookingTypeDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),

      child: Container(
        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Pilih Jenis Booking",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "Pilih metode pendaftaran",
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 28),

            /// KANAN KIRI
            Row(
              children: [
                Expanded(
                  child: _bookingCard(
                    context,
                    icon: Icons.person,
                    title: "UMUM",
                    subtitle: "Pasien Umum / Non Bpjs",
                    color: Colors.orange,
                    jenis: '1',
                  ),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: _bookingCard(
                    context,
                    icon: Icons.health_and_safety,
                    title: "BPJS",
                    subtitle: "Peserta JKN aktif",
                    color: Colors.blue,
                    jenis: '2',
                  ),
                ),
              ],
            ),

            // const SizedBox(height: 24),

            // SizedBox(
            //   width: double.infinity,
            //   child: TextButton(
            //     onPressed: () => Navigator.pop(context),
            //     child: const Text("Batal", style: TextStyle(fontSize: 16)),
            //   ),
            // ),
          ],
        ),
      ),
    ),
  );
}

Widget _bookingCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required String jenis,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(12),

    onTap: () {
      Navigator.pop(context);

      Navigator.of(context).push(
        BackSwipePageRoute(
          builder: (_) => BlocProvider(
            create: (_) => BookingBloc(),
            child: BookingPage(jenis: jenis),
          ),
        ),
      );
    },

    child: Container(
      height: 290,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(.15), color.withOpacity(.04)],
        ),

        borderRadius: BorderRadius.circular(28),

        border: Border.all(color: color.withOpacity(.20)),

        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Container(
            width: 90,
            height: 90,

            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, size: 46, color: Colors.white),
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700], height: 1.4),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),

            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),

            child: const Text(
              "Pilih",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
