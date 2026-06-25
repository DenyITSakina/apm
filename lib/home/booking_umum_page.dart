import 'package:apm/blog/booking_bloc.dart';
import 'package:apm/blog/booking_event.dart';
import 'package:apm/blog/booking_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';

class BookingUmumPage extends StatefulWidget {
  const BookingUmumPage({Key? key}) : super(key: key);

  @override
  State<BookingUmumPage> createState() => _BookingUmumPageState();
}

class _BookingUmumPageState extends State<BookingUmumPage> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _nohpController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedPoliId;
  String? _selectedDokterId;
  String? _selectedJadwalId;

  @override
  void dispose() {
    _nikController.dispose();
    _nohpController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        // Handle error
        if (state.status == BookingStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NIK
                TextFormField(
                  controller: _nikController,
                  decoration: const InputDecoration(
                    labelText: 'NIK',
                    hintText: 'Masukkan NIK (16 digit)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIK wajib diisi';
                    }
                    if (value.length != 16) {
                      return 'NIK harus 16 digit';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'NIK harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // No HP
                TextFormField(
                  controller: _nohpController,
                  decoration: const InputDecoration(
                    labelText: 'No HP',
                    hintText: 'Masukkan No HP',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 15,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'No HP wajib diisi';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'No HP harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tanggal Periksa (Pindahkan sebelum Dokter)
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                        _selectedDokterId = null;
                        _selectedJadwalId = null;
                      });
                      // Jika poli sudah dipilih, load dokter dengan tanggal baru
                      if (_selectedPoliId != null) {
                        context.read<BookingBloc>().add(
                          LoadDokterUmumEvent(
                            idLayanan: int.parse(_selectedPoliId!),
                            tanggal: DateFormat('yyyy-MM-dd').format(date),
                          ),
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
                          ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                          : 'Pilih Tanggal',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Poli
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Pilih Poli',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                  value: _selectedPoliId,
                  items: state.poliList.map((poli) {
                    return DropdownMenuItem(
                      value: poli.id.toString(),
                      child: Text(poli.nama),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPoliId = value;
                      _selectedDokterId = null;
                      _selectedJadwalId = null;
                    });
                    if (value != null && _selectedDate != null) {
                      // Load dokter dengan tanggal yang dipilih
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

                // Dokter
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
                              color: dokter.isLibur ? Colors.red : Colors.grey,
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
                      // Find selected dokter and get jadwal id
                      final selectedDokter = state.dokterList.firstWhere(
                        (d) => d.idDokter.toString() == value,
                      );
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
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state.status == BookingStatus.loading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate() &&
                                _selectedDate != null &&
                                _selectedDokterId != null) {
                              _submitBooking(context);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: state.status == BookingStatus.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Booking', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitBooking(BuildContext context) {
    final state = context.read<BookingBloc>().state;
    final selectedDokter = state.dokterList.firstWhere(
      (d) => d.idDokter.toString() == _selectedDokterId,
    );

    final request = BookingRequest(
      jenis: '1',
      nik: _nikController.text,
      nohp: _nohpController.text,
      idUnit: int.parse(_selectedPoliId!),
      idDokter: int.parse(_selectedDokterId!),
      tanggalPeriksa: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      idJadwalDokter: selectedDokter.idJadwalDetail,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
    );

    context.read<BookingBloc>().add(SubmitBookingUmumEvent(request));
  }
}
