import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../../Blog Antrian APM/antrian_apm_bloc.dart';
import '../../../models/apm/apm_antrian_model.dart';
import '../responsive/responsive.dart';
import 'validated_data_display.dart';
import 'action_buttons.dart';

class InputSection extends StatelessWidget {
  final TextEditingController textController;
  final String selectedType;
  final ApmAntrianModel? validatedData;
  final AntrianApmState state;
  final bool isLanjutButtonsDisabled;
  final bool isFormPendaftaranActive;
  final bool isBatalBooking;
  final VoidCallback onBackToSelection;
  final VoidCallback onValidateAntrian;
  final VoidCallback onLanjutPoli;
  final VoidCallback onLanjutLoket;
  final VoidCallback onJknPressed;
  final VoidCallback onUmumPressed;
  final VoidCallback onPendaftaranPressed;

  const InputSection({
    super.key,
    required this.textController,
    required this.selectedType,
    required this.validatedData,
    required this.state,
    required this.isLanjutButtonsDisabled,
    required this.isFormPendaftaranActive,
    required this.isBatalBooking,
    required this.onBackToSelection,
    required this.onValidateAntrian,
    required this.onLanjutPoli,
    required this.onLanjutLoket,
    required this.onJknPressed,
    required this.onUmumPressed,
    required this.onPendaftaranPressed, required isVisible,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(context, isMobile),
            const SizedBox(height: 12),
            _buildInputField(isMobile),
            const SizedBox(height: 16),

            if (state is AntrianApmLoading)
              _buildLoadingState()
            else
              _buildInteractiveSection(context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedType.isNotEmpty && validatedData == null)
          _buildSelectionHeader(context, isMobile),

        const SizedBox(height: 10),
        _buildMainTitle(isMobile),
        const SizedBox(height: 6),
        _buildSubtitle(isMobile),
        const SizedBox(height: 10),
        _buildDynamicMessage(context, isMobile),
      ],
    );
  }

  Widget _buildSelectionHeader(BuildContext context, bool isMobile) {
    final (IconData icon, Color color, String label) = _getTypeInfo(selectedType);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: isMobile ? 14 : 16,
            child: Icon(icon, color: Colors.white, size: isMobile ? 16 : 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tipe Antrian: $label',
              style: GoogleFonts.montserrat(
                fontSize: isMobile ? 15 : 17,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          _buildBackButton(isMobile),
        ],
      ),
    );
  }

  Widget _buildMainTitle(bool isMobile) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: Text(
        'Anjungan Pendaftaran Mandiri',
        style: GoogleFonts.montserrat(
          fontSize: isMobile ? 20 : 28,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildSubtitle(bool isMobile) {
    // Mapping tipe ke subtitle
    final Map<String, String> subtitleMap = {
      'jkn': 'Masukkan No. BPJS / KTP',
      'umum': 'Masukkan No. Peserta / Booking / RM / KTP',
      'pendaftaran': 'Masukkan No. RM',
    };

    return Text(
      subtitleMap[selectedType] ??
          'Silahkan Pilih',
      style: GoogleFonts.montserrat(
        fontSize: isMobile ? 13 : 18,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildDynamicMessage(BuildContext context, bool isMobile) {
    final hasSelection = selectedType.isNotEmpty;
    final String message = hasSelection
        ? 'Silakan masukkan nomor untuk tipe ${selectedType.toUpperCase()}'
        : 'Pilih tipe antrian terlebih dahulu untuk melanjutkan';

    final Color backgroundColor = hasSelection ? Colors.blue.shade50 : Colors.amber.shade50;
    final Color iconColor = hasSelection ? Colors.blue.shade600 : Colors.amber.shade600;
    final IconData icon = hasSelection ? Icons.info_outline : Icons.warning_amber;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: isMobile ? 18 : 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.montserrat(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: textController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: _getLabelText(),
          labelStyle: GoogleFonts.montserrat(
            fontSize: isMobile ? 12 : 14,
            color: Colors.grey.shade600,
          ),
          hintText: 'Contoh: 1234567890',
          hintStyle: GoogleFonts.montserrat(
            fontSize: isMobile ? 12 : 14,
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade400,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue.shade500, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: isMobile ? 10 : 14,
          ),
        ),
        style: GoogleFonts.montserrat(
          fontSize: isMobile ? 18 : 22,
          fontWeight: FontWeight.w700,
          color: Colors.blue.shade800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(Colors.blue.shade700),
            ),
            const SizedBox(height: 10),
            Text(
              'Memvalidasi data...',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveSection(BuildContext context, bool isMobile) {
    if (validatedData != null) {
      return Column(
        children: [
          ValidatedDataDisplay(
            validatedData: validatedData!,
            onBackToSelection: onBackToSelection,
            isBatalBooking: isBatalBooking,
          ),
          const SizedBox(height: 10),
          ActionButtons(
            isJknEnabled: false,
            isUmumEnabled: false,
            isPendaftaranEnabled: false,
            isLanjutButtonsDisabled: isLanjutButtonsDisabled,
            isFormPendaftaranActive: isFormPendaftaranActive,
            isBatalBooking: isBatalBooking,
            isValidated: true,
            isLoading: state is AntrianApmLoading,
            selectedType: selectedType,
            textControllerText: textController.text,
            onJknPressed: onJknPressed,
            onUmumPressed: onUmumPressed,
            onPendaftaranPressed: onPendaftaranPressed,
            onValidateAntrian: onValidateAntrian,
            onLanjutPoli: onLanjutPoli,
            onLanjutLoket: onLanjutLoket,
          ),
        ],
      );
    }

    return ActionButtons(
      isJknEnabled: true,
      isUmumEnabled: true,
      isPendaftaranEnabled: true,
      isLanjutButtonsDisabled: isLanjutButtonsDisabled,
      isFormPendaftaranActive: isFormPendaftaranActive,
      isBatalBooking: isBatalBooking,
      isValidated: false,
      isLoading: state is AntrianApmLoading,
      selectedType: selectedType,
      textControllerText: textController.text,
      onJknPressed: onJknPressed,
      onUmumPressed: onUmumPressed,
      onPendaftaranPressed: onPendaftaranPressed,
      onValidateAntrian: onValidateAntrian,
      onLanjutPoli: onLanjutPoli,
      onLanjutLoket: onLanjutLoket,
    );
  }

  Widget _buildBackButton(bool isMobile) {
    return TextButton.icon(
      onPressed: onBackToSelection,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 6),
      ),
      icon: Icon(Icons.arrow_back_rounded, size: isMobile ? 14 : 16, color: Colors.grey.shade700),
      label: Text(
        'Ulangi',
        style: GoogleFonts.montserrat(
          fontSize: isMobile ? 12 : 14,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (IconData, Color, String) _getTypeInfo(String type) {
    switch (type) {
      case 'jkn':
        return (Icons.health_and_safety, Colors.blue.shade700, 'JKN');
      case 'umum':
        return (Icons.person, Colors.green.shade600, 'UMUM');
      case 'pendaftaran':
        return (Icons.app_registration, Colors.deepOrange, 'DAFTAR POLI');
      default:
        return (Icons.info, Colors.grey, 'BELUM DIPILIH');
    }
  }

  String _getLabelText() {
    switch (selectedType) {
      case 'jkn':
        return 'No. Peserta JKN';
      case 'umum':
        return 'No. RM / KTP';
      case 'pendaftaran':
        return 'No. RM Pendaftaran Poli';
      default:
        return 'Nomor Identitas';
    }
  }
}
