import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../responsive/responsive.dart';

class ActionButtons extends StatelessWidget {
  final bool isJknEnabled;
  final bool isUmumEnabled;
  final bool isPendaftaranEnabled;
  final bool isLanjutButtonsDisabled;
  final bool isFormPendaftaranActive;
  final bool isBatalBooking;
  final bool isValidated;
  final bool isLoading;
  final String selectedType;
  final String textControllerText;

  final VoidCallback onJknPressed;
  final VoidCallback onUmumPressed;
  final VoidCallback onPendaftaranPressed;
  final VoidCallback onValidateAntrian;
  final VoidCallback onLanjutPoli;
  final VoidCallback onLanjutLoket;

  const ActionButtons({
    super.key,
    required this.isJknEnabled,
    required this.isUmumEnabled,
    required this.isPendaftaranEnabled,
    required this.isLanjutButtonsDisabled,
    required this.isFormPendaftaranActive,
    required this.isBatalBooking,
    required this.isValidated,
    required this.isLoading,
    required this.selectedType,
    required this.textControllerText,
    required this.onJknPressed,
    required this.onUmumPressed,
    required this.onPendaftaranPressed,
    required this.onValidateAntrian,
    required this.onLanjutPoli,
    required this.onLanjutLoket,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtils.isMobile(context);
    final double buttonHeight = isMobile ? 42 : 52;
    final double fontSize = isMobile
        ? 14
        : (ResponsiveUtils.isTablet(context) ? 18 : 22);

    return isValidated
        ? _buildLanjutButtons(context, buttonHeight, fontSize, isMobile)
        : _buildMainButtons(context, buttonHeight, fontSize, isMobile);
  }

  Widget _buildLanjutButtons(
      BuildContext context, double buttonHeight, double fontSize, bool isMobile) {
    final bool isDisabled = isBatalBooking || isLanjutButtonsDisabled;

    if (isFormPendaftaranActive) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16, vertical: 8),
        child: isMobile
            ? Column(
                children: [
                  _buildActionButton(
                    selectedType == 'pendaftaran' ? 'Pilih POLI' : 'Ke Poli',
                    isDisabled ? Colors.grey : Colors.blue.shade700,
                    isDisabled ? null : onLanjutPoli,
                    buttonHeight,
                    fontSize,
                  ),
                  const SizedBox(height: 6),
                  _buildActionButton(
                    'Ke Loket',
                    isDisabled ? Colors.grey : Colors.green.shade600,
                    isDisabled ? null : onLanjutLoket,
                    buttonHeight,
                    fontSize,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      selectedType == 'pendaftaran' ? 'Pilih Poli' : 'Ke Poli',
                      isDisabled ? Colors.grey : Colors.blue.shade700,
                      isDisabled ? null : onLanjutPoli,
                      buttonHeight,
                      fontSize,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionButton(
                      'Ke Loket',
                      isDisabled ? Colors.grey : Colors.green.shade600,
                      isDisabled ? null : onLanjutLoket,
                      buttonHeight,
                      fontSize,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  //TOMBOL UTAMA
  Widget _buildMainButtons(
      BuildContext context, double buttonHeight, double fontSize, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16, vertical: 8),
      child: Column(
        children: [
          // --- Baris 1: JKN dan UMUM ---
          isMobile
              ? Column(
                  children: [
                    _buildActionButton(
                      'JKN',
                      Colors.blue.shade700,
                      isJknEnabled && !isLoading ? onJknPressed : null,
                      buttonHeight,
                      fontSize,
                    ),
                    const SizedBox(height: 6),
                    _buildActionButton(
                      'UMUM',
                      Colors.green.shade600,
                      isUmumEnabled && !isLoading ? onUmumPressed : null,
                      buttonHeight,
                      fontSize,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'JKN',
                        Colors.blue.shade700,
                        isJknEnabled && !isLoading ? onJknPressed : null,
                        buttonHeight,
                        fontSize,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        'UMUM',
                        Colors.green.shade600,
                        isUmumEnabled && !isLoading ? onUmumPressed : null,
                        buttonHeight,
                        fontSize,
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 8),

          // --- Baris 2: DAFTAR POLI dan LANJUT ---
          isMobile
              ? Column(
                  children: [
                    _buildActionButton(
                      'DAFTAR POLI',
                      Colors.deepOrange,
                      isPendaftaranEnabled && !isLoading ? onPendaftaranPressed : null,
                      buttonHeight,
                      fontSize,
                    ),
                    const SizedBox(height: 6),
                    _buildActionButton(
                      'LANJUT',
                      _getLanjutButtonColor(),
                      _getLanjutButtonCallback(),
                      buttonHeight,
                      fontSize,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'DAFTAR POLI',
                        Colors.deepOrange,
                        isPendaftaranEnabled && !isLoading ? onPendaftaranPressed : null,
                        buttonHeight,
                        fontSize,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        'LANJUT',
                        _getLanjutButtonColor(),
                        _getLanjutButtonCallback(),
                        buttonHeight,
                        fontSize,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  // Helper method untuk menentukan warna tombol LANJUT
  Color _getLanjutButtonColor() {
    if (isLoading) {
      return Colors.grey;
    }
    
    final bool isEnabled = selectedType.isNotEmpty && 
                          textControllerText.isNotEmpty && 
                          !isLoading;
    
    return isEnabled ? Colors.redAccent : Colors.grey.shade400;
  }

  // Helper method untuk menentukan callback tombol LANJUT
  VoidCallback? _getLanjutButtonCallback() {
    if (isLoading) {
      return null;
    }
    
    final bool isEnabled = selectedType.isNotEmpty && 
                          textControllerText.isNotEmpty && 
                          !isLoading;
    
    return isEnabled ? onValidateAntrian : null;
  }

  //TEMPLATE BUTTON
  Widget _buildActionButton(
    String text,
    Color color,
    VoidCallback? onPressed,
    double height,
    double fontSize,
  ) {
    final bool disabled = onPressed == null;

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? Colors.grey.shade400 : color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: disabled ? 0 : 3,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: _getAdjustedFontSize(text, fontSize),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Helper method untuk menyesuaikan ukuran font berdasarkan panjang teks
  double _getAdjustedFontSize(String text, double baseFontSize) {
    if (text.length > 10) {
      return baseFontSize * 0.85;
    } else if (text.length > 8) {
      return baseFontSize * 0.9;
    }
    return baseFontSize;
  }
}