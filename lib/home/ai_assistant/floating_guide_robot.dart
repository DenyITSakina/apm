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
    with SingleTickerProviderStateMixin {
  bool _expanded = true;
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
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
        animation: _pulse,
        builder: (context, _) {
          final glow = 0.20 + (_pulse.value * 0.18);
          return Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [widget.accent, widget.accent.withValues(alpha: 0.75)],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.7),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.accent.withValues(alpha: glow),
                  blurRadius: 16,
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
              alignment: Alignment.center,
              children: [
                Icon(
                  _expanded
                      ? Icons.smart_toy_rounded
                      : Icons.smart_toy_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                Positioned(
                  right: 8,
                  top: 9,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ADE80),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
                'Sentuh robot: buka/tutup • Geser: pindahkan',
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
