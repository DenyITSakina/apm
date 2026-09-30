import 'package:apm/blog/antrian_apm_bloc.dart';
import 'package:apm/blog/booking/booking_bloc.dart';
import 'package:apm/dialog/konfirmasi.dart';
import 'package:apm/func/navigation_helpers.dart';
import 'package:apm/home/booking/booking_page.dart';
import 'package:apm/home/check_in_bpjs/cekin_bpjs_page.dart';
import 'package:apm/home/check_in_umum/cekin_umum_page.dart';
import 'package:apm/theme/app_tokens.dart';
import 'package:apm/theme/app_typography.dart';
import 'package:apm/widget/app_card.dart';
import 'package:apm/widget/app_page_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardApm extends StatefulWidget {
  const DashboardApm({super.key});

  @override
  State<DashboardApm> createState() => _DashboardApmState();
}

class _DashboardApmState extends State<DashboardApm>
    with TickerProviderStateMixin {
  late final AnimationController _enterController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  void _pilihBooking() {
    HapticFeedback.mediumImpact();
    ConfirmationDialog.show(
      context,
      title: 'Booking Online',
      message: 'Pilih jenis pasien untuk melakukan booking.',
      icon: Icons.event_available_rounded,
      color: AppColors.primary,
      confirmLabel: 'UMUM',
      cancelLabel: 'BPJS',
      points: const [
        'UMUM: pasien umum / non-BPJS.',
        'BPJS: peserta BPJS Kesehatan aktif.',
      ],
      onCancel: () => _bukaBooking('2'),
      onConfirm: () => _bukaBooking('1'),
    );
  }

  void _bukaBooking(String jenis) {
    pushBackSwipePage(
      context: context,
      page: BlocProvider(
        create: (_) => BookingBloc(),
        child: BookingPage(jenis: jenis),
      ),
    );
  }

  void _pilihLayanan({required bool bpjs}) {
    HapticFeedback.mediumImpact();
    final title = bpjs ? 'Cek-in BPJS' : 'Cek-in Umum';
    final message = bpjs
        ? 'Gunakan layanan ini jika Anda sudah memiliki nomor booking dan terdaftar sebagai peserta BPJS Kesehatan.'
        : 'Gunakan layanan ini jika Anda sudah memiliki nomor booking dan merupakan pasien umum (non-BPJS).';

    ConfirmationDialog.show(
      context,
      title: title,
      message: message,
      icon: bpjs ? Icons.health_and_safety_rounded : Icons.people_alt_rounded,
      color: bpjs ? AppColors.bpjs : AppColors.umum,
      confirmLabel: 'LANJUT',
      cancelLabel: 'BATAL',
      onCancel: () {},
      onConfirm: () {
        pushBackSwipePage(
          context: context,
          page: BlocProvider(
            create: (_) => AntrianApmBloc(),
            child: bpjs
                ? const CekinBpjs(selectType: 'bpjs')
                : const CekinUmumPage(selectType: 'umum'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final pad = isWide ? AppSpacing.lg : AppSpacing.md;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  pad,
                  AppSpacing.md,
                  pad,
                  AppSpacing.md,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isWide ? 1200 : 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBrand(isWide: isWide),
                        const SizedBox(height: AppSpacing.md),
                        _buildGreeting(),
                        const SizedBox(height: AppSpacing.md),
                        Expanded(child: _buildServiceGrid(isWide: isWide)),
                        const SizedBox(height: AppSpacing.md),
                        if (isWide)
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(flex: 3, child: _buildStepsCard()),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(flex: 2, child: _buildHelpCard()),
                              ],
                            ),
                          )
                        else
                          _buildHelpChips(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _fadeIn(Widget child, int index) {
    final animation = CurvedAnimation(
      parent: _enterController,
      curve: Interval(
        (index * 0.12).clamp(0.0, 0.7),
        ((index * 0.12) + 0.5).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  Widget _buildBrand({required bool isWide}) {
    return _fadeIn(
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: isWide ? AppSpacing.lg : AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: AppGradients.brand,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadow.glow(AppColors.primary),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -50,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  'RSU SAKINA IDAMAN',
                  textAlign: TextAlign.center,
                  style: AppText.headerTitle(
                    context,
                  ).copyWith(fontSize: isWide ? 30 : 24),
                ),
                const SizedBox(height: 4),
                Text(
                  'Peduli Sesama, Sakina Pilihanku',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppText.family,
                    fontSize: isWide ? 16 : 13.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.touch_app_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'ANJUNGAN PENDAFTARAN MANDIRI',
                          style: const TextStyle(
                            fontFamily: AppText.family,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      0,
    );
  }

  Widget _buildGreeting() {
    return _fadeIn(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.touch_app_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Silakan pilih layanan di bawah untuk memulai',
              textAlign: TextAlign.center,
              style: AppText.body(context),
            ),
          ),
        ],
      ),
      1,
    );
  }

  Widget _buildServiceGrid({required bool isWide}) {
    final cards = [
      _ServiceConfig(
        title: 'Cek-in BPJS',
        subtitle: 'Peserta BPJS Kesehatan',
        image: 'assets/images/bpjs_logo.png',
        icon: Icons.health_and_safety_rounded,
        gradient: AppGradients.bpjs,
        color: AppColors.bpjs,
        steps: 'Pindai kartu BPJS / NIK',
        onTap: () => _pilihLayanan(bpjs: true),
      ),
      _ServiceConfig(
        title: 'Cek-in Umum',
        subtitle: 'Pasien umum / non-BPJS',
        image: 'assets/images/umum.png',
        icon: Icons.people_alt_rounded,
        gradient: AppGradients.umum,
        color: AppColors.umum,
        steps: 'Pindai kartu / NIK / No RM',
        onTap: () => _pilihLayanan(bpjs: false),
      ),
      // _ServiceConfig(
      //   title: 'Booking Online',
      //   subtitle: 'Daftarpoli tanpa datang',
      //   image: 'assets/images/booking.png',
      //   icon: Icons.event_available_rounded,
      //   gradient: AppGradients.brand,
      //   color: AppColors.primary,
      //   steps: 'Pilih poli, dokter, dan tanggal',
      //   onTap: _pilihBooking,
      // ),
    ];

    return _fadeIn(
      LayoutBuilder(
        builder: (context, constraints) {
          const gap = AppSpacing.md;
          final columns = constraints.maxWidth >= 1000
              ? 3
              : constraints.maxWidth >= 620
              ? 2
              : 1;

          final rows = <List<_ServiceConfig>>[];
          for (var i = 0; i < cards.length; i += columns) {
            rows.add(cards.sublist(i, (i + columns).clamp(0, cards.length)));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var r = 0; r < rows.length; r++) ...[
                if (r > 0) const SizedBox(height: gap),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var c = 0; c < rows[r].length; c++) ...[
                        if (c > 0) const SizedBox(width: gap),
                        Expanded(
                          child: _ServiceCard(config: rows[r][c], fill: true),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
      2,
    );
  }

  Widget _buildStepsCard() {
    return _fadeIn(
      AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSectionLabel(
              text: 'Cara Penggunaan',
              icon: Icons.help_outline_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            const _StepRow(
              number: '1',
              title: 'Pilih layanan',
              description: 'Cek-in BPJS atau  cek-in umum,',
            ),
            const _StepRow(
              number: '2',
              title: 'Pindai / ketik nomor',
              description: 'Pindai barcode kartu, NIK, atau No RM.',
            ),
            const _StepRow(
              number: '3',
              title: 'Verifikasi data',
              description: 'Ikuti petunjuk poli atau loket dari petugas.',
              isLast: true,
            ),
          ],
        ),
      ),
      3,
    );
  }

  Widget _buildHelpCard() {
    return _fadeIn(
      AppNotice(
        title: 'Jam operasional 24 jam',
        message:
            'Layanan UGD tersedia 24 jam. Untuk informasi lain hubungi petugas front office.',
        icon: Icons.support_agent_rounded,
        color: AppColors.warning,
        background: AppColors.warningSoft,
        points: const [
          'Booking dulu sebelum datang.',
          'Simpan bukti booking / kode antrean.',
        ],
      ),
      4,
    );
  }

  Widget _buildHelpChips() {
    const tips = [
      (Icons.schedule_rounded, '24 jam'),
      (Icons.event_available_rounded, 'Booking dulu'),
      (Icons.support_agent_rounded, 'Bantuan front office'),
    ];

    return _fadeIn(
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        alignment: WrapAlignment.center,
        children: [
          for (final tip in tips)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warningSoft,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tip.$1, size: 13, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Text(
                    tip.$2,
                    style: const TextStyle(
                      fontFamily: AppText.family,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      4,
    );
  }
}

class _ServiceConfig {
  const _ServiceConfig({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.icon,
    required this.gradient,
    required this.color,
    required this.steps,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String image;
  final IconData icon;
  final Gradient gradient;
  final Color color;
  final String steps;
  final VoidCallback onTap;
}

class _ServiceCard extends StatefulWidget {
  const _ServiceCard({required this.config, this.fill = false});

  final _ServiceConfig config;
  final bool fill;

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    return Semantics(
      button: true,
      label: '${config.title}. ${config.subtitle}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
          scale: _hovered ? 1.015 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: InkWell(
              onTap: config.onTap,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: config.gradient,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: AppShadow.glow(config.color),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -18,
                      top: -18,
                      child: Icon(
                        config.icon,
                        size: 150,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final height = constraints.maxHeight;
                          final tiny = height < 190;
                          final horizontal = constraints.maxWidth >= 280;
                          final logoSize = tiny
                              ? 52.0
                              : horizontal
                              ? 72.0
                              : 60.0;

                          final info = Column(
                            crossAxisAlignment: horizontal
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                config.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: horizontal
                                    ? TextAlign.start
                                    : TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppText.family,
                                  fontSize: tiny
                                      ? 19
                                      : horizontal
                                      ? 23
                                      : 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                config.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: horizontal
                                    ? TextAlign.start
                                    : TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppText.family,
                                  fontSize: tiny ? 12 : 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.92),
                                ),
                              ),
                              SizedBox(height: tiny ? 6 : AppSpacing.sm),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: tiny ? 5 : 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.qr_code_scanner_rounded,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        config.steps,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: AppText.family,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );

                          final action = Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: tiny ? 8 : 11,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'MULAI',
                                  style: TextStyle(
                                    fontFamily: AppText.family,
                                    fontSize: tiny ? 13 : 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: config.color,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: tiny ? 16 : 18,
                                  color: config.color,
                                ),
                              ],
                            ),
                          );

                          if (horizontal) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _LogoBadge(
                                  image: config.image,
                                  icon: config.icon,
                                  size: logoSize,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Center(
                                    child: widget.fill
                                        ? SingleChildScrollView(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            child: info,
                                          )
                                        : info,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                action,
                              ],
                            );
                          }

                          return Column(
                            mainAxisSize: widget.fill
                                ? MainAxisSize.max
                                : MainAxisSize.min,
                            children: [
                              _LogoBadge(
                                image: config.image,
                                icon: config.icon,
                                size: logoSize,
                              ),
                              SizedBox(height: tiny ? 6 : AppSpacing.md),
                              if (widget.fill)
                                Expanded(child: Center(child: info))
                              else
                                info,
                              SizedBox(height: tiny ? 6 : AppSpacing.md),
                              action,
                            ],
                          );
                        },
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

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({
    required this.image,
    required this.icon,
    required this.size,
  });

  final String image;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: ClipOval(
        child: Image.asset(
          image,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Icon(icon, size: size * 0.5),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  final String number;
  final String title;
  final String description;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: AppGradients.brand,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    fontFamily: AppText.family,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppText.family,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: AppText.family,
                      fontSize: 13.5,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
