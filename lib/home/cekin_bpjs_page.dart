import 'package:apm/dialog/top_toast.dart';
import 'package:apm/home/cekin_bpjs_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Blog/antrian_apm_bloc.dart';
import '../widget/keypad_section.dart';

class CekinBpjs extends StatefulWidget {
  final String selectType;
  const CekinBpjs({super.key, required this.selectType});

  @override
  State<CekinBpjs> createState() => _CekinBpjsState();
}

class _CekinBpjsState extends State<CekinBpjs> {
  final TextEditingController controller = TextEditingController();
  bool _isProcessing = false;
  String? hasil;

  final Color primaryColor = const Color(0xFF0D8AAE);
  final Color secondaryColor = const Color(0xFF0ABF68);
  final Color bgColor = const Color(0xFFF8FAFC);

  void _add(String val) => setState(() => controller.text += val);
  void _remove() {
    if (controller.text.isNotEmpty) {
      setState(
        () => controller.text = controller.text.substring(
          0,
          controller.text.length - 1,
        ),
      );
    }
  }

  void _clear() => setState(() => controller.clear());

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  children: [
                    // const SizedBox(height: 30),
                    // _buildStepIndicator(),
                    const SizedBox(height: 12),
                    _inputDisplay(),
                    const SizedBox(height: 12),
                    _buildKeypadAndAction(),
                    if (hasil != null) _resultInfo(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
          _footer(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 140,
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
                  fontSize: 36,
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
                "Silahkan masukkan No BPJS Anda",
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
                  hasText ? controller.text : "Masukkan nomor...",
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: hasText ? FontWeight.w700 : FontWeight.w500,
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
              onNumberPressed: _add,
              onBackspacePressed: _remove,
              onClearPressed: _clear,
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
        } else if (state is AntrianApmValidated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AntrianApmBloc>(),
                  child: CekinBpjsDataPage(
                    noBpjs: controller.text,
                    data: state.apmData,
                    jenisPasien: widget.selectType,
                  ),
                ),
              ),
            );
          });
        } else if (state is AntrianApmBlocked) {
          TopToast.warning(context, state.message);
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
            onTap: isEnabled
                ? () {
                    setState(() => _isProcessing = true);
                    context.read<AntrianApmBloc>().add(
                      ValidateAntrianEvent(
                        noAntrian: controller.text,
                        jenisAntrian: widget.selectType.toLowerCase(),
                      ),
                    );
                  }
                : () {
                    if (controller.text.isEmpty) {
                      TopToast.error(
                        context,
                        "Silahkan Masukkan Nomor Terlebih Dahulu..",
                      );
                    }
                  },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
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
          // Teks tengah
          Center(
            child: Text(
              "RSU SAKINA IDAMAN • Pelayanan BPJS",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Teks kanan pojok
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
