import 'dart:async';
import 'dart:convert';
import 'package:colorful_print/colorful_print.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/Services/api_service_config.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/apm_antrian_model.dart';
import '../models/apm_antrian_poli_model.dart';
import '../models/dokter_model.dart';
import '../models/pendaftaran_poli_model.dart';
import '../models/poli_model.dart';

//EVENTS
abstract class AntrianApmEvent {}

// class ValidateAntrianEvent extends AntrianApmEvent {
//   final String noAntrian, jenisAntrian;
//   final String? noIdentitas;
//   ValidateAntrianEvent(this.noAntrian, this.jenisAntrian, {this.noIdentitas});
// }

class ValidateAntrianEvent extends AntrianApmEvent {
  final String noAntrian;
  final String jenisAntrian;

  ValidateAntrianEvent({required this.noAntrian, required this.jenisAntrian});
}

class PrintStrukEvent extends AntrianApmEvent {
  final PendaftaranPoliModel pendaftaranData;
  final String jenisAntrian;
  final String jaminan;
  final List<PoliModel> listPoli;

  PrintStrukEvent({
    required this.pendaftaranData,
    required this.jenisAntrian,
    required this.jaminan,
    required this.listPoli,
  });

  @override
  List<Object> get props => [pendaftaranData, jenisAntrian, jaminan];
}

class ReprintPoliEvent extends AntrianApmEvent {}

class ReprintLoketEvent extends AntrianApmEvent {}

class ReprintPendaftaranEvent extends AntrianApmEvent {}

class LanjutKePoliEvent extends AntrianApmEvent {
  final String? noBoking;
  final String? noRm;
  final String? noKtp;
  final String jenisAntrian;

  LanjutKePoliEvent({
    this.noBoking,
    this.noRm,
    this.noKtp,
    required this.jenisAntrian,
  });
}

// class LanjutKePoliSuccess extends AntrianApmState {
//   final ApmAntrianModel pendaftaranData;
//   final String jenisAntrian;

//   LanjutKePoliSuccess({
//     required this.pendaftaranData,
//     required this.jenisAntrian,
//   });
// }

class AntrianApmBlocked extends AntrianApmState {
  final String? message;
  final ApmAntrianModel apmData;

  const AntrianApmBlocked({this.message, required this.apmData});
}

class LanjutKeLoketEvent extends AntrianApmEvent {
  final ApmAntrianModel apmData;
  final String jenisAntrian;
  final String noBooking;
  LanjutKeLoketEvent(this.apmData, this.jenisAntrian, this.noBooking);
}

class LanjutKePendaftaranEvent extends AntrianApmEvent {
  final String rm;
  final String jaminan;
  final String idJadwalDokter;
  final String idDokter;
  final String idLayanan;
  final String jenisAntrian;

  LanjutKePendaftaranEvent({
    required this.rm,
    required this.jaminan,
    required this.idJadwalDokter,
    required this.idDokter,
    required this.idLayanan,
    required this.jenisAntrian,
  });
}

class FetchPoliListEvent extends AntrianApmEvent {}

class FetchDokterEvent extends AntrianApmEvent {
  final int idLayanan;
  final int? groupJaminan;

  FetchDokterEvent({required this.idLayanan, this.groupJaminan});
}

class ResetValidationEvent extends AntrianApmEvent {}

// STATES
abstract class AntrianApmState {
  const AntrianApmState();
}

class AntrianApmInitial extends AntrianApmState {
  const AntrianApmInitial();
}

class AntrianApmLoading extends AntrianApmState {
  const AntrianApmLoading();
}

class AntrianApmValidated extends AntrianApmState {
  final ApmAntrianModel apmData;
  final String jenisAntrian;
  final bool isBatalBooking;

  const AntrianApmValidated({
    required this.apmData,
    required this.jenisAntrian,
    this.isBatalBooking = false,
  });
}

class AntrianApmPrinting extends AntrianApmState {
  const AntrianApmPrinting();
}

class AntrianApmPrinted extends AntrianApmState {
  final String message;
  final String noAntrian;

