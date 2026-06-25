import 'package:apm/blog/booking_bloc.dart';
import 'package:apm/blog/booking_event.dart';
import 'package:apm/blog/booking_state.dart';
import 'package:apm/widget/keypad_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../models/booking_model.dart';

class BookingUmumPage extends StatefulWidget {
  const BookingUmumPage({super.key});

  @override
  State<BookingUmumPage> createState() => _BookingUmumPageState();
}

class _BookingUmumPageState extends State<BookingUmumPage> {
  final _formKey = GlobalKey<FormState>();

  final _nikController = TextEditingController();
  final _nohpController = TextEditingController();
  final _emailController = TextEditingController();

  TextEditingController? _activeController;

  DateTime? _selectedDate;
  String? _selectedPoliId;
  String? _selectedDokterId;
  String? _selectedJadwalId;

  // Tambahkan untuk menyimpan nama poli dan dokter
  String? _selectedPoliNama;
  String? _selectedDokterNama;

  @override
  void dispose() {
    _nikController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state.status == BookingStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? "Terjadi kesalahan")),
          );
        }

        // Tampilkan dialog sukses
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
                        /// NIK
                        TextFormField(
                          controller: _nikController,

                          readOnly: true,

                          onTap: () {
                            _activeController = _nikController;

                            setState(() {});
                          },

                          decoration: InputDecoration(
                            labelText: 'NIK',

                            border: OutlineInputBorder(),

                            suffixIcon: _activeController == _nikController
                                ? const Icon(Icons.keyboard)
                                : null,
                          ),

                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'NIK wajib';
                            }

                            if (v.length != 16) {
                              return 'NIK harus 16 digit';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        /// NO HP
                        TextFormField(
                          controller: _nohpController,

                          readOnly: true,

                          onTap: () {
                            _activeController = _nohpController;

                            setState(() {});
                          },

                          decoration: InputDecoration(
                            labelText: 'No HP',

                            border: OutlineInputBorder(),

                            suffixIcon: _activeController == _nohpController
                                ? const Icon(Icons.keyboard)
                                : null,
                          ),

                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'No HP wajib';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        /// TANGGAL
                        InkWell(
                          onTap: _pickDate,

                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Periksa',

                              border: OutlineInputBorder(),
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

                        /// POLI
                        DropdownButtonFormField<String>(
                          value: _selectedPoliId,

                          decoration: const InputDecoration(
                            labelText: 'Pilih Poli',

                            border: OutlineInputBorder(),
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
                              // Simpan nama poli
                              final selectedPoli = state.poliList.firstWhere(
                                (e) => e.id.toString() == value,
                                orElse: () => state.poliList.first,
                              );
                              _selectedPoliNama = selectedPoli.nama;
                            });

                            if (value != null && _selectedDate != null) {
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
                        ),

                        const SizedBox(height: 16),

                        /// DOKTER
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Pilih Dokter',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          value: _selectedDokterId,
                          items: state.dokterList.map((dokter) {
                            return DropdownMenuItem(
                              value: dokter.idDokter.toString(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(dokter.namaDokter),
                                  Text(
                                    dokter.jadwalLengkap,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: dokter.isLibur
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                  ),
                                  if (dokter.terpakaiKapasitaspasien != null)
                                    Text(
                                      'Sisa Kuota: ${dokter.sisaKoutaKapasitaspasien ?? 0}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.blue,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDokterId = value;
                              // Simpan nama dokter
                              final selectedDokter = state.dokterList
                                  .firstWhere(
                                    (d) => d.idDokter.toString() == value,
                                  );
                              _selectedDokterNama = selectedDokter.namaDokter;
                              _selectedJadwalId = selectedDokter.idJadwalDetail;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Dokter wajib dipilih';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,

                          height: 55,

                          child: ElevatedButton(
                            onPressed: state.status == BookingStatus.loading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      _submitBooking(context);
                                    }
                                  },

                            child: state.status == BookingStatus.loading
                                ? const CircularProgressIndicator()
                                : const Text("BOOKING"),
                          ),
                        ),
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
                  height: 650,

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
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
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
            onPressed: () {
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
