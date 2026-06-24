import 'dart:async';
import 'package:apm/Blog/blog_booking_pasien_baru.dart';
import 'package:apm/constants/app_constants.dart';
import 'package:apm/dialog/sukses.dart';
import 'package:apm/dialog/top_toast.dart';
import 'package:apm/home/dashboard_apm.dart';
import 'package:apm/models/booking_pasien_baru_model.dart';
import 'package:apm/models/dokter_model.dart';
import 'package:apm/models/poli_model.dart';
import 'package:apm/models/bpjs_cek_rujukan_model.dart';
import 'package:apm/utils/validators.dart';
import 'package:apm/widget/custom_text_field.dart';
import 'package:apm/widget/keypad_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BookingPasienBaruPage extends StatefulWidget {
  final int initialJenisBooking;

  const BookingPasienBaruPage({super.key, this.initialJenisBooking = 1});

  @override
  State<BookingPasienBaruPage> createState() => _BookingPasienBaruPageState();
}

class _BookingPasienBaruPageState extends State<BookingPasienBaruPage> {
  final _nikController = TextEditingController();
  final _nohpController = TextEditingController();
  final _tanggalPeriksaController = TextEditingController();
  final _nomorKartuController = TextEditingController();

  // Hasil cek rujukan BPJS
  String? _namaPasienBpjs;
  String? _nikPasienBpjs;

  // Simpan response untuk modal BPJS
  BpjsCekRujukanResponse? _bpjsRujukan;
  DateTime? _selectedTglPeriksa;

  // mapping rujukan BPJS -> form poli/dokter/jadwal
  String? _kodePoliRujukanBpjs;
  String? _kodeDokterRujukan;
  String? _jadwalDokterRujukan;

  PoliModel? _selectedPoli;
  DokterModel? _selectedDokter;
  int _jenisBooking = 1;
  bool _isLoading = false;

  // kontrol modal untuk jenis 2
  bool _isBpjsModalOpen = false;

  // agar UI BPJS awal hanya butuh tanggal/poli/dokter dari rujukan
  String? _tglKunjunganBpjs;
  String? _noKunjunganBpjs;

  final _formKey = GlobalKey<FormState>();

  TextEditingController? _activeFieldController;

  @override
  void initState() {
    super.initState();
    _jenisBooking = widget.initialJenisBooking;
    context.read<BookingPasienBaruBloc>().add(LoadPoliListEvent());
  }

