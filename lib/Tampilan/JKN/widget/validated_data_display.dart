import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/apm_antrian_model.dart';

class ValidatedDataDisplay extends StatelessWidget {
  final ApmAntrianModel validatedData;
  final VoidCallback onBackToSelection;
  final bool isBatalBooking;

  const ValidatedDataDisplay({
    super.key,
    required this.validatedData,
    required this.onBackToSelection,
    required this.isBatalBooking,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: isBatalBooking
            ? Colors.orange.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isBatalBooking ? Colors.orange : Colors.green,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isBatalBooking ? 'Booking Dibatalkan' : 'Data Ditemukan:',
                  style: GoogleFonts.montserrat(
                    fontSize: isMobile ? 18 : 24,
                    fontWeight: FontWeight.bold,
                    color: isBatalBooking ? Colors.orange : Colors.green,
                  ),
                ),
              ),
              if (isBatalBooking)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'DIBATALKAN',
                    style: GoogleFonts.montserrat(
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onBackToSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 15,
                    vertical: isMobile ? 6 : 8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.restart_alt, size: isMobile ? 16 : 18),
                    const SizedBox(width: 5),
                    Text(
                      'ULANGI',
                      style: GoogleFonts.montserrat(
                        fontSize: isMobile ? 10 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow('ID:', validatedData.id, context),
          if (validatedData.rm != null) 
            _buildInfoRow('RM:', validatedData.rm!, context),
          _buildInfoRow('Nama:', validatedData.pasien, context),
          _buildInfoRow('Tanggal Lahir:', validatedData.tglLahir, context),
          _buildInfoRow('Alamat:', validatedData.alamatDomisili, context),
          if (isBatalBooking) _buildWarningBanner(context),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: isMobile ? 14 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.montserrat(
                fontSize: isMobile ? 14 : 18,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange.shade700, size: isMobile ? 18 : 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Booking ini telah dibatalkan. Hanya dapat dilanjutkan ke Loket.',
              style: GoogleFonts.montserrat(
                fontSize: isMobile ? 12 : 14,
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}