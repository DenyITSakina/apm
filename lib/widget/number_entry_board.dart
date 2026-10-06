import 'package:apm/theme/app_tokens.dart';
import 'package:apm/theme/app_typography.dart';
import 'package:apm/widget/app_button.dart';
import 'package:apm/widget/app_page_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Papan input nomor untuk kiosk: display scanner + keypad numerik.
///
/// Menyatukan field scanner (hidden TextField yang menangkap input dari
/// barcode scanner), tampilan nomor yang besar, dan keypad numerik supaya
/// semua halaman cek-in/pendaftaran punya perilaku identik.
class NumberEntryBoard extends StatefulWidget {
  /// Key untuk testing: nomor yang tampil di layar scanner.
  static const Key displayKey = Key('scanner-display');

  const NumberEntryBoard({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
    required this.onSubmit,
    this.hint = 'Masukkan nomor / pindai barcode',
    this.submitLabel = 'LANJUT',
    this.submitIcon = Icons.arrow_forward_rounded,
    this.submitCaption,
    this.maxLength = 16,
    this.accent = AppColors.primary,
    this.submitGradient = AppGradients.brand,
    this.submitLoading = false,
    this.submitEnabled = true,
    this.helperText,
    this.belowKeypad,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onSubmit;
  final String submitLabel;
  final IconData submitIcon;

  /// Keterangan singkat di bawah tombol untuk memandu pengguna.
  final String? submitCaption;
  final int maxLength;
  final Color accent;
  final Gradient submitGradient;
  final bool submitLoading;
  final bool submitEnabled;
  final String? helperText;
  final Widget? belowKeypad;

  @override
  State<NumberEntryBoard> createState() => _NumberEntryBoardState();
}

class _NumberEntryBoardState extends State<NumberEntryBoard> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  Future<void> _refocus() async {
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    FocusScope.of(context).requestFocus(widget.focusNode);
  }

  void _handleDigit(String value) {
    if (widget.controller.text.length >= widget.maxLength) {
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.selectionClick();
    widget.onDigit(value);
    _refocus();
  }

  void _handleBackspace() {
    if (widget.controller.text.isEmpty) return;
    HapticFeedback.selectionClick();
    widget.onBackspace();
    _refocus();
  }

  void _handleClear() {
    HapticFeedback.mediumImpact();
    widget.onClear();
    _refocus();
  }

  void _handleSubmit() {
    HapticFeedback.mediumImpact();
    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.maxHeight.isFinite;
        final stacked = constraints.maxWidth < 720;

        final keypad = NumberKeypad(
          accent: widget.accent,
          onDigit: _handleDigit,
          onBackspace: _handleBackspace,
          onClear: _handleClear,
        );
        final submit = _SubmitBlock(
          label: widget.submitLabel,
          icon: widget.submitIcon,
          caption: widget.submitCaption,
          gradient: widget.submitGradient,
          loading: widget.submitLoading,
          enabled: widget.submitEnabled,
          onPressed: _handleSubmit,
        );

        final header = _ScannerDisplay(
          controller: widget.controller,
          focusNode: widget.focusNode,
          label: widget.label,
          hint: widget.hint,
          accent: widget.accent,
          maxLength: widget.maxLength,
          compact: !bounded || constraints.maxHeight < 640,
          onSubmitted: (_) => _handleSubmit(),
        );

        final notice = widget.belowKeypad;

        // Tanpa batas tinggi (mis. di dalam SingleChildScrollView) kembali ke
        // susunan bertumpuk agar tidak memaksa keypad mengisi tinggi tak hingga.
        if (!bounded || stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              const SizedBox(height: AppSpacing.md),
              submit,
              const SizedBox(height: AppSpacing.md),
              keypad,
              if (notice != null) ...[
                const SizedBox(height: AppSpacing.md),
                notice,
              ],
            ],
          );
        }

        // Tombol aksi diletakkan di kanan atas, sejajar dengan display scanner,
        // sehingga tidak berada di tengah dan mudah dijangkau ibu jari.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: header),
                const SizedBox(width: AppSpacing.md),
                SizedBox(width: 280, child: submit),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Align(alignment: Alignment.topCenter, child: keypad),
            ),
            if (notice != null) ...[
              const SizedBox(height: AppSpacing.md),
              notice,
            ],
          ],
        );
      },
    );
  }
}

/// Blok tombol submit: judul kecil, tombol besar, dan keterangan singkat.
class _SubmitBlock extends StatelessWidget {
  const _SubmitBlock({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onPressed,
    required this.loading,
    required this.enabled,
    this.caption,
  });

  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onPressed;
  final bool loading;
  final bool enabled;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final ready = enabled && !loading;
    final accent = _accentOf(gradient);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadow.soft,
        border: Border.all(color: ready ? accent : AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: accent,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'LANGKAH BERIKUTNYA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppText.family,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppGradientButton(
            label: label,
            icon: icon,
            caption: caption,
            onPressed: onPressed,
            loading: loading,
            enabled: enabled,
            gradient: gradient,
            height: 66,
            fontSize: 16,
          ),
          const SizedBox(height: 6),
          Text(
            loading
                ? 'Mohon tunggu, sedang memproses data...'
                : ready
                ? caption ?? 'Periksa nomor lalu tekan tombol di atas'
                : 'Isi atau pindai nomor terlebih dahulu',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppText.family,
              fontSize: 11,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  static Color _accentOf(Gradient gradient) {
    if (gradient is LinearGradient && gradient.colors.isNotEmpty) {
      return gradient.colors.first;
    }
    return AppColors.primary;
  }
}

class _ScannerDisplay extends StatelessWidget {
  const _ScannerDisplay({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.accent,
    required this.maxLength,
    required this.onSubmitted,
    this.compact = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final Color accent;
  final int maxLength;
  final ValueChanged<String> onSubmitted;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;
    final digits = controller.text.length;

    return AppCardScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.qr_code_scanner_rounded, size: 18, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (hasText)
                Text(
                  '$digits/$maxLength',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: compact ? 12 : 20,
                  horizontal: 18,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: hasText ? accent : AppColors.border,
                    width: hasText ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        hasText ? controller.text : hint,
                        key: hasText ? NumberEntryBoard.displayKey : null,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: hasText
                            ? AppText.numeric(context, size: compact ? 24 : 30)
                            : TextStyle(
                                fontFamily: AppText.family,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                      ),
                    ),
                    if (hasText) ...[
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () => controller.clear(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.dangerSoft,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasText) const Positioned.fill(child: ScanPulse()),
              // Kolom tersembunyi untuk menangkap input barcode scanner.
              SizedBox(
                width: 0,
                height: 0,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  showCursor: false,
                  keyboardType: TextInputType.text,
                  enableInteractiveSelection: false,
                  enableIMEPersonalizedLearning: false,
                  style: const TextStyle(
                    color: Colors.transparent,
                    fontSize: 1,
                    height: 1,
                  ),
                  cursorColor: Colors.transparent,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: onSubmitted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Keypad numerik 3x4 dengan gaya seragam.
class NumberKeypad extends StatelessWidget {
  const NumberKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
    this.accent = AppColors.primary,
  });

  static const double maxButtonSize = 104;
  static const double minButtonSize = 48;

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.maxHeight.isFinite;
        // Padding 10 + border 1 pada semua sisi.
        final innerWidth = constraints.maxWidth - 22;
        final innerHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight - 22
            : double.infinity;

        final byWidth = (innerWidth - 16) / 3;
        final byHeight = bounded ? innerHeight / 4 - 8 : byWidth;

        final size = (byWidth < byHeight ? byWidth : byHeight).clamp(
          minButtonSize,
          maxButtonSize,
        );
        final fontSize = (size * 0.38).clamp(18.0, 32.0);

        Widget row(List<String> keys) =>
            _row(keys, size, fontSize, fill: bounded);

        final rows = [
          row(['1', '2', '3']),
          row(['4', '5', '6']),
          row(['7', '8', '9']),
          row(['backspace', '0', 'clear']),
        ];

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadow.soft,
            border: Border.all(color: AppColors.border),
          ),
          child: bounded
              ? Column(children: [for (final r in rows) Expanded(child: r)])
              : Column(mainAxisSize: MainAxisSize.min, children: rows),
        );
      },
    );
  }

  Widget _row(
    List<String> keys,
    double size,
    double fontSize, {
    bool fill = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            fill ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < keys.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            SizedBox(
              width: size,
              height: fill ? null : size,
              child: _buildKey(keys[i], fontSize),
            ),
          ],
        ],
      ),
    );
  }

  static Color _keyBackground(String key, Color accent) {
    switch (key) {
      case 'backspace':
        return AppColors.surfaceMuted;
      case 'clear':
        return AppColors.dangerSoft;
      default:
        return AppColors.surfaceMuted;
    }
  }

  static Color _keyBorder(String key, Color accent) {
    switch (key) {
      case 'clear':
        return AppColors.danger.withValues(alpha: 0.35);
      default:
        return AppColors.border;
    }
  }

  Widget _buildKey(String key, double fontSize) {
    late final VoidCallback onTap;
    Widget child;
    switch (key) {
      case 'backspace':
        onTap = onBackspace;
        child = Icon(
          Icons.backspace_rounded,
          size: fontSize * 0.9,
          color: AppColors.textSecondary,
        );
        break;
      case 'clear':
        onTap = onClear;
        child = Text(
          'C',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppText.family,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: AppColors.danger,
          ),
        );
        break;
      default:
        onTap = () => onDigit(key);
        child = Text(
          key,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppText.family,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        );
    }

    return _KeyButton(
      key: ValueKey('keypad-$key'),
      onTap: onTap,
      background: _keyBackground(key, accent),
      border: _keyBorder(key, accent),
      child: child,
    );
  }
}

class _KeyButton extends StatefulWidget {
  const _KeyButton({
    super.key,
    required this.onTap,
    required this.child,
    required this.background,
    required this.border,
  });

  final VoidCallback onTap;
  final Widget child;
  final Color background;
  final Color border;

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.93 : 1,
      duration: const Duration(milliseconds: 90),
      child: Material(
        color: widget.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: widget.onTap,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: widget.border),
              boxShadow: _pressed
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}

/// Wrapper kartu putih ringkas (dipakai di dalam board).
class AppCardScaffold extends StatelessWidget {
  const AppCardScaffold({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadow.soft,
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
