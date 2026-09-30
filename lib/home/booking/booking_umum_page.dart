import 'package:apm/blog/booking/booking_bloc.dart';
import 'package:apm/blog/booking/booking_event.dart';
import 'package:apm/blog/booking/booking_state.dart';
import 'package:apm/theme/app_tokens.dart';
import 'package:apm/utils/print_setup_runner.dart';
import 'package:apm/widget/app_button.dart';
import 'package:apm/widget/app_card.dart';
import 'package:apm/widget/app_page_chrome.dart';
import 'package:apm/widget/doctor_option_card.dart';
import 'package:apm/widget/number_entry_board.dart';
import 'package:colorful_print/colorful_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
      return const AppEmptyState(
        title: 'Belum ada dokter tersedia',
        message: 'Silakan pilih tanggal pemeriksaan dan poli terlebih dahulu.',
        icon: Icons.medical_information_outlined,
        color: AppColors.textMuted,
      );
    }

    final availableCount = state.dokterList
        .where((d) => !d.isLibur && (d.sisaKoutaKapasitaspasien ?? 0) > 0)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DoctorListHeader(
          total: state.dokterList.length,
          tersedia: availableCount,
        ),
        for (final dokter in state.dokterList) ...[
          DoctorOptionCard(
            dokter: dokter,
            accent: AppColors.umum,
            isSelected: _selectedDokterId == dokter.idDokter.toString(),
            onTap: () {
              setState(() {
                _selectedDokterId = dokter.idDokter.toString();
                _selectedDokterNama = dokter.namaDokter;
                _selectedJadwalId = dokter.idJadwalDetail;
              });
            },
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
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
                                    maxLength: 12,
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'No HP wajib';
                                      }
                                      if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
                                        return 'No HP harus berupa angka';
                                      }
                                      if (v.length > 12) {
                                        return 'No HP maksimal 12 digit';
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
                                      ? const Padding(
                                          padding: EdgeInsets.all(AppSpacing.lg),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Memuat data dokter...',
                                                style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
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

                                  AppGradientButton(
                                    label: 'BOOKING',
                                    icon: Icons.event_available_rounded,
                                    gradient: AppGradients.umum,
                                    height: 58,
                                    loading:
                                        state.status == BookingStatus.loading,
                                    onPressed:
                                        state.status == BookingStatus.loading
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              _submitBooking(context);
                                            }
                                          },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          flex: 2,
                          child: NumberKeypad(
                            accent: AppColors.umum,
                            onDigit: _appendNumber,
                            onBackspace: _backspace,
                            onClear: _clear,
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
    return const AppPageFooter(
      message: 'RSU Sakina Idaman - Pelayanan Booking Umum',
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
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Column(
          children: [
            Text(
              'Booking Berhasil!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Booking anda telah terkonfirmasi',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(height: 24, thickness: 1, color: Color(0xFFE8F5E9)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF1F8E9), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8F5E9), width: 1),
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
                    Icons.qr_code_2,
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
                  _buildInfoRow(
                    Icons.access_time_filled_outlined,
                    'Jam Praktek',
                    data.jamPraktek,
                  ),
                  _buildDivider(),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: ElevatedButton(
                  onPressed: () async {
                    await _printBookingTicket(
                      kodeBooking: data.kodeBooking,
                      namaPoli: unitName,
                      tanggalPeriksa: data.tanggalPeriksa,
                      namaDokter: dokterName,
                      jamPraktek: data.jamPraktek,
                      qrData: data.kodeBooking,
                    );

                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                    context.read<BookingBloc>().add(ResetBookingEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.print, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Cetak Tiket',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isHighlighted
                  ? const Color(0xFF43A047)
                  : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
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
                fontSize: 13,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted ? const Color(0xFF2E7D32) : Colors.black87,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runPrintSetupAutomation() async {
    try {
      printColor(
        'Menjalankan Print Setup automation...',
        textColor: TextColor.cyan,
      );
      await Future.delayed(const Duration(milliseconds: 200));
      await PrintSetupRunner.runScript('print_setup2.py');
      printColor('Print Setup automation selesai!', textColor: TextColor.green);
    } catch (e) {
      printColor(
        'Gagal menjalankan Print Setup automation: $e',
        textColor: TextColor.red,
      );
    }
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

    final printingTask = Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
    await Future.delayed(const Duration(milliseconds: 800));
    await _runPrintSetupAutomation();
    await printingTask;
  }
}
