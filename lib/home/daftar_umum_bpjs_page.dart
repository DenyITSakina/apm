import 'package:apm/home/daftar_umum_bpjs_daftar.dart';
import 'package:apm/widget/keypad_section.dart';
import 'package:apm/dialog/top_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Blog/blog_pendaftran.dart';

class PendaftaranPoliPage extends StatefulWidget {
  final String selectType;

  const PendaftaranPoliPage({super.key, required this.selectType});

  @override
  State<PendaftaranPoliPage> createState() => _PendaftaranPoliPageState();
}

class _PendaftaranPoliPageState extends State<PendaftaranPoliPage> {
  final TextEditingController bpjsController = TextEditingController();
  bool loading = false;
  String? hasil;

  final Color primaryColor = const Color(0xFF0D8AAE);
  final Color secondaryColor = const Color(0xFF0ABF68);
  final Color bgColor = const Color(0xFFF8FAFC);

  void _addDigit(String number) {
    if (bpjsController.text.length < 16) {
      setState(() => bpjsController.text += number);
    }
  }

  void _removeDigit() {
    if (bpjsController.text.isNotEmpty) {
      setState(() {
        bpjsController.text = bpjsController.text.substring(
          0,
          bpjsController.text.length - 1,
        );
      });
    }
  }

  void _clearText() => setState(() => bpjsController.clear());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: BlocListener<CekinBloc, CekinState>(
        listener: (context, state) {
          if (state is CekinLoading) {
            setState(() => loading = true);
          }
          if (state is CekinSuccess) {
            setState(() {
              loading = false;
              hasil = "Data Pasien ditemukan!";
            });

            TopToast.success(context, "Data Pasien ditemukan!");

            Future.delayed(const Duration(milliseconds: 800), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DaftarUmumBpjsDaftar(data: state.data),
                ),
              );
            });
          }
          if (state is CekinFailed) {
            setState(() {
              loading = false;
              hasil = "Data Pasien Tidak Ditemukan. Silahkan Ke Loket.";
            });

            TopToast.error(
              context,
              "Data Pasien Tidak Ditemukan. Silahkan Ke Loket.",
            );
          }
        },
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _inputDisplay(),
                      const SizedBox(height: 12),
                      _bodyKeypadWithButton(),
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
                "PENDAFTARAN POLI",
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
                "Silakan masukkan data pendaftaran Anda",
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

  Widget _inputDisplay() {
    final hasText = bpjsController.text.isNotEmpty;
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
                : "NOMOR REKAM MEDIS (NO RM)",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: hasText ? primaryColor : Colors.transparent,
              ),
            ),
            child: Text(
              hasText ? bpjsController.text : "0000 0000 0000",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: hasText ? Colors.black87 : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyKeypadWithButton() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.45,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: KeypadSection(
              onNumberPressed: _addDigit,
              onBackspacePressed: _removeDigit,
              onClearPressed: _clearText,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(flex: 1, child: _buildSubmitButton()),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bool isEnabled = bpjsController.text.isNotEmpty && !loading;

    return Material(
      color: isEnabled ? secondaryColor : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(20),
      elevation: isEnabled ? 8 : 0,
      shadowColor: secondaryColor.withOpacity(0.5),
      child: InkWell(
        onTap: isEnabled
            ? () {
                final nomor = bpjsController.text.trim();

                if (widget.selectType == "bpjs") {
                  if (nomor.length != 13 && nomor.length != 16) {
                    TopToast.warning(
                      context,
                      "Nomor BPJS harus 13 digit atau NIK 16 digit",
                    );
                    return;
                  }

                  if (!RegExp(r'^[0-9]+$').hasMatch(nomor)) {
                    TopToast.warning(
                      context,
                      "Nomor hanya boleh terdiri dari angka",
                    );
                    return;
                  }
                } else {
                  if (nomor.isEmpty) {
                    TopToast.warning(
                      context,
                      "Silakan masukkan nomor rekam medis",
                    );
                    return;
                  }
                }

                context.read<CekinBloc>().add(
                  CekNomorEvent(nomor: nomor, jenis: widget.selectType),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(
                      Icons.arrow_forward_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
              const SizedBox(height: 10),
              Text(
                "LANJUT",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultInfo() {
    final sukses = hasil!.contains("✔️") || hasil!.contains("ditemukan");
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: sukses ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: sukses ? Colors.green.shade200 : Colors.red.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              sukses ? Icons.check_circle : Icons.error,
              color: sukses ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasil!,
                style: GoogleFonts.plusJakartaSans(
                  color: sukses ? Colors.green.shade900 : Colors.red.shade900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
              "RSU Sakina Idaman •  Pelayanan Pendaftaran Pasien Umum/BPJS",
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
