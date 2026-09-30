import 'package:apm/theme/app_tokens.dart';
import 'package:apm/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Tombol aksi besar dengan gradien, state disabled, dan loading spinner.
class AppGradientButton extends StatefulWidget {
  const AppGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient = AppGradients.brand,
    this.loading = false,
    this.enabled = true,
    this.height = 64,
    this.fontSize,
    this.badge,
    this.caption,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient gradient;
  final bool loading;
  final bool enabled;
  final double height;
  final double? fontSize;
  final String? badge;
  final String? caption;

  @override
  State<AppGradientButton> createState() => _AppGradientButtonState();
}

class _AppGradientButtonState extends State<AppGradientButton> {
  bool _pressed = false;

  bool get _active => widget.enabled && !widget.loading;

  @override
  Widget build(BuildContext context) {
    final active = _active;

    return Semantics(
      button: true,
      enabled: active,
      label: widget.label,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
        child: Opacity(
          opacity: active ? 1 : 0.5,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Ink(
              height: widget.height,
              decoration: BoxDecoration(
                gradient: active ? widget.gradient : null,
                color: active ? null : AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: active
                    ? AppShadow.glow(_gradientColor(widget.gradient))
                    : null,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: active ? widget.onPressed : null,
                onHighlightChanged: (value) =>
                    setState(() => _pressed = value),
                onTapDown: active ? (_) => setState(() => _pressed = true) : null,
                onTapUp: active ? (_) => setState(() => _pressed = false) : null,
                onTapCancel: active
                    ? () => setState(() => _pressed = false)
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.loading)
                            LoadingAnimationWidget.fourRotatingDots(
                              color: Colors.white,
                              size: 26,
                            )
                          else if (widget.icon != null)
                            Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          if (widget.loading || widget.icon != null)
                            const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              widget.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: AppText.button(context).copyWith(
                                fontSize: widget.fontSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.caption != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.caption!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppText.family,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
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

  static Color _gradientColor(Gradient gradient) {
    if (gradient is LinearGradient && gradient.colors.isNotEmpty) {
      return gradient.colors.first;
    }
    return AppColors.primary;
  }
}

/// Tombol aksi sekunder (outline) dengan gaya yang sama.
class AppOutlineButton extends StatelessWidget {
  const AppOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppColors.primary,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: Opacity(
        opacity: onPressed == null ? 0.5 : 1,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onPressed,
            child: Container(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: color),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppText.family,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: color,
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
