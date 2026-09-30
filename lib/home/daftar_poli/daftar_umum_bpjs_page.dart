import 'package:apm/blog/blog_pendaftran.dart';
import 'package:apm/dialog/top_toast.dart';
import 'package:apm/func/navigation_helpers.dart';
import 'package:apm/home/daftar_poli/daftar_umum_bpjs_daftar.dart';
import 'package:apm/theme/app_tokens.dart';
import 'package:apm/widget/app_card.dart';
import 'package:apm/widget/app_page_chrome.dart';
import 'package:apm/widget/number_entry_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PendaftaranPoliPage extends StatefulWidget {
  final String selectType;

  const PendaftaranPoliPage({super.key, required this.selectType});

  @override
  State<PendaftaranPoliPage> createState() => _PendaftaranPoliPageState();
}

class _PendaftaranPoliPageState extends State<PendaftaranPoliPage> {
  final TextEditingController nomorController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool loading = false;

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
    nomorController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _addDigit(String number) {
    final current = nomorController.text;
    if (current.length >= 16) {
      HapticFeedback.heavyImpact();
      return;
    }
    setState(() {
      nomorController.text = current + number;
      nomorController.selection = TextSelection.fromPosition(
        TextPosition(offset: nomorController.text.length),
      );
    });
  }

  void _removeDigit() {
    final current = nomorController.text;
    if (current.isEmpty) return;
    setState(() {
      nomorController.text = current.substring(0, current.length - 1);
      nomorController.selection = TextSelection.fromPosition(
        TextPosition(offset: nomorController.text.length),
      );
    });
  }

  void _clearText() => setState(() => nomorController.clear());

  Future<void> _refocusScanner() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    FocusScope.of(context).requestFocus(focusNode);
  }

  void _submitData() {
    if (loading) return;

    final nomor = nomorController.text.trim();
    if (nomor.isEmpty) {
      HapticFeedback.heavyImpact();
      TopToast.warning(
        context,
        _isBpjs
            ? 'Silakan masukkan nomor BPJS, NIK, atau No Booking.'
            : 'Silakan masukkan nomor rekam medis terlebih dahulu.',
      );
      _refocusScanner();
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(nomor)) {
      TopToast.warning(context, 'Nomor hanya boleh terdiri dari angka');
      _refocusScanner();
      return;
    }

    if (_isBpjs && nomor.length != 13 && nomor.length != 16) {
      TopToast.warning(
        context,
        'Nomor BPJS harus 13 digit atau NIK 16 digit',
      );
      _refocusScanner();
      return;
    }

    HapticFeedback.mediumImpact();
    context.read<CekinBloc>().add(
      CekNomorEvent(nomor: nomor, jenis: widget.selectType),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<CekinBloc, CekinState>(
          listener: _handleState,
          child: Column(
            children: [
              AppPageHeader(
                title: 'PENDAFTARAN POLI',
                subtitle: 'Verifikasi data pasien sebelum mendaftar poli',
                badge: 'Step 1 dari 3',
                badgeIcon: Icons.qr_code_scanner_rounded,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: NumberEntryBoard(
                        controller: nomorController,
                        focusNode: focusNode,
                        label: _isBpjs
                            ? 'NOMOR KARTU BPJS / NIK / NO BOOKING'
                            : 'NOMOR REKAM MEDIS / NIK / NO BOOKING',
                        accent: _isBpjs ? AppColors.bpjs : AppColors.umum,
                        maxLength: 16,
                        onDigit: _addDigit,
                        onBackspace: _removeDigit,
                        onClear: _clearText,
                        onSubmit: _submitData,
                        submitLabel: 'LANJUT',
                        submitIcon: Icons.arrow_forward_rounded,
                        submitGradient: _isBpjs
                            ? AppGradients.bpjs
                            : AppGradients.umum,
                        submitLoading: loading,
                        submitEnabled: nomorController.text.isNotEmpty,
                        belowKeypad: AppNotice(
                          title: 'Cara pendaftaran poli',
                          message:
                              'Pindai barcode atau masukkan nomor, lalu tekan '
                              'LANJUT untuk verifikasi data pasien.',
                          icon: Icons.assignment_turned_in_outlined,
                          color: AppColors.primary,
                          background: AppColors.primarySoft,
                          points: const [
                            'Nomor BPJS 13 digit atau NIK 16 digit.',
                            'Pastikan Anda sudah memiliki nomor booking.',
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const AppPageFooter(
                message: 'RSU Sakina Idaman - Pendaftaran Poli',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleState(BuildContext context, CekinState state) {
    if (state is CekinLoading) {
      setState(() => loading = true);
      return;
    }

    if (state is CekinSuccess) {
      setState(() {
        loading = false;
        nomorController.clear();
      });

      TopToast.success(context, 'Data pasien ditemukan.');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        pushBackSwipePage(
          context: context,
          page: DaftarUmumBpjsDaftar(data: state.data),
        );
      });
      return;
    }

    if (state is CekinFailed) {
      setState(() => loading = false);
      TopToast.error(
        context,
        'Data pasien tidak ditemukan. Silakan menuju loket.',
      );
      _refocusScanner();
    }
  }
}
