import 'package:apm/theme/app_tokens.dart';
import 'package:apm/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Robot pemandu mengambang: menampilkan instruksi/langkah (bukan pertanyaan).
class FloatingGuideRobot extends StatefulWidget {
  const FloatingGuideRobot({
    super.key,
    required this.message,
    this.title = 'Pemandu APM',
    this.accent = AppColors.primary,
    this.step,
    this.totalSteps,
    this.alignRight = false,
  });

  /// Teks panduan yang ditampilkan.
  final String message;
  final String title;
  final Color accent;
  final int? step;
  final int? totalSteps;

  /// true = gelembung muncul ke kiri dari robot (robot di kanan bawah).
  final bool alignRight;

  @override
  State<FloatingGuideRobot> createState() => _FloatingGuideRobotState();
}

/// Wrapper yang membuat [FloatingGuideRobot] dapat digeser ke mana saja
/// di dalam [Stack] induk. Gunakan sebagai child langsung dari [Stack].
class DraggableGuideRobot extends StatefulWidget {
  const DraggableGuideRobot({
    super.key,
    required this.message,
    this.title = 'Pemandu APM',
    this.accent = AppColors.primary,
    this.step,
    this.totalSteps,
    this.initialLeft = 8,
    this.initialBottom = 8,
  });

  final String message;
  final String title;
  final Color accent;
  final int? step;
  final int? totalSteps;
  final double initialLeft;
  final double initialBottom;

  @override
  State<DraggableGuideRobot> createState() => _DraggableGuideRobotState();
}

class _DraggableGuideRobotState extends State<DraggableGuideRobot> {
  double? _dx;
  double? _dy;

  void _ensureInit(BoxConstraints bc) {
    if (_dx != null && _dy != null) return;
    _dx = widget.initialLeft.clamp(
      0.0,
      (bc.maxWidth - 60).clamp(0.0, double.infinity),
    );
    final initBottom = widget.initialBottom + 56;
    _dy = (bc.maxHeight - initBottom).clamp(
      0.0,
      (bc.maxHeight - 60).clamp(0.0, double.infinity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, bc) {
          if (bc.maxWidth <= 0 || bc.maxHeight <= 0) {
            return const SizedBox.shrink();
          }
          _ensureInit(bc);
          final dx = _dx!.clamp(
            0.0,
            (bc.maxWidth - 56).clamp(0.0, double.infinity),
          );
          final dy = _dy!.clamp(
            0.0,
            (bc.maxHeight - 56).clamp(0.0, double.infinity),
          );
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: dx,
                top: dy,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (d) {
                    setState(() {
                      _dx = (dx + d.delta.dx).clamp(
                        0.0,
                        (bc.maxWidth - 56).clamp(0.0, double.infinity),
                      );
                      _dy = (dy + d.delta.dy).clamp(
                        0.0,
                        (bc.maxHeight - 56).clamp(0.0, double.infinity),
                      );
                    });
                  },
                  child: FloatingGuideRobot(
                    message: widget.message,
                    title: widget.title,
                    accent: widget.accent,
                    step: widget.step,
                    totalSteps: widget.totalSteps,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FloatingGuideRobotState extends State<FloatingGuideRobot>
    with TickerProviderStateMixin {
  bool _expanded = true;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  late final AnimationController _sway = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  late final Animation<double> _rotate = Tween<double>(
    begin: -0.16,
    end: 0.16,
  ).animate(CurvedAnimation(parent: _sway, curve: Curves.easeInOut));

  late final Animation<double> _bob = Tween<double>(
    begin: -2.0,
    end: 2.0,
  ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

  @override
  void dispose() {
    _pulse.dispose();
    _sway.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bubble = _expanded ? _buildBubble() : const SizedBox.shrink();
    final robot = _buildRobot();

    final children = widget.alignRight
        ? [if (_expanded) bubble, robot]
        : [robot, if (_expanded) bubble];

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: widget.alignRight
          ? Alignment.bottomRight
          : Alignment.bottomLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _buildRobot() {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulse, _sway]),
        builder: (context, _) {
          final glow = 0.22 + (_pulse.value * 0.22);
          return Transform.translate(
            offset: Offset(0, _bob.value),
            child: Transform.rotate(
              angle: _rotate.value,
              child: SizedBox(
                width: 64,
                height: 74,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    // antena
                    Positioned(
                      top: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFFD54F),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFFD54F,
                                  ).withValues(alpha: 0.7),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 3,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // badan robot lucu
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.accent,
                              Color.lerp(widget.accent, Colors.white, 0.15)!,
                              widget.accent.withValues(alpha: 0.85),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.75),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.accent.withValues(alpha: glow),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // telinga kiri
                            Positioned(
                              left: -5,
                              top: 16,
                              child: _ear(widget.accent),
                            ),
                            // telinga kanan
                            Positioned(
                              right: -5,
                              top: 16,
                              child: _ear(widget.accent),
                            ),
                            // wajah
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 6),
                                  // mata
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _eye(blink: _sway.value),
                                      const SizedBox(width: 10),
                                      _eye(blink: _sway.value),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // pipi + senyum
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _blush(),
                                      const SizedBox(width: 6),
                                      _smile(),
                                      const SizedBox(width: 6),
                                      _blush(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // indikator online
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4ADE80),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _ear(Color accent) {
    return Container(
      width: 8,
      height: 14,
      decoration: BoxDecoration(
        color: Color.lerp(accent, Colors.white, 0.25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
    );
  }

  Widget _eye({required double blink}) {
    final squeeze = (blink < 0.12) ? 0.25 : 1.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 14,
      height: 14 * squeeze,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 2)],
      ),
      alignment: Alignment.center,
      child: squeeze > 0.5
          ? Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                shape: BoxShape.circle,
              ),
              child: Align(
                alignment: const Alignment(-0.3, -0.3),
                child: Container(
                  width: 2.5,
                  height: 2.5,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
          : Container(
              width: 10,
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
    );
  }

  Widget _blush() {
    return Container(
      width: 8,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFFF8FAB).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _smile() {
    return SizedBox(
      width: 14,
      height: 8,
      child: CustomPaint(painter: _SmilePainter()),
    );
  }

  Widget _buildBubble() {
    final maxW = (MediaQuery.of(context).size.width * 0.42).clamp(220.0, 360.0);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: Container(
          key: ValueKey(widget.message),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.accent.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: widget.accent.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: widget.accent,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: AppText.family,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: widget.accent,
                      ),
                    ),
                  ),
                  if (widget.step != null && widget.totalSteps != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: widget.accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.step}/${widget.totalSteps}',
                        style: TextStyle(
                          fontFamily: AppText.family,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: widget.accent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                widget.message,
                style: const TextStyle(
                  fontFamily: AppText.family,
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sentuh robot: buka/tutup panduan',
                style: TextStyle(
                  fontFamily: AppText.family,
                  fontSize: 10.5,
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(1, 2);
    path.quadraticBezierTo(size.width / 2, size.height + 1, size.width - 1, 2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
