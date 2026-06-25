import 'package:apm/blog/booking_bloc.dart';
import 'package:apm/blog/booking_event.dart';
import 'package:apm/blog/booking_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';

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
  DateTime? _selectedDate;
  bool _isDataLoaded = false;
  String? _selectedDokterId;
  int? _selectedPoliId; // Tambahkan untuk menyimpan poli yang dipilih

  @override
  void dispose() {
    _noBpjsController.dispose();
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

        if (state.status == BookingStatus.loaded &&
            state.pasienBpjs != null &&
            !_isDataLoaded) {
          setState(() {
            _isDataLoaded = true;
          });

          // Auto select poli based on rujukan
          if (state.pasienBpjs!.kodePoliRujukan != null) {
            final matchedPoli = state.poliList.firstWhere(
              (p) => p.kodeBpjs == state.pasienBpjs!.kodePoliRujukan,
              orElse: () => state.poliList.first,
            );
            if (matchedPoli.id != 0) {
              setState(() {
                _selectedPoliId = matchedPoli.id;
              });
              // Load dokter JKN dengan tanggal (jika sudah dipilih)
              _loadDokterJkn(context, matchedPoli.id);
            }
          }
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
                // No BPJS
                TextFormField(
                  controller: _noBpjsController,
                  decoration: InputDecoration(
                    labelText: 'No BPJS',
                    hintText: 'Masukkan No BPJS (13 digit)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.card_membership),
                    suffixIcon: state.pasienBpjs != null
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                  keyboardType: TextInputType.number,
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
                const SizedBox(height: 8),

                // Cek BPJS Button
                if (state.pasienBpjs == null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.status == BookingStatus.loading
                          ? null
                          : () {
                              if (_noBpjsController.text.length == 13) {
                                context.read<BookingBloc>().add(
                                  CekPasienBpjsEvent(_noBpjsController.text),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
                          : const Text('Cek Data BPJS'),
                    ),
                  ),
                const SizedBox(height: 16),

                // Data Pasien BPJS
                if (state.pasienBpjs != null) ...[
                  _buildInfoCard('Data Pasien', [
                    _buildInfoItem('Nama', state.pasienBpjs!.nama),
                    _buildInfoItem('NIK', state.pasienBpjs!.nik),
                    _buildInfoItem('No BPJS', state.pasienBpjs!.noPeserta),
                    if (state.pasienBpjs!.noTelp != null)
                      _buildInfoItem('No HP', state.pasienBpjs!.noTelp!),
                    if (state.pasienBpjs!.jenisKelamin != null)
                      _buildInfoItem(
                        'Jenis Kelamin',
                        state.pasienBpjs!.jenisKelamin!,
                      ),
                    if (state.pasienBpjs!.poliRujukan != null)
                      _buildInfoItem(
                        'Poli Rujukan',
                        state.pasienBpjs!.poliRujukan!,
                      ),
                  ]),
                  const SizedBox(height: 16),

                  // No HP (override)
                  TextFormField(
                    controller: _nohpController,
                    decoration: const InputDecoration(
                      labelText: 'No HP',
                      hintText: 'Masukkan No HP (opsional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 15,
                  ),
                  const SizedBox(height: 16),

                  // Email (Optional)
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email (Opsional)',
                      hintText: 'Masukkan Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Format email tidak valid';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tanggal Periksa (Pindahkan sebelum Poli & Dokter)
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
                          _selectedDokterId =
                              null; // Reset dokter saat tanggal berubah
                        });
                        // Jika poli sudah dipilih, load dokter dengan tanggal baru
                        if (_selectedPoliId != null) {
                          _loadDokterJkn(context, _selectedPoliId!);
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

                  // Poli (Auto select from rujukan)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Pilih Poli',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_hospital),
                    ),
                    value: _selectedPoliId?.toString(),
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
                        });
                        // Load dokter dengan tanggal yang dipilih
                        _loadDokterJkn(context, int.parse(value));
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
                          : const Text(
                              'Booking',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method untuk load dokter JKN
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

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
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

  void _submitBooking(BuildContext context) {
    final state = context.read<BookingBloc>().state;
    final selectedDokter = state.dokterList.firstWhere(
      (d) => d.idDokter.toString() == _selectedDokterId,
    );

    final request = BookingRequest(
      jenis: '2',
      nik: state.pasienBpjs!.nik,
      nohp: _nohpController.text.isNotEmpty
          ? _nohpController.text
          : state.pasienBpjs!.noTelp ?? '', // fallback
      idUnit: _selectedPoliId!,
      idDokter: int.parse(_selectedDokterId!),
      tanggalPeriksa: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      idJadwalDokter: selectedDokter.idJadwalDetail,
      noBpjs: state.pasienBpjs!.noPeserta,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
    );

    context.read<BookingBloc>().add(SubmitBookingBpjsEvent(request));
  }
}
