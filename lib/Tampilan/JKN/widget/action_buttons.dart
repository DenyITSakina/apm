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

  // Tombol LANJUT
  Color _getLanjutButtonColor() {
    final bool isEnabled =
        selectedType.isNotEmpty && textControllerText.isNotEmpty && !isLoading;
    return isEnabled ? Colors.redAccent : Colors.grey.shade400;
  }

  VoidCallback? _getLanjutButtonCallback() {
    final bool isEnabled =
        selectedType.isNotEmpty && textControllerText.isNotEmpty && !isLoading;
    return isEnabled ? onValidateAntrian : null;
  }

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
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Tombol utama (JKN, UMUM, DAFTAR POLI, LANJUT)
  Widget _buildMainButtons(
    BuildContext context,
    double buttonHeight,
    double fontSize,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16, vertical: 8),
      child: Column(
        children: [
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
          isMobile
              ? Column(
                  children: [
                    _buildActionButton(
                      'DAFTAR POLI',
                      Colors.deepOrange,
                      isPendaftaranEnabled && !isLoading
                          ? onPendaftaranPressed
                          : null,
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
                        isPendaftaranEnabled && !isLoading
                            ? onPendaftaranPressed
                            : null,
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

  // Tombol Lanjut setelah validasi
  Widget _buildLanjutButtons(
    BuildContext context,
    double buttonHeight,
    double fontSize,
    bool isMobile,
  ) {
    final bool isDisabled = isBatalBooking || isLanjutButtonsDisabled;
    if (isFormPendaftaranActive) return const SizedBox.shrink();

    final VoidCallback? poliCallback = isDisabled ? null : onLanjutPoli;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16, vertical: 8),
      child: isMobile
          ? Column(
              children: [
                _buildActionButton(
                  selectedType == 'pendaftaran' ? 'Pilih POLI' : 'Ke Poli',
                  isDisabled ? Colors.grey : Colors.blue.shade700,
                  // isDisabled ? null : onLanjutPoli,
                  poliCallback,
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
                    // isDisabled ? null : onLanjutPoli,
                    poliCallback,
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
    );
  }
}
