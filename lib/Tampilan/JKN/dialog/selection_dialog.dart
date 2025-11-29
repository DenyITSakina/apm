import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../responsive/responsive.dart';

class SelectionDialog extends StatelessWidget {
  final VoidCallback onJknPressed;
  final VoidCallback onUmumPressed;
  final VoidCallback onPendaftaranPressed;

  const SelectionDialog({
    super.key,
    required this.onJknPressed,
    required this.onUmumPressed,
    required this.onPendaftaranPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtils.isMobile(context);
    final double fontSize = ResponsiveUtils.getFontSize(
      context,
      mobile: 18,
      tablet: 22,
      desktop: 24,
    );
    final double buttonFontSize = ResponsiveUtils.getFontSize(
      context,
      mobile: 20,
      tablet: 30,
      desktop: 35,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: ResponsiveUtils.getDialogPadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Tipe Antrian',
              style: GoogleFonts.montserrat(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Silakan pilih tipe antrian terlebih dahulu sebelum memasukkan nomor',
              style: GoogleFonts.montserrat(
                fontSize: fontSize * 0.8,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            if (!isMobile)
              Row(
                children: [
                  Expanded(child: _buildDialogButton(context, 'JKN', Colors.blue.shade700, onJknPressed, buttonFontSize)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildDialogButton(context, 'UMUM', Colors.green.shade600, onUmumPressed, buttonFontSize)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildDialogButton(context, 'DAFTAR POLI', Colors.deepOrange, onPendaftaranPressed, buttonFontSize)),
                ],
              )
            else
              Column(
                children: [
                  _buildDialogButton(context, 'JKN', Colors.blue.shade700, onJknPressed, buttonFontSize),
                  const SizedBox(height: 10),
                  _buildDialogButton(context, 'UMUM', Colors.green.shade600, onUmumPressed, buttonFontSize),
                  const SizedBox(height: 10),
                  _buildDialogButton(context, 'DAFTAR POLI', Colors.deepOrange, onPendaftaranPressed, buttonFontSize),
                ],
              ),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 15 : 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  'TUTUP',
                  style: GoogleFonts.montserrat(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Sekarang context dikirim sebagai parameter
  Widget _buildDialogButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onPressed,
    double fontSize,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop(); // sekarang context valid
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 3,
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
