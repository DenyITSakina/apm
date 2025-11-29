import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../Blog Antrian APM/antrian_apm_bloc.dart';
import '../../models/apm/apm_antrian_model.dart';

class PendaftaranDialog extends StatefulWidget {
  final ApmAntrianModel pasienData;
  final List<PoliModel> listPoli;
  final VoidCallback onDialogClose;

  const PendaftaranDialog({
    super.key,
    required this.pasienData,
    required this.listPoli,
    required this.onDialogClose,
  });

  @override
  State<PendaftaranDialog> createState() => _PendaftaranDialogState();
}

class _PendaftaranDialogState extends State<PendaftaranDialog> {
  PoliModel? selectedPoli;
  DokterModel? selectedDokter;
  String selectedTipe = 'UMUM';
  bool isSubmitting = false;
  bool? isSuccess;
  String serverMessage = "";

  PendaftaranPoliModel? _pendaftaranData;
  String? _jenisAntrianFinal;
  String? _jaminanFinal;

  late final TextEditingController tglController;

  @override
  void initState() {
    super.initState();
    tglController = TextEditingController(
      text: DateTime.now().toString().split(' ')[0],
    );
  }

  @override
  void dispose() {
    tglController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      selectedPoli = null;
      selectedDokter = null;
      selectedTipe = 'UMUM';
      isSubmitting = false;
      isSuccess = null;
      serverMessage = "";
      _pendaftaranData = null;
      _jenisAntrianFinal = null;
      _jaminanFinal = null;
      tglController.text = DateTime.now().toString().split(' ')[0];
    });

    // Reset state Bloc jika perlu
    context.read<AntrianApmBloc>().add(ResetValidationEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 20,
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: BlocListener<AntrianApmBloc, AntrianApmState>(
          listener: (context, state) {
            if (state is PendaftaranSuccessWaitingPrint) {
              setState(() {
                isSubmitting = false;
                isSuccess = true;
                serverMessage = state.pendaftaranData.noAntrian;
                _pendaftaranData = state.pendaftaranData;
                _jenisAntrianFinal = state.jenisAntrian;
                _jaminanFinal = state.jaminan;
              });
            } else if (state is PendaftaranSuccess) {
              setState(() {
                isSubmitting = false;
                isSuccess = true;
                serverMessage = state.pendaftaranData.noAntrian;
                _pendaftaranData = null;
              });
            } else if (state is AntrianApmError) {
              setState(() {
                isSubmitting = false;
                isSuccess = false;
                serverMessage = state.pesan;
              });
            } else if (state is DokterLoaded) {
              setState(() {});
            }
          },
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isSubmitting) return _buildLoading();
    if (isSuccess == true) return _buildSuccessContent();
    //if (isSuccess == false) return _buildErrorContent();
    return _buildFormContent();
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingAnimationWidget.dotsTriangle(size: 60, color: Colors.teal),
          const SizedBox(height: 22),
          Text(
            "Mengirim data...",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 6),
          const Text(
            "Mohon tunggu sebentar",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_hospital, size: 36, color: Colors.teal),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Form Pendaftaran',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal[700]),
                ),
              ),
            ],
          ),
          Divider(height: 28, thickness: 1.5, color: Colors.teal[100]),
          const SizedBox(height: 12),
          Text('Nama Pasien', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(widget.pasienData.pasien, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedTipe,
            items: ['UMUM', 'JKN'].map((tipe) => DropdownMenuItem(value: tipe, child: Text(tipe))).toList(),
            onChanged: (value) => setState(() => selectedTipe = value!),
            decoration: InputDecoration(
              labelText: 'Tipe Pasien',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: tglController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Tanggal',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: Icon(Icons.calendar_today, color: Colors.teal),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<PoliModel>(
            value: selectedPoli,
            hint: const Text('Pilih POLI'),
            items: widget.listPoli.map((poli) => DropdownMenuItem(value: poli, child: Text(poli.poli))).toList(),
            onChanged: (value) {
              setState(() {
                selectedPoli = value;
                selectedDokter = null;
              });
              if (value != null) {
                context.read<AntrianApmBloc>().add(FetchDokterEvent(
                      idLayanan: value.id,
                      groupJaminan: selectedTipe == "UMUM" ? 1 : 2,
                    ));
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<AntrianApmBloc, AntrianApmState>(
            builder: (context, state) {
              if (state is AntrianApmLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is DokterLoaded && state.dokter.isNotEmpty) {
                return DropdownButtonFormField<DokterModel>(
                  value: selectedDokter,
                  hint: const Text("Pilih Dokter"),
                  items: state.dokter.map((dokter) => DropdownMenuItem(value: dokter, child: Text(dokter.namaDokter))).toList(),
                  onChanged: (value) => setState(() => selectedDokter = value),
                  decoration: InputDecoration(
                    labelText: "Dokter",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                );
              }

              return const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text("Belum ada dokter untuk poli ini", style: TextStyle(fontSize: 12, color: Colors.red)),
              );
            },
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Batal', style: TextStyle(color: Colors.grey[700], fontSize: 14))),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPoli != null && selectedDokter != null ? Colors.teal : Colors.grey[400],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 6,
                ),
                onPressed: selectedPoli != null && selectedDokter != null
                    ? () {
                        setState(() => isSubmitting = true);
                        context.read<AntrianApmBloc>().add(LanjutKePendaftaranEvent(
                              rm: widget.pasienData.rm.toString(),
                              jaminan: selectedTipe,
                              idJadwalDokter: selectedDokter!.id.toString(),
                              idLayanan: selectedPoli!.id.toString(),
                              jenisAntrian: 'pendaftaran',
                            ));
                      }
                    : null,
                child: const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, size: 90, color: Colors.teal),
        const SizedBox(height: 14),
        Text(
          "Pendaftaran Berhasil!",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.teal[800], letterSpacing: 0.3),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Divider(color: Colors.teal[100], thickness: 1),
        const SizedBox(height: 14),
        const Text("Nomor Antrian", style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text(serverMessage, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.teal, letterSpacing: 1.2)),
        const SizedBox(height: 26),
        if (_pendaftaranData != null)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: Colors.teal),
                  ),
                  onPressed: () {
                    // _resetForm();
                    Navigator.pop(context);
                    // widget.onDialogClose();   
                  },
                  child: const Text("Tutup", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.teal)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                  onPressed: () {
                    context.read<AntrianApmBloc>().add(PrintStrukEvent(
                          pendaftaranData: _pendaftaranData!,
                          jenisAntrian: _jenisAntrianFinal!,
                          jaminan: _jaminanFinal!,
                        ));
                  },
                  child: const Text("Print Struk", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                //_resetForm();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Tutup", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  // Widget _buildErrorContent() {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Icon(Icons.error_rounded, size: 90, color: Colors.redAccent),
  //       const SizedBox(height: 14),
  //       Text(
  //         "Pendaftaran Gagal",
  //         style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.red[700], letterSpacing: 0.3),
  //         textAlign: TextAlign.center,
  //       ),
  //       const SizedBox(height: 14),
  //       Divider(color: Colors.red[100], thickness: 1),
  //       const SizedBox(height: 14),
  //       Text(serverMessage, style: const TextStyle(fontSize: 15.5, color: Colors.grey, height: 1.4), textAlign: TextAlign.center),
  //       const SizedBox(height: 26),
  //       SizedBox(
  //         width: double.infinity,
  //         child: OutlinedButton(
  //           style: OutlinedButton.styleFrom(
  //             side: const BorderSide(color: Colors.redAccent, width: 1.2),
  //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //             padding: const EdgeInsets.symmetric(vertical: 12),
  //           ),
  //           onPressed: () => setState(() => isSuccess = null),
  //           child: const Text("Kembali", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.redAccent)),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
