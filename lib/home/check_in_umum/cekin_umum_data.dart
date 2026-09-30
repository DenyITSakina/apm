import 'package:apm/blog/antrian_apm_bloc.dart';
import 'package:apm/dialog/konfirmasi.dart';
import 'package:apm/dialog/sukses.dart';
import 'package:apm/dialog/top_toast.dart';
import 'package:apm/models/apm_antrian_model.dart';
import 'package:apm/theme/Style/format_tgl.dart';
import 'package:apm/theme/app_tokens.dart';
import 'package:apm/widget/app_button.dart';
import 'package:apm/widget/app_card.dart';
import 'package:apm/widget/app_page_chrome.dart';
import 'package:apm/widget/patient_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CekinUmumDataPage extends StatelessWidget {
  const CekinUmumDataPage({
    super.key,
    required this.noRm,
    required this.data,
    required this.jenisPasien,
  });

  final String noRm;
  final ApmAntrianModel data;
  final String jenisPasien;

  bool get _isBpjs => jenisPasien.toLowerCase() == 'bpjs';

  bool get _isPasienBaru => data.pasienBaru == 1;

  String get _title => _isBpjs ? 'DATA PASIEN BPJS' : 'DATA PASIEN UMUM';

  @override
  Widget build(BuildContext context) {
    if (!data.isValid) {
      return _buildErrorPage(context);
    }

    return BlocConsumer<AntrianApmBloc, AntrianApmState>(
      listenWhen: (previous, current) =>
          current is AntrianApmPrinted ||
          current is AntrianApmPrinting ||
          current is AntrianApmError ||
          current is AntrianApmBlocked,
      listener: _handleState,
      builder: (context, state) {
        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: Column(
                children: [
                  AppPageHeader(
                    title: _title,
                    subtitle: 'Periksa data berikut sebelum melanjutkan',
                    badge: 'Verifikasi Pasien',
                    badgeIcon: Icons.verified_user_rounded,
                    dense: true,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 880;
                              final dense = constraints.maxHeight < 600;

                              final card = _buildPatientCard(
                                columns: isWide ? 2 : 1,
                                dense: dense,
                              );
                              final actions = PatientChoiceActions(
                                isPasienBaru: _isPasienBaru,
                                poliBusy: state is AntrianApmLoading,
                                loketBusy: state is AntrianApmPrinting,
                                onPoli: () => _handlePoli(context),
                                onLoket: () => _handleLoket(context),
                                dense: dense,
                                showNotice: !dense,
                              );

                              if (isWide) {
                                return Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(flex: 3, child: card),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(flex: 2, child: actions),
                                  ],
                                );
                              }

                              return Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: card),
                                  const SizedBox(height: AppSpacing.sm),
                                  actions,
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppPageFooter(
                    message:
                        'RSU Sakina Idaman - Pelayanan ${_isBpjs ? 'BPJS' : 'Umum'}',
                    showClock: false,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientCard({int columns = 1, bool dense = false}) {
    return PatientDataCard(
      data: data,
      title: _title,
      gradient: _isBpjs ? AppGradients.bpjs : AppGradients.umum,
      columns: columns,
      dense: dense,
      status: AppChip(
        label: _isPasienBaru ? 'PASIEN BARU' : 'PASIEN LAMA',
        icon: _isPasienBaru
            ? Icons.person_add_alt_1_rounded
            : Icons.person_rounded,
        color: Colors.white,
        background: Colors.white24,
      ),
      sections: [
        PatientDataSection(
          title: 'Identitas',
          icon: Icons.badge_outlined,
          rows: [
            AppDataRow(
              icon: Icons.person_rounded,
              label: 'Nama Pasien',
              value: data.pasien,
              emphasized: true,
              dense: dense,
            ),
            AppDataRow(
              icon: Icons.cake_rounded,
              label: 'Tanggal Lahir',
              value: formatTglBlnTahun(data.tglLahir),
              dense: dense,
            ),
            AppDataRow(
              icon: Icons.home_rounded,
              label: 'Alamat',
              value: data.alamatDomisili,
              dense: dense,
            ),
            AppDataRow(
              icon: Icons.groups_rounded,
              label: 'Jenis Pasien',
              value: _isBpjs ? 'BPJS' : 'UMUM',
              dense: dense,
            ),
          ],
        ),
        PatientDataSection(
          title: 'Pendaftaran',
          icon: Icons.confirmation_number_outlined,
          rows: [
            AppDataRow(
              icon: Icons.confirmation_number_rounded,
              label: 'Nomor RM',
              value: noRm.isNotEmpty ? noRm : data.rm,
              dense: dense,
            ),
            AppDataRow(
              icon: Icons.book_online_rounded,
              label: 'No. Booking',
              value: data.noBooking,
              dense: dense,
            ),
            if (_isBpjs)
              AppDataRow(
                icon: Icons.badge_rounded,
                label: 'No. BPJS',
                value: data.noPeserta,
                emphasized: true,
                dense: dense,
              ),
            AppDataRow(
              icon: Icons.info_outline_rounded,
              label: 'Status',
              value: data.statusText,
              dense: dense,
            ),
          ],
        ),
        PatientDataSection(
          title: 'Kunjungan',
          icon: Icons.local_hospital_outlined,
          rows: [
            AppDataRow(
              icon: Icons.local_hospital_rounded,
              label: 'Poli',
              value: data.poli.isNotEmpty ? data.poli : data.namaPoli,
              dense: dense,
            ),
            AppDataRow(
              icon: Icons.medical_services_rounded,
              label: 'Nama Dokter',
              value: data.namaDokter,
              dense: dense,
            ),
            AppDataRow(
              icon: Icons.schedule_rounded,
              label: 'Jam Praktik',
              value: data.jamPraktik,
              dense: dense,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorPage(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppPageHeader(
                title: _title,
                onBack: () => Navigator.maybePop(context),
                dense: true,
              ),
              Expanded(
                child: AppEmptyState(
                  title: 'Data pasien tidak ditemukan',
                  message:
                      'Silakan periksa kembali nomor rekam medis, NIK, atau No '
                      'Booking yang Anda masukkan.',
                  icon: Icons.person_off_rounded,
                  action: AppGradientButton(
                    label: 'KEMBALI',
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.maybePop(context),
                    height: 56,
                  ),
                ),
              ),
              const AppPageFooter(showClock: false),
            ],
          ),
        ),
      ),
    );
  }

  void _handleState(BuildContext context, AntrianApmState state) {
    if (state is AntrianApmPrinted || state is AntrianApmPrinting) {
      final message = state is AntrianApmPrinted
          ? 'Sukses: ${state.message}'
          : 'Check-in berhasil, silakan lanjutkan.';
      showSuccessDialog(context, message);
      return;
    }

    if (state is AntrianApmError) {
      TopToast.error(context, state.pesan);
      return;
    }

    if (state is AntrianApmBlocked) {
      TopToast.warning(context, state.message);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (context.mounted) Navigator.pop(context);
      });
    }
  }

  void _handlePoli(BuildContext context) {
    HapticFeedback.mediumImpact();
    ConfirmationDialog.show(
      context,
      title: 'Menuju Poli',
      message: 'Anda yakin ingin melanjutkan ke pelayanan Poli?',
      icon: Icons.local_hospital_rounded,
      color: AppColors.accentDark,
      onConfirm: () {
        if (!context.mounted) return;
        context.read<AntrianApmBloc>().add(
          LanjutKePoliEvent(
            noRm: data.rm,
            jenisAntrian: jenisPasien.toLowerCase(),
          ),
        );
      },
    );
  }

  void _handleLoket(BuildContext context) {
    HapticFeedback.mediumImpact();
    ConfirmationDialog.show(
      context,
      title: 'Menuju Loket',
      message: 'Anda yakin ingin melanjutkan ke pelayanan Loket?',
      icon: Icons.account_balance_wallet_rounded,
      color: _isBpjs ? AppColors.bpjs : AppColors.umum,
      points: const [
        'Simpan nomor antrean Anda.',
        'Tunjukkan ke petugas Front Office.',
      ],
      onConfirm: () {
        if (!context.mounted) return;
        context.read<AntrianApmBloc>().add(
          LanjutKeLoketEvent(
            apmData: data,
            jenisAntrian: jenisPasien.toLowerCase(),
            noBooking: data.noBooking,
          ),
        );
      },
    );
  }
}
