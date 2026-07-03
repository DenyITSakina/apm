import 'package:apm/dialog/top_toast.dart';
import 'package:apm/home/check_in_bpjs/cekin_bpjs_data.dart';
import 'package:apm/func/navigation_helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../Blog/antrian_apm_bloc.dart';
import '../../widget/keypad_section.dart';
import '../../api/booking_api_service.dart';
import '../../models/apm_antrian_model.dart';

class CekinBpjs extends StatefulWidget {
  final String selectType;
  const CekinBpjs({super.key, required this.selectType});

  @override
  State<CekinBpjs> createState() => _CekinBpjsState();
}

class _CekinBpjsState extends State<CekinBpjs> {
  final TextEditingController controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isProcessing = false;
  String? hasil;

  final Color primaryColor = const Color(0xFF0D8AAE);
  final Color secondaryColor = const Color(0xFF0ABF68);
  final Color bgColor = const Color(0xFFF8FAFC);

  String _formatJamPeriksa(String jamPraktikRaw) {
    final s = jamPraktikRaw.trim();
    if (s.isEmpty) return '-';

    final normalized = s.replaceAll('–', '-').replaceAll('—', '-');
    return normalized;
  }

  bool _isTimeInRange(TimeOfDay now, String jamPraktikRaw) {
    final s = jamPraktikRaw.trim();

    if (s.isEmpty || s.toLowerCase() == 'null') return false;

    final reg = RegExp(
      r'(\d{1,2})(?:[\.:](\d{1,2}))?\s*[-–—]\s*(\d{1,2})(?:[\.:](\d{1,2}))?',
    );
    final match = reg.firstMatch(s);
    if (match == null) {
      final singleReg = RegExp(r'^(\d{1,2})(?:[\.:](\d{1,2}))?$');
      final m2 = singleReg.firstMatch(s);
      if (m2 == null) return true;
      final startH = int.parse(m2.group(1)!);
      final startM = m2.group(2) != null
          ? int.parse(m2.group(2)!.padRight(2, '0'))
          : 0;
      final nowMinutes = now.hour * 60 + now.minute;
      final startMinutes = startH * 60 + startM;
      return nowMinutes >= startMinutes;
    }

    int toHourMinute(int h, String? mStr) {
      final m = (mStr == null || mStr.isEmpty)
          ? 0
          : int.parse(mStr.padRight(2, '0'));
      return h * 60 + m;
    }

    final startH = int.parse(match.group(1)!);
    final startMStr = match.group(2);
    final endH = int.parse(match.group(3)!);
    final endMStr = match.group(4);

    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = toHourMinute(startH, startMStr);
    final endMinutes = toHourMinute(endH, endMStr);

    if (endMinutes >= startMinutes) {
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    }
    return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onNumberPressed(String val) {
    final current = controller.text;
    if (current.length >= 16) return;

    setState(() {
      controller.text = current + val;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    });

    _focusNode.requestFocus();
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

    _focusNode.requestFocus();
  }

  void _onClearPressed() {
    setState(() {
      controller.clear();
      hasil = null;
    });

    _refocusScanner();
  }

  void _refocusScanner() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _submitData() {
    if (controller.text.isEmpty || _isProcessing) {
      if (controller.text.isEmpty) {
        TopToast.error(context, "Silahkan Masukkan Nomor Terlebih Dahulu..");
      }
      return;
    }

    setState(() => _isProcessing = true);
    context.read<AntrianApmBloc>().add(
      ValidateAntrianEvent(
        noAntrian: controller.text,
        jenisAntrian: widget.selectType.toLowerCase(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _inputDisplay(),
                      const SizedBox(height: 12),
                      _buildKeypadAndAction(),
                      if (hasil != null) _resultInfo(),
                      const SizedBox(height: 2),
                      _info(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 125,
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withBlue(150)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(45),
          bottomRight: Radius.circular(45),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/images/logo_sakina.png',
                    height: 42,
                    color: Colors.white,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.local_hospital,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              Text(
                "CHECK-IN BPJS",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Silahkan masukkan No BPJS Anda / atau scan barcode BPJS",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepCircle("1", "Input", true),
        _stepLine(true),
        _stepCircle("2", "Verifikasi", false),
        _stepLine(false),
        _stepCircle("3", "Selesai", false),
      ],
    );
  }

  Widget _stepCircle(String num, String label, bool active) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active ? secondaryColor : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Text(
            num,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: active ? secondaryColor : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool active) => Container(
    width: 30,
    height: 2,
    color: active ? secondaryColor : Colors.grey.shade300,
    margin: const EdgeInsets.only(bottom: 20),
  );

  Widget _inputDisplay() {
    final hasText = controller.text.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hidden TextField untuk scanner
          SizedBox(
            width: 0,
            height: 0,
            child: TextField(
              controller: controller,
              focusNode: _focusNode,
              autofocus: true,
              showCursor: false,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
              cursorColor: Colors.transparent,
              onSubmitted: (value) {
                _submitData();
              },
              // Mencegah keyboard muncul
              enableInteractiveSelection: false,
              enableIMEPersonalizedLearning: false,
            ),
          ),
          Text(
            widget.selectType == "bpjs"
                ? "NOMOR KARTU BPJS / NIK"
                : "NOMOR REKAM MEDIS / KTP",
            style: GoogleFonts.oswald(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade900,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: hasText ? primaryColor : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hasText ? controller.text : "Masukkan nomor / Scan barcode",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: hasText ? Colors.black87 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadAndAction() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: KeypadSection(
              onNumberPressed: _onNumberPressed,
              onBackspacePressed: _onBackspacePressed,
              onClearPressed: _onClearPressed,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(flex: 1, child: _buildSubmitButton()),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocConsumer<AntrianApmBloc, AntrianApmState>(
      listenWhen: (previous, current) =>
          current is AntrianApmError ||
          current is AntrianApmValidated ||
          current is AntrianApmBlocked,
      listener: (context, state) {
        setState(() => _isProcessing = false);

        if (state is AntrianApmError) {
          TopToast.error(context, state.pesan);
          _refocusScanner();
        } else if (state is AntrianApmValidated) {
          final jamPraktikRaw = state.apmData.jamPraktik.trim();
          final jamPeriksaText = _formatJamPeriksa(jamPraktikRaw);

          final now = TimeOfDay.now();
          final canCheck = _isTimeInRange(now, jamPraktikRaw);

          if (!canCheck) {
            TopToast.warning(
              context,
              'Jam periksa anda $jamPeriksaText dan tidak dapat melakukan check-in sekarang.',
            );
            setState(() => _isProcessing = false);
            _refocusScanner();
            return;
          }

          final rawNoPeserta = state.apmData.noPeserta?.trim() ?? '';
          final noPeserta = rawNoPeserta.replaceAll(RegExp(r'\D'), '');
          if (rawNoPeserta.isEmpty) {
            TopToast.error(context, 'Nomor peserta BPJS tidak ditemukan');
            setState(() => _isProcessing = false);
            _refocusScanner();
            return;
          }
          if (noPeserta.isEmpty) {
            TopToast.error(context, 'Nomor peserta BPJS tidak valid');
            setState(() => _isProcessing = false);
            _refocusScanner();
            return;
          }
          if (noPeserta.length != 13) {
            TopToast.error(context, 'Nomor BPJS harus 13 digit');
            setState(() => _isProcessing = false);
            _refocusScanner();
            return;
          }

          setState(() {
            controller.clear();
            hasil = null;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              final resp = await BookingApiService.cekPasienBpjs(noPeserta);
              if (!mounted) return;

              if (resp.status != true) {
                TopToast.error(
                  context,
                  resp.message.isNotEmpty
                      ? resp.message
                      : 'Data BPJS tidak valid',
                );
                setState(() => _isProcessing = false);
                _refocusScanner();
                return;
              }

              final peserta = resp.peserta;
              final apmDataFromBpjs = ApmAntrianModel(
                rm: state.apmData.rm,
                pasien: peserta?.nama ?? '',
                alamatDomisili: peserta?.alamat ?? '',
                tglLahir: peserta?.tglLahir ?? '',
                noPeserta: peserta?.noPeserta ?? noPeserta,
                noIdentitas: peserta?.nik ?? '',
                namaPoli: state.apmData.namaPoli,
                noBooking: state.apmData.noBooking,
                namaDokter: state.apmData.namaDokter,
              );

              pushBackSwipePage(
                context: context,
                page: BlocProvider.value(
                  value: context.read<AntrianApmBloc>(),
                  child: CekinBpjsDataPage(
                    noBpjs: noPeserta,
                    data: apmDataFromBpjs,
                    jenisPasien: widget.selectType,
                  ),
                ),
              );
            } catch (e) {
              if (!mounted) return;
              TopToast.error(context, 'Gagal validasi data BPJS: $e');
              setState(() => _isProcessing = false);
              _refocusScanner();
            }
          });
        } else if (state is AntrianApmBlocked) {
          TopToast.warning(context, state.message);
          _refocusScanner();
        }
      },
      builder: (context, state) {
        final isLoading = state is AntrianApmLoading || _isProcessing;
        final bool isEnabled = controller.text.isNotEmpty && !isLoading;

        return Material(
          color: isEnabled ? secondaryColor : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
          elevation: isEnabled ? 8 : 0,
          child: InkWell(
            onTap: isEnabled ? _submitData : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isLoading
                      ? LoadingAnimationWidget.fourRotatingDots(
                          color: Colors.white,
                          size: 45,
                        )
                      : const Icon(
                          Icons.done_all_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                  const SizedBox(height: 10),
                  Text(
                    "CEK BPJS",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.oswald(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _resultInfo() {
    final sukses = hasil!.contains("✔");
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: sukses ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: sukses ? Colors.green : Colors.red),
        ),
        child: Text(
          hasil!,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: sukses ? Colors.green.shade900 : Colors.red.shade900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _info() {
    final primary = Colors.teal;
    final bg = const Color(0xFFF8FAFC);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.assignment_turned_in_outlined,
              color: primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Check-in BPJS",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Scan barcode atau masukkan nomor BPJS atau menggunakan NIK -> lalu klik cek BPJS",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.2,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "Pasien BPJS",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              "RSU Sakina Idaman • Pelayanan BPJS",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "#pedulisesama | #sakinapilihanku",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.4),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 14,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "v1.1.1",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 14,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "2026",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.4),
                      fontWeight: FontWeight.w300,
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
