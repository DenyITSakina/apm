import 'dart:async';

import 'package:apm/theme/app_tokens.dart';
import 'package:apm/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Toast ringkas di atas layar dengan animasi slide + fade.
class TopToast {
  const TopToast._();

  static void show(
    BuildContext context,
    String message, {
    Color backgroundColor = AppColors.danger,
    IconData icon = Icons.error_rounded,
    Duration duration = const Duration(seconds: 6),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
        duration: duration,
        onDismiss: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );

    overlay.insert(entry);
  }

  static void success(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_rounded,
      duration: const Duration(seconds: 4),
    );
  }

  static void error(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: AppColors.danger,
      icon: Icons.error_rounded,
      duration: const Duration(seconds: 7),
    );
  }

  static void warning(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_amber_rounded,
      duration: const Duration(seconds: 6),
    );
  }

  static void info(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: AppColors.info,
      icon: Icons.info_rounded,
      duration: const Duration(seconds: 5),
    );
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.onDismiss,
    required this.duration,
  });

  final String message;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onDismiss;
  final Duration duration;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  )..forward();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (!mounted) return;
    _controller.reverse().then((_) => widget.onDismiss());
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: topInset + 12,
      left: AppSpacing.md,
      right: AppSpacing.md,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.4),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        ),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOut,
          ),
          child: Semantics(
            liveRegion: true,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 720),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: widget.backgroundColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(widget.icon, color: Colors.white, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.message,
                              style: const TextStyle(
                                fontFamily: AppText.family,
                                fontSize: 14.5,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  size: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Ketuk untuk menutup',
                                  style: TextStyle(
                                    fontFamily: AppText.family,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _dismiss();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18,
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
      ),
    );
  }
}
