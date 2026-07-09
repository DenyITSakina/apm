import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:apm/api/api_config.dart';
import 'package:apm/utils/print_setup_runner.dart';
import 'package:colorful_print/colorful_print.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/apm_antrian_model.dart';
import '../models/apm_antrian_poli_model.dart';
import '../models/apm_antrian_loket_model.dart';
import '../models/dokter_model.dart';
import '../models/pendaftaran_poli_model.dart';
import '../models/poli_model.dart';
import '../theme/format_text.dart';

abstract class AntrianApmEvent {
  const AntrianApmEvent();
}

class ValidateAntrianEvent extends AntrianApmEvent {
  final String noAntrian;
  final String jenisAntrian;

  const ValidateAntrianEvent({
    required this.noAntrian,
    required this.jenisAntrian,
  });

  @override
  List<Object> get props => [noAntrian, jenisAntrian];
}

class PrintStrukEvent extends AntrianApmEvent {
  final PendaftaranPoliModel pendaftaranData;
  final String jenisAntrian;
  final String jaminan;
  final List<PoliModel> listPoli;

  const PrintStrukEvent({
    required this.pendaftaranData,
    required this.jenisAntrian,
    required this.jaminan,
    required this.listPoli,
  });

  @override
  List<Object> get props => [pendaftaranData, jenisAntrian, jaminan];
}

class ReprintPoliEvent extends AntrianApmEvent {
  const ReprintPoliEvent();
}

class ReprintLoketEvent extends AntrianApmEvent {
  const ReprintLoketEvent();
}

class ReprintPendaftaranEvent extends AntrianApmEvent {
  const ReprintPendaftaranEvent();
}

class AntrianApmLoaded extends AntrianApmState {
  final Map<String, dynamic> poliData;

  const AntrianApmLoaded(this.poliData);

  @override
  List<Object> get props => [poliData];
}

class LanjutKePoliEvent extends AntrianApmEvent {
  final String? noBoking;
  final String? noRm;
  final String? noKtp;
  final String? noPeserta;
  final String jenisAntrian;

  const LanjutKePoliEvent({
    this.noBoking,
    this.noRm,
    this.noKtp,
    this.noPeserta,
    required this.jenisAntrian,
  });

  @override
  List<Object> get props => [jenisAntrian];
}

class LanjutKeLoketEvent extends AntrianApmEvent {
  final ApmAntrianModel apmData;
  final String jenisAntrian;
  final String noBooking;

  const LanjutKeLoketEvent({
    required this.apmData,
    required this.jenisAntrian,
    required this.noBooking,
  });

  @override
  List<Object> get props => [apmData, jenisAntrian, noBooking];
}

class LanjutKePendaftaranEvent extends AntrianApmEvent {
  final String rm;
  final String jaminan;
  final String idJadwalDokter;
  final String idDokter;
  final String idLayanan;
  final String jenisAntrian;

  const LanjutKePendaftaranEvent({
    required this.rm,
    required this.jaminan,
    required this.idJadwalDokter,
    required this.idDokter,
    required this.idLayanan,
    required this.jenisAntrian,
  });

  @override
  List<Object> get props => [
    rm,
    jaminan,
    idJadwalDokter,
    idDokter,
    idLayanan,
    jenisAntrian,
  ];
}

class FetchPoliListEvent extends AntrianApmEvent {
  const FetchPoliListEvent();
}

class FetchDokterEvent extends AntrianApmEvent {
  final int idLayanan;
  final int? groupJaminan;

  const FetchDokterEvent({required this.idLayanan, this.groupJaminan});

  @override
  List<Object> get props => [idLayanan];
}

class ResetValidationEvent extends AntrianApmEvent {
  const ResetValidationEvent();
}

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

  @override
  List<Object> get props => [apmData, jenisAntrian, isBatalBooking];
}

class AntrianApmPrinting extends AntrianApmState {
  const AntrianApmPrinting();
}

class AntrianApmPrinted extends AntrianApmState {
  final String message;
  final String noAntrian;

  const AntrianApmPrinted(this.message, {this.noAntrian = ''});

  @override
  List<Object> get props => [message, noAntrian];
}

class AntrianApmError extends AntrianApmState {
  final String pesan;

  const AntrianApmError(this.pesan);

