import 'package:apm/home/cekin_bpjs_page.dart';
import 'package:apm/home/cekin_umum_page.dart';
import 'package:apm/home/daftar_umum_bpjs_page.dart';
import 'package:apm/widget/booking_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Blog/antrian_apm_bloc.dart';
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
                            const SizedBox(height: 8),
                            Text(
                              "Melayani Dengan Sepenuh Hati",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lora(
                                fontSize: isTablet ? 20 : 16,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.95),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  color: Colors.white.withOpacity(0.9),
                                  size: isTablet ? 32 : 24,
                                ),
                                const SizedBox(width: 12),
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
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.medical_services,
                                  color: Colors.white.withOpacity(0.9),
                                  size: isTablet ? 32 : 24,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

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
                            const SizedBox(height: 8),
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

                  const SizedBox(height: 35),

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
                                  description: "Pendaftaran poli tujuan",
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
                                  onTap: () => showBookingDialog(context),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFF00838F).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time,
                          color: const Color(0xFF006064),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Jam Operasional: 24 Jam",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF006064),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
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
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
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
