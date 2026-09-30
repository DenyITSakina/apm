import 'package:apm/blog/booking/booking_bloc.dart';
import 'package:apm/blog/booking/booking_event.dart';
import 'package:apm/blog/booking/booking_state.dart';
import 'package:apm/dialog/top_toast.dart';
import 'package:apm/func/open_aplikasi_bpjsDaftar.dart';
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

class BookingBpjsPage extends StatefulWidget {
  const BookingBpjsPage({Key? key}) : super(key: key);

  @override
  State<BookingBpjsPage> createState() => _BookingBpjsPageState();
}

class _BookingBpjsPageState extends State<BookingBpjsPage> {
  final _formKey = GlobalKey<FormState>();
  final _noBpjsController = TextEditingController();
  final _nohpController = TextEditingController();
  final _emailController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  TextEditingController? _activeController;

  DateTime? _selectedDate;
  bool _isDataLoaded = false;
  String? _selectedDokterId;
  int? _selectedPoliId;

  bool _isDokterSelected = false;

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
    _noBpjsController.dispose();
    _nohpController.dispose();
    _emailController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _appendNumber(String value) {
    if (_activeController == null) return;
    final current = _activeController!.text;
    // Batasi panjang input (13 digit untuk BPJS)
    if (current.length >= 13) return;

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
            accent: AppColors.bpjs,
            isSelected: _selectedDokterId == dokter.idDokter.toString(),
            onTap: () {
              setState(() {
                _selectedDokterId = dokter.idDokter.toString();
                _selectedDokterNama = dokter.namaDokter;
                _isDokterSelected = true;
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
            // Main content
            Expanded(
              child: BlocConsumer<BookingBloc, BookingState>(
                listener: (context, state) {
                  if (state.status == BookingStatus.error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.errorMessage ?? 'Terjadi kesalahan',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    _refocusScanner();
                  }

                  if (state.status == BookingStatus.loaded &&
                      state.pasienBpjs != null &&
                      !_isDataLoaded) {
                    setState(() {
                      _isDataLoaded = true;
                      // _noBpjsController.clear();
                    });

                    final kodePoliRujukan = state.pasienBpjs!.kodePoliRujukan;
                    if (kodePoliRujukan != null &&
                        kodePoliRujukan.trim().isNotEmpty) {
                      final matchedPoli = state.poliList.firstWhere(
                        (p) => p.kodeBpjs.trim() == kodePoliRujukan.trim(),
                        orElse: () => state.poliList.first,
                      );

                      if (matchedPoli.id != 0) {
                        setState(() {
                          _selectedPoliId = matchedPoli.id;
                          _selectedPoliNama = matchedPoli.nama;
                        });

                        if (_selectedDate != null) {
                          _loadDokterJkn(context, matchedPoli.id);
                        }
                      }
                    }
                  }

                  if (state.status == BookingStatus.success &&
                      state.bookingResult != null) {
                    _showSuccessDialog(context, state);
                  }
                },
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Hidden TextField untuk scanner
                                  SizedBox(
                                    width: 0,
                                    height: 0,
                                    child: TextField(
                                      controller: _noBpjsController,
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
                                      onSubmitted: (value) {
                                        if (_noBpjsController.text.length ==
                                            13) {
                                          context.read<BookingBloc>().add(
                                            CekPasienBpjsEvent(
                                              _noBpjsController.text,
                                            ),
                                          );
                                        }
                                      },
                                      enableInteractiveSelection: false,
                                      enableIMEPersonalizedLearning: false,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _noBpjsController,
                                    readOnly: true,
                                    onTap: () {
                                      _activeController = _noBpjsController;
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'No BPJS',
                                      hintText: 'Masukkan No BPJS (13 digit)',
                                      border: const OutlineInputBorder(),
                                      suffixIcon: state.pasienBpjs != null
                                          ? const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            )
                                          : (_activeController ==
                                                    _noBpjsController
                                                ? const Icon(Icons.keyboard)
                                                : null),
                                    ),
                                    maxLength: 13,
                                    enabled: state.pasienBpjs == null,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'No BPJS wajib diisi';
                                      }
                                      if (value.length != 13) {
                                        return 'No BPJS harus 13 digit';
                                      }
                                      if (!RegExp(
                                        r'^[0-9]+$',
                                      ).hasMatch(value)) {
                                        return 'No BPJS harus berupa angka';
                                      }
                                      return null;
                                    },
                                  ),

                                  if (state.pasienBpjs == null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Colors.blue.shade700,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Informasi Penting!',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '• Silahkan scan barcode atau klik dulu no inputan baru mengisi lewat keypad',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.blue.shade800,
                                              height: 1.5,
                                            ),
                                          ),
                                          Text(
                                            '• Pastikan nomor BPJS yang Anda masukkan sudah benar (13 digit angka)',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.blue.shade800,
                                              height: 1.5,
                                            ),
                                          ),
                                          Text(
                                            '• Klik tombol "Cek Data BPJS" untuk memverifikasi kevalidan nomor Anda',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.blue.shade800,
                                              height: 1.5,
                                            ),
                                          ),
                                          Text(
                                            '• Data yang terverifikasi akan otomatis mengisi formulir booking',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.blue.shade800,
                                              height: 1.5,
                                            ),
                                          ),
                                          Text(
                                            '• Jika nomor BPJS tidak ditemukan, silakan hubungi petugas pendaftaran / front office',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.blue.shade800,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],