  @override
  List<Object> get props => [pesan];
}

class AntrianApmReset extends AntrianApmState {
  const AntrianApmReset();
}

class AntrianApmBlocked extends AntrianApmState {
  final String message;
  final ApmAntrianModel apmData;

  const AntrianApmBlocked({required this.message, required this.apmData});

  @override
  List<Object> get props => [message, apmData];
}

class PoliListLoaded extends AntrianApmState {
  final List<PoliModel> poliList;

  const PoliListLoaded(this.poliList);

  @override
  List<Object> get props => [poliList];
}

class DokterLoaded extends AntrianApmState {
  final List<DokterModel> dokterList;
  final List<PoliModel> poliList;

  const DokterLoaded({required this.dokterList, required this.poliList});

  @override
  List<Object> get props => [dokterList, poliList];
}

// class PendaftaranSuccess extends AntrianApmState {
//   final PendaftaranPoliModel pendaftaranData;

//   const PendaftaranSuccess(this.pendaftaranData);

//   @override
//   List<Object> get props => [pendaftaranData];
// }

class PendaftaranSuccess extends AntrianApmState {
  final PendaftaranPoliModel pendaftaranData;
  final String message;

  const PendaftaranSuccess({
    required this.pendaftaranData,
    required this.message,
  });

  @override
  List<Object> get props => [pendaftaranData, message];
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

class AntrianApmBloc extends Bloc<AntrianApmEvent, AntrianApmState> {
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
        throw HttpException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      final jsonResp = json.decode(response.body) as Map<String, dynamic>;
      printColor('Response: $jsonResp', textColor: TextColor.yellow);
      return jsonResp;
    } on TimeoutException catch (_) {
      printColor('HTTP Timeout', textColor: TextColor.red);
      rethrow;
    } on HttpException catch (e) {
      printColor('HTTP Error: $e', textColor: TextColor.red);
      rethrow;
    } catch (e) {
      printColor('Error: $e', textColor: TextColor.red);
      rethrow;
    }
  }

  // Future<void> _onValidateAntrian(
  //   ValidateAntrianEvent event,
  //   Emitter<AntrianApmState> emit,
  // ) async {
  //   emit(const AntrianApmLoading());

  //   try {
  //     final resp = await _requestPost(
  //       '${ApiConfig.antrianApm}/${event.jenisAntrian}',
  //       {'no': event.noAntrian},
  //     );

  //     if (resp['code'] == 200) {
  //       final apmData = ApmAntrianModel.fromJson(resp['data']);

  //       if (apmData.isDibatalkan) {
  //         emit(
  //           AntrianApmValidated(
  //             apmData: apmData,
  //             jenisAntrian: event.jenisAntrian,
  //             isBatalBooking: true,
  //           ),
  //         );
  //       } else {
  //         emit(
  //           AntrianApmValidated(
  //             apmData: apmData,
  //             jenisAntrian: event.jenisAntrian,
  //             isBatalBooking: false,
  //           ),
  //         );
  //       }
  //     } else {
  //       emit(AntrianApmError(resp['message'] ?? 'Gagal validasi antrian'));
  //     }
  //   } on HttpException catch (e) {
  //     emit(AntrianApmError('Koneksi gagal: ${e.message}'));
  //   } catch (e) {
  //     emit(AntrianApmError('Error validasi: $e'));
  //   }
  // }

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
        final apmData = ApmAntrianModel.fromJson(resp);

        if (!apmData.isValid) {
          emit(AntrianApmError('Data pasien tidak ditemukan'));
          return;
        }

        if (apmData.isDibatalkan) {
          emit(
            AntrianApmValidated(
              apmData: apmData,
              jenisAntrian: event.jenisAntrian,
              isBatalBooking: true,
            ),
          );
        } else {
          emit(
            AntrianApmValidated(
              apmData: apmData,
              jenisAntrian: event.jenisAntrian,
              isBatalBooking: false,
            ),
          );
        }
      } else {
        emit(AntrianApmError(resp['message'] ?? 'Gagal validasi antrian'));
      }
    } on HttpException catch (e) {
      emit(AntrianApmError('Koneksi gagal: ${e.message}'));
    } catch (e) {
      emit(AntrianApmError('Error validasi: $e'));
    }
  }

  Future<void> _onLanjutKeLoket(
    LanjutKeLoketEvent event,
    Emitter<AntrianApmState> emit,
  ) async {
    emit(const AntrianApmPrinting());

    try {
      final url = '${ApiConfig.antrianApmLoket}/${event.jenisAntrian}';
      final resp = await _requestPost(url, {'no': event.noBooking});

      if (resp['code'] == 200) {
        final loketDataJson = resp['data'];
        final loketData = loketDataJson is Map<String, dynamic>
            ? ApmAntrianLoketModel.fromJson(loketDataJson)
            : ApmAntrianLoketModel.fromJson(
                (loketDataJson as Map).cast<String, dynamic>(),
              );

        try {
          await _printToThermalPrinterLoket(
            event.apmData,
            event.jenisAntrian,
            loketData,
          );
        } catch (e) {
          printColor(
            'Gagal mencetak tiket Loket: $e',
            textColor: TextColor.red,
          );
        }

        emit(
          AntrianApmPrinted(
            'Berhasil lanjut ke Loket',
            noAntrian: loketData.noAntrian.toString(),
          ),
        );
      } else {
        emit(AntrianApmError(resp['message'] ?? 'Gagal lanjut ke Loket'));
      }
    } catch (e) {
      emit(AntrianApmError('Error lanjut ke Loket: $e'));
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

        try {
          final poliResponse = await http
              .get(Uri.parse(ApiConfig.poliListApm))
              .timeout(const Duration(seconds: 15));

          if (poliResponse.statusCode == 200) {
            final jsonResp = json.decode(poliResponse.body);
            if (jsonResp['code'] == 200) {
              _lastPendaftaranPoliList = (jsonResp['data'] as List)
                  .map((e) => PoliModel.fromJson(e))
                  .toList();
            }
          }
        } catch (e) {
          printColor('Gagal fetch poli: $e', textColor: TextColor.yellow);
        }

        emit(const AntrianApmPrinting());

        try {
          await _printToThermalPrinterPendaftaran(
            pendaftaranData,
            jenisAntrianFinal,
            event.jaminan,
            _lastPendaftaranPoliList,
          );
        } catch (e) {
          printColor('Gagal cetak struk: $e', textColor: TextColor.red);
        }

        emit(
          PendaftaranSuccess(
            pendaftaranData: pendaftaranData,
            message: "Pasien berhasil didaftarkan!",
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

  Future<void> _onLanjutKePoli(
    LanjutKePoliEvent event,
    Emitter<AntrianApmState> emit,
  ) async {
    emit(const AntrianApmLoading());

    try {
      final no = event.noPeserta ?? event.noRm ?? event.noKtp ?? '';
      if (no.isEmpty) {
        emit(const AntrianApmError('Nomor pasien tidak boleh kosong'));
        return;
      }

      final url = '${ApiConfig.antrianApmPoli}/${event.jenisAntrian}';

      final resp = await _requestPost(url, {'no': no});

      if (resp['code'] != 200 || resp['data'] == null) {
        emit(AntrianApmError(resp['message'] ?? 'Data Poli tidak ditemukan'));
        return;
      }

      final poliData = resp['data'];
      printColor('Data Poli: $poliData', textColor: TextColor.green);

      // final apmPoliData = ApmAntrianPoliModel.fromJson(poliData);
      final apmPoliData = ApmAntrianPoliModel.fromJson(resp);

      try {
        await _printToThermalPrinterPoli(apmPoliData, event.jenisAntrian);
      } catch (e) {
        printColor('Gagal mencetak tiket Poli: $e', textColor: TextColor.red);
      }

      emit(AntrianApmPrinted('Tiket POLI berhasil dicetak'));

      emit(AntrianApmLoaded(poliData));
    } catch (e, st) {
      debugPrint('Error fetch antrian poli: $e\n$st');
      emit(AntrianApmError('Error fetch antrian poli: $e'));
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

  // Future<void> _onFetchDokter(
  //   FetchDokterEvent event,
  //   Emitter<AntrianApmState> emit,
  // ) async {
  //   try {
  //     final resp = await _requestPost(ApiConfig.dokterJadwalApm, {
  //       "id_layanan": event.idLayanan.toString(),
  //     });
  //     if (resp['code'] == 200) {
  //       final data = resp['data'];
  //       List<DokterModel> dokterList = [];

  //       if (data is List) {
  //         dokterList = data
  //             .map((e) => DokterModel.fromJson(Map<String, dynamic>.from(e)))
  //             .toList();
  //       } else if (data is Map) {
  //         dokterList = [DokterModel.fromJson(Map<String, dynamic>.from(data))];
  //       }

  //       // Ambil data poli untuk konteks
  //       List<PoliModel> poliList = [];
  //       try {
  //         final poliResp = await _onFetchPoliListInternal();
  //         poliList = poliResp;
  //       } catch (_) {}

  //       emit(DokterLoaded(dokterList: dokterList, poliList: poliList));
  //     } else {
  //       emit(AntrianApmError(resp['message'] ?? 'Gagal fetch dokter'));
  //     }
  //   } catch (e) {
  //     emit(AntrianApmError('Error fetch dokter: $e'));
  //   }
  // }

  Future<void> _onFetchDokter(
    FetchDokterEvent event,
    Emitter<AntrianApmState> emit,
  ) async {
    try {
      final int idLayanan = event.idLayanan;
      final int jadwalGroup = event.groupJaminan ?? 1;

      // groupJaminan: 1 = Umum, 2 = JKN/BPJS (ikut penamaan yang ada di UI)
      final String tanggal = _formatDate(DateTime.now());

      // Panggilan dokter bedakan umum vs jkn
      List<DokterModel> dokterList = [];
      try {
        final url = jadwalGroup == 2
            ? ApiConfig.baseUrl + '/jadwal-dokter-jkn'
            : ApiConfig.baseUrl + '/jadwal-dokter-umum';

        final resp = await _requestPost(url, {
          'id_layanan': idLayanan.toString(),
          'tanggal': tanggal,
        });

        if (resp['code'] == 200 && resp['data'] != null) {
          final data = resp['data'];
          if (data is List) {
            dokterList = data
                .map((e) => DokterModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          } else if (data is Map) {
            dokterList = [
              DokterModel.fromJson(Map<String, dynamic>.from(data)),
            ];
          }
        } else {
          emit(AntrianApmError(resp['message'] ?? 'Gagal fetch dokter'));
          return;
        }
      } catch (e) {
        emit(AntrianApmError('Error fetch dokter: $e'));
        return;
      }

      // Ambil poli list
      List<PoliModel> poliList = [];
      try {
        final poliResp = await _onFetchPoliListInternal();
        poliList = poliResp;
      } catch (_) {}

      emit(DokterLoaded(dokterList: dokterList, poliList: poliList));
    } catch (e) {
      emit(AntrianApmError('Error fetch dokter: $e'));
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

      emit(
        PendaftaranSuccess(
          pendaftaranData: event.pendaftaranData,
          message: "Pasien berhasil didaftarkan!",
        ),
      );
    } catch (e) {
      emit(AntrianApmError('Gagal mencetak: $e'));
    }
  }

  void _onResetValidation(
    ResetValidationEvent event,
    Emitter<AntrianApmState> emit,
  ) {
    printColor('Reset validation state', textColor: TextColor.cyan);
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
      await _printToThermalPrinterPoli(
        _lastPoliPrinted!,
        _lastPoliJenis ?? 'umum',
      );
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
        _lastLoketJenis ?? 'umum',
        _lastLoketNo as ApmAntrianLoketModel,
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
        _lastPendaftaranJenis ?? 'umum',
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

  Future<List<PoliModel>> _onFetchPoliListInternal() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.poliListApm))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResp = json.decode(response.body);

        if (jsonResp['code'] == 200) {
          return (jsonResp['data'] as List)
              .map((e) => PoliModel.fromJson(e))
              .toList();
        }
      }
    } catch (_) {}

    return [];
  }

  Future<void> _runPrintSetupAutomation() async {
    try {
      printColor(
        'Menjalankan Print Setup automation...',
        textColor: TextColor.cyan,
      );
      await Future.delayed(const Duration(milliseconds: 200));
      await PrintSetupRunner.runScript('print_setup.py');
      printColor('Print Setup automation selesai!', textColor: TextColor.green);
    } catch (e) {
      printColor(
        'Gagal menjalankan Print Setup automation: $e',
        textColor: TextColor.red,
      );
    }
  }

  Future<void> _printToThermalPrinterPoli(
    ApmAntrianPoliModel apmPoliModel,
    String jenisAntrian,
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final qrData = apmPoliModel.rm;
    final logoBytes = (await rootBundle.load(
      'assets/images/logo.webp',
    )).buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          210 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 2 * PdfPageFormat.mm,
        ),
        build: (context) => _buildPoliTicket(
          apmPoliModel,
          qrData,
          _formatDate(now),
          _formatTime(now),
          logoBytes,
        ),
      ),
    );
    printColor('Menampilkan Print Setup dialog...', textColor: TextColor.cyan);

    final printingTask = Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );

    await Future.delayed(const Duration(milliseconds: 800));
    await _runPrintSetupAutomation();
    await printingTask;
  }

  Future<void> _runPrintSetupAutomation2() async {
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

  Future<void> _printToThermalPrinterLoket(
    ApmAntrianModel apmData,
    String jenisAntrian,
    ApmAntrianLoketModel loketData,
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
          loketData,
          _formatDate(now),
          _formatTime(now),
        ),
      ),
    );
    printColor('Menampilkan Print Setup dialog...', textColor: TextColor.cyan);

    final printingTask = Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );

    await Future.delayed(const Duration(milliseconds: 800));
    await _runPrintSetupAutomation2();
    await printingTask;
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
    final logoBytes = (await rootBundle.load(
      'assets/images/logo.webp',
    )).buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          210 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 2 * PdfPageFormat.mm,
        ),
        build: (context) => _buildPendaftaranTicket(
          data,
          qrData,
          jaminan,
          _formatDate(now),
          _formatTime(now),
          listPoli,
          logoBytes,
        ),
      ),
    );

    printColor('Menampilkan Print Setup dialog...', textColor: TextColor.cyan);

    final printingTask = Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );

    await Future.delayed(const Duration(milliseconds: 800));
    await _runPrintSetupAutomation();
    await printingTask;
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';

  pw.Widget _buildHeader() => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
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

  pw.Widget _buildCardHeader(Uint8List logoBytes) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 2)),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 20,
            height: 20,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 1),
              color: PdfColors.grey200,
            ),
            child: pw.Center(
              child: pw.Image(
                pw.MemoryImage(logoBytes),
                width: 15,
                height: 15,
                fit: pw.BoxFit.contain,
              ),
            ),
          ),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'RSU SAKINA IDAMAN',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Jl. Nyi Tjondro Loekito No.60 | Telp. 0274 501 8021 - 0274 502 9090',
                  style: const pw.TextStyle(fontSize: 7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCardInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 30,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(': $value', style: const pw.TextStyle(fontSize: 7)),
        ],
      ),
    );
  }

  pw.Widget _buildCardFormTable() {
    return pw.Table(
      border: pw.TableBorder.all(width: 1),
      columnWidths: const {
        0: pw.FixedColumnWidth(20),
        1: pw.FixedColumnWidth(20),
        2: pw.FlexColumnWidth(0.6),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildCardTableCell(
              'Ket.',
              textAlign: pw.TextAlign.center,
              fontWeight: pw.FontWeight.bold,
            ),
            _buildCardTableCell(
              'No.',
              textAlign: pw.TextAlign.center,
              fontWeight: pw.FontWeight.bold,
            ),
            _buildCardTableCell(
              'Prosedur',
              textAlign: pw.TextAlign.center,
              fontWeight: pw.FontWeight.bold,
            ),
            _buildCardTableCell(
              'Paraf',
              textAlign: pw.TextAlign.center,
              fontWeight: pw.FontWeight.bold,
            ),
            _buildCardTableCell(
              'Keterangaan',
              textAlign: pw.TextAlign.center,
              fontWeight: pw.FontWeight.bold,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCardTableCell(
              'A',
              textAlign: pw.TextAlign.center,
              fontWeight: pw.FontWeight.bold,
            ),
            _buildCardTableCell('', textAlign: pw.TextAlign.center),
            _buildCardTableCell('Konsultasi', fontWeight: pw.FontWeight.bold),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCardTableCell(''),
            _buildCardTableCell('1', textAlign: pw.TextAlign.center),
            _buildCardTableCell(''),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCardTableCell(''),
            _buildCardTableCell('2', textAlign: pw.TextAlign.center),
            _buildCardTableCell(''),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCardTableCell(
              'B',
              textAlign: pw.TextAlign.center,
              fontWeight: pw.FontWeight.bold,
            ),
            _buildCardTableCell('', textAlign: pw.TextAlign.center),
            _buildCardTableCell(
              'Tindakan Medis',
              fontWeight: pw.FontWeight.bold,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCardTableCell(''),
            _buildCardTableCell('1', textAlign: pw.TextAlign.center),
            _buildCardTableCell(''),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCardTableCell(''),
            _buildCardTableCell('2', textAlign: pw.TextAlign.center),
            _buildCardTableCell(''),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCardTableCell(
              'C',
              textAlign: pw.TextAlign.center,
              fontWeight: pw.FontWeight.bold,
            ),
            _buildCardTableCell('', textAlign: pw.TextAlign.center),
            _buildCardTableCell(
              'Penunjang Medis',
              fontWeight: pw.FontWeight.bold,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCardTableCell(''),
            _buildCardTableCell('1', textAlign: pw.TextAlign.center),
            _buildCardTableCell(''),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCardTableCell(''),
            _buildCardTableCell('2', textAlign: pw.TextAlign.center),
            _buildCardTableCell(''),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCardTableCell(
              'D',
              textAlign: pw.TextAlign.center,
              fontWeight: pw.FontWeight.bold,
            ),
            _buildCardTableCell('', textAlign: pw.TextAlign.center),
            _buildCardTableCell('Resep', fontWeight: pw.FontWeight.bold),
          ],
        ),
        pw.TableRow(
          children: [
            _buildCardTableCell(
              'E',
              textAlign: pw.TextAlign.center,
              fontWeight: pw.FontWeight.bold,
            ),
            _buildCardTableCell('', textAlign: pw.TextAlign.center),
            _buildCardTableCell('Lain-lain', fontWeight: pw.FontWeight.bold),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCardTableCell(
    String text, {
    pw.TextAlign textAlign = pw.TextAlign.left,
    pw.FontWeight fontWeight = pw.FontWeight.normal,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2),
      child: pw.Text(
        text,
        textAlign: textAlign,
        style: pw.TextStyle(fontSize: 7, fontWeight: fontWeight),
      ),
    );
  }

  pw.Widget _buildPoliTicket(
    ApmAntrianPoliModel m,
    String qrData,
    String date,
    String time,
    Uint8List logoBytes,
  ) {
    return pw.Container(
      width: 200 * PdfPageFormat.mm,
      padding: const pw.EdgeInsets.all(2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildCardHeader(logoBytes),
          pw.SizedBox(height: 3),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 35,
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 1.5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildCardInfoRow('RM', m.rm),
                            _buildCardInfoRow(
                              'Nama',
                              formatNama(m.nama.toUpperCase()),
                            ),
                            _buildCardInfoRow(
                              'Tgl Lahir',
                              m.tanggalLahir ?? '-',
                            ),
                            _buildCardInfoRow(
                              'Tgl Admisi',
                              '${m.tanggalBooking} ${m.jamBooking}' ?? '-',
                            ),
                            _buildCardInfoRow('Poli', formatNama(m.namaPoli)),
                            _buildCardInfoRow(
                              'Dokter',
                              m.namadokter.isNotEmpty ? m.namadokter : '-',
                            ),
                          ],
                        ),
                      ),
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 1.5)),
                        ),
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.center,
                                children: [
                                  pw.Text(
                                    'NO ANTRIAN',
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  pw.Text(
                                    m.noAntrianPoli,
                                    style: pw.TextStyle(
                                      fontSize: 29,
                                      fontWeight: pw.FontWeight.bold,
                                      height: 1,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(width: 3),
                            pw.SizedBox(
                              width: 57,
                              height: 57,
                              child: pw.BarcodeWidget(
                                barcode: pw.Barcode.qrCode(),
                                data: qrData,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 4),
              pw.Expanded(
                flex: 80,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1.5),
                        color: PdfColors.grey300,
                      ),
                      padding: const pw.EdgeInsets.all(2),
                      child: pw.Center(
                        child: pw.Text(
                          'FORMULIR KENDALI TINDAKAN RAWAT JALAN',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          left: pw.BorderSide(width: 1.5),
                          right: pw.BorderSide(width: 1.5),
                          bottom: pw.BorderSide(width: 1.5),
                        ),
                      ),
                      child: _buildCardFormTable(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(width: 1)),
            ),
            padding: const pw.EdgeInsets.only(top: 3),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Generated: $date $time',
                  style: const pw.TextStyle(fontSize: 7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildLoketTicket(
    ApmAntrianModel m,
    String qrData,
    ApmAntrianLoketModel loketData,
    String date,
    String time,
  ) {
    return pw.Container(
      width: 210 * PdfPageFormat.mm,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          _buildHeader(),
          pw.Text(
            'ANTRIAN LOKET',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(),
          pw.Text(
            loketData.noAntrian.toString(),
            style: pw.TextStyle(fontSize: 42, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text('${loketData.waktu}', style: const pw.TextStyle(fontSize: 8)),
          pw.Divider(),
          pw.Text(
            'Silahkan menunggu panggilan',
            style: const pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPendaftaranTicket(
    PendaftaranPoliModel m,
    String qrData,
    String jaminan,
    String date,
    String time,
    List<PoliModel> listPoli,
    Uint8List logoBytes,
  ) {
    final namaPoli = m.namaPoli;

    return pw.Container(
      width: 200 * PdfPageFormat.mm,
      padding: const pw.EdgeInsets.all(2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildCardHeader(logoBytes),
          pw.SizedBox(height: 3),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 35,
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 1.5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildCardInfoRow('RM', m.rm),
                            _buildCardInfoRow(
                              'Nama',
                              formatNama(m.nama.toUpperCase()),
                            ),
                            _buildCardInfoRow(
                              'Tgl Lahir',
                              m.tglLahir.isNotEmpty ? m.tglLahir : '-',
                            ),
                            _buildCardInfoRow(
                              'Tgl Admisi',
                              '${m.tglMasuk} ${m.jamMasuk}'.trim().isNotEmpty
                                  ? '${m.tglMasuk} ${m.jamMasuk}'.trim()
                                  : '-',
                            ),
                            _buildCardInfoRow('Poli', formatNama(namaPoli)),
                            _buildCardInfoRow(
                              'Dokter',
                              m.namaDokter.isNotEmpty ? m.namaDokter : '-',
                            ),
                          ],
                        ),
                      ),
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(width: 1.5)),
                        ),
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.center,
                                children: [
                                  pw.Text(
                                    'NO ANTRIAN',
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  pw.Text(
                                    m.noAntrian,
                                    style: pw.TextStyle(
                                      fontSize: 29,
                                      fontWeight: pw.FontWeight.bold,
                                      height: 1,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(width: 3),
                            pw.SizedBox(
                              width: 60,
                              height: 60,
                              child: pw.BarcodeWidget(
                                barcode: pw.Barcode.qrCode(),
                                data: qrData,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 4),
              pw.Expanded(
                flex: 80,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1.5),
                        color: PdfColors.grey300,
                      ),
                      padding: const pw.EdgeInsets.all(2),
                      child: pw.Center(
                        child: pw.Text(
                          'FORMULIR KENDALI TINDAKAN RAWAT JALAN',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          left: pw.BorderSide(width: 1.5),
                          right: pw.BorderSide(width: 1.5),
                          bottom: pw.BorderSide(width: 1.5),
                        ),
                      ),
                      child: _buildCardFormTable(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(width: 1)),
            ),
            padding: const pw.EdgeInsets.only(top: 3),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Generated: $date $time',
                  style: const pw.TextStyle(fontSize: 7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String getNamaPoliByIdUnit(String idUnit, List<PoliModel> listPoli) {
  try {
    final poli = listPoli.firstWhere(
      (p) => p.id.toString() == idUnit,
      orElse: () => PoliModel(id: 0, nama: '-', kodeBpjs: ""),
    );
    return poli.nama;
  } catch (_) {
    return '-';
  }
}

class HttpException implements Exception {
  final String message;

  const HttpException(this.message);

  @override
  String toString() => 'HttpException: $message';
}