  const AntrianApmPrinted(this.message, {this.noAntrian = ''});
}

class AntrianApmError extends AntrianApmState {
  final String pesan;

  const AntrianApmError(this.pesan);
}

class AntrianApmReset extends AntrianApmState {
  const AntrianApmReset();
}

class PoliListLoaded extends AntrianApmState {
  final List<PoliModel> poliList;

  const PoliListLoaded(this.poliList);
}

class DokterLoaded extends AntrianApmState {
  final List<DokterModel> dokter;
  final List<PoliModel> poliklinik;

  const DokterLoaded({required this.dokter, required this.poliklinik});
}

class PendaftaranSuccess extends AntrianApmState {
  final PendaftaranPoliModel pendaftaranData;

  const PendaftaranSuccess(this.pendaftaranData);
}

//Ambil nama poli
String getNamaPoliByIdUnit(String idUnit, List<PoliModel> listPoli) {
  final poli = listPoli.firstWhere(
    (p) => p.id.toString() == idUnit,
    orElse: () => PoliModel(id: 0, nama: '-'),
  );

  return poli.nama;
}

class PendaftaranSuccessWaitingPrint extends AntrianApmState {
  final PendaftaranPoliModel pendaftaranData;
  final String jenisAntrian;
  final String jaminan;

  const PendaftaranSuccessWaitingPrint({
    required this.pendaftaranData,
    required this.jenisAntrian,
    required this.jaminan,
  });

  @override
  List<Object> get props => [pendaftaranData, jenisAntrian, jaminan];
}

//BLOC
class AntrianApmBloc extends Bloc<AntrianApmEvent, AntrianApmState> {
  // Keep track of last printed data for reprint functionality
  ApmAntrianPoliModel? _lastPoliPrinted;
  String? _lastPoliJenis;

  ApmAntrianModel? _lastLoketApmData;
  String? _lastLoketJenis;
  String? _lastLoketNo;

  PendaftaranPoliModel? _lastPendaftaranPrinted;
  String? _lastPendaftaranJenis;
  String? _lastPendaftaranJaminan;
  List<PoliModel> _lastPendaftaranPoliList = [];

  AntrianApmBloc() : super(const AntrianApmInitial()) {
    on<ValidateAntrianEvent>(_onValidateAntrian);
    on<LanjutKePoliEvent>(_onLanjutKePoli);
    on<LanjutKeLoketEvent>(_onLanjutKeLoket);
    on<LanjutKePendaftaranEvent>(_onLanjutKePendaftaran);
    on<FetchPoliListEvent>(_onFetchPoliList);
    on<FetchDokterEvent>(_onFetchDokter);
    on<ResetValidationEvent>(_onResetValidation);
    on<PrintStrukEvent>(_onPrintStruk);
    on<ReprintPoliEvent>(_onReprintPoli);
    on<ReprintLoketEvent>(_onReprintLoket);
    on<ReprintPendaftaranEvent>(_onReprintPendaftaran);
  }

