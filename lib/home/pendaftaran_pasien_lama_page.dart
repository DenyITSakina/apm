import 'dart:async';
import 'package:apm/Blog/booking_pasien_lama_bloc.dart';
import 'package:apm/constants/app_constants.dart';
import 'package:apm/dialog/sukses.dart';
import 'package:apm/dialog/top_toast.dart';
import 'package:apm/home/dashboard_apm.dart';
import 'package:apm/models/booking_pasien_lama_model.dart';
import 'package:apm/models/dokter_model.dart';
import 'package:apm/models/poli_model.dart';
import 'package:apm/widget/custom_text_field.dart';
import 'package:apm/widget/keypad_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BookingPasienLamaPage extends StatefulWidget {
  final int initialJenisBooking;

  const BookingPasienLamaPage({super.key, this.initialJenisBooking = 1});

  @override
  State<BookingPasienLamaPage> createState() => _BookingPasienLamaPageState();
}

class _BookingPasienLamaPageState extends State<BookingPasienLamaPage> {
  final _rmController = TextEditingController();
  final _tanggalPeriksaController = TextEditingController();
  final _nomorKartuController = TextEditingController();
  final _nomorReferensiController = TextEditingController();

  DateTime? _selectedTglPeriksa;
  PoliModel? _selectedPoli;
  DokterModel? _selectedDokter;
  int _jenisBooking = 1;
  bool _isLoading = false;
  bool _isPasienValid = false;
  CekPasienData? _dataPasien;

  String? _selectedJam;

  final _formKey = GlobalKey<FormState>();
  final _rmFormKey = GlobalKey<FormState>();

  TextEditingController? _activeFieldController;

  // final List<String> _availableTimes = [
  //   '08:00',
  //   '08:30',
  //   '09:00',
  //   '09:30',
  //   '10:00',
  //   '10:30',
  //   '11:00',
  //   '11:30',
  //   '12:00',
  //   '12:30',
  //   '13:00',
  //   '13:30',
  //   '14:00',
  //   '14:30',
  //   '15:00',
  //   '15:30',
  //   '16:00',
  //   '16:30',
  //   '17:00',
  //   '17:30',
  //   '18:00',
  //   '18:30',
  //   '19:00',
  //   '19:30',
  //   '20:00',
  //   '20:30',
  //   '21:00',
  // ];

  @override
  void initState() {
    super.initState();
    _jenisBooking = widget.initialJenisBooking;
  }

