import 'package:apm/blog/booking/booking_bloc.dart';
import 'package:apm/blog/booking/booking_event.dart';
import 'package:apm/blog/booking/booking_state.dart';
import 'package:apm/widget/keypad_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../models/booking_model.dart';
import '../../theme/format_text.dart';

class BookingUmumPage extends StatefulWidget {
  const BookingUmumPage({super.key});

  @override
  State<BookingUmumPage> createState() => _BookingUmumPageState();
}

class _BookingUmumPageState extends State<BookingUmumPage> {
  final _formKey = GlobalKey<FormState>();

  final _nikController = TextEditingController();
  final _nohpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  TextEditingController? _activeController;

  DateTime? _selectedDate;
  String? _selectedPoliId;
  String? _selectedDokterId;
  String? _selectedJadwalId;

  String? _selectedPoliNama;
  String? _selectedDokterNama;

  final Color primaryColor = const Color(0xFF0D8AAE);

  @override
  void initState() {
    super.initState();
    // Fokus otomatis untuk scanner
    Future.delayed(const Duration(milliseconds: 300), () {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nikController.dispose();
    _nohpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _appendNumber(String value) {
    if (_activeController == null) return;
    final current = _activeController!.text;
    // Batasi panjang input (16 digit untuk NIK)
    if (current.length >= 16) return;

    setState(() {
      _activeController!.text = current + value;
      _activeController!.selection = TextSelection.fromPosition(
        TextPosition(offset: _activeController!.text.length),
      );
    });

    _focusNode.requestFocus();
  }

  void _backspace() {
    if (_activeController == null) return;
    final current = _activeController!.text;
    if (current.isEmpty) return;

    setState(() {
      _activeController!.text = current.substring(0, current.length - 1);
      _activeController!.selection = TextSelection.fromPosition(
        TextPosition(offset: _activeController!.text.length),
      );
    });

    _focusNode.requestFocus();
  }

  void _clear() {
    _activeController?.clear();
    setState(() {});
    _refocusScanner();
  }

  void _refocusScanner() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date == null) return;

    setState(() {
      _selectedDate = date;
      _selectedDokterId = null;
      _selectedJadwalId = null;
      _selectedDokterNama = null;
    });

    if (_selectedPoliId != null) {
      context.read<BookingBloc>().add(
        LoadDokterUmumEvent(
          idLayanan: int.parse(_selectedPoliId!),
          tanggal: DateFormat('yyyy-MM-dd').format(date),
        ),
      );
    }
  }

  Widget _buildDokterList(BookingState state) {
    if (state.dokterList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.person_off, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Tidak ada dokter tersedia',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 4),
              Text(
                'Silakan pilih tanggal dan poli terlebih dahulu',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final availableCount = state.dokterList
        .where((d) => !d.isLibur && (d.sisaKoutaKapasitaspasien ?? 0) > 0)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            '$availableCount dari ${state.dokterList.length} dokter tersedia',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        // List dokter
        ...state.dokterList.map((dokter) {
          final isLibur = dokter.isLibur;
          final kuota = dokter.sisaKoutaKapasitaspasien ?? 0;
          final hasKuota = dokter.terpakaiKapasitaspasien != null;
          final isAvailable = !isLibur && (!hasKuota || kuota > 0);
          final isSelected = _selectedDokterId == dokter.idDokter.toString();

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: isSelected ? 4 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: isSelected ? 2 : 0,
              ),
            ),
            child: InkWell(
              onTap: isAvailable
                  ? () {
                      setState(() {
                        _selectedDokterId = dokter.idDokter.toString();
                        _selectedDokterNama = dokter.namaDokter;
                        _selectedJadwalId = dokter.idJadwalDetail;
                      });
                    }
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Icon status
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isLibur
                            ? Colors.red.withOpacity(0.1)
                            : isAvailable
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLibur
                            ? Icons.event_busy
                            : isAvailable
                            ? Icons.check_circle
                            : Icons.warning,
                        size: 24,
                        color: isLibur
                            ? Colors.red
                            : isAvailable
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Info dokter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dokter.namaDokter,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isLibur ? Colors.grey : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: isLibur ? Colors.red : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dokter.jadwalLengkap,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isLibur
                                      ? Colors.red
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          if (hasKuota) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 14,
                                  color: kuota > 0
                                      ? Colors.blue
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Sisa Kuota: $kuota',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: kuota > 0
                                        ? Colors.blue
                                        : Colors.orange,
                                    fontWeight: kuota > 0
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Status badge + selected indicator
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLibur)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'LIBUR',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (!isAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'PENUH',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'DIPILIH',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 4),
                        if (isSelected)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<BookingBloc, BookingState>(
                listener: (context, state) {
                  if (state.status == BookingStatus.error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.errorMessage ?? "Terjadi kesalahan",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    _refocusScanner();
                  }

                  if (state.status == BookingStatus.success &&
                      state.bookingResult != null) {
                    setState(() {
                      _nikController.clear();
                      _nohpController.clear();
                    });
                    _showSuccessDialog(context, state);
                  }
                },

                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// FORM
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 0,
                                    height: 0,
                                    child: TextField(
                                      controller: _nikController,
                                      focusNode: _focusNode,
                                      autofocus: true,
                                      showCursor: false,
                                      keyboardType: TextInputType.text,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isCollapsed: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.transparent,
                                        fontSize: 1,
                                      ),
                                      cursorColor: Colors.transparent,
                                      onSubmitted: (value) {},
                                      enableInteractiveSelection: false,
                                      enableIMEPersonalizedLearning: false,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _nikController,
                                    readOnly: true,
                                    onTap: () {
                                      _activeController = _nikController;
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'NIK',
                                      hintText: 'Masukkan NIK (16 digit)',
                                      border: const OutlineInputBorder(),
                                      suffixIcon:
                                          _activeController == _nikController
                                          ? const Icon(Icons.keyboard)
                                          : null,
                                    ),
                                    maxLength: 16,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'NIK wajib';
                                      }
                                      if (v.length != 16) {
                                        return 'NIK harus 16 digit';
                                      }
                                      if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
                                        return 'NIK harus berupa angka';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  TextFormField(
                                    controller: _nohpController,
                                    readOnly: true,
                                    onTap: () {
                                      _activeController = _nohpController;
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'No HP',
                                      hintText: 'Masukkan No HP',
                                      border: const OutlineInputBorder(),
                                      suffixIcon:
                                          _activeController == _nohpController
                                          ? const Icon(Icons.keyboard)
                                          : null,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'No HP wajib';
                                      }
                                      if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
                                        return 'No HP harus berupa angka';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  InkWell(
                                    onTap: _pickDate,
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Tanggal Periksa',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.calendar_today),
                                      ),
                                      child: Text(
                                        _selectedDate != null
                                            ? DateFormat(
                                                'dd/MM/yyyy',
                                              ).format(_selectedDate!)
                                            : 'Pilih tanggal',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  DropdownButtonFormField<String>(
                                    value: _selectedPoliId,
                                    decoration: const InputDecoration(
                                      labelText: 'Pilih Poli',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.local_hospital),
                                    ),
                                    items: state.poliList.map((e) {
                                      return DropdownMenuItem(
                                        value: e.id.toString(),
                                        child: Text(e.nama),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPoliId = value;
                                        _selectedDokterId = null;
                                        _selectedDokterNama = null;
                                        _selectedJadwalId = null;
                                        final selectedPoli = state.poliList
                                            .firstWhere(
                                              (e) => e.id.toString() == value,
                                              orElse: () =>
                                                  state.poliList.first,
                                            );
                                        _selectedPoliNama = selectedPoli.nama;
                                      });

                                      if (value != null &&
                                          _selectedDate != null) {
                                        context.read<BookingBloc>().add(
                                          LoadDokterUmumEvent(
                                            idLayanan: int.parse(value),
                                            tanggal: DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(_selectedDate!),
                                          ),
                                        );
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Poli wajib dipilih';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 20,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Pilih Dokter',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (_selectedDokterId != null)
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _selectedDokterId = null;
                                              _selectedDokterNama = null;
                                              _selectedJadwalId = null;
                                            });
                                          },
                                          child: const Text('Hapus Pilihan'),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  state.status == BookingStatus.loadingDokter
                                      ? Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(20),
                                            child: Column(
                                              children: [
                                                LoadingAnimationWidget.fourRotatingDots(
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                                SizedBox(height: 12),
                                                Text('Memuat data dokter...'),
                                              ],
                                            ),
                                          ),
                                        )
                                      : _buildDokterList(state),

                                  const SizedBox(height: 12),

                                  if (_selectedDokterId != null &&
                                      _selectedDokterNama != null)
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Dokter terpilih: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              _selectedDokterNama!,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 20),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed:
                                          state.status == BookingStatus.loading
                                          ? null
                                          : () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                _submitBooking(context);
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFFF6F00,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child:
                                          state.status == BookingStatus.loading
                                          ? LoadingAnimationWidget.fourRotatingDots(
                                              color: Colors.white,
                                              size: 15,
                                            )
                                          : const Text("BOOKING"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 550,
                            child: KeypadSection(
                              onNumberPressed: _appendNumber,
                              onBackspacePressed: _backspace,
                              onClearPressed: _clear,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Footer
            _footer(),
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
          Center(
            child: Text(
              "RSU Sakina Idaman • Pelayanan Booking Umum",
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

  void _submitBooking(BuildContext context) {
    final state = context.read<BookingBloc>().state;

    final dokter = state.dokterList.firstWhere(
      (e) => e.idDokter.toString() == _selectedDokterId,
    );

    final request = BookingRequest(
      jenis: '1',
      nik: _nikController.text,
      nohp: _nohpController.text,
      idUnit: int.parse(_selectedPoliId!),
      idDokter: int.parse(_selectedDokterId!),
      tanggalPeriksa: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      idJadwalDokter: dokter.idJadwalDetail,
    );

    context.read<BookingBloc>().add(SubmitBookingUmumEvent(request));
  }

  void _showSuccessDialog(BuildContext context, BookingState state) {
    final data = state.bookingResult!;

    final unitName = _selectedPoliNama ?? data.unit ?? '-';
    final dokterName = _selectedDokterNama ?? data.dokter ?? '-';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header dengan animasi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.greenAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_sharp,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Booking Berhasil!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Booking anda telah terkonfirmasi',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              Container(
                height: 2,
                width: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade300, Colors.green.shade700],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.numbers,
                      'No. Antrian',
                      data.noAntrian,
                      isHighlighted: true,
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      Icons.qr_code,
                      'Kode Booking',
                      data.kodeBooking,
                      isHighlighted: true,
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      Icons.person,
                      'Nama Pasien',
                      data.namaPasien.isNotEmpty ? data.namaPasien : '-',
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Tanggal Periksa',
                      data.tanggalPeriksa,
                    ),
                    _buildDivider(),
                    _buildInfoRow(Icons.local_hospital, 'Unit', unitName),
                    _buildDivider(),
                    _buildInfoRow(Icons.medical_services, 'Dokter', dokterName),
                    _buildDivider(),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _printBookingTicket(
                      kodeBooking: data.kodeBooking,
                      namaPoli: unitName,
                      tanggalPeriksa: data.tanggalPeriksa,
                      namaDokter: dokterName,
                      jamPraktek: data.jamBooking,
                      qrData: data.kodeBooking,
                    );

                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                    context.read<BookingBloc>().add(ResetBookingEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.print, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Cetak Tiket',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? Colors.green.shade50
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isHighlighted ? Colors.green : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted ? Colors.green.shade700 : Colors.black87,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade200);
  }

  Future<void> _printBookingTicket({
    required String kodeBooking,
    required String namaPoli,
    required String tanggalPeriksa,
    required String namaDokter,
    required String jamPraktek,
    required String qrData,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          72 * PdfPageFormat.mm,
          100 * PdfPageFormat.mm,
        ),
        margin: const pw.EdgeInsets.all(12),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'RSU SAKINA IDAMAN',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Jl. Nyi Tjondro Loekito No. 60',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Text(
                'Telp. (0274) 5018221, 5029090',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Divider(thickness: 1),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          formatNama(namaPoli),
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          formatNama(namaDokter),
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Tanggal: $tanggalPeriksa',
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                        pw.Text(
                          'Jam Praktek: $jamPraktek',
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(
                    width: 50,
                    height: 50,
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: qrData,
                    ),
                  ),
                ],
              ),

              pw.Divider(thickness: 1),

              pw.Text('No. Booking', style: const pw.TextStyle(fontSize: 9)),
              pw.Text(
                kodeBooking,
                style: pw.TextStyle(
                  fontSize: 30,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 8),
              pw.Text(
                'Tgl Daftar: $tanggalPeriksa',
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
