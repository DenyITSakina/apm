import 'package:apm/models/dokter_model.dart';
import 'package:apm/theme/app_tokens.dart';
import 'package:apm/widget/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Kartu pilihan dokter yang dipakai bersama oleh halaman booking BPJS dan
/// Umum supaya status (libur/penuh/dipilih) konsisten di kedua layanan.
class DoctorOptionCard extends StatelessWidget {
  const DoctorOptionCard({
    super.key,
    required this.dokter,
    required this.isSelected,
    required this.onTap,
    this.accent = AppColors.primary,
  });

  final DokterModel dokter;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isLibur = dokter.isLibur;
    final kuota = dokter.sisaKoutaKapasitaspasien ?? 0;
    final hasKuota = dokter.terpakaiKapasitaspasien != null;
    final isAvailable = !isLibur && (!hasKuota || kuota > 0);
    final enabled = onTap != null && isAvailable;

    final (statusColor, statusBg, statusIcon, statusLabel) = isLibur
        ? (
            AppColors.danger,
            AppColors.dangerSoft,
            Icons.event_busy_rounded,
            'LIBUR',
          )
        : !isAvailable
        ? (
            AppColors.warning,
            AppColors.warningSoft,
            Icons.warning_amber_rounded,
            'PENUH',
          )
        : isSelected
        ? (
            AppColors.success,
            AppColors.successSoft,
            Icons.check_circle_rounded,
            'DIPILIH',
          )
        : (
            accent,
            accent.withValues(alpha: 0.08),
            Icons.check_circle_outline_rounded,
            'TERSEDIA',
          );

    return Semantics(
      button: enabled,
      selected: isSelected,
      label: '${dokter.namaDokter}, ${dokter.jadwalLengkap}, $statusLabel',
      child: AppCard(
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onTap?.call();
              }
            : null,
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: AppRadius.md,
        border: Border.all(
          color: isSelected ? AppColors.success : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        shadows: isSelected ? AppShadow.soft : const [],
        child: Opacity(
          opacity: isAvailable ? 1 : 0.65,
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: statusBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, size: 22, color: statusColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dokter.namaDokter,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isLibur
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: isLibur
                              ? AppColors.danger
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            dokter.jadwalLengkap,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isLibur
                                  ? AppColors.danger
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (hasKuota) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.groups_rounded,
                            size: 14,
                            color: kuota > 0
                                ? AppColors.info
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Sisa kuota: $kuota',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: kuota > 0
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: kuota > 0
                                  ? AppColors.info
                                  : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppChip(
                label: statusLabel,
                icon: statusIcon,
                color: statusColor,
                background: statusBg,
                filled: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Judul + ringkasan jumlah dokter tersedia.
class DoctorListHeader extends StatelessWidget {
  const DoctorListHeader({
    super.key,
    required this.total,
    required this.tersedia,
  });

  final int total;
  final int tersedia;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          const AppSectionLabel(text: 'Pilih Dokter'),
          const Spacer(),
          AppChip(
            label: '$tersedia/$total tersedia',
            icon: Icons.groups_rounded,
            color: tersedia > 0 ? AppColors.success : AppColors.danger,
            background: tersedia > 0
                ? AppColors.successSoft
                : AppColors.dangerSoft,
            filled: false,
          ),
        ],
      ),
    );
  }
}