                                  if (state.pasienBpjs == null)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed:
                                            state.status ==
                                                BookingStatus.loading
                                            ? null
                                            : () {
                                                if (_noBpjsController
                                                        .text
                                                        .length ==
                                                    13) {
                                                  context
                                                      .read<BookingBloc>()
                                                      .add(
                                                        CekPasienBpjsEvent(
                                                          _noBpjsController
                                                              .text,
                                                        ),
                                                      );
                                                } else {
                                                  TopToast.warning(
                                                    context,
                                                    'Nomor BPJS harus 13 digit',
                                                  );
                                                  _refocusScanner();
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(
                                            double.infinity,
                                            30,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 25,
                                            vertical: 25,
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child:
                                            state.status ==
                                                BookingStatus.loading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                            : const Text('Cek Data BPJS'),
                                      ),
                                    ),
                                  const SizedBox(height: 2),

                                  if (state.pasienBpjs != null) ...[
                                    _buildInfoCard('Data Pasien', [
                                      _buildExpandableInfo(
                                        items: <MapEntry<String, String>>[
                                          MapEntry(
                                            'Nama',
                                            state.pasienBpjs!.nama,
                                          ),
                                          MapEntry(
                                            'NIK',
                                            state.pasienBpjs!.nik,
                                          ),
                                          MapEntry(
                                            'No BPJS',
                                            state.pasienBpjs!.noPeserta,
                                          ),
                                          if (state.pasienBpjs!.noKunjungan !=
                                                  null &&
                                              state
                                                  .pasienBpjs!
                                                  .noKunjungan!
                                                  .isNotEmpty)
                                            MapEntry(
                                              'No Kunjungan',
                                              state.pasienBpjs!.noKunjungan!,
                                            ),
                                          if (state.pasienBpjs!.noTelp !=
                                                  null &&
                                              state
                                                  .pasienBpjs!
                                                  .noTelp!
                                                  .isNotEmpty)
                                            MapEntry(
                                              'No HP',
                                              state.pasienBpjs!.noTelp!,
                                            ),
                                          if (state.pasienBpjs!.jenisKelamin !=
                                              null)
                                            MapEntry(
                                              'Jenis Kelamin',
                                              state.pasienBpjs!.jenisKelamin!,
                                            ),
                                          if (state.pasienBpjs!.tglLahir !=
                                              null)
                                            MapEntry(
                                              'Tgl Lahir',
                                              state.pasienBpjs!.tglLahir!,
                                            ),
                                          if (state.pasienBpjs!.poliRujukan !=
                                              null)
                                            MapEntry(
                                              'Poli Rujukan',
                                              state
                                                  .pasienBpjs!
                                                  .kodePoliRujukan!,
                                            ),
                                        ],
                                        initialVisibleCount: 4,
                                      ),
                                    ]),

                                    const SizedBox(height: 12),

                                    InkWell(
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now().add(
                                            const Duration(days: 30),
                                          ),
                                        );
                                        if (date != null) {
                                          setState(() {
                                            _selectedDate = date;
                                            _selectedDokterId = null;
                                            _selectedDokterNama = null;
                                          });
                                          if (_selectedPoliId != null) {
                                            _loadDokterJkn(
                                              context,
                                              _selectedPoliId!,
                                            );
                                          }
                                        }
                                      },
                                      child: InputDecorator(
                                        decoration: const InputDecoration(
                                          labelText: 'Tanggal Periksa',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(
                                            Icons.calendar_today,
                                          ),
                                        ),
                                        child: Text(
                                          _selectedDate != null
                                              ? DateFormat(
                                                  'dd/MM/yyyy',
                                                ).format(_selectedDate!)
                                              : 'Pilih Tanggal',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    AbsorbPointer(
                                      absorbing:
                                          state.pasienBpjs != null &&
                                          _selectedPoliId != null &&
                                          _selectedPoliId != 0,
                                      child: DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          labelText: 'Pilih Poli',
                                          border: const OutlineInputBorder(),
                                          prefixIcon: const Icon(
                                            Icons.local_hospital,
                                          ),
                                          helperText:
                                              state.pasienBpjs != null &&
                                                  _selectedPoliId != null &&
                                                  _selectedPoliId != 0
                                              ? '🔒 Poli ditentukan dari rujukan BPJS'
                                              : null,
                                          helperStyle: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                        value:
                                            (_selectedPoliId == null ||
                                                _selectedPoliId == 0)
                                            ? null
                                            : _selectedPoliId!.toString(),
                                        items: state.poliList.map((poli) {
                                          return DropdownMenuItem(
                                            value: poli.id.toString(),
                                            child: Text(poli.nama),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              _selectedPoliId = int.parse(
                                                value,
                                              );
                                              _selectedDokterId = null;
                                              _selectedDokterNama = null;
                                              final selectedPoli = state
                                                  .poliList
                                                  .firstWhere(
                                                    (e) =>
                                                        e.id.toString() ==
                                                        value,
                                                  );
                                              _selectedPoliNama =
                                                  selectedPoli.nama;
                                            });

                                            if (_selectedDate != null) {
                                              _loadDokterJkn(
                                                context,
                                                int.parse(value),
                                              );
                                            }
                                          }
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Poli wajib dipilih';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // List dokter dengan status
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
                                                _isDokterSelected = false;
                                              });
                                            },
                                            child: const Text('Hapus Pilihan'),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // List dokter
                                    state.status == BookingStatus.loadingDokter
                                        ? const Padding(
                                            padding: EdgeInsets.all(
                                              AppSpacing.lg,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                        color: AppColors.primary,
                                                      ),
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Memuat data dokter...',
                                                  style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : _buildDokterList(state),

                                    const SizedBox(height: 12),

                                    // Tampilkan dokter terpilih
                                    if (_selectedDokterId != null)
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                                _selectedDokterNama ?? '-',
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
                                    const SizedBox(height: 12),

                                    /// Submit Button
                                    AppGradientButton(
                                      label: 'BOOKING',
                                      icon: Icons.event_available_rounded,
                                      gradient: AppGradients.bpjs,
                                      height: 58,
                                      loading:
                                          state.status == BookingStatus.loading,
                                      onPressed:
                                          state.status == BookingStatus.loading
                                          ? null
                                          : () {
                                              if (_formKey.currentState!
                                                      .validate() &&
                                                  _selectedDate !=
                                                      null &&
                                                  _selectedDokterId !=
                                                      null) {
                                                _submitBooking(context);
                                              }
                                            },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        /// KEYPAD
                        Expanded(
                          flex: 2,
                          child: NumberKeypad(
                            accent: AppColors.bpjs,
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
      message: 'RSU Sakina Idaman - Pelayanan Booking BPJS',
    );
  }

  void _loadDokterJkn(BuildContext context, int idLayanan) {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final tanggal = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    context.read<BookingBloc>().add(
      LoadDokterJknEvent(idLayanan: idLayanan, tanggal: tanggal),
    );
  }

  Widget _buildInfoCard(
    String title,
    List<Widget> children, {
    IconData icon = Icons.description_outlined,
    Color color = Colors.blue,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withOpacity(.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade200, thickness: 1),

            /// CONTENT
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(': $value')),
        ],
      ),
    );
  }

