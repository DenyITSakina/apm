import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:marquee/marquee.dart';

import '../responsive/responsive.dart';


class AntrianHeader extends StatelessWidget {
  const AntrianHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: isMobile ? 10 : 14,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6EC1E4), 
            Color(0xFF61CE70),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //text jalan
          //  SizedBox(
          //   height: isMobile ? 26 : 32,
          //   width: double.infinity,
          //   child: Marquee(
          //     text:
          //         'Selamat Datang di RSU Sakina Idaman • Silakan Ambil Nomor Antrian Anda',
          //     style: GoogleFonts.poppins(
          //       fontSize: isMobile ? 12 : 14,
          //       color: Colors.white,
          //       fontWeight: FontWeight.w500,
          //     ),
          //     scrollAxis: Axis.horizontal,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     blankSpace: 60.0,
          //     velocity: 30.0,
          //     pauseAfterRound: const Duration(seconds: 1),
          //     startPadding: 5.0,
          //     accelerationDuration: const Duration(seconds: 1),
          //     accelerationCurve: Curves.linear,
          //     decelerationDuration: const Duration(milliseconds: 500),
          //     decelerationCurve: Curves.easeOut,
          //   ),
          // ),

          const SizedBox(height: 4),
          // Logo
          Image.asset(
            "assets/images/logo_sakina.png",
            height: isMobile ? 45 : 65,
            fit: BoxFit.contain,
          ),

          // Teks bawah logo
          if (!isMobile) ...[
            const SizedBox(height: 6),
            Text(
              'Anjungan Pendaftaran Mandiri',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: ResponsiveUtils.getFontSize(
                  context,
                  mobile: 14,
                  tablet: 18,
                  desktop: 20,
                ),
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'RSU SAKINA IDAMAN',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.getFontSize(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
