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
import 'package:google_fonts/google_fonts.dart'; // Tambahkan import ini

import '../models/booking_model.dart';
import '../theme/format_text.dart';

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
  void dispose() {
    _noBpjsController.dispose();
    _nohpController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _appendNumber(String value) {
    if (_activeController == null) return;
    setState(() {
      _activeController!.text += value;
    });
  }

  void _backspace() {
    if (_activeController == null) return;
    if (_activeController!.text.isNotEmpty) {
      setState(() {
        _activeController!.text = _activeController!.text.substring(
          0,
          _activeController!.text.length - 1,
        );
      });
    }
  }

  void _clear() {
    _activeController?.clear();
    setState(() {});
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info jumlah dokter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            '${state.dokterList.where((d) => !d.isLibur && (d.sisaKoutaKapasitaspasien ?? 0) > 0).length} dokter tersedia',
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
                        _isDokterSelected = true;
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
      body: Column(
        children: [
          // Main content
          Expanded(
            child: BlocConsumer<BookingBloc, BookingState>(
              listener: (context, state) {
                if (state.status == BookingStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }

                if (state.status == BookingStatus.loaded &&
                    state.pasienBpjs != null &&
                    !_isDataLoaded) {
                  setState(() {
                    _isDataLoaded = true;
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
                      /// FORM
                      Expanded(
                        flex: 3,
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
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
                                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                      return 'No BPJS harus berupa angka';
                                    }
                                    return null;
                                  },
                                ),

                                if (state.pasienBpjs == null)
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed:
                                          state.status == BookingStatus.loading
                                          ? null
                                          : () {
                                              if (_noBpjsController
                                                      .text
                                                      .length ==
                                                  13) {
                                                context.read<BookingBloc>().add(
                                                  CekPasienBpjsEvent(
                                                    _noBpjsController.text,
                                                  ),
                                                );
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
                                          state.status == BookingStatus.loading
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
                                        MapEntry('NIK', state.pasienBpjs!.nik),
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
                                        if (state.pasienBpjs!.noTelp != null &&
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
                                        if (state.pasienBpjs!.tglLahir != null)
                                          MapEntry(
                                            'Tgl Lahir',
                                            state.pasienBpjs!.tglLahir!,
                                          ),
                                        if (state.pasienBpjs!.poliRujukan !=
                                            null)
                                          MapEntry(
                                            'Poli Rujukan',
                                            state.pasienBpjs!.kodePoliRujukan!,
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
                                        prefixIcon: Icon(Icons.calendar_today),
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
                                            _selectedPoliId = int.parse(value);
                                            _selectedDokterId = null;
                                            _selectedDokterNama = null;
                                            final selectedPoli = state.poliList
                                                .firstWhere(
                                                  (e) =>
                                                      e.id.toString() == value,
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

                                  // DropdownButtonFormField<String>(
                                  //   decoration: const InputDecoration(
                                  //     labelText: 'Pilih Dokter',
                                  //     border: OutlineInputBorder(),
                                  //     prefixIcon: Icon(Icons.person),
                                  //   ),
                                  //   value: _selectedDokterId,
                                  //   items: state.dokterList.map((dokter) {
                                  //     return DropdownMenuItem(
                                  //       value: dokter.idDokter.toString(),
                                  //       child: Column(
                                  //         crossAxisAlignment: CrossAxisAlignment.start,
                                  //         children: [
                                  //           Text(dokter.namaDokter),
                                  //           Text(
                                  //             dokter.jadwalLengkap,
                                  //             style: TextStyle(
                                  //               fontSize: 12,
                                  //               color: dokter.isLibur
                                  //                   ? Colors.red
                                  //                   : Colors.grey,
                                  //             ),
                                  //           ),
                                  //           if (dokter.terpakaiKapasitaspasien != null)
                                  //             Text(
                                  //               'Sisa Kuota: ${dokter.sisaKoutaKapasitaspasien ?? 0}',
                                  //               style: const TextStyle(
                                  //                 fontSize: 10,
                                  //                 color: Colors.blue,
                                  //               ),
                                  //             ),
                                  //         ],
                                  //       ),
                                  //     );
                                  //   }).toList(),
                                  //   onChanged: (value) {
                                  //     setState(() {
                                  //       _selectedDokterId = value;
                                  //       final selectedDokter = state.dokterList
                                  //           .firstWhere(
                                  //             (d) => d.idDokter.toString() == value,
                                  //           );
                                  //       _selectedDokterNama = selectedDokter.namaDokter;
                                  //     });
                                  //   },
                                  //   validator: (value) {
                                  //     if (value == null || value.isEmpty) {
                                  //       return 'Dokter wajib dipilih';
                                  //     }
                                  //     return null;
                                  //   },
                                  // ),
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
                                      ? const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(20),
                                            child: Column(
                                              children: [
                                                CircularProgressIndicator(),
                                                SizedBox(height: 12),
                                                Text('Memuat data dokter...'),
                                              ],
                                            ),
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
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed:
                                          state.status == BookingStatus.loading
                                          ? null
                                          : () {
                                              if (_formKey.currentState!
                                                      .validate() &&
                                                  _selectedDate != null &&
                                                  _selectedDokterId != null) {
                                                _submitBooking(context);
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child:
                                          state.status == BookingStatus.loading
                                          ? const CircularProgressIndicator()
                                          : const Text("BOOKING"),
                                    ),
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
              "RSU Sakina Idaman • Pelayanan Booking BPJS",
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

  // void _submitBooking(BuildContext context) {
  //   final state = context.read<BookingBloc>().state;
  //   final selectedDokter = state.dokterList.firstWhere(
  //     (d) => d.idDokter.toString() == _selectedDokterId,
  //   );

  //   final request = BookingRequest(
  //     jenis: '2',
  //     nik: state.pasienBpjs!.nik,
  //     nohp: _nohpController.text.isNotEmpty
  //         ? _nohpController.text
  //         : state.pasienBpjs!.noTelp ?? '',
  //     idUnit: _selectedPoliId!,
  //     idDokter: int.parse(_selectedDokterId!),
  //     tanggalPeriksa: DateFormat('yyyy-MM-dd').format(_selectedDate!),
  //     idJadwalDokter: selectedDokter.idJadwalDetail,
  //     noBpjs: state.pasienBpjs!.noPeserta,
  //     email: _emailController.text.isNotEmpty ? _emailController.text : null,
  //   );

  //   context.read<BookingBloc>().add(SubmitBookingBpjsEvent(request));
  // }
  void _submitBooking(BuildContext context) {
    final state = context.read<BookingBloc>().state;
    final pasien = state.pasienBpjs!;

    final selectedDokter = state.dokterList.firstWhere(
      (d) => d.idDokter.toString() == _selectedDokterId,
    );

    final request = BookingRequest(
      jenis: '2',
      nik: pasien.nik,
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
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Booking Berhasil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('No. Antrian', data.noAntrian),
            _buildInfoRow('Kode Booking', data.kodeBooking),
            _buildInfoRow(
              'Nama Pasien',
              data.namaPasien.isNotEmpty ? data.namaPasien : '-',
            ),
            _buildInfoRow('Tanggal Periksa', data.tanggalPeriksa),
            _buildInfoRow('Unit', unitName),
            _buildInfoRow('Dokter', dokterName),
          ],
        ),
        actions: [
          TextButton(
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
            child: const Text('OK'),
          ),
        ],
      ),
    );
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
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
}
