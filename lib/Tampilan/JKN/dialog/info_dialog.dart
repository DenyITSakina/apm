import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../responsive/responsive.dart';

class InfoDialog extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;
  final IconData? iconData;
  final Color? primaryColor;
  final String? okText;

  const InfoDialog({
    super.key,
    required this.title,
    required this.message,
    this.onClose,
    this.iconData,
    this.primaryColor,
    this.okText,
  });

  @override
  State<InfoDialog> createState() => _InfoDialogState();
}

class _InfoDialogState extends State<InfoDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.decelerate,
      ),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtils.isMobile(context);
    final double fontSize = ResponsiveUtils.getFontSize(
      context,
      mobile: 15,
      tablet: 16,
      desktop: 18,
    );

    final Color primary = widget.primaryColor ?? Colors.blue.shade700;
    final IconData icon = widget.iconData ?? Icons.info_outline_rounded;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: ScaleTransition(
            scale: _scale,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isMobile ? 420 : 520),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 26, vertical: isMobile ? 18 : 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primary.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close icon
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onClose?.call();
                        },
                        child: Icon(Icons.close, size: isMobile ? 18 : 20, color: Colors.grey[400]),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Icon circle
                    CircleAvatar(
                      radius: isMobile ? 28 : 34,
                      backgroundColor: primary.withOpacity(0.12),
                      child: Icon(icon, size: isMobile ? 28 : 34, color: primary),
                    ),

                    const SizedBox(height: 14),

                    // Title
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: isMobile ? (fontSize + 2) : (fontSize + 4),
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Message
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: fontSize,
                        color: Colors.grey[800],
                        height: 1.48,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // OK Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onClose?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                        child: Text(
                          widget.okText ?? 'OK',
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
      ),
    );
  }
}
