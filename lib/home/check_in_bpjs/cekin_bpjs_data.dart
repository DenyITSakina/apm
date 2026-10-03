import 'package:apm/blog/antrian_apm_bloc.dart';
import 'package:apm/dialog/konfirmasi.dart';
import 'package:apm/dialog/sukses.dart';
import 'package:apm/dialog/top_toast.dart';
import 'package:apm/func/navigation_helpers.dart';
import 'package:apm/func/open_aplikasi_bpjsDaftar.dart';
import 'package:apm/models/apm_antrian_model.dart';
import 'package:apm/theme/Style/format_tgl.dart';
import 'package:apm/theme/app_tokens.dart';
import 'package:apm/theme/format_text.dart';
import 'package:apm/widget/app_card.dart';
import 'package:apm/widget/app_page_chrome.dart';
import 'package:apm/widget/patient_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CekinBpjsDataPage extends StatefulWidget {
  const CekinBpjsDataPage({
    super.key,
    required this.noBpjs,
    required this.data,
    required this.jenisPasien,
  });

  final String noBpjs;
  final ApmAntrianModel data;
  final String jenisPasien;

  /// Samarkan nomor peserta tanpa pernah melempar RangeError.
  static String maskNomor(String? nomor) {
    final value = (nomor ?? "").trim();
    if (value.length < 8) {
      return value.isEmpty ? "-" : value;
    }
    return "${value.substring(0, 4)}...${value.substring(value.length - 4)}";
  }

  /// Kembali ke halaman utama (dashboard) dan membersihkan stack.
  static void kembaliKeHome(BuildContext context) {
    popToRoot(context);
  }

  @override
  State<CekinBpjsDataPage> createState() => _CekinBpjsDataPageState();
}

class _CekinBpjsDataPageState extends State<CekinBpjsDataPage> {
  bool sedangProses = false;

  ApmAntrianModel get data => widget.data;

  bool get isPasienBaru => data.pasienBaru == 1;

  /// Peserta BPJS tanpa rujukan tidak bisa mendapat SEP, jadi tombol
  /// LANJUT KE POLI dinonaktifkan sampai syarat terpenuhi.
  bool get lanjutKePoliBisa => data.bpjsSiapSep;

