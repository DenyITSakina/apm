import 'dart:async';

import 'package:apm/theme/app_tokens.dart';
import 'package:apm/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Header halaman dengan gradien brand, tombol kembali, dan logo.
///
/// Dipakai konsisten di semua halaman proses (cek-in, daftar poli, booking)
/// supaya patient's eye sudah tahu"Letakkan scanner di bawah" begitu masuk.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.badge,
    this.badgeIcon,
    this.onBack,
    this.showLogo = true,
    this.accent = AppColors.accent,
    this.height,
    this.dense = false,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final String? badge;
  final IconData? badgeIcon;
  final VoidCallback? onBack;
  final bool showLogo;
  final Color accent;
  final double? height;

  /// Versi ramping untuk halaman yang harus muat dalam satu layar.
  final bool dense;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 600 && height == null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.paddingOf(context).top + (dense ? 4 : AppSpacing.sm),
        AppSpacing.md,
        dense ? AppSpacing.sm : AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.brand,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _HeaderPattern()),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _CircleAction(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Kembali',
                    onTap: onBack ?? () => Navigator.maybePop(context),
                  ),
                  const Spacer(),
                  if (showLogo)
                    Text(
                      'RSU SAKINA IDAMAN',
                      style: TextStyle(
                        fontFamily: AppText.family,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  const Spacer(),
                  if (trailing != null)
                    trailing!
                  else if (showLogo)
                    _HeaderLogo(size: dense ? 46 : 56)
                  else
                    const SizedBox(width: 44),
                ],
              ),
              SizedBox(
                height: dense
                    ? 4
                    : isCompact
                    ? AppSpacing.sm
                    : AppSpacing.md,
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: dense
                    ? AppText.headerTitle(
                        context,
                      ).copyWith(fontSize: 22, height: 1.1)
                    : AppText.headerTitle(context),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: dense
                      ? AppText.headerSubtitle(context).copyWith(fontSize: 12.5)
                      : AppText.headerSubtitle(context),
                ),
              ],
              if (badge != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: dense ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (badgeIcon != null) ...[
                        Icon(badgeIcon, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        badge!,
                        style: const TextStyle(
                          fontFamily: AppText.family,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: 0.35),
                    accent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo rumah sakit di sisi kanan header.
class _HeaderLogo extends StatelessWidget {
  const _HeaderLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo_sakina.png',
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Icon(
            Icons.local_hospital_rounded,
            size: size * 0.6,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, this.onTap, this.tooltip});

  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class _HeaderPattern extends StatelessWidget {
  const _HeaderPattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CrossPatternPainter());
  }
}

class _CrossPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    const step = 54.0;
    const arm = 8.0;
    for (var x = step / 2; x < size.width; x += step) {
      for (var y = step / 2; y < size.height; y += step) {
        final center = Offset(x, y);
        canvas.drawLine(
          center.translate(-arm, 0),
          center.translate(arm, 0),
          paint,
        );
        canvas.drawLine(
          center.translate(0, -arm),
          center.translate(0, arm),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Footer slim dengan identitas dan jam operasional.
class AppPageFooter extends StatelessWidget {
  const AppPageFooter({
    super.key,
    this.message,
    this.left,
    this.showClock = true,
  });

  final String? message;
  final String? left;
  final bool showClock;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: compact ? 10 : 12,
      ),
      decoration: const BoxDecoration(
        gradient: AppGradients.footer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_hospital_rounded,
            color: Colors.white70,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message ??
                  left ??
                  'RSU Sakina Idaman • Anjungan Pendaftaran Mandiri',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppText.family,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          if (showClock && !compact) ...[
            const SizedBox(width: 12),
            Container(width: 1, height: 14, color: Colors.white24),
            const SizedBox(width: 12),
            const LiveClock(),
          ],
        ],
      ),
    );
  }
}

class LiveClock extends StatefulWidget {
  const LiveClock({super.key});

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleNextTick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Timer dijadwalkan ulang tepat di detik berikutnya agar jam tidak meleset.
  void _scheduleNextTick() {
    final now = DateTime.now();
    final delay = Duration(
      milliseconds: (60 - now.second) * 1000 - now.millisecond,
    );
    _timer = Timer(delay, () {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
      _scheduleNextTick();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _format(_now),
      style: const TextStyle(
        fontFamily: AppText.family,
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }

  static String _format(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '${value.day} ${months[value.month - 1]} ${value.year}  $hh:$mm';
  }
}

/// Latar dekoratif lembut (gelembung) untuk halaman utama.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.animate = true});

  final Widget child;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(gradient: AppGradients.brandSoft),
          ),
        ),
        Positioned(
          right: -80,
          top: -60,
          child: _GlowBubble(
            color: AppColors.primary,
            size: 260,
            alignment: Alignment.bottomRight,
          ),
        ),
        Positioned(
          left: -90,
          bottom: -70,
          child: _GlowBubble(
            color: AppColors.accent,
            size: 240,
            alignment: Alignment.topRight,
          ),
        ),
        child,
      ],
    );
  }
}

class _GlowBubble extends StatelessWidget {
  const _GlowBubble({
    required this.color,
    required this.size,
    required this.alignment,
  });

  final Color color;
  final double size;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.16),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lottie-free animated "scan line" untuk memberi kesan scanner aktif.
class ScanPulse extends StatefulWidget {
  const ScanPulse({super.key, this.color = AppColors.accent});

  final Color color;

  @override
  State<ScanPulse> createState() => _ScanPulseState();
}

class _ScanPulseState extends State<ScanPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = Curves.easeInOut.transform(_controller.value);
        return SizedBox(
          height: 18,
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: widget.color.withValues(alpha: 0.18),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(-1 + 2 * progress, 0),
                child: FractionallySizedBox(
                  widthFactor: 0.45,
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: widget.color,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.7),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
