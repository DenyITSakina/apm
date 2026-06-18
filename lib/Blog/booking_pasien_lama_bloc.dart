import 'dart:async';
import 'dart:convert';
import 'package:apm/api/api_config.dart';
import 'package:apm/models/booking_pasien_lama_model.dart';
import 'package:apm/models/dokter_model.dart';
import 'package:apm/models/poli_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:colorful_print/colorful_print.dart';

// Events
abstract class BookingPasienLamaEvent {}

class CekPasienEvent extends BookingPasienLamaEvent {
  final String rm;

  CekPasienEvent({required this.rm});
}

class LoadPoliListEvent extends BookingPasienLamaEvent {}

class LoadDokterJadwalEvent extends BookingPasienLamaEvent {
  final int idLayanan;
  final int jenisBooking;

  LoadDokterJadwalEvent({required this.idLayanan, required this.jenisBooking});
}

class SubmitBookingLamaEvent extends BookingPasienLamaEvent {
  final BookingPasienLamaRequest request;

  SubmitBookingLamaEvent({required this.request});
}

class ResetBookingLamaEvent extends BookingPasienLamaEvent {}

abstract class BookingPasienLamaState {}

class BookingPasienLamaInitial extends BookingPasienLamaState {}

class BookingPasienLamaLoading extends BookingPasienLamaState {}

class CekPasienSuccess extends BookingPasienLamaState {
  final CekPasienData pasien;

  CekPasienSuccess({required this.pasien});
}

class CekPasienError extends BookingPasienLamaState {
  final String message;

  CekPasienError({required this.message});
}

class PoliListLoaded extends BookingPasienLamaState {
  final List<PoliModel> poliList;

  PoliListLoaded({required this.poliList});
}

class DokterJadwalLoaded extends BookingPasienLamaState {
  final List<DokterModel> dokterList;

  DokterJadwalLoaded({required this.dokterList});
}

class BookingLamaSuccess extends BookingPasienLamaState {
  final BookingLamaResponse response;

  BookingLamaSuccess({required this.response});
}

class BookingLamaError extends BookingPasienLamaState {
  final String message;

  BookingLamaError({required this.message});
}

