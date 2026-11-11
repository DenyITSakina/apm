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
    pushPage(
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
        pushPage(
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
                                Expanded(child: _buildStepsCard()),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(child: _buildHelpCard()),
                              ],
                            ),
                          )
                        else
                          _buildHelpChips(),
                        const SizedBox(height: AppSpacing.xs),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${AppInfo.appName} ${AppInfo.label}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppText.family,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
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
    final double logoSize = isWide ? 88 : 68;

    return _fadeIn(
      Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 28 : 18,
          vertical: isWide ? 24 : 18,
        ),
        decoration: BoxDecoration(
          gradient: AppGradients.brand,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1,
          ),
          boxShadow: AppShadow.glow(AppColors.primary),
        ),
        child: Stack(
          children: [
            // Ornamen dekoratif
            Positioned(
              right: -45,
              top: -75,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              right: 75,
              bottom: -100,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              left: -55,
              bottom: -85,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),

            // Konten utama
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nama rumah sakit
                      Text(
                        'RSU SAKINA IDAMAN',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.headerTitle(context).copyWith(
                          fontSize: isWide ? 29 : 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: isWide ? 1.3 : 0.7,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 7),

                      // Slogan
                      Text(
                        '#pedulisesama  .  #sakinapilihanku',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppText.family,
                          fontSize: isWide ? 15 : 12,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),

                      SizedBox(height: isWide ? 18 : 13),

                      // Badge anjungan
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 16 : 11,
                          vertical: isWide ? 9 : 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                'ANJUNGAN PENDAFTARAN MANDIRI',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppText.family,
                                  fontSize: isWide ? 11.5 : 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: isWide ? 24 : 12),

                // Logo dengan bingkai transparan
                Container(
                  width: logoSize + 14,
                  height: logoSize + 14,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(child: _BrandLogo(size: logoSize)),
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
        steps: 'Pindai kartu BPJS / NIK / No RM',
        badge: 'JKN',
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
        badge: 'UMUM',
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
      //   badge: 'BOOKING',
      //   onTap: _pilihBooking,
      // ),
    ];

    return _fadeIn(
      LayoutBuilder(
        builder: (context, constraints) {
          const gap = AppSpacing.lg;
          final columns = constraints.maxWidth >= 620 ? 2 : 1;

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
            const SizedBox(height: 6),
            const _StepRow(
              number: '1',
              title: 'Pilih layanan',
              description: 'Pilih Cek-in Umum atau Cek-in BPJS.',
            ),
            const _StepRow(
              number: '2',
              title: 'Pindai / ketik nomor',
              description: 'Pindai kartu, atau masukkan NIK / No. RM.',
            ),
            const _StepRow(
              number: '3',
              title: 'Verifikasi data',
              description: 'Periksa data, lalu ikuti petunjuk petugas.',
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
      AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSectionLabel(
              text: 'Jam Operasional',
              icon: Icons.schedule_rounded,
            ),
            const SizedBox(height: 6),
            const _StepRow(
              number: '24',
              title: 'Layanan 24 Jam',
              description: 'UGD buka 24 jam setiap hari.',
            ),
            const _StepRow(
              number: 'i',
              title: 'Informasi & Bantuan',
              description: 'Info lain: hubungi petugas front office.',
            ),
            const _StepRow(
              number: '•',
              title: 'Persiapan Kunjungan',
              description: 'Booking dahulu dan simpan kode antrean.',
              isLast: true,
            ),
          ],
        ),
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
    this.badge,
  });

  final String title;
  final String subtitle;
  final String image;
  final IconData icon;
  final Gradient gradient;
  final Color color;
  final String steps;
  final VoidCallback onTap;
  final String? badge;
}

class _ServiceCard extends StatefulWidget {
  const _ServiceCard({required this.config, this.fill = false});

  final _ServiceConfig config;
  final bool fill;

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;
  late final AnimationController _shineController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

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
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..translate(0.0, _hovered && !_pressed ? -6.0 : 0.0)
              ..scale(_pressed ? 0.985 : (_hovered ? 1.012 : 1.0)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                ...AppShadow.glow(config.color),
                BoxShadow(
                  color: config.color.withValues(alpha: _hovered ? 0.35 : 0.18),
                  blurRadius: _hovered ? 36 : 20,
                  offset: Offset(0, _hovered ? 18 : 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: InkWell(
                onTap: config.onTap,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                splashColor: Colors.white.withValues(alpha: 0.12),
                highlightColor: Colors.white.withValues(alpha: 0.06),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: config.gradient,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color:
                          Colors.white.withValues(alpha: _hovered ? 0.42 : 0.2),
                      width: 1.4,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.12),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.06),
                                ],
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -50,
                          top: -55,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.18),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -40,
                          bottom: -60,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.07),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -6,
                          bottom: -24,
                          child: Transform.rotate(
                            angle: -0.12,
                            child: Icon(
                              config.icon,
                              size: 190,
                              color: Colors.white.withValues(alpha: 0.07),
                            ),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _shineController,
                          builder: (context, _) {
                            final t = _shineController.value;
                            return Positioned.fill(
                              child: IgnorePointer(
                                child: Opacity(
                                  opacity: _hovered ? 0.22 : 0.12,
                                  child: FractionalTranslation(
                                    translation: Offset(-1.2 + (t * 2.6), 0),
                                    child: Transform.rotate(
                                      angle: -0.35,
                                      child: Container(
                                        width: 120,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white
                                                  .withValues(alpha: 0.0),
                                              Colors.white
                                                  .withValues(alpha: 0.45),
                                              Colors.white
                                                  .withValues(alpha: 0.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.all(
                            widget.fill ? AppSpacing.xl : AppSpacing.lg,
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final compact = constraints.maxHeight < 220;
                              final wide = constraints.maxWidth >= 360;
                              final logoSize =
                                  compact ? 64.0 : (wide ? 90.0 : 74.0);

                              final badge = config.badge == null
                                  ? const SizedBox.shrink()
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.pill),
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            config.icon,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            config.badge!,
                                            style: const TextStyle(
                                              fontFamily: AppText.family,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.9,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                              final info = Column(
                                crossAxisAlignment: wide
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (config.badge != null) ...[
                                    badge,
                                    SizedBox(height: compact ? 8 : 12),
                                  ],
                                  Text(
                                    config.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: wide
                                        ? TextAlign.start
                                        : TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: AppText.family,
                                      fontSize:
                                          compact ? 23 : (wide ? 30 : 25),
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1.12,
                                      letterSpacing: 0.1,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.18),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    config.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: wide
                                        ? TextAlign.start
                                        : TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: AppText.family,
                                      fontSize: compact ? 13.5 : 15,
                                      fontWeight: FontWeight.w500,
                                      height: 1.35,
                                      color: Colors.white
                                          .withValues(alpha: 0.94),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 12 : 16),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: compact ? 8 : 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white
                                              .withValues(alpha: 0.22),
                                          Colors.white
                                              .withValues(alpha: 0.10),
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.md),
                                      border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.22),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.22),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.qr_code_scanner_rounded,
                                            size: 17,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          child: Text(
                                            config.steps,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: AppText.family,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              height: 1.3,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );

                              final action = AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOut,
                                padding: EdgeInsets.symmetric(
                                  horizontal: compact ? 20 : 24,
                                  vertical: compact ? 11 : 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.14),
                                      blurRadius: _hovered ? 20 : 14,
                                      offset: Offset(0, _hovered ? 10 : 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'MULAI CEK-IN',
                                      style: TextStyle(
                                        fontFamily: AppText.family,
                                        fontSize: compact ? 13.5 : 15,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.6,
                                        color: config.color,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 220),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: config.color
                                            .withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: AnimatedSlide(
                                        duration:
                                            const Duration(milliseconds: 220),
                                        offset: _hovered
                                            ? const Offset(0.18, 0)
                                            : Offset.zero,
                                        child: Icon(
                                          Icons.arrow_forward_rounded,
                                          size: compact ? 18 : 20,
                                          color: config.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (wide) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.14),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white
                                                    .withValues(alpha: 0.22),
                                              ),
                                            ),
                                            child: _LogoBadge(
                                              image: config.image,
                                              icon: config.icon,
                                              size: logoSize - 12,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.lg),
                                          Expanded(
                                            child: widget.fill
                                                ? SingleChildScrollView(
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    child: info,
                                                  )
                                                : info,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                        height: compact ? 12 : AppSpacing.md),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.touch_app_rounded,
                                              size: 16,
                                              color: Colors.white
                                                  .withValues(alpha: 0.8),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Sentuh untuk melanjutkan',
                                              style: TextStyle(
                                                fontFamily: AppText.family,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white
                                                    .withValues(alpha: 0.85),
                                              ),
                                            ),
                                          ],
                                        ),
                                        action,
                                      ],
                                    ),
                                  ],
                                );
                              }

                              return Column(
                                mainAxisSize: widget.fill
                                    ? MainAxisSize.max
                                    : MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.14),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.22),
                                      ),
                                    ),
                                    child: _LogoBadge(
                                      image: config.image,
                                      icon: config.icon,
                                      size: logoSize - 12,
                                    ),
                                  ),
                                  SizedBox(
                                      height: compact ? 10 : AppSpacing.md),
                                  if (widget.fill)
                                    Expanded(
                                      child: SingleChildScrollView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        child: info,
                                      ),
                                    )
                                  else
                                    info,
                                  SizedBox(
                                      height: compact ? 12 : AppSpacing.md),
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
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo_sakina.png',
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Icon(
            Icons.local_hospital_rounded,
            size: size * 0.55,
            color: AppColors.primary,
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
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.45),
            blurRadius: 0,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: ClipOval(
        child: Image.asset(
          image,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Icon(
            icon,
            size: size * 0.5,
            color: AppColors.primary,
          ),
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
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: AppGradients.brand,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    fontFamily: AppText.family,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppText.family,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: AppText.family,
                      fontSize: 13.5,
                      height: 1.4,
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