  //HTTP
  Future<Map<String, dynamic>> _requestPost(
    String url,
    Map<String, dynamic> body,
  ) async {
    printColor('POST $url | Body: $body', textColor: TextColor.cyan);

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: body.map((key, value) => MapEntry(key, value.toString())),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      final jsonResp = json.decode(response.body) as Map<String, dynamic>;
      printColor('Response: $jsonResp', textColor: TextColor.yellow);
      return jsonResp;
    } on TimeoutException catch (_) {
      printColor('HTTP Timeout', textColor: TextColor.red);
      rethrow;
    } catch (e) {
      printColor('HTTP Error: $e', textColor: TextColor.red);
      rethrow;
    }
  }

  //EVENT HANDLERS
  Future<void> _onValidateAntrian(
    ValidateAntrianEvent event,
    Emitter<AntrianApmState> emit,
  ) async {
    emit(const AntrianApmLoading());
    try {
      final resp = await _requestPost(
        '${ApiConfig.antrianApm}/${event.jenisAntrian}',
        {'no': event.noAntrian},
      );

      if (resp['code'] == 200) {
        final apmData = ApmAntrianModel.fromJson(resp['data']);
        emit(
          AntrianApmValidated(
            apmData: apmData,
            jenisAntrian: event.jenisAntrian,
            isBatalBooking: apmData.isDibatalkan,
          ),
        );
      } else {
        emit(AntrianApmError(resp['message'] ?? 'Gagal validasi'));
      }
    } catch (e) {
      emit(AntrianApmError('Error validate: $e'));
    }
  }

  Future<void> _onLanjutKePoli(
    LanjutKePoliEvent event,
    Emitter<AntrianApmState> emit,
  ) async {
    emit(const AntrianApmLoading());

    if ((event.noBoking?.isEmpty ?? true) &&
        (event.noRm?.isEmpty ?? true) &&
        (event.noKtp?.isEmpty ?? true)) {
      emit(const AntrianApmError('Nomor booking, RM, atau KTP harus diisi'));
      return;
    }

    try {
      final no = event.noBoking ?? event.noRm ?? event.noKtp;

      final respPoliData = await _requestPost(
        '${ApiConfig.antrianApmPoli}/${event.jenisAntrian}',
        {'no': no},
      );

      if (respPoliData['code'] != 200 || respPoliData['data'] == null) {
        emit(
          AntrianApmError(
            respPoliData['message'] ?? 'Data Poli tidak ditemukan',
          ),
        );
        return;
      }

      final poliData = respPoliData['data'];

      if (poliData['status_booking'] == 5) {
        emit(
          AntrianApmBlocked(
            message: 'Tiket sudah di Loket',
            apmData: ApmAntrianModel.fromJson(poliData),
          ),
        );
        return;
      }

      final body = <String, dynamic>{
        'rm': poliData['rm'],
        'id_layanan': poliData['id_layanan'],
        'jaminan': poliData['jaminan'],
        'id_dokter': poliData['id_dokter'],
        'id_jadwal_dokter': poliData['id_jadwal_dokter'],
      };

      final resp = await _requestPost(
        '${ApiConfig.daftarApmRegPoli}/${event.jenisAntrian}',
        body,
      );

      if (resp['code'] == 200 && resp['data'] != null) {
        final apmPoliData = ApmAntrianPoliModel.fromJson(resp['data']);
        final namaPoli = resp['nama_poli']?.toString() ?? '';
        apmPoliData.namaPoli = namaPoli;
        printColor('Nama Poli: $namaPoli', textColor: TextColor.green);
        _lastPoliPrinted = apmPoliData;
        _lastPoliJenis = event.jenisAntrian;

        try {
          await _printToThermalPrinterPoli(apmPoliData, event.jenisAntrian);
        } catch (e) {
          printColor('Gagal mencetak tiket Poli: $e', textColor: TextColor.red);
        }

        emit(
          AntrianApmPrinted(
            'Berhasil lanjut ke Poli',
            noAntrian: apmPoliData.noAntrianPoli,
          ),
        );
      } else if (resp['code'] == 400 && resp['data'] != null) {
        emit(
          AntrianApmBlocked(
            message: resp['message'],
            apmData: ApmAntrianModel.fromJson(resp['data']),
          ),
        );
      } else {
        emit(AntrianApmError(resp['message'] ?? 'Gagal lanjut ke Poli'));
      }
    } catch (e, st) {
      debugPrint('Error lanjut ke Poli: $e\n$st');
      emit(AntrianApmError('Error lanjut ke Poli: $e'));
    }
  }

  Future<void> _onLanjutKeLoket(
    LanjutKeLoketEvent event,
    Emitter<AntrianApmState> emit,
  ) async {
    emit(const AntrianApmPrinting());

    try {
      final url = '${ApiConfig.antrianApmLoket}/${event.noBooking}';
      printColor('POST -> $url');

      final resp = await _requestPost(url, {
        'jenis_antrian': event.jenisAntrian,
      });

      if (resp['code'] == 200) {
        final noLoket = resp['data'].toString();

        // store last loket info for reprint
        _lastLoketApmData = event.apmData;
        _lastLoketJenis = event.jenisAntrian;
        _lastLoketNo = noLoket;

        // Attempt printing but continue even if printing fails
        try {
          await _printToThermalPrinterLoket(
            event.apmData,
            event.jenisAntrian,
            noLoket,
          );
        } catch (e) {
          printColor(
            'Gagal mencetak tiket Loket: $e',
            textColor: TextColor.red,
          );
        }

        emit(AntrianApmPrinted('Berhasil lanjut ke Loket', noAntrian: noLoket));
      } else {
        emit(AntrianApmError(resp['message'] ?? 'Gagal lanjut ke Loket'));
      }
    } catch (e) {
      emit(AntrianApmError('Error lanjut ke Loket: $e'));
    }
  }

  Future<void> _onFetchPoliList(
    FetchPoliListEvent event,
    Emitter<AntrianApmState> emit,
  ) async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.poliListApm))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final jsonResp = json.decode(response.body);
        if (jsonResp['code'] == 200) {
          final poliList = (jsonResp['data'] as List)
              .map((e) => PoliModel.fromJson(e))
              .toList();
          emit(PoliListLoaded(poliList));
        } else {
          emit(AntrianApmError(jsonResp['message'] ?? 'Gagal fetch poli'));
        }
      } else {
        emit(AntrianApmError('Server error: ${response.statusCode}'));
      }
    } catch (e) {
      emit(AntrianApmError('Error fetch poli: $e'));
    }
  }

  Future<void> _onFetchDokter(
    FetchDokterEvent event,
    Emitter<AntrianApmState> emit,
  ) async {
    try {
      final resp = await _requestPost(ApiConfig.dokterJadwalApm, {
        "id_layanan": event.idLayanan.toString(),
      });

      if (resp['code'] == 200) {
        final data = resp['data'];

        List<DokterModel> dokterList = [];

        if (data is List) {
          dokterList = data
              .map((e) => DokterModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else if (data is Map) {
          dokterList = [DokterModel.fromJson(Map<String, dynamic>.from(data))];
        }

        emit(DokterLoaded(dokter: dokterList, poliklinik: []));
      } else {
        emit(AntrianApmError(resp['message'] ?? 'Gagal fetch dokter'));
      }
    } catch (e) {
      emit(AntrianApmError('Error fetch dokter: $e'));
    }
  }

  Future<void> _onLanjutKePendaftaran(
    LanjutKePendaftaranEvent event,
    Emitter<AntrianApmState> emit,
  ) async {
    emit(const AntrianApmLoading());

    try {
      if (event.rm.isEmpty) {
        throw Exception('Nomor rekam medis (RM) harus diisi');
      }

      if (event.idJadwalDokter.isEmpty) {
        throw Exception('Jadwal dokter belum dipilih');
      }

      final jenisAntrianFinal = event.jenisAntrian.isNotEmpty
          ? event.jenisAntrian
          : 'pendaftaran';

      final url = '${ApiConfig.daftarApmRegPoli}/$jenisAntrianFinal';

      final resp = await _requestPost(url, {
        'rm': event.rm,
        'jaminan': event.jaminan,
        'id_jadwal_dokter': event.idJadwalDokter,
        'id_layanan': event.idLayanan,
        'id_dokter': event.idDokter,
      });

      if (resp['code'] == 200) {
        final pendaftaranData = PendaftaranPoliModel.fromJson(resp['data']);

        _lastPendaftaranPrinted = pendaftaranData;
        _lastPendaftaranJenis = jenisAntrianFinal;
        _lastPendaftaranJaminan = event.jaminan;

        emit(const AntrianApmPrinting());

        try {
          List<PoliModel> listPoli = [];
          try {
            final response = await http
                .get(Uri.parse(ApiConfig.poliListApm))
                .timeout(const Duration(seconds: 15));
            if (response.statusCode == 200) {
              final jsonResp = json.decode(response.body);
              if (jsonResp['code'] == 200) {
                listPoli = (jsonResp['data'] as List)
                    .map((e) => PoliModel.fromJson(e))
                    .toList();
              }
            }
          } catch (e) {
            printColor(
              'Gagal fetch poli untuk print: $e',
              textColor: TextColor.yellow,
            );
          }

          await _printToThermalPrinterPendaftaran(
            pendaftaranData,
            jenisAntrianFinal,
            event.jaminan,
            listPoli,
          );
        } catch (e) {
          printColor(
            'Gagal mencetak struk pendaftaran: $e',
            textColor: TextColor.red,
          );
        }
        emit(PendaftaranSuccess(pendaftaranData));

        //
      } else if (resp['code'] == 400 && resp['data'] != null) {
        emit(
          AntrianApmBlocked(
            message: resp['message'],
            apmData: ApmAntrianModel.fromJson(resp['data']),
          ),
        );
      } else {
        emit(
          AntrianApmError(
            resp['message'] ?? 'Gagal melakukan pendaftaran poli',
          ),
        );
      }
    } catch (e) {
      emit(AntrianApmError('Error pendaftaran: $e'));
    }
  }

  Future<void> _onPrintStruk(
    PrintStrukEvent event,
    Emitter<AntrianApmState> emit,
  ) async {
    emit(const AntrianApmPrinting());

    try {
      await _printToThermalPrinterPendaftaran(
        event.pendaftaranData,
        event.jenisAntrian,
        event.jaminan,
        event.listPoli,
      );

      emit(PendaftaranSuccess(event.pendaftaranData));
    } catch (e) {
      emit(PendaftaranSuccess(event.pendaftaranData));
      print('Error printing: $e');
    }
  }

  void _onResetValidation(
    ResetValidationEvent event,
    Emitter<AntrianApmState> emit,
  ) {
    printColor('Reset state', textColor: TextColor.cyan);
    emit(const AntrianApmReset());
  }

  Future<void> _onReprintPoli(
    ReprintPoliEvent event,
    Emitter<AntrianApmState> emit,
  ) async {
    if (_lastPoliPrinted == null) {
      emit(const AntrianApmError('Tidak ada data poli untuk dicetak ulang'));
      return;
    }

    emit(const AntrianApmPrinting());

    try {
      await _printToThermalPrinterPoli(_lastPoliPrinted!, _lastPoliJenis ?? '');
      emit(
        AntrianApmPrinted(
          'Berhasil cetak ulang Poli',
          noAntrian: _lastPoliPrinted!.noAntrianPoli,
        ),
      );
    } catch (e) {
      emit(AntrianApmError('Gagal mencetak ulang Poli: $e'));
    }
  }

  Future<void> _onReprintLoket(
    ReprintLoketEvent event,
    Emitter<AntrianApmState> emit,
  ) async {
    if (_lastLoketApmData == null || _lastLoketNo == null) {
      emit(const AntrianApmError('Tidak ada data loket untuk dicetak ulang'));
      return;
    }

    emit(const AntrianApmPrinting());

    try {
      await _printToThermalPrinterLoket(
        _lastLoketApmData!,
        _lastLoketJenis ?? '',
        _lastLoketNo!,
      );
      emit(
        AntrianApmPrinted(
          'Berhasil cetak ulang Loket',
          noAntrian: _lastLoketNo!,
        ),
      );
    } catch (e) {
      emit(AntrianApmError('Gagal mencetak ulang Loket: $e'));
    }
  }

  Future<void> _onReprintPendaftaran(
    ReprintPendaftaranEvent event,
    Emitter<AntrianApmState> emit,
  ) async {
    if (_lastPendaftaranPrinted == null) {
      emit(
        const AntrianApmError('Tidak ada data pendaftaran untuk dicetak ulang'),
      );
      return;
    }

    emit(const AntrianApmPrinting());

    try {
      await _printToThermalPrinterPendaftaran(
        _lastPendaftaranPrinted!,
        _lastPendaftaranJenis ?? '',
        _lastPendaftaranJaminan ?? '',
        _lastPendaftaranPoliList,
      );
      emit(
        AntrianApmPrinted(
          'Berhasil cetak ulang Pendaftaran',
          noAntrian: _lastPendaftaranPrinted!.noAntrian,
        ),
      );
    } catch (e) {
      emit(AntrianApmError('Gagal mencetak ulang Pendaftaran: $e'));
    }
  }

  //PRINTING
  Future<void> _printToThermalPrinterPoli(
    ApmAntrianPoliModel apmPoliModel,
    String jenisAntrian,
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final qrData = json.encode(apmPoliModel.rm);

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          72 * PdfPageFormat.mm,
          100 * PdfPageFormat.mm,
        ),
        margin: const pw.EdgeInsets.all(12),
        build: (context) => _buildPoliTicket(
          apmPoliModel,
          qrData,
          _formatDate(now),
          _formatTime(now),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _printToThermalPrinterLoket(
    ApmAntrianModel apmData,
    String jenisAntrian,
    String noAntrianLoket,
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final qrData = json.encode(apmData.rm);

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          72 * PdfPageFormat.mm,
          80 * PdfPageFormat.mm,
        ),
        margin: const pw.EdgeInsets.all(12),
        build: (context) => _buildLoketTicket(
          apmData,
          qrData,
          noAntrianLoket,
          _formatDate(now),
          _formatTime(now),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _printToThermalPrinterPendaftaran(
    PendaftaranPoliModel data,
    String jenisAntrian,
    String jaminan,
    List<PoliModel> listPoli,
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final qrData = json.encode(data.rm);

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          72 * PdfPageFormat.mm,
          100 * PdfPageFormat.mm,
        ),
        margin: const pw.EdgeInsets.all(12),
        build: (context) => _buildPendaftaranTicket(
          data,
          qrData,
          jaminan,
          _formatDate(now),
          _formatTime(now),
          listPoli,
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  //HELPERS
  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  String _formatTanggal(String tanggal) {
    try {
      return tanggal.isEmpty ? '-' : _formatDate(DateTime.parse(tanggal));
    } catch (_) {
      return tanggal;
    }
  }

  //PDF TICKETS
  pw.Widget _buildHeader() => pw.Column(
    children: [
      pw.Text(
        'RSU SAKINA IDAMAN',
        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
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
    ],
  );

  pw.Widget _buildPoliTicket(
    ApmAntrianPoliModel m,
    String qrData,
    String date,
    String time,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        _buildHeader(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    m.nama.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'RM: ${m.rm}',
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
        pw.Text('No. Antrian Poli', style: const pw.TextStyle(fontSize: 9)),
        pw.Text(m.namaPoli, style: const pw.TextStyle(fontSize: 7)),
        pw.Text(
          m.noAntrianPoli,
          style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold),
        ),
        // pw.Text(m.namaPoli.toUpperCase(), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.Text('$date / $time', style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }

  pw.Widget _buildLoketTicket(
    ApmAntrianModel m,
    String qrData,
    String no,
    String date,
    String time,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'RSU SAKINA IDAMAN',
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text('ANTRIAN LOKET', style: pw.TextStyle(fontSize: 9)),
        pw.Divider(),
        pw.Text(
          no,
          style: pw.TextStyle(fontSize: 42, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.Text('$date  $time', style: pw.TextStyle(fontSize: 8)),
        pw.Divider(),
        pw.Text(
          'Silahkan menunggu panggilan',
          style: pw.TextStyle(fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  pw.Widget _buildPendaftaranTicket(
    PendaftaranPoliModel m,
    String qrData,
    String jaminan,
    String date,
    String time,
    List<PoliModel> listPoli,
  ) {
    final namaPoli = getNamaPoliByIdUnit(m.idUnit, listPoli);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        _buildHeader(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    m.nama,
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'RM: ${m.rm}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  // pw.Text('Jaminan: $jaminan', style: const pw.TextStyle(fontSize: 8)),
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
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 1),
        pw.Text('No. Antrian Poli', style: const pw.TextStyle(fontSize: 9)),
        pw.Text(namaPoli, style: const pw.TextStyle(fontSize: 7)),
        pw.SizedBox(height: 4),
        pw.Text(
          m.noAntrian,
          style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold),
        ),
        // pw.SizedBox(height: 4),
        // pw.Text(m.idUnit.toUpperCase(), style:pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('$date / $time', style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }
}