  Widget _buildExpandableInfo({
    required List<MapEntry<String, String>> items,
    int initialVisibleCount = 4,
  }) {
    final visibleCount = initialVisibleCount.clamp(0, items.length);
    final firstBatch = items.take(visibleCount).toList();
    final remaining = items.skip(visibleCount).toList();

    if (remaining.isEmpty) {
      return Column(
        children: firstBatch
            .map((e) => _buildInfoItem(e.key, e.value))
            .toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...firstBatch.map((e) => _buildInfoItem(e.key, e.value)),
        ...[
          ExpansionTile(
            title: const Text('Lihat info lainnya'),
            children: remaining
                .map(
                  (e) => Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: _buildInfoItem(e.key, e.value),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  void _submitBooking(BuildContext context) async {
    final state = context.read<BookingBloc>().state;
    final pasien = state.pasienBpjs!;

    final nik = pasien.nik;

    if (nik.isNotEmpty) {
      final success = await openExeFromMap(context, {"nomor": nik});

      if (!success) {
        return;
      }
    } else {
      TopToast.error(context, "NIK tidak ditemukan pada data pasien!");
      return;
    }

    final selectedDokter = state.dokterList.firstWhere(
      (d) => d.idDokter.toString() == _selectedDokterId,
    );

    final request = BookingRequest(
      jenis: '2',
      nik: nik,
      nohp: _nohpController.text.isNotEmpty
          ? _nohpController.text
          : pasien.noTelp ?? '',
      idUnit: _selectedPoliId!,
      idDokter: int.parse(_selectedDokterId!),
      tanggalPeriksa: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      idJadwalDokter: selectedDokter.idJadwalDetail,
      noBpjs: pasien.noPeserta,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      noKunjungan: pasien.noKunjungan,
    );

    context.read<BookingBloc>().add(SubmitBookingBpjsEvent(request));
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
                  _buildDivider(),
                  // _buildInfoRow(
                  //   Icons.access_time,
                  //   'Jam Praktek',
                  //   data.jamBooking,
                  // ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                flex: 3,
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

    // await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    final printingTask = Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
    await Future.delayed(const Duration(milliseconds: 800));
    await _runPrintSetupAutomation();
    await printingTask;
  }
}
