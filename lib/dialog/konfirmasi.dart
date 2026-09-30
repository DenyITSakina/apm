import 'package:apm/theme/app_tokens.dart';
import 'package:apm/theme/app_typography.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatefulWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.onCancel,
    this.icon,
    this.color = AppColors.primary,
    this.confirmLabel = 'LANJUT',
    this.cancelLabel = 'BATAL',
    this.points = const [],
  });

  final String title;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color color;
  final String confirmLabel;
  final String cancelLabel;
  final List<String> points;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    IconData? icon,
    Color color = AppColors.primary,
    String confirmLabel = 'LANJUT',
    String cancelLabel = 'BATAL',
    List<String> points = const [],
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.textPrimary.withValues(alpha: 0.45),
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
        onCancel: onCancel,
        icon: icon,
        color: color,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        points: points,
      ),
    );
  }

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  )..forward();

  late final Animation<double> _scale = Tween(
    begin: 0.92,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    final compact = MediaQuery.sizeOf(context).width < 480;

    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _fade,
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              padding: EdgeInsets.all(compact ? 24 : 30),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.18),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withValues(alpha: 0.9),
                            color,
                          ],
                        ),
                        boxShadow: AppShadow.glow(color),
                      ),
                      child: Icon(
                        widget.icon ?? Icons.help_outline_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppText.family,
                      fontSize: compact ? 20 : 23,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppText.family,
                      fontSize: 14.5,
                      height: 1.55,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  for (final point in widget.points) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 16, color: color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              point,
                              style: const TextStyle(
                                fontFamily: AppText.family,
                                fontSize: 13,
                                height: 1.45,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _DialogButton(
                          label: widget.cancelLabel,
                          background: AppColors.surfaceMuted,
                          foreground: AppColors.textSecondary,
                          onTap: () {
                            Navigator.pop(context);
                            final onCancel = widget.onCancel;
                            if (onCancel != null) {
                              Future.delayed(
                                const Duration(milliseconds: 200),
                                onCancel,
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _DialogButton(
                          label: widget.confirmLabel,
                          background: color,
                          foreground: Colors.white,
                          elevated: true,
                          onTap: () {
                            Navigator.pop(context);
                            widget.onConfirm();
                          },
                        ),
                      ),
                    ],
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

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.elevated = false,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: elevated
                  ? null
                  : Border.all(color: AppColors.border),
              boxShadow: elevated ? AppShadow.soft : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppText.family,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