  @override
  Widget build(BuildContext context) {
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
                  const AppPageHeader(
                    title: 'DATA PASIEN BPJS',
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
                                isPasienBaru: isPasienBaru,
                                poliBusy: state is AntrianApmLoading,
                                loketBusy: state is AntrianApmPrinting,
                                poliEnabled: lanjutKePoliBisa,
                                onPoli: _handlePoli,
                                onLoket: _handleLoket,
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  const AppPageFooter(
                    message: 'RSU Sakina Idaman - Pelayanan BPJS',
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
      title: 'DATA PASIEN BPJS',
      gradient: AppGradients.bpjs,
      columns: columns,
      dense: dense,
      status: AppChip(
        label: isPasienBaru ? 'PASIEN BARU' : 'PASIEN LAMA',
        icon: isPasienBaru
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
              value: formatNama(data.pasien),
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
              icon: Icons.fingerprint_rounded,
              label: 'No. NIK',
              value: data.noIdentitas,
              dense: dense,
            ),
            AppDataRow(
              icon: Icons.home_rounded,
              label: 'Alamat',
              value: formatNama(data.alamatDomisili),
              dense: dense,
            ),
          ],
        ),
        PatientDataSection(
          title: 'Pendaftaran',
          icon: Icons.confirmation_number_outlined,
          rows: [
            AppDataRow(
              icon: Icons.badge_rounded,
              label: 'No. BPJS',
              value: data.noPeserta,
              emphasized: true,
              dense: dense,
            ),
            AppDataRow(
              icon: Icons.confirmation_number_rounded,
              label: 'Nomor RM',
              value: data.rm,
              dense: dense,
            ),
            AppDataRow(
              icon: Icons.book_online_rounded,
              label: 'No. Booking',
              value: data.noBooking,
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
              label: 'Nama Poli',
              value: data.namaPoli.isNotEmpty ? data.namaPoli : data.poli,
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
        if (data.punyaDataBpjs) ...[
          PatientDataSection(
            title: 'Status BPJS',
            icon: Icons.health_and_safety_outlined,
            rows: [
              AppDataRow(
                icon: Icons.verified_user_rounded,
                label: 'Status Peserta',
                value: data.bpjsStatusText,
                emphasized: true,
                dense: dense,
              ),
              AppDataRow(
                icon: Icons.badge_rounded,
                label: 'No. Kartu',
                value: data.bpjsNoKartu.isNotEmpty
                    ? data.bpjsNoKartu
                    : data.noPeserta,
                dense: dense,
              ),
              AppDataRow(
                icon: Icons.workspace_premium_rounded,
                label: 'Hak Kelas',
                value: data.bpjsHakKelas,
                dense: dense,
              ),
              AppDataRow(
                icon: Icons.groups_rounded,
                label: 'Jenis Peserta',
                value: data.bpjsJenisPeserta,
                dense: dense,
              ),
            ],
          ),
          PatientDataSection(
            title: 'Rujukan',
            icon: Icons.assignment_rounded,
            rows: [
              AppDataRow(
                icon: Icons.medical_information_rounded,
                label: 'Diagnosa',
                value: data.rujukanKode.isNotEmpty
                    ? '${data.rujukanKode} - ${data.rujukanNama}'
                    : 'Tidak ada rujukan',
                emphasized: true,
                dense: dense,
              ),
              AppDataRow(
                icon: Icons.local_hospital_outlined,
                label: 'Faskes Perujuk',
                value: data.rujukanFaskesNama,
                dense: dense,
              ),
              AppDataRow(
                icon: Icons.confirmation_number_rounded,
                label: 'No. Kunjungan',
                value: data.rujukanNoKunjungan,
                dense: dense,
              ),
              AppDataRow(
                icon: Icons.event_rounded,
                label: 'Tgl Kunjungan',
                value: data.rujukanTglKunjungan,
                dense: dense,
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _handleState(BuildContext context, AntrianApmState state) {
    if (!mounted) return;

    if (state is AntrianApmPrinted || state is AntrianApmPrinting) {
      sedangProses = false;

      if (state is AntrianApmPrinting) {
        showSuccessDialog(context, 'Check-in berhasil, silakan lanjutkan.');
        return;
      }

      final printed = state as AntrianApmPrinted;
      final poli = printed.poliData;

      if (poli != null && poli.sepSuccess && poli.noSep.isNotEmpty) {
        showSuccessDialog(
          context,
          'SEP berhasil dibuat.\nNomor SEP: ${poli.noSep}\n'
          'Poli: ${poli.sepPoli.isNotEmpty ? poli.sepPoli : poli.namaPoli}',
          title: 'SEP Berhasil Terbit',
        );
        return;
      }

      if (poli != null && !poli.sepSuccess) {
        showSuccessDialog(
          context,
          'Check-in ke poli berhasil, tetapi SEP belum berhasil dibuat.\n'
          'Pesan BPJS: ${poli.sepMessage.isNotEmpty ? poli.sepMessage : 'tidak diketahui'}\n'
          'Mohon laporkan ke petugas loket untuk penerbitan SEP manual.',
        );
        return;
      }

      showSuccessDialog(context, 'Sukses: ${printed.message}');
      return;
    }

    if (state is AntrianApmError) {
      sedangProses = false;
      TopToast.error(context, state.pesan);
      return;
    }

    if (state is AntrianApmBlocked) {
      sedangProses = false;
      TopToast.warning(context, state.message);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  Future<void> _handlePoli() async {
    if (sedangProses) return;

    if (!lanjutKePoliBisa) {
      TopToast.warning(
        context,
        !data.bpjsAktif
            ? 'Peserta BPJS tidak aktif sehingga SEP tidak dapat dibuat.'
            : 'Peserta belum memiliki rujukan BPJS sehingga SEP hanya dapat '
                  'diterbitkan melalui poli IGD. Hubungi petugas loket.',
      );
      return;
    }

    sedangProses = true;

    final nomor = data.noPeserta.trim();
    if (nomor.isEmpty) {
      sedangProses = false;
      TopToast.error(context, 'Nomor peserta BPJS tidak ditemukan.');
      return;
    }
    if (nomor.length != 13) {
      sedangProses = false;
      TopToast.error(context, 'Nomor BPJS harus 13 digit.');
      return;
    }

    final tutupDialog = showSidikJariProgress(context);
    var sukses = false;
    try {
      sukses = await openExeFromMap(context, {
        'nomor': nomor,
      }, tampilkanToast: false);
    } catch (e) {
      debugPrint('Gagal proses sidik jari: $e');
    }
    tutupDialog();

    if (!mounted) return;

    // After.exe yang menutup dirinya sendiri (popup error, versi kadaluarsa,
    // dll) tetap diteruskan ke dialog konfirmasi, tidak dianggap gagal.
    if (sukses != true && !lastSidikJariDitutupOtomatis) {
      sedangProses = false;
      debugPrint('Alasan gagal: $lastSidikJariReason');
      TopToast.error(
        context,
        lastSidikJariReason.isEmpty
            ? 'Sidik jari gagal diproses. Silakan coba lagi.'
            : 'Sidik jari gagal: $lastSidikJariReason',
      );
      return;
    }

    ConfirmationDialog.show(
      context,
      title: 'Menuju Poli',
      message: 'Anda yakin ingin melanjutkan ke pelayanan Poli?',
      icon: Icons.local_hospital_rounded,
      color: AppColors.accentDark,
      onConfirm: () {
        if (!mounted) return;
        HapticFeedback.mediumImpact();
        context.read<AntrianApmBloc>().add(
          LanjutKePoliEvent(
            noRm: data.rm,
            jenisAntrian: widget.jenisPasien.toLowerCase(),
            diagAwal: data.diagAwal,
          ),
        );
      },
      onCancel: () {
        sedangProses = false;
        if (mounted) popToRoot(context);
      },
    );
  }

  void _handleLoket() {
    if (sedangProses) return;
    sedangProses = true;
    HapticFeedback.mediumImpact();

    ConfirmationDialog.show(
      context,
      title: 'Menuju Loket',
      message: 'Anda yakin ingin melanjutkan ke pelayanan Loket?',
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.bpjs,
      points: const [
        'Simpan nomor antrean Anda.',
        'Tunjukkan ke petugas Front Office.',
      ],
      onConfirm: () {
        if (!mounted) return;
        context.read<AntrianApmBloc>().add(
          LanjutKeLoketEvent(
            apmData: data,
            jenisAntrian: widget.jenisPasien.toLowerCase(),
            noBooking: data.noBooking,
          ),
        );
      },
      onCancel: () => sedangProses = false,
    );
  }
}
