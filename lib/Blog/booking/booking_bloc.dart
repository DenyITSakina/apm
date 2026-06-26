import 'package:apm/api/booking_api_service.dart';
import 'package:apm/models/poli_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc() : super(const BookingState()) {
    on<LoadPoliEvent>(_onLoadPoli);
    on<LoadDokterUmumEvent>(_onLoadDokterUmum);
    on<LoadDokterJknEvent>(_onLoadDokterJkn);
    on<CekPasienBpjsEvent>(_onCekPasienBpjs);
    on<SubmitBookingUmumEvent>(_onSubmitBookingUmum);
    on<SubmitBookingBpjsEvent>(_onSubmitBookingBpjs);
    on<ResetBookingEvent>(_onReset);
  }

  Future<void> _onLoadPoli(
    LoadPoliEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(status: BookingStatus.loading));
    try {
      final poliList = await BookingApiService.getPoliList();
      emit(state.copyWith(status: BookingStatus.loaded, poliList: poliList));
    } catch (e) {
      emit(
        state.copyWith(status: BookingStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLoadDokterUmum(
    LoadDokterUmumEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(status: BookingStatus.loading));
    try {
      final dokterList = await BookingApiService.getDokterUmum(
        idLayanan: event.idLayanan,
        tanggal: event.tanggal,
      );
      emit(
        state.copyWith(
          status: BookingStatus.loaded,
          dokterList: dokterList,
          selectedPoliId: event.idLayanan,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: BookingStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLoadDokterJkn(
    LoadDokterJknEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(status: BookingStatus.loading));
    try {
      final dokterList = await BookingApiService.getDokterJkn(
        idLayanan: event.idLayanan,
        tanggal: event.tanggal,
      );
      emit(
        state.copyWith(
          status: BookingStatus.loaded,
          dokterList: dokterList,
          selectedPoliId: event.idLayanan,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: BookingStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onCekPasienBpjs(
    CekPasienBpjsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(status: BookingStatus.loading));
    try {
      final response = await BookingApiService.cekPasienBpjs(event.noBpjs);
      if (response.status && response.peserta != null) {
        // Auto select poli based on rujukan
        final poliList = state.poliList;
        PoliModel? matchedPoli;
        if (response.peserta!.kodePoliRujukan != null) {
          matchedPoli = poliList.firstWhere(
            (p) => p.kodeBpjs == response.peserta!.kodePoliRujukan,
            orElse: () => poliList.first,
          );
        }

        emit(
          state.copyWith(
            status: BookingStatus.loaded,
            pasienBpjs: response.peserta,
            selectedPoliId: matchedPoli?.id ?? state.selectedPoliId,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: BookingStatus.error,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: BookingStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSubmitBookingUmum(
    SubmitBookingUmumEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(status: BookingStatus.loading));
    try {
      final response = await BookingApiService.bookingPasien(
        jenis: '1',
        request: event.request,
      );
      if (response.success) {
        emit(
          state.copyWith(
            status: BookingStatus.success,
            bookingResult: response.data,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: BookingStatus.error,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: BookingStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSubmitBookingBpjs(
    SubmitBookingBpjsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(status: BookingStatus.loading));
    try {
      final response = await BookingApiService.bookingPasien(
        jenis: '2',
        request: event.request,
      );
      if (response.success) {
        emit(
          state.copyWith(
            status: BookingStatus.success,
            bookingResult: response.data,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: BookingStatus.error,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: BookingStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void _onReset(ResetBookingEvent event, Emitter<BookingState> emit) {
    emit(const BookingState());
  }
}
