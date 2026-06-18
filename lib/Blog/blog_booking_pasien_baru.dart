import 'dart:async';
import 'dart:convert';
import 'package:apm/api/api_config.dart';
import 'package:apm/models/booking_pasien_baru_model.dart';
import 'package:apm/models/dokter_model.dart';
import 'package:apm/models/poli_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:colorful_print/colorful_print.dart';

// Events
abstract class BookingPasienBaruEvent {}

class LoadPoliListEvent extends BookingPasienBaruEvent {}

class LoadDokterJadwalEvent extends BookingPasienBaruEvent {
  final int idLayanan;
  final int jenisBooking;

  LoadDokterJadwalEvent({required this.idLayanan, required this.jenisBooking});
}

class SubmitBookingEvent extends BookingPasienBaruEvent {
  final BookingRequestModel request;

  SubmitBookingEvent({required this.request});
}

class ResetBookingEvent extends BookingPasienBaruEvent {}

// States
abstract class BookingPasienBaruState {}

class BookingPasienBaruInitial extends BookingPasienBaruState {}

class BookingPasienBaruLoading extends BookingPasienBaruState {}

class PoliListLoaded extends BookingPasienBaruState {
  final List<PoliModel> poliList;

  PoliListLoaded({required this.poliList});
}

class DokterJadwalLoaded extends BookingPasienBaruState {
  final List<DokterModel> dokterList;

  DokterJadwalLoaded({required this.dokterList});
}

class BookingSuccess extends BookingPasienBaruState {
  final BookingResponseModel response;

  BookingSuccess({required this.response});
}

class BookingError extends BookingPasienBaruState {
  final String message;

  BookingError({required this.message});
}

// Bloc
class BookingPasienBaruBloc
    extends Bloc<BookingPasienBaruEvent, BookingPasienBaruState> {
  BookingPasienBaruBloc() : super(BookingPasienBaruInitial()) {
    on<LoadPoliListEvent>(_onLoadPoliList);
    on<LoadDokterJadwalEvent>(_onLoadDokterJadwal);
    on<SubmitBookingEvent>(_onSubmitBooking);
    on<ResetBookingEvent>(_onResetBooking);
  }

  Future<void> _onLoadPoliList(
    LoadPoliListEvent event,
    Emitter<BookingPasienBaruState> emit,
  ) async {
    emit(BookingPasienBaruLoading());

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
            BookingError(
              message:
                  jsonResp['message'] ?? jsonResp['msg'] ?? 'Gagal load poli',
            ),
          );
        }
      } else {
        emit(BookingError(message: 'Server error: ${response.statusCode}'));
      }
    } catch (e) {
      emit(BookingError(message: 'Error load poli: $e'));
    }
  }

  Future<void> _onLoadDokterJadwal(
    LoadDokterJadwalEvent event,
    Emitter<BookingPasienBaruState> emit,
  ) async {
    emit(BookingPasienBaruLoading());

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
            BookingError(
              message:
                  jsonResp['message'] ?? jsonResp['msg'] ?? 'Gagal load dokter',
            ),
          );
        }
      } else {
        emit(BookingError(message: 'Server error: ${response.statusCode}'));
      }
    } catch (e) {
      emit(BookingError(message: 'Error load dokter: $e'));
    }
  }

  Future<void> _onSubmitBooking(
    SubmitBookingEvent event,
    Emitter<BookingPasienBaruState> emit,
  ) async {
    emit(BookingPasienBaruLoading());

    try {
      final jenis = event.request.jenisBooking == 1 ? '1' : '2';
      final url = '${ApiConfig.baseUrl}/pasien-baru/$jenis';

      final requestBody = event.request.toJson();

      printColor('POST $url', textColor: TextColor.cyan);
      printColor(
        'Body: ${json.encode(requestBody)}',
        textColor: TextColor.cyan,
      );

      if (event.request.jenisBooking == 1) {
        assert(
          !requestBody.containsKey('jadwal'),
          'UMUM tidak boleh mengirim field jadwal',
        );
      }

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
        final bookingResponse = BookingResponseModel.fromJson(jsonResp);

        if (bookingResponse.success) {
          emit(BookingSuccess(response: bookingResponse));
        } else {
          emit(BookingError(message: bookingResponse.message));
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

        emit(BookingError(message: errorMessage));
      } else {
        emit(BookingError(message: 'Server error: ${response.statusCode}'));
      }
    } catch (e) {
      emit(BookingError(message: 'Error submit booking: $e'));
    }
  }

  void _onResetBooking(
    ResetBookingEvent event,
    Emitter<BookingPasienBaruState> emit,
  ) {
    emit(BookingPasienBaruInitial());
  }
}