  @override
  void dispose() {
    _nikController.dispose();
    _nohpController.dispose();
    _tanggalPeriksaController.dispose();
    _nomorKartuController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          _activeFieldController = null;
        });
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: BlocConsumer<BookingPasienBaruBloc, BookingPasienBaruState>(
          listener: _handleStateListener,
          builder: (context, state) {
            if (state is BookingPasienBaruLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(AppDimens.paddingMedium),
              child: Form(
                key: _formKey,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      return _buildDesktopLayout(state);
                    } else {
                      return _buildMobileLayout(state);
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BookingPasienBaruState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildJenisBookingSelector(),
                const SizedBox(height: AppDimens.paddingMedium),
                if (_jenisBooking != 2) ...[
                  _buildDataPasienSection(),
                  const SizedBox(height: AppDimens.paddingMedium),
                  _buildPoliDokterSection(state),
                  const SizedBox(height: AppDimens.paddingMedium),
                  _buildSubmitButton(state is BookingPasienBaruLoading),
                ] else ...[
                  // Untuk BPJS: tampil awal hanya selector jenis, input No BPJS, dan tombol CARI.
                  _buildBpjsSection(),
                  const SizedBox(height: AppDimens.paddingMedium),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(width: AppDimens.paddingLarge),

        Expanded(
          flex: 2,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: KeypadSection(
                        onNumberPressed: _handleKeypadNumber,
                        onBackspacePressed: _handleKeypadBackspace,
                        onClearPressed: _handleKeypadClear,
                      ),
                    ),
                    if (_activeFieldController != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            "Mengetik di: ${_getActiveFieldName()}",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BookingPasienBaruState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJenisBookingSelector(),
          const SizedBox(height: AppDimens.paddingMedium),
          if (_jenisBooking != 2) ...[
            _buildDataPasienSection(),
            const SizedBox(height: AppDimens.paddingMedium),
            _buildPoliDokterSection(state),
            const SizedBox(height: AppDimens.paddingMedium),
          ] else ...[
            _buildBpjsSection(),
            const SizedBox(height: AppDimens.paddingMedium),
          ],

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              leading: Icon(Icons.keyboard, color: Colors.blue.shade700),
              title: Text(
                "Keypad Input",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Container(
                        height: 300,
                        child: KeypadSection(
                          onNumberPressed: _handleKeypadNumber,
                          onBackspacePressed: _handleKeypadBackspace,
                          onClearPressed: _handleKeypadClear,
                        ),
                      ),
                      if (_activeFieldController != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Mengetik di: ${_getActiveFieldName()}",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimens.paddingMedium),
          _buildSubmitButton(state is BookingPasienBaruLoading),
        ],
      ),
    );
  }

  String _getActiveFieldName() {
    if (_activeFieldController == _nikController) return "NIK";
    if (_activeFieldController == _nohpController) return "No. HP";
    if (_activeFieldController == _nomorKartuController)
      return "No. Kartu BPJS";
    return "Tidak ada field yang dipilih";
  }

  void _handleKeypadNumber(String number) {
    if (_activeFieldController != null) {
      final text = _activeFieldController!.text;
      final selection = _activeFieldController!.selection;

      final newText =
          text.substring(0, selection.start) +
          number +
          text.substring(selection.end);

      _activeFieldController!.text = newText;
      _activeFieldController!.selection = TextSelection.collapsed(
        offset: selection.start + 1,
      );
    }
  }

  void _handleKeypadBackspace() {
    if (_activeFieldController != null) {
      final text = _activeFieldController!.text;
      final selection = _activeFieldController!.selection;

      if (selection.start > 0) {
        final newText =
            text.substring(0, selection.start - 1) +
            text.substring(selection.end);

        _activeFieldController!.text = newText;
        _activeFieldController!.selection = TextSelection.collapsed(
          offset: selection.start - 1,
        );
      }
    }
  }

  void _handleKeypadClear() {
    if (_activeFieldController != null) {
      _activeFieldController!.clear();
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 140,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withBlue(150)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 16, top: 24),
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            splashRadius: 24,
          ),
        ),
      ),
      leadingWidth: 70,
      title: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_sakina.png',
              height: 45,
              color: Colors.white,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.local_hospital,
                color: Colors.white,
                size: 30,
              ),
            ),
            Text(
              "BOOKING PASIEN BARU",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 30,
                color: Colors.white,
                letterSpacing: 1.2,
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
              "Lengkapi data untuk booking pemeriksaan",
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withOpacity(0.85),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      centerTitle: true,
    );
  }

  void _handleStateListener(
    BuildContext context,
    BookingPasienBaruState state,
  ) {
    if (state is BookingError) {
      setState(() => _isLoading = false);
      TopToast.error(context, state.message);
    }

    if (state is BookingSuccess) {
      setState(() => _isLoading = false);
      showSuccessDialog(context, 'Booking Berhasil!}').then((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardApm()),
          (route) => false,
        );
      });
    }

    if (state is BpjsRujukanLoaded) {
      setState(() {
        _bpjsRujukan = state.response;
        _namaPasienBpjs = state.response.peserta?.nama;
        _nikPasienBpjs = state.response.peserta?.nik;
        _isBpjsModalOpen = true;

        // ambil data rujukan pertama
        final rujukanItem =
            state.response.rujukan?.bpjs?.rujukan?.isNotEmpty == true
            ? state.response.rujukan!.bpjs!.rujukan!.first
            : null;

        _tglKunjunganBpjs = rujukanItem?.tglKunjungan;
        _noKunjunganBpjs = rujukanItem?.noKunjungan;

        _kodePoliRujukanBpjs = rujukanItem?.poliRujukan?.kode;
        _kodeDokterRujukan = null;
        _jadwalDokterRujukan = null;

        // set tanggal periksa dari tglKunjungan jika format parse sesuai
        if (_tglKunjunganBpjs != null && _tglKunjunganBpjs!.isNotEmpty) {
          try {
            final parsed = DateTime.parse(_tglKunjunganBpjs!);
            _selectedTglPeriksa = parsed;
            _tanggalPeriksaController.text = DateFormat(
              'yyyy-MM-dd',
            ).format(parsed);
          } catch (_) {
            _selectedTglPeriksa = null;
          }
        } else {
          _selectedTglPeriksa = null;
        }

        // reset pilihan poli/dokter agar modal bisa memaksa pemilihan dari hasil cek
        _selectedPoli = null;
        _selectedDokter = null;
      });

      // munculkan modal BPJS.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openBpjsBookingModal(context);
      });
    }

    if (state is DokterJadwalLoaded) {
      setState(() {
        _selectedDokter = null;
      });
    }
  }

  Widget _buildJenisBookingSelector() {
    return CustomSectionCard(
      title: "Pilih Jenis Booking",
      icon: Icons.assignment_outlined,
      children: [
        Row(
          children: [
            if (_jenisBooking == null || _jenisBooking == 1)
              Expanded(
                child: _buildJenisButton(
                  title: "UMUM",
                  value: 1,
                  icon: Icons.person_outline,
                ),
              ),
            if (_jenisBooking == null) const SizedBox(width: 12),
            if (_jenisBooking == null || _jenisBooking == 2)
              Expanded(
                child: _buildJenisButton(
                  title: "BPJS",
                  value: 2,
                  icon: Icons.health_and_safety_outlined,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildJenisButton({
    required String title,
    required int value,
    required IconData icon,
  }) {
    final bool isSelected = _jenisBooking == value;

    return InkWell(
      onTap: () {
        setState(() {
          _jenisBooking = value;
          _selectedDokter = null;
          if (_selectedPoli != null) {
            context.read<BookingPasienBaruBloc>().add(
              LoadDokterJadwalEvent(
                idLayanan: _selectedPoli!.id,
                jenisBooking: value,
              ),
            );
          }
        });
      },
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPasienSection() {
    return CustomSectionCard(
      title: "Data Pasien",
      icon: Icons.person_outline,
      children: [
        CustomTextField(
          controller: _nikController,
          label: "NIK",
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          maxLength: 16,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onTap: () {
            setState(() {
              _activeFieldController = _nikController;
            });
          },
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              setState(() {
                _activeFieldController = _nikController;
              });
            }
          },
          validator: Validators.validateNIK,
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: _nohpController,
          label: "No. HP",
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          maxLength: 13, // Batasi maksimal 13 digit
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // Hanya angka
          ],
          onTap: () {
            setState(() {
              _activeFieldController = _nohpController;
            });
          },
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              setState(() {
                _activeFieldController = _nohpController;
              });
            }
          },
          validator: Validators.validateNoHP,
        ),
        const SizedBox(height: 16),

        CustomDatePickerField(
          controller: _tanggalPeriksaController,
          label: "Tanggal Periksa",
          icon: Icons.calendar_today,
          onTap: _selectTglPeriksa,
          validator: (v) => _selectedTglPeriksa == null
              ? "Tanggal periksa wajib diisi"
              : null,
        ),
      ],
    );
  }

  Widget _buildBpjsSection() {
    final isBpjsReady = (_nomorKartuController.text.trim().isNotEmpty);

    return CustomSectionCard(
      title: "Data BPJS",
      icon: Icons.health_and_safety,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _nomorKartuController,
                label: "No BPJS",
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 13,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onTap: () {
                  setState(() {
                    _activeFieldController = _nomorKartuController;
                  });
                },
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    setState(() {
                      _activeFieldController = _nomorKartuController;
                    });
                  }
                },
                validator: Validators.validateNomorKartuBPJS,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 90,
              child: ElevatedButton.icon(
                onPressed: (_isLoading || !isBpjsReady)
                    ? null
                    : () {
                        context.read<BookingPasienBaruBloc>().add(
                          CekRujukanBpjsEvent(
                            noBpjs: _nomorKartuController.text.trim(),
                          ),
                        );
                      },
                icon: const Icon(Icons.search_rounded, size: 18),
                label: const Text("CARI"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_namaPasienBpjs != null && _nikPasienBpjs != null)
          Text(
            "Ditemukan: ${_namaPasienBpjs} (NIK: ${_nikPasienBpjs})",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.blueGrey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildPoliDokterSection(BookingPasienBaruState state) {
    // Khusus tampilan awal BPJS (jenis 2) tidak ditampilkan sampai modal muncul.
    if (_jenisBooking == 2) {
      return const SizedBox.shrink();
    }

    List<PoliModel> poliList = [];

    if (state is PoliListLoaded) {
      poliList = state.poliList;
    } else if (state is DokterJadwalLoaded && _selectedPoli != null) {
      poliList = [_selectedPoli!];
    }

    return CustomSectionCard(
      title: "Pilih Poli & Dokter",
      icon: Icons.local_hospital,
      children: [
        if (poliList.isNotEmpty) ...[
          CustomDropdown<PoliModel>(
            label: "Pilih Poli",
            value: poliList.contains(_selectedPoli) ? _selectedPoli : null,
            items: poliList,
            display: (p) => p.nama,
            onChanged: (poli) {
              setState(() {
                _selectedPoli = poli;
                _selectedDokter = null;
              });

              if (poli != null) {
                context.read<BookingPasienBaruBloc>().add(
                  LoadDokterJadwalEvent(
                    idLayanan: poli.id,
                    jenisBooking: _jenisBooking,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
        ],

        if (state is DokterJadwalLoaded && _selectedPoli != null) ...[
          const Divider(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Pilih Dokter",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedPoli = null;
                    _selectedDokter = null;
                  });

                  context.read<BookingPasienBaruBloc>().add(
                    LoadPoliListEvent(),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.teal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  "ULANG PENGISIAN",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Builder(
            builder: (_) {
              final filteredDokter = state.dokterList.where((dokter) {
                if (dokter.libur != 0) return false;

                if (_jenisBooking == 2) {
                  if ((dokter.kapasitasPasien ?? 0) <= 0) return false;
                  if (dokter.jamBuka == null || dokter.jamTutup == null)
                    return false;
                  return true;
                } else {
                  if (dokter.tipe != null) return false;
                  return true;
                }
              }).toList();

              if (filteredDokter.isNotEmpty) {
                return Column(
                  children: filteredDokter.map((dokter) {
                    return DokterListItem(
                      dokter: dokter,
                      isSelected: _selectedDokter == dokter,
                      onTap: () {
                        setState(() {
                          _selectedDokter = dokter;
                        });
                      },
                    );
                  }).toList(),
                );
              }

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _jenisBooking == 2
                            ? "Tidak ada dokter BPJS tersedia untuk poli ini"
                            : "Tidak ada dokter umum tersedia untuk poli ini",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    // Tombol kirim booking untuk BPJS hanya tampil di dalam modal.
    if (_jenisBooking == 2) {
      return const SizedBox.shrink();
    }

    return CustomSubmitButton(
      onPressed: _submitBooking,
      text: "KIRIM BOOKING",
      isLoading: isLoading,
    );
  }

  Future<void> _selectTglPeriksa() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.teal600,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTglPeriksa = picked;
        _tanggalPeriksaController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(picked);
      });
    }
  }

  // void _openBpjsBookingModal(BuildContext context) {
  //   if (_bpjsRujukan == null) return;

  //   // Modal BPJS: tampilkan data pasien + tanggal + poli/dokter/jadwal.
  //   // UI poli/dokter diambil lewat mekanisme dokternya (LoadDokterJadwalEvent) bila tersedia.
  //   // Karena saat ini komponen pemilihan dokter/poli belum difitting ke modal,
  //   // kita tampilkan dulu data yang sudah ada dari rujukan + jadwal dari dokter yang dipilih.

  //   // Pastikan daftar poli/dokter dimuat: trigger load dokter jadwal berdasarkan kode poli rujukan.
  //   if (_kodePoliRujukanBpjs != null) {
  //     // Di sistem lama poli dipakai pakai id layanan (idLayanan), bukan kode.
  //     // Untuk menjaga kompatibilitas, kita paksa pilih poli pertama dari list poli yang sudah dimuat.
  //     // Jika tidak ada list poli di state, pengguna tetap bisa memilih dari hasil load (di dalam modal).
  //   }

  //   final rujukanItem = _bpjsRujukan!.rujukan?.bpjs?.rujukan?.isNotEmpty == true
  //       ? _bpjsRujukan!.rujukan!.bpjs!.rujukan!.first
  //       : null;

  //   final tglKunjungan = rujukanItem?.tglKunjungan;
  //   final noKunjungan = rujukanItem?.noKunjungan;
  //   final namaPasien = _namaPasienBpjs;
  //   final nikPasien = _nikPasienBpjs;

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (ctx) {
  //       return StatefulBuilder(
  //         builder: (ctx, setModalState) {
  //           // Isi default pemilihan poli/dokter dari hasil rujukan (jika cocok dengan daftar yang ada)
  //           // Dalam versi ini, kita reuse variabel page.

  //           return Dialog(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(18),
  //             ),
  //             child: ConstrainedBox(
  //               constraints: const BoxConstraints(maxWidth: 720),
  //               child: Padding(
  //                 padding: const EdgeInsets.all(16),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         const Text(
  //                           'Data Pasien (BPJS)',
  //                           style: TextStyle(
  //                             fontSize: 18,
  //                             fontWeight: FontWeight.w700,
  //                           ),
  //                         ),
  //                         IconButton(
  //                           icon: const Icon(Icons.close),
  //                           onPressed: () {
  //                             Navigator.of(ctx).pop();
  //                             setState(() {
  //                               _isBpjsModalOpen = false;
  //                             });
  //                           },
  //                         ),
  //                       ],
  //                     ),
  //                     const Divider(),
  //                     const SizedBox(height: 8),
  //                     _buildModalInfoRow(
  //                       label: 'Nama',
  //                       value: namaPasien ?? '-',
  //                     ),
  //                     _buildModalInfoRow(label: 'NIK', value: nikPasien ?? '-'),
  //                     // Tgl: gunakan CustomDatePickerField agar sama seperti request.
  //                     CustomDatePickerField(
  //                       controller: _tanggalPeriksaController,
  //                       label: 'Tanggal Periksa',
  //                       icon: Icons.calendar_today,
  //                       onTap: _selectTglPeriksa,
  //                       validator: (v) => _selectedTglPeriksa == null
  //                           ? 'Tanggal periksa wajib diisi'
  //                           : null,
  //                     ),

  //                     _buildModalInfoRow(
  //                       label: 'No Kunjungan',
  //                       value: noKunjungan ?? '-',
  //                     ),
  //                     const SizedBox(height: 10),

  //                     // Poli -> dropdown
  //                     const SizedBox(height: 6),
  //                     BlocBuilder<
  //                       BookingPasienBaruBloc,
  //                       BookingPasienBaruState
  //                     >(
  //                       builder: (pageContext, poliState) {
  //                         final poliList = poliState is PoliListLoaded
  //                             ? poliState.poliList
  //                             : <PoliModel>[];

  //                         return CustomDropdown<PoliModel>(
  //                           label: 'Pilih Poli',
  //                           value: _selectedPoli,
  //                           // Filter dropdown BPJS sesuai kodeBpjs dari rujukan.
  //                           items: poliList
  //                               .where(
  //                                 (p) =>
  //                                     p.kodeBpjs == _kodePoliRujukanBpjs ||
  //                                     _kodePoliRujukanBpjs == null,
  //                               )
  //                               .toSet()
  //                               .toList(),
  //                           display: (p) => p.nama,
  //                           onChanged: (poli) {
  //                             setModalState(() {
  //                               _selectedPoli = poli;
  //                               _selectedDokter = null;
  //                             });

  //                             if (poli != null) {
  //                               pageContext.read<BookingPasienBaruBloc>().add(
  //                                 LoadDokterJadwalEvent(
  //                                   idLayanan: poli.id,
  //                                   jenisBooking: 2,
  //                                 ),
  //                               );
  //                             }
  //                           },
  //                         );
  //                       },
  //                     ),

  //                     const SizedBox(height: 16),

  //                     // Dokter -> list
  //                     BlocBuilder<
  //                       BookingPasienBaruBloc,
  //                       BookingPasienBaruState
  //                     >(
  //                       builder: (context, dokterState) {
  //                         if (dokterState is DokterJadwalLoaded &&
  //                             _selectedPoli != null) {
  //                           final filteredDokter = dokterState.dokterList.where(
  //                             (dokter) {
  //                               if (dokter.libur != 0) return false;
  //                               if (dokter.kapasitasPasien != null &&
  //                                   dokter.kapasitasPasien! <= 0)
  //                                 return false;
  //                               if (dokter.jamBuka == null ||
  //                                   dokter.jamTutup == null)
  //                                 return false;
  //                               return true;
  //                             },
  //                           ).toList();

  //                           if (filteredDokter.isEmpty) {
  //                             return const Padding(
  //                               padding: EdgeInsets.symmetric(vertical: 8),
  //                               child: Text(
  //                                 'Tidak ada dokter BPJS tersedia untuk poli ini',
  //                                 textAlign: TextAlign.center,
  //                               ),
  //                             );
  //                           }

  //                           return Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 'Pilih Dokter',
  //                                 style: GoogleFonts.poppins(
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.w600,
  //                                   color: AppColors.textPrimary,
  //                                 ),
  //                               ),
  //                               const SizedBox(height: 8),
  //                               Column(
  //                                 children: filteredDokter.map((dokter) {
  //                                   return DokterListItem(
  //                                     dokter: dokter,
  //                                     isSelected: _selectedDokter == dokter,
  //                                     onTap: () {
  //                                       setModalState(() {
  //                                         _selectedDokter = dokter;
  //                                         _jadwalDokterRujukan = dokter.jadwal;
  //                                       });
  //                                     },
  //                                   );
  //                                 }).toList(),
  //                               ),
  //                               const SizedBox(height: 8),
  //                               _buildModalInfoRow(
  //                                 label: 'Jadwal',
  //                                 value:
  //                                     (_selectedDokter?.jadwal != null &&
  //                                         _selectedDokter!.jadwal!.isNotEmpty)
  //                                     ? _selectedDokter!.jadwal!
  //                                     : (_jadwalDokterRujukan ?? '-'),
  //                               ),
  //                             ],
  //                           );
  //                         }

  //                         return const SizedBox.shrink();
  //                       },
  //                     ),

  //                     const SizedBox(height: 16),
  //                     Row(
  //                       children: [
  //                         Expanded(
  //                           child: ElevatedButton(
  //                             onPressed: () {
  //                               // Untuk BPJS: di requirement, tombol kirim ada di modal.
  //                               // Kita gunakan submitBooking, tapi pastikan field poli/dokter/jadwal terisi.
  //                               Navigator.of(ctx).pop();
  //                               _submitBooking();
  //                             },
  //                             style: ElevatedButton.styleFrom(
  //                               backgroundColor: AppColors.primary,
  //                               foregroundColor: Colors.white,
  //                               padding: const EdgeInsets.symmetric(
  //                                 vertical: 14,
  //                               ),
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(12),
  //                               ),
  //                             ),
  //                             child: const Text('KIRIM BOOKING'),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 8),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void _openBpjsBookingModal(BuildContext context) {
    if (_bpjsRujukan == null) return;

    final rujukanItem = _bpjsRujukan!.rujukan?.bpjs?.rujukan?.isNotEmpty == true
        ? _bpjsRujukan!.rujukan!.bpjs!.rujukan!.first
        : null;

    final tglKunjungan = rujukanItem?.tglKunjungan;
    final noKunjungan = rujukanItem?.noKunjungan;
    final namaPasien = _namaPasienBpjs;
    final nikPasien = _nikPasienBpjs;

    // AMBIL BLOC DARI CONTEXT PARENT
    final bloc = context.read<BookingPasienBaruBloc>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        // WARISKAN BLOC KE DIALOG MENGGUNAKAN BlocProvider.value
        return BlocProvider.value(
          value: bloc,
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Data Pasien (BPJS)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                setState(() {
                                  _isBpjsModalOpen = false;
                                });
                              },
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildModalInfoRow(
                          label: 'Nama',
                          value: namaPasien ?? '-',
                        ),
                        _buildModalInfoRow(
                          label: 'NIK',
                          value: nikPasien ?? '-',
                        ),
                        CustomDatePickerField(
                          controller: _tanggalPeriksaController,
                          label: 'Tanggal Periksa',
                          icon: Icons.calendar_today,
                          onTap: _selectTglPeriksa,
                          validator: (v) => _selectedTglPeriksa == null
                              ? 'Tanggal periksa wajib diisi'
                              : null,
                        ),
                        _buildModalInfoRow(
                          label: 'No Kunjungan',
                          value: noKunjungan ?? '-',
                        ),
                        const SizedBox(height: 10),

                        const SizedBox(height: 6),
                        // SEKARANG BlocBuilder DI SINI AKAN BEKERJA
                        BlocBuilder<
                          BookingPasienBaruBloc,
                          BookingPasienBaruState
                        >(
                          builder: (pageContext, poliState) {
                            final poliList = poliState is PoliListLoaded
                                ? poliState.poliList
                                : <PoliModel>[];

                            return CustomDropdown<PoliModel>(
                              label: 'Pilih Poli',
                              value: _selectedPoli,
                              items: poliList
                                  .where(
                                    (p) =>
                                        p.kodeBpjs == _kodePoliRujukanBpjs ||
                                        _kodePoliRujukanBpjs == null,
                                  )
                                  .toSet()
                                  .toList(),
                              display: (p) => p.nama,
                              onChanged: (poli) {
                                setModalState(() {
                                  _selectedPoli = poli;
                                  _selectedDokter = null;
                                });

                                if (poli != null) {
                                  pageContext.read<BookingPasienBaruBloc>().add(
                                    LoadDokterJadwalEvent(
                                      idLayanan: poli.id,
                                      jenisBooking: 2,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        BlocBuilder<
                          BookingPasienBaruBloc,
                          BookingPasienBaruState
                        >(
                          builder: (context, dokterState) {
                            if (dokterState is DokterJadwalLoaded &&
                                _selectedPoli != null) {
                              final filteredDokter = dokterState.dokterList
                                  .where((dokter) {
                                    if (dokter.libur != 0) return false;
                                    if (dokter.kapasitasPasien != null &&
                                        dokter.kapasitasPasien! <= 0)
                                      return false;
                                    if (dokter.jamBuka == null ||
                                        dokter.jamTutup == null)
                                      return false;
                                    return true;
                                  })
                                  .toList();

                              if (filteredDokter.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Tidak ada dokter BPJS tersedia untuk poli ini',
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pilih Dokter',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Column(
                                    children: filteredDokter.map((dokter) {
                                      return DokterListItem(
                                        dokter: dokter,
                                        isSelected: _selectedDokter == dokter,
                                        onTap: () {
                                          setModalState(() {
                                            _selectedDokter = dokter;
                                            _jadwalDokterRujukan =
                                                dokter.jadwal;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildModalInfoRow(
                                    label: 'Jadwal',
                                    value:
                                        (_selectedDokter?.jadwal != null &&
                                            _selectedDokter!.jadwal!.isNotEmpty)
                                        ? _selectedDokter!.jadwal!
                                        : (_jadwalDokterRujukan ?? '-'),
                                  ),
                                ],
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),

                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  _submitBooking();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('KIRIM BOOKING'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildModalInfoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  void _submitBooking() async {
    if (_formKey.currentState?.validate() != true) {
      TopToast.error(context, "Harap lengkapi semua field dengan benar");
      return;
    }

    if (_selectedPoli == null) {
      TopToast.error(context, "Pilih poli terlebih dahulu");
      return;
    }

    if (_selectedDokter == null) {
      TopToast.error(context, "Pilih dokter terlebih dahulu");
      return;
    }

    if (_jenisBooking == 2) {
      if (_selectedDokter!.jadwal == null || _selectedDokter!.jadwal!.isEmpty) {
        TopToast.error(
          context,
          "Dokter yang dipilih harus memiliki jadwal untuk booking BPJS",
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final request = BookingRequestModel(
      nik: _nikController.text.trim(),
      nohp: _nohpController.text.trim(),
      idUnit: _selectedPoli!.id,
      idDokter: _selectedDokter!.idDokter,
      tanggalperiksa: DateFormat('yyyy-MM-dd').format(_selectedTglPeriksa!),
      // jadwal: _jenisBooking == 2 ? _selectedDokter!.jadwal : null,
      jadwal: DateFormat('HH:mm:ss').format(DateTime.now()),
      idJadwalDokter: _selectedDokter!.idJadwal,
      kapasitaspasien: _selectedDokter!.kapasitasPasien,
      jenisBooking: _jenisBooking,
      nomorkartu: _jenisBooking == 2 ? _nomorKartuController.text.trim() : null,
      noReferensi: null,

      kodepoli: _jenisBooking == 2 ? _selectedPoli!.kodeBpjs : null,
      namapoli: _jenisBooking == 2 ? _selectedPoli!.nama : null,
      kodedokter: _jenisBooking == 2 ? _selectedDokter!.kodeDokter : null,
      namadokter: _jenisBooking == 2 ? _selectedDokter!.namaDokter : null,
      jeniskunjungan: _jenisBooking == 2 ? 1 : null,
      pasienBaru: _jenisBooking == 2 ? 1 : null,
    );

    context.read<BookingPasienBaruBloc>().add(
      SubmitBookingEvent(request: request),
    );
  }
}
