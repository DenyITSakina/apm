import 'package:apm/models/apm_antrian_model.dart';
import 'package:apm/theme/app_tokens.dart';
import 'package:apm/theme/app_typography.dart';
import 'package:apm/widget/app_button.dart';
import 'package:apm/widget/app_card.dart';
import 'package:flutter/material.dart';

/// Kartu data pasien dengan header gradien dan baris label:nilai.
class PatientDataCard extends StatelessWidget {
  const PatientDataCard({
    super.key,
    required this.data,
    required this.title,
    this.rows = const [],
    this.sections = const [],
    this.status,
    this.gradient = AppGradients.brand,
    this.columns = 1,
    this.dense = false,
  });

  final ApmAntrianModel data;
  final String title;

  /// Baris data bebas (tanpa pengelompokan).
  final List<Widget> rows;

  /// Baris data yang dikelompokkan per bagian, lebih mudah dipindai.
  final List<PatientDataSection> sections;

  final Widget? status;
  final Gradient gradient;

  /// Jumlah kolom untuk baris data (berguna di layar lebar/kios).
  final int columns;

  /// Versi rapat supaya seluruh kartu muat dalam satu layar.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final groups = sections.isNotEmpty
        ? sections
        : [PatientDataSection(title: null, rows: rows)];

    Widget buildGroup(PatientDataSection group, int offset) {
      final items = group.rows;
      final tiles = <Widget>[];

      for (var i = 0; i < items.length; i++) {
        if (i > 0) SizedBox(height: dense ? 6 : 8);
        tiles.add(_DataTile(index: offset + i, dense: dense, child: items[i]));
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (group.title != null) ...[
            _SectionLabel(title: group.title!, icon: group.icon, dense: dense),
            SizedBox(height: dense ? 6 : AppSpacing.sm),
          ],
          ...tiles,
        ],
      );
    }

    final perColumn = (groups.length / columns).ceil();
    final chunked = <List<PatientDataSection>>[
      for (var i = 0; i < columns; i++)
        groups.skip(i * perColumn).take(perColumn).toList(),
    ];

    final body = Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        dense ? AppSpacing.xs : AppSpacing.md,
        AppSpacing.md,
        dense ? AppSpacing.sm : AppSpacing.md,
      ),
      child: columns == 1
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < groups.length; i++) ...[
                  if (i > 0) SizedBox(height: dense ? 10 : AppSpacing.md),
                  buildGroup(groups[i], i),
                ],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var c = 0; c < chunked.length; c++) ...[
                  if (c > 0) SizedBox(width: dense ? 12 : 20),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < chunked[c].length; i++) ...[
                          if (i > 0)
                            SizedBox(height: dense ? 10 : AppSpacing.md),
                          buildGroup(chunked[c][i], c * perColumn + i),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );

    final header = Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: dense ? AppSpacing.sm : AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              Icons.badge_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppText.family,
                fontSize: dense ? 15 : 16.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: Colors.white,
              ),
            ),
          ),
          if (status != null) ...[const SizedBox(width: 8), status!],
        ],
      ),
    );

    return AppCard(
      borderRadius: AppRadius.lg,
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Tinggi tak terbatas (di dalam scroll view) tetap memakai tinggi
          // natural; bila terbatas, isi_diskecilkan agar tidak overflowing.
          if (!constraints.maxHeight.isFinite) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [header, body],
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: SizedBox(width: constraints.maxWidth, child: body),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Kelompok baris data dengan judul bagian, mis. "Identitas", "Kunjungan".
class PatientDataSection {
  const PatientDataSection({required this.rows, this.title, this.icon});

  final List<Widget> rows;
  final String? title;
  final IconData? icon;
}

/// Label pembatas antar bagian data.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.dense, this.icon});

  final String title;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: dense ? 13 : 14, color: AppColors.primary),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppText.family,
              fontSize: dense ? 10.5 : 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider(height: 1, color: AppColors.border)),
      ],
    );
  }
}

/// Pembungkus baris data dengan latar selang-seling agar mudah dipindai.
class _DataTile extends StatelessWidget {
  const _DataTile({
    required this.index,
    required this.child,
    required this.dense,
  });

