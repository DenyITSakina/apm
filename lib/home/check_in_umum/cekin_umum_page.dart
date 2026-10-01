import 'package:apm/blog/antrian_apm_bloc.dart';
import 'package:apm/dialog/top_toast.dart';
import 'package:apm/func/navigation_helpers.dart';
import 'package:apm/home/check_in_umum/cekin_umum_data.dart';
import 'package:apm/theme/app_tokens.dart';
import 'package:apm/theme/app_typography.dart';
import 'package:apm/widget/app_page_chrome.dart';
import 'package:apm/widget/number_entry_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CekinUmumPage extends StatefulWidget {
  final String selectType;

  const CekinUmumPage({super.key, required this.selectType});

  @override
  State<CekinUmumPage> createState() => _CekinUmumPageState();
}

class _CekinUmumPageState extends State<CekinUmumPage> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool isProcessing = false;

  bool get _isBpjs => widget.selectType.toLowerCase() == 'bpjs';

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
        'Silakan masukkan nomor rekam medis, NIK, atau No Booking terlebih dahulu.',
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
              AppPageHeader(
                title: _isBpjs ? 'CEK-IN BPJS' : 'CEK-IN UMUM',
                subtitle:
                    'Pindai kartu, NIK, nomor rekam medis, atau No Booking',
                badge: _isBpjs ? 'Layanan BPJS' : 'Layanan Pasien Umum',
                badgeIcon: _isBpjs
                    ? Icons.health_and_safety_rounded
                    : Icons.people_alt_rounded,
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
                            label: _isBpjs
                                ? 'NOMOR BPJS / NIK / NO REKAM MEDIS / NO BOOKING'
                                : 'NOMOR REKAM MEDIS / NIK / NO BOOKING',
                            accent: _isBpjs ? AppColors.bpjs : AppColors.umum,
                            maxLength: 16,
                            onDigit: _onNumberPressed,
                            onBackspace: _onBackspacePressed,
                            onClear: _onClearPressed,
                            onSubmit: _submitData,
                            submitLabel: 'CARI DATA',
                            submitIcon: Icons.search_rounded,
                            submitCaption: 'Cari data pasien',
                            submitGradient: _isBpjs
                                ? AppGradients.bpjs
                                : AppGradients.umum,
                            submitLoading: loading,
                            submitEnabled: controller.text.isNotEmpty,
                            belowKeypad: _UmumGuide(isBpjs: _isBpjs),
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
        'Tanggal booking Anda $tanggalBooking, silakan lanjutkan check-in.',
      );
    }

    // Nomor harus disimpan sebelum controller dikosongkan.
    final nomor = controller.text.trim();
    setState(() => controller.clear());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      pushPage(
        context: context,
        page: BlocProvider.value(
          value: context.read<AntrianApmBloc>(),
          child: CekinUmumDataPage(
            noRm: nomor,
            data: state.apmData,
            jenisPasien: widget.selectType,
          ),
        ),
      );
    });
  }
}

class _UmumGuide extends StatelessWidget {
  const _UmumGuide({required this.isBpjs});

  final bool isBpjs;

  @override
  Widget build(BuildContext context) {
    final color = isBpjs ? AppColors.bpjs : AppColors.umum;
    final background = isBpjs ? AppColors.infoSoft : AppColors.accentSoft;
    final tips = <(IconData, String)>[
      (Icons.event_available_rounded, 'Sudah booking'),
      (Icons.badge_outlined, 'Bawa kartu / NIK'),
      (Icons.backspace_rounded, 'Tombol C hapus'),
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
              color: background,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tip.$1, size: 13, color: color),
                const SizedBox(width: 6),
                Text(
                  tip.$2,
                  style: TextStyle(
                    fontFamily: AppText.family,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
