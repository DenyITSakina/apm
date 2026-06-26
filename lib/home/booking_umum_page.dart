import 'package:apm/blog/booking/booking_bloc.dart';
import 'package:apm/blog/booking/booking_event.dart';
import 'package:apm/blog/booking/booking_state.dart';
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
        // Info jumlah dokter
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
    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state.status == BookingStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? "Terjadi kesalahan"),
              backgroundColor: Colors.red,
            ),
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
                            border: const OutlineInputBorder(),
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
                            border: const OutlineInputBorder(),
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

                        /// EMAIL (Optional)
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email (Optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v != null && v.isNotEmpty) {
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(v)) {
                                return 'Email tidak valid';
                              }
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

                        /// POLI
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Poli wajib dipilih';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        /// LABEL PILIH DOKTER
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

                        /// LIST DOKTER
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

                        /// TAMPILKAN DOKTER TERPILIH
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
                                  style: TextStyle(fontWeight: FontWeight.w500),
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

                        /// SUBMIT BUTTON
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
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