  final int index;
  final Widget child;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final shaded = index.isOdd;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpacing.sm : 12,
        vertical: dense ? 0 : 2,
      ),
      decoration: BoxDecoration(
        color: shaded ? AppColors.surfaceMuted : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: child,
    );
  }
}

/// Dua pilihan lanjutan: ke Poli atau ke Loket.
///
/// Hanya satu tombol yang tampil mengikuti status pasien agar layar tidak
/// membingungkan dan tidak ada dua aksi yang bisa tertukar.
class PatientChoiceActions extends StatelessWidget {
  const PatientChoiceActions({
    super.key,
    required this.isPasienBaru,
    required this.onPoli,
    required this.onLoket,
    this.poliBusy = false,
    this.loketBusy = false,
    this.poliTitle = 'LANJUT KE POLI',
    this.loketTitle = 'PINDAH KE LOKET',
    this.poliCaption = 'Konsultasi dokter, tunggu nomor dipanggil di poli',
    this.loketCaption = 'Administrasi dan pendaftaran di Front Office',
    this.dense = false,
    this.showNotice = true,
  });

  final bool isPasienBaru;
  final VoidCallback onPoli;
  final VoidCallback onLoket;
  final bool poliBusy;
  final bool loketBusy;
  final String poliTitle;
  final String loketTitle;
  final String poliCaption;
  final String loketCaption;

  /// Versi rapat supaya blok aksi muat tanpa menggulir.
  final bool dense;

  /// Sembunyikan notice bila layar terlalu pendek.
  final bool showNotice;

  @override
  Widget build(BuildContext context) {
    final keLoket = isPasienBaru;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: EdgeInsets.all(dense ? AppSpacing.sm : AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'LANGKAH SELANJUTNYA',
                    style: TextStyle(
                      fontFamily: AppText.family,
                      fontSize: dense ? 10 : 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                ],
              ),
              SizedBox(height: dense ? AppSpacing.sm : 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (keLoket ? AppColors.warningSoft : AppColors.accentSoft)
                      .withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: (keLoket ? AppColors.warning : AppColors.accentDark)
                        .withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (keLoket ? AppColors.warning : AppColors.accent)
                            .withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        keLoket
                            ? Icons.account_balance_wallet_rounded
                            : Icons.local_hospital_rounded,
                        size: 20,
                        color: keLoket
                            ? AppColors.warning
                            : AppColors.accentDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            keLoket
                                ? 'Pasien Baru - Registrasi Loket'
                                : 'Pasien Lama - Langsung ke Poli',
                            style: TextStyle(
                              fontFamily: AppText.family,
                              fontSize: dense ? 13.5 : 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            keLoket
                                ? 'Tunjukkan kartu BPJS di loket FO untuk '
                                      'pendaftaran awal.'
                                : 'Tunggu nomor antrean dipanggil di layar '
                                      'poliklinik tujuan.',
                            style: const TextStyle(
                              fontFamily: AppText.family,
                              fontSize: 12,
                              height: 1.35,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: dense ? AppSpacing.sm : 12),
              AppGradientButton(
                label: keLoket ? loketTitle : poliTitle,
                icon: keLoket
                    ? Icons.account_balance_wallet_rounded
                    : Icons.arrow_forward_rounded,
                caption: keLoket ? loketCaption : poliCaption,
                onPressed: keLoket ? onLoket : onPoli,
                loading: keLoket ? loketBusy : poliBusy,
                height: dense ? 62 : 78,
                fontSize: dense ? 15.5 : 17,
              ),
            ],
          ),
        ),
        if (showNotice) ...[
          SizedBox(height: dense ? AppSpacing.sm : AppSpacing.md),
          AppNotice(
            title: 'Informasi pelayanan',
            message: keLoket
                ? 'Karena berstatus pasien baru, Anda diarahkan ke loket Front '
                      'Office untuk registrasi awal.'
                : 'Karena berstatus pasien lama, Anda dapat langsung menuju '
                      'poliklinik tujuan.',
            icon: Icons.info_outline_rounded,
            color: keLoket ? AppColors.warning : AppColors.accentDark,
            background: keLoket ? AppColors.warningSoft : AppColors.accentSoft,
            points: const [
              'Simpan nomor antrean atau kode booking Anda.',
              'Tunjukkan ke petugas bila diminta.',
            ],
          ),
        ],
      ],
    );
  }
}