  @override
  void dispose() {
    _rmController.dispose();
    _tanggalPeriksaController.dispose();
    _nomorKartuController.dispose();
    _nomorReferensiController.dispose();
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
        body: BlocConsumer<BookingPasienLamaBloc, BookingPasienLamaState>(
          listener: _handleStateListener,
          builder: (context, state) {
            if (state is BookingPasienLamaLoading && !_isPasienValid) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(AppDimens.paddingMedium),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return _buildDesktopLayout(state);
                  } else {
                    return _buildMobileLayout(state);
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BookingPasienLamaState state) {
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

                if (!_isPasienValid)
                  _buildCekRMBagian()
                else ...[
                  _buildInfoPasienCard(),
                  const SizedBox(height: AppDimens.paddingMedium),

                  if (_jenisBooking == 2) ...[
                    _buildBpjsSection(),
                    // const SizedBox(height: AppDimens.paddingMedium),
                    // _buildJamSection(),
                    const SizedBox(height: AppDimens.paddingMedium),
                  ],

                  _buildPoliDokterSection(state),
                  const SizedBox(height: AppDimens.paddingMedium),

                  _buildSubmitButton(state is BookingPasienLamaLoading),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(width: AppDimens.paddingLarge),

        if (_shouldShowKeypad())
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

  Widget _buildMobileLayout(BookingPasienLamaState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJenisBookingSelector(),
          const SizedBox(height: AppDimens.paddingMedium),

          if (!_isPasienValid)
            _buildCekRMBagianWithKeypad()
          else ...[
            _buildInfoPasienCard(),
            const SizedBox(height: AppDimens.paddingMedium),

            if (_jenisBooking == 2) ...[
              _buildBpjsSectionWithKeypad(),
              // const SizedBox(height: AppDimens.paddingMedium),
              // _buildJamSection(),
              const SizedBox(height: AppDimens.paddingMedium),
            ],

            _buildPoliDokterSection(state),
            const SizedBox(height: AppDimens.paddingMedium),

            _buildSubmitButton(state is BookingPasienLamaLoading),
          ],
        ],
      ),
    );
  }

  bool _shouldShowKeypad() {
    if (!_isPasienValid) return true;
    if (_jenisBooking == 2) {
      return _activeFieldController == _nomorKartuController ||
          _activeFieldController == _nomorReferensiController;
    }
    return false;
  }

  Widget _buildCekRMBagian() {
    return CustomSectionCard(
      title: "Cek Data Pasien",
      icon: Icons.search,
      children: [
        Form(
          key: _rmFormKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _rmController,
                label: "Nomor RM",
                icon: Icons.assignment_ind,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                onTap: () {
                  setState(() {
                    _activeFieldController = _rmController;
                  });
                },
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    setState(() {
                      _activeFieldController = _rmController;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Nomor RM wajib diisi";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _cekPasien,
                  icon: const Icon(Icons.search, size: 23),
                  label: Text(
                    _isLoading ? "Mengecek..." : "CEK PASIEN",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCekRMBagianWithKeypad() {
    return CustomSectionCard(
      title: "Cek Data Pasien",
      icon: Icons.search,
      children: [
        Form(
          key: _rmFormKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _rmController,
                label: "Nomor RM",
                icon: Icons.assignment_ind,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                onTap: () {
                  setState(() {
                    _activeFieldController = _rmController;
                  });
                },
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    setState(() {
                      _activeFieldController = _rmController;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Nomor RM wajib diisi";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              if (_activeFieldController == _rmController)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          child: KeypadSection(
                            onNumberPressed: _handleKeypadNumber,
                            onBackspacePressed: _handleKeypadBackspace,
                            onClearPressed: _handleKeypadClear,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Mengetik di Nomor RM",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _cekPasien,
                  icon: const Icon(Icons.search),
                  label: Text(_isLoading ? "Mengecek..." : "CEK PASIEN"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPasienCard() {
    return CustomSectionCard(
      title: "Data Pasien",
      icon: Icons.person,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.blue.shade700,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _dataPasien?.nama ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'RM: ${_dataPasien?.rm ?? ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildInfoRow(Icons.credit_card, "NIK", _dataPasien?.nik ?? '-'),
              _buildInfoRow(Icons.phone, "No. HP", _dataPasien?.noTelp ?? '-'),
              _buildInfoRow(
                Icons.cake,
                "Tgl Lahir",
                _dataPasien?.tglLahir != null
                    ? DateFormat(
                        'dd-MM-yyyy',
                      ).format(DateTime.parse(_dataPasien!.tglLahir))
                    : '-',
              ),
              _buildInfoRow(
                Icons.location_on,
                "Alamat",
                _dataPasien?.alamat ?? '-',
              ),
              if (_jenisBooking == 2 && _dataPasien?.noPeserta != null)
                _buildInfoRow(
                  Icons.health_and_safety,
                  "No. Peserta",
                  _dataPasien!.noPeserta!,
                ),
            ],
          ),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJenisBookingSelector() {
    return CustomSectionCard(
      title: "Pilih Jenis Booking",
      icon: Icons.assignment_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildJenisButton(
                title: "UMUM",
                value: 1,
                icon: Icons.person_outline,
              ),
            ),
            const SizedBox(width: 12),
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
      onTap: _isPasienValid
          ? () {
              setState(() {
                _jenisBooking = value;
                _selectedDokter = null;
                _selectedJam = null;
                if (_selectedPoli != null) {
                  context.read<BookingPasienLamaBloc>().add(
                    LoadDokterJadwalEvent(
                      idLayanan: _selectedPoli!.id,
                      jenisBooking: value,
                    ),
                  );
                }
              });
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black),
            const SizedBox(height: 6),
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

  Widget _buildBpjsSection() {
    return CustomSectionCard(
      title: "Data BPJS",
      icon: Icons.health_and_safety,
      children: [
        CustomTextField(
          controller: _nomorKartuController,
          label: "Nomor Kartu BPJS",
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
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
          validator: (value) {
            if (_jenisBooking == 2) {
              if (value == null || value.isEmpty) {
                return "Nomor kartu BPJS wajib diisi";
              }
              if (value.length != 13) {
                return "Nomor kartu harus 13 digit";
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: _nomorReferensiController,
          label: "Nomor Rujuk",
          icon: Icons.receipt_outlined,
          textInputAction: TextInputAction.done,
          onTap: () {
            setState(() {
              _activeFieldController = _nomorReferensiController;
            });
          },
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              setState(() {
                _activeFieldController = _nomorReferensiController;
              });
            }
          },
          validator: (value) {
            if (_jenisBooking == 2) {
              if (value == null || value.isEmpty) {
                return "Nomor rujuk wajib diisi";
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBpjsSectionWithKeypad() {
    return CustomSectionCard(
      title: "Data BPJS",
      icon: Icons.health_and_safety,
      children: [
        CustomTextField(
          controller: _nomorKartuController,
          label: "Nomor Kartu BPJS",
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
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
          validator: (value) {
            if (_jenisBooking == 2 && (value == null || value.isEmpty)) {
              return "Nomor kartu BPJS wajib diisi";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: _nomorReferensiController,
          label: "Nomor Rujuk",
          icon: Icons.receipt_outlined,
          textInputAction: TextInputAction.done,
          onTap: () {
            setState(() {
              _activeFieldController = _nomorReferensiController;
            });
          },
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              setState(() {
                _activeFieldController = _nomorReferensiController;
              });
            }
          },
          validator: (value) {
            if (_jenisBooking == 2 && (value == null || value.isEmpty)) {
              return "Nomor rujuk wajib diisi";
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        if (_activeFieldController == _nomorKartuController ||
            _activeFieldController == _nomorReferensiController)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    child: KeypadSection(
                      onNumberPressed: _handleKeypadNumber,
                      onBackspacePressed: _handleKeypadBackspace,
                      onClearPressed: _handleKeypadClear,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
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
          ),
      ],
    );
  }

  // Widget _buildJamSection() {
  //   return CustomSectionCard(
  //     title: "Pilih Jam Kunjungan",
  //     icon: Icons.access_time,
  //     children: [
  //       DropdownButtonFormField<String>(
  //         value: _selectedJam,
  //         decoration: InputDecoration(
  //           labelText: "Pilih Jam",
  //           labelStyle: GoogleFonts.poppins(
  //             fontSize: 14,
  //             color: Colors.grey.shade600,
  //           ),
  //           prefixIcon: Icon(Icons.access_time, color: Colors.teal.shade700),
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(12),
  //             borderSide: BorderSide(color: Colors.grey.shade300),
  //           ),
  //           enabledBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(12),
  //             borderSide: BorderSide(color: Colors.grey.shade300),
  //           ),
  //           focusedBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(12),
  //             borderSide: const BorderSide(color: Colors.teal, width: 2),
  //           ),
  //           errorBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(12),
  //             borderSide: const BorderSide(color: Colors.red, width: 1),
  //           ),
  //           filled: true,
  //           fillColor: Colors.white,
  //         ),
  //         items: _availableTimes.map((time) {
  //           return DropdownMenuItem<String>(
  //             value: time,
  //             child: Text(time, style: GoogleFonts.poppins(fontSize: 14)),
  //           );
  //         }).toList(),
  //         onChanged: (time) {
  //           setState(() {
  //             _selectedJam = time;
  //           });
  //         },
  //         validator: (value) {
  //           if (_jenisBooking == 2) {
  //             if (value == null) {
  //               return "Jam kunjungan wajib dipilih";
  //             }
  //           }
  //           return null;
  //         },
  //       ),
  //     ],
  //   );
  // }

  Widget _buildPoliDokterSection(BookingPasienLamaState state) {
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
                context.read<BookingPasienLamaBloc>().add(
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

                  context.read<BookingPasienLamaBloc>().add(
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
    return CustomSubmitButton(
      onPressed: _submitBooking,
      text: "KIRIM BOOKING",
      isLoading: isLoading,
    );
  }

  String _getActiveFieldName() {
    if (_activeFieldController == _rmController) return "Nomor RM";
    if (_activeFieldController == _nomorKartuController)
      return "No. Kartu BPJS";
    if (_activeFieldController == _nomorReferensiController)
      return "No. Referensi";
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
              "BOOKING PASIEN LAMA",
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
    BookingPasienLamaState state,
  ) {
    if (state is CekPasienSuccess) {
      setState(() {
        _isPasienValid = true;
        _dataPasien = state.pasien;
        _isLoading = false;
      });

      if (state.pasien.noPeserta != null && _jenisBooking == 2) {
        _nomorKartuController.text = state.pasien.noPeserta!;
      }

      context.read<BookingPasienLamaBloc>().add(LoadPoliListEvent());
      TopToast.success(context, 'Data pasien ditemukan');
    }

    if (state is CekPasienError) {
      setState(() => _isLoading = false);
      TopToast.error(context, state.message);
    }

    if (state is PoliListLoaded) {
      setState(() {});
    }

    if (state is DokterJadwalLoaded) {
      setState(() {
        _selectedDokter = null;
      });
    }

    if (state is BookingLamaError) {
      setState(() => _isLoading = false);
      TopToast.error(context, state.message);
    }

    if (state is BookingLamaSuccess) {
      setState(() => _isLoading = false);

      showSuccessDialog(
        context,
        'Booking Berhasil!\nNo Antrian: ${state.response.data?.noAntrian}\nRM: ${state.response.data?.rm}',
      ).then((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardApm()),
          (route) => false,
        );
      });
    }
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

  void _cekPasien() async {
    if (_rmFormKey.currentState?.validate() != true) {
      return;
    }

    setState(() => _isLoading = true);

    context.read<BookingPasienLamaBloc>().add(
      CekPasienEvent(rm: _rmController.text.trim()),
    );
  }

  void _submitBooking() async {
    List<String> errors = [];

    if (_selectedTglPeriksa == null) {
      errors.add("Tanggal periksa wajib diisi");
    }

    if (_selectedPoli == null) {
      errors.add("Pilih poli terlebih dahulu");
    }

    if (_selectedDokter == null) {
      errors.add("Pilih dokter terlebih dahulu");
    }

    if (_jenisBooking == 2) {
      if (_selectedDokter != null &&
          (_selectedDokter!.jadwal == null ||
              _selectedDokter!.jadwal!.isEmpty)) {
        errors.add(
          "Dokter yang dipilih harus memiliki jadwal untuk booking BPJS",
        );
      }

      if (_nomorKartuController.text.isEmpty) {
        errors.add("Nomor kartu BPJS wajib diisi");
      } else if (_nomorKartuController.text.length != 13) {
        errors.add("Nomor kartu BPJS harus 13 digit");
      }

      if (_nomorReferensiController.text.isEmpty) {
        errors.add("Nomor rujuk wajib diisi");
      }

      if (_selectedJam == null || _selectedJam!.isEmpty) {
        errors.add("Jam kunjungan wajib dipilih untuk BPJS");
      }
    }

    if (errors.isNotEmpty) {
      TopToast.error(context, errors.first);
      return;
    }

    setState(() => _isLoading = true);

    if (_jenisBooking == 1) {
      final request = BookingPasienLamaRequest(
        rm: _dataPasien!.rm,
        idUnit: _selectedPoli!.id,
        idDokter: _selectedDokter!.idDokter,
        tanggalperiksa: DateFormat('yyyy-MM-dd').format(_selectedTglPeriksa!),
        jadwal: '',
        idJadwalDokter: _selectedDokter!.idJadwal,
        kapasitaspasien: _selectedDokter!.kapasitasPasien,
        jenisBooking: 1,
        nomorkartu: null,
        noReferensi: null,
        kodepoli: null,
        namapoli: null,
        kodedokter: null,
        namadokter: null,
        jeniskunjungan: null,
      );

      context.read<BookingPasienLamaBloc>().add(
        SubmitBookingLamaEvent(request: request),
      );
    } else {
      final request = BookingPasienLamaRequest(
        rm: _dataPasien!.rm,
        idUnit: _selectedPoli!.id,
        idDokter: _selectedDokter!.idDokter,
        tanggalperiksa: DateFormat('yyyy-MM-dd').format(_selectedTglPeriksa!),
        jadwal: _selectedJam!,
        idJadwalDokter: _selectedDokter!.idJadwal,
        kapasitaspasien: _selectedDokter!.kapasitasPasien,
        jenisBooking: 2,
        nomorkartu: _nomorKartuController.text.trim(),
        noReferensi: _nomorReferensiController.text.trim(),
        kodepoli: _selectedPoli!.kodeBpjs,
        namapoli: _selectedPoli!.nama,
        kodedokter: _selectedDokter!.kodeDokter,
        namadokter: _selectedDokter!.namaDokter,
        jeniskunjungan: 1,
      );

      context.read<BookingPasienLamaBloc>().add(
        SubmitBookingLamaEvent(request: request),
      );
    }
  }
}
