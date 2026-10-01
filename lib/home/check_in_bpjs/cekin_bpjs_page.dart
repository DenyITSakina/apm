import 'package:apm/blog/antrian_apm_bloc.dart';
import 'package:apm/dialog/top_toast.dart';
import 'package:apm/func/navigation_helpers.dart';
import 'package:apm/home/check_in_bpjs/cekin_bpjs_data.dart';
import 'package:apm/models/apm_antrian_model.dart';
import 'package:apm/theme/app_tokens.dart';
import 'package:apm/theme/app_typography.dart';
import 'package:apm/widget/app_page_chrome.dart';
import 'package:apm/widget/number_entry_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CekinBpjs extends StatefulWidget {
  final String selectType;

  const CekinBpjs({super.key, required this.selectType});

  @override
  State<CekinBpjs> createState() => _CekinBpjsState();
}

class _CekinBpjsState extends State<CekinBpjs> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _onNumberPressed(String value) {
    final current = controller.text;
    if (current.length >= 16) {
      HapticFeedback.heavyImpact();
      return;
    }
    setState(() {
      controller.text = current + value;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    });
  }

  void _onBackspacePressed() {
    final current = controller.text;
    if (current.isEmpty) return;
    setState(() {
      controller.text = current.substring(0, current.length - 1);
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    });
  }

  void _onClearPressed() => setState(() => controller.clear());

  Future<void> _refocusScanner() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    FocusScope.of(context).requestFocus(focusNode);
  }

  void _submitData() {
    if (isProcessing) return;

    final nomor = controller.text.trim();
    if (nomor.isEmpty) {
      HapticFeedback.heavyImpact();
      TopToast.warning(
        context,
        'Silakan masukkan nomor BPJS, NIK, atau No Booking terlebih dahulu.',
      );
      _refocusScanner();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => isProcessing = true);
    context.read<AntrianApmBloc>().add(
      ValidateAntrianEvent(
        noAntrian: nomor,
        jenisAntrian: widget.selectType.toLowerCase(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              const AppPageHeader(
                title: 'CEK-IN BPJS',
                subtitle: 'Pindai kartu BPJS, NIK, atau nomor rekam medis',
                badge: 'Layanan BPJS Kesehatan',
                badgeIcon: Icons.health_and_safety_rounded,
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
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: BlocConsumer<AntrianApmBloc, AntrianApmState>(
                        listenWhen: (previous, current) =>
                            current is AntrianApmError ||
                            current is AntrianApmValidated ||
                            current is AntrianApmBlocked,
                        listener: _handleState,
                        builder: (context, state) {
                          final loading =
                              state is AntrianApmLoading || isProcessing;

                          return NumberEntryBoard(
                            controller: controller,
                            focusNode: focusNode,
                            label: 'NOMOR KARTU BPJS / NIK / NO REKAM MEDIS',
                            accent: AppColors.bpjs,
                            maxLength: 16,
                            onDigit: _onNumberPressed,
                            onBackspace: _onBackspacePressed,
                            onClear: _onClearPressed,
                            onSubmit: _submitData,
                            submitLabel: 'CEK BPJS',
                            submitIcon: Icons.verified_rounded,
                            submitCaption: 'Kirim data ke server',
                            submitGradient: AppGradients.bpjs,
                            submitLoading: loading,
                            submitEnabled: controller.text.isNotEmpty,
                            belowKeypad: const _BpjsGuide(),
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
  }

  void _handleState(BuildContext context, AntrianApmState state) {
    if (!mounted) return;
    setState(() => isProcessing = false);

    if (state is AntrianApmError) {
      TopToast.error(context, state.pesan);
      _refocusScanner();
      return;
    }

    if (state is AntrianApmBlocked) {
      TopToast.warning(context, state.message);
      _refocusScanner();
      return;
    }

    if (state is AntrianApmValidated) {
      _handleValidated(context, state);
    }
  }

  void _handleValidated(BuildContext context, AntrianApmValidated state) {
    final tanggalBooking = state.apmData.tglBooking.trim();
    if (tanggalBooking.isNotEmpty) {
      TopToast.warning(
        context,
        'Tanggal booking Anda $tanggalBooking. Silakan lanjutkan check-in.',
      );
    }

    final rawNoPeserta = state.apmData.noPeserta.trim();
    final noPeserta = rawNoPeserta.replaceAll(RegExp(r'\D'), '');

    if (rawNoPeserta.isEmpty) {
      TopToast.error(
        context,
        'Nomor peserta BPJS tidak ditemukan. Silakan menuju Front Office '
        'untuk registrasi/check-in.',
      );
      _refocusScanner();
      return;
    }

    if (noPeserta.length != 13) {
      TopToast.error(
        context,
        noPeserta.isEmpty
            ? 'Nomor peserta BPJS tidak valid'
            : 'Nomor BPJS harus 13 digit',
      );
      _refocusScanner();
      return;
    }

    setState(() => controller.clear());

    final data = ApmAntrianModel(
      rm: state.apmData.rm,
      pasien: state.apmData.pasien,
      alamatDomisili: state.apmData.alamatDomisili,
      tglLahir: state.apmData.tglLahir,
      noPeserta: noPeserta,
      noIdentitas: state.apmData.noIdentitas,
      namaPoli: state.apmData.namaPoli,
      noBooking: state.apmData.noBooking,
      namaDokter: state.apmData.namaDokter,
      poli: state.apmData.poli,
      noAntrian: state.apmData.noAntrian,
      tglBooking: state.apmData.tglBooking,
      jamPraktik: state.apmData.jamPraktik,
      statusBooking: state.apmData.statusBooking,
      pasienBaru: state.apmData.pasienBaru,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      pushPage(
        context: context,
        page: BlocProvider.value(
          value: context.read<AntrianApmBloc>(),
          child: CekinBpjsDataPage(
            noBpjs: noPeserta,
            data: data,
            jenisPasien: widget.selectType,
          ),
        ),
      );
    });
  }
}

class _BpjsGuide extends StatelessWidget {
  const _BpjsGuide();

  @override
  Widget build(BuildContext context) {
    const tips = [
      (Icons.badge_outlined, '13 digit'),
      (Icons.event_available_outlined, 'Sudah booking'),
      (Icons.backspace_outlined, 'Tombol C hapus'),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        for (final tip in tips)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.infoSoft,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.bpjs.withValues(alpha: 0.22)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tip.$1, size: 13, color: AppColors.bpjs),
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
    );
  }
}
