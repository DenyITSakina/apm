import 'dart:convert';
import 'dart:io';
import 'package:apm/api/api_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

abstract class CekinEvent {}

class CekNomorEvent extends CekinEvent {
  final String nomor;
  final String jenis;
  CekNomorEvent({required this.nomor, required this.jenis});
}

abstract class CekinState {}

class CekinInitial extends CekinState {}

class CekinLoading extends CekinState {}

class CekinSuccess extends CekinState {
  final Map<String, dynamic> data;
  CekinSuccess(this.data);
}

class CekinFailed extends CekinState {
  final String message;
  CekinFailed(this.message);
}

class CekinBloc extends Bloc<CekinEvent, CekinState> {
  CekinBloc() : super(CekinInitial()) {
    on<CekNomorEvent>(_onCekNomor);
  }

  Future<void> _onCekNomor(
    CekNomorEvent event,
    Emitter<CekinState> emit,
  ) async {
    emit(CekinLoading());

    print("Cek nomor: ${event.nomor} | jenis: ${event.jenis}");

    try {
      final url = "${ApiConfig.getDaftar}/${event.jenis}";
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"no": event.nomor},
      );

      final sosial = json.decode(response.body);

      print("Response: ${sosial['code']} | ${sosial['message']}");

      if (sosial['code'] == 200) {
        emit(CekinSuccess(sosial['data']));
      } else {
        emit(CekinFailed(sosial['message'] ?? "Pasien tidak ditemukan"));
      }
    } on SocketException catch (e) {
      emit(CekinFailed('Tidak ada koneksi: $e'));
    } on HttpException catch (e) {
      emit(CekinFailed('Error HTTP: ${e.message}'));
    } catch (e) {
      emit(CekinFailed('Error: $e'));
    }
  }
}
