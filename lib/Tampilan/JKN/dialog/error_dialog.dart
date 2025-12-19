import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../responsive/responsive.dart';

class ErrorDialog extends StatefulWidget {
  final String title;
  final String message;
  final IconData? iconData;
  final Color? primaryColor;
  final String? okText;
  final VoidCallback? onClose;

  const ErrorDialog({
    super.key,
    this.title = 'Peringatan',
    required this.message,
    this.iconData,
    this.primaryColor,
    this.okText,
    this.onClose,
  });

  @override
  State<ErrorDialog> createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> with TickerProviderStateMixin {
  late AnimationController _dialogController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  late AnimationController _iconController;
  late Animation<double> _iconPulse;

  @override
  void initState() {
    super.initState();

    _dialogController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _dialogController, curve: Curves.decelerate),
    );

    _fadeAnimation = CurvedAnimation(parent: _dialogController, curve: Curves.easeIn);

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _iconPulse = Tween<double>(begin: 0.96, end: 1.06).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );

    _dialogController.forward();
    _iconController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _dialogController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    try {
      await _dialogController.reverse();
    } catch (_) {}
    _iconController.stop();

    if (!mounted) return;
    Navigator.of(context).pop();
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtils.isMobile(context);
    final double fontSize = ResponsiveUtils.getFontSize(
      context,
      mobile: 16,
      tablet: 18,
      desktop: 20,
    );

    final Color primary = widget.primaryColor ?? Colors.red.shade700;
    final IconData icon = widget.iconData ?? Icons.error_outline;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? 420 : 520),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 22, vertical: isMobile ? 14 : 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primary.withOpacity(0.12)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: _handleClose,
                      child: Icon(Icons.close, size: isMobile ? 18 : 20, color: Colors.grey[400]),
                    ),
                  ),

                  const SizedBox(height: 6),

                  ScaleTransition(
                    scale: _iconPulse,
                    child: CircleAvatar(
                      radius: isMobile ? 28 : 34,
                      backgroundColor: primary.withOpacity(0.12),
                      child: Icon(icon, size: isMobile ? 28 : 34, color: primary),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: isMobile ? (fontSize + 2) : (fontSize + 4),
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: fontSize,
                      color: Colors.grey[800],
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                      child: Text(
                        widget.okText ?? 'TUTUP',
                        style: GoogleFonts.montserrat(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