// Bloc
class BookingPasienLamaBloc
    extends Bloc<BookingPasienLamaEvent, BookingPasienLamaState> {
  BookingPasienLamaBloc() : super(BookingPasienLamaInitial()) {
    on<CekPasienEvent>(_onCekPasien);
    on<LoadPoliListEvent>(_onLoadPoliList);
    on<LoadDokterJadwalEvent>(_onLoadDokterJadwal);
    on<SubmitBookingLamaEvent>(_onSubmitBooking);
    on<ResetBookingLamaEvent>(_onResetBooking);
  }

  Future<void> _onCekPasien(
    CekPasienEvent event,
    Emitter<BookingPasienLamaState> emit,
  ) async {
    emit(BookingPasienLamaLoading());

    try {
      final url = '${ApiConfig.baseUrl}/cek-pasien-by-rm/${event.rm}';
      printColor('GET $url', textColor: TextColor.cyan);

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResp = json.decode(response.body);
        printColor('Response cek pasien: $jsonResp', textColor: TextColor.cyan);

        if (jsonResp['success'] == true) {
          final pasien = CekPasienData.fromJson(jsonResp['data']);
          emit(CekPasienSuccess(pasien: pasien));
        } else {
          emit(
            CekPasienError(
              message: jsonResp['message'] ?? 'Pasien tidak ditemukan',
            ),
          );
        }
      } else {
        emit(CekPasienError(message: 'Server error: ${response.statusCode}'));
      }
    } catch (e) {
      emit(CekPasienError(message: 'Error cek pasien: $e'));
    }
  }

  Future<void> _onLoadPoliList(
    LoadPoliListEvent event,
    Emitter<BookingPasienLamaState> emit,
  ) async {
    emit(BookingPasienLamaLoading());

    try {
      final response = await http
          .get(Uri.parse(ApiConfig.poliListApm))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResp = json.decode(response.body);

        if (jsonResp['code'] == 200 || jsonResp['success'] == true) {
          final dataList = jsonResp['data'] ?? [];
          final poliList = (dataList as List)
              .map((e) => PoliModel.fromJson(e))
              .toList();
          emit(PoliListLoaded(poliList: poliList));
        } else {
          emit(
            BookingLamaError(
              message:
                  jsonResp['message'] ?? jsonResp['msg'] ?? 'Gagal load poli',
            ),
          );
        }
      } else {
        emit(BookingLamaError(message: 'Server error: ${response.statusCode}'));
      }
    } catch (e) {
      emit(BookingLamaError(message: 'Error load poli: $e'));
    }
  }

  Future<void> _onLoadDokterJadwal(
    LoadDokterJadwalEvent event,
    Emitter<BookingPasienLamaState> emit,
  ) async {
    emit(BookingPasienLamaLoading());

    try {
      final url = ApiConfig.dokterJadwalApm;
      printColor(
        'POST $url | id_layanan: ${event.idLayanan}, jenisBooking: ${event.jenisBooking}',
        textColor: TextColor.cyan,
      );

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {
              'id_layanan': event.idLayanan.toString(),
              'group_jaminan': event.jenisBooking.toString(),
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResp = json.decode(response.body);
        printColor('Response dokter: $jsonResp', textColor: TextColor.cyan);

        if (jsonResp['code'] == 200 || jsonResp['success'] == true) {
          final dataList = jsonResp['data'] ?? [];

          final semuaDokter = (dataList as List)
              .map((e) => DokterModel.fromJson(e))
              .toList();

          List<DokterModel> filteredDokter;

          if (event.jenisBooking == 2) {
            filteredDokter = semuaDokter
                .where((d) => d.jadwal != null && d.jadwal!.isNotEmpty)
                .toList();

            printColor(
              'Filtered for BPJS: ${filteredDokter.length} dari ${semuaDokter.length} dokter',
              textColor: TextColor.green,
            );
          } else {
            filteredDokter = semuaDokter;
          }

          emit(DokterJadwalLoaded(dokterList: filteredDokter));
        } else {
          emit(
            BookingLamaError(
              message:
                  jsonResp['message'] ?? jsonResp['msg'] ?? 'Gagal load dokter',
            ),
          );
        }
      } else {
        emit(BookingLamaError(message: 'Server error: ${response.statusCode}'));
      }
    } catch (e) {
      emit(BookingLamaError(message: 'Error load dokter: $e'));
    }
  }

  Future<void> _onSubmitBooking(
    SubmitBookingLamaEvent event,
    Emitter<BookingPasienLamaState> emit,
  ) async {
    emit(BookingPasienLamaLoading());

    try {
      final jenis = event.request.jenisBooking == 1 ? '1' : '2';
      final url = '${ApiConfig.baseUrl}/pasien-lama/$jenis';

      final requestBody = event.request.toJson();

      printColor('POST $url', textColor: TextColor.cyan);
      printColor(
        'Body: ${json.encode(requestBody)}',
        textColor: TextColor.cyan,
      );

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      printColor(
        'Response status: ${response.statusCode}',
        textColor: TextColor.yellow,
      );
      printColor(
        'Response body: ${response.body}',
        textColor: TextColor.yellow,
      );

      if (response.statusCode == 200) {
        final jsonResp = json.decode(response.body);
        final bookingResponse = BookingLamaResponse.fromJson(jsonResp);

        if (bookingResponse.success) {
          emit(BookingLamaSuccess(response: bookingResponse));
        } else {
          emit(BookingLamaError(message: bookingResponse.message));
        }
      } else if (response.statusCode == 422) {
        final jsonResp = json.decode(response.body);
        String errorMessage = 'Validasi gagal';

        if (jsonResp['errors'] != null) {
          final errors = jsonResp['errors'] as Map;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first.toString();
          }
        } else {
          errorMessage = jsonResp['message'] ?? errorMessage;
        }

        emit(BookingLamaError(message: errorMessage));
      } else {
        emit(BookingLamaError(message: 'Server error: ${response.statusCode}'));
      }
    } catch (e) {
      emit(BookingLamaError(message: 'Error submit booking: $e'));
    }
  }

  void _onResetBooking(
    ResetBookingLamaEvent event,
    Emitter<BookingPasienLamaState> emit,
  ) {
    emit(BookingPasienLamaInitial());
  }
}
