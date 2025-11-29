import 'package:intl/intl.dart';

import 'cetak_tiket_model.dart';

class TiketModel {
  final String id;
  final String nomorAntrian; // Format: "1-A", "2-A", dll
  final DateTime tanggalCetak;
  final String status;
  final String message;

  TiketModel({
    required this.id,
    required this.nomorAntrian,
    required this.tanggalCetak,
    required this.status,
    required this.message,
  });

  // Getter dengan format dd-mm-yyyy HH:mm
  String get formattedTanggalCetak {
    return DateFormat('dd-MM-yyyy HH:mm').format(tanggalCetak);
  }


  factory TiketModel.fromCetakTiketResponse(CetakTiketResponse response) {
    return TiketModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nomorAntrian: '${response.data}', // Format nomor antrian
      tanggalCetak: DateTime.now(),
      status: 'SUCCESS',
      message: response.message,
    );
  }

  factory TiketModel.empty() {
    return TiketModel(
      id: '',
      nomorAntrian: '--',
      tanggalCetak: DateTime.now(),
      status: 'EMPTY',
      message: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomorAntrian': nomorAntrian,
      'tanggalCetak': tanggalCetak.toIso8601String(),
      'status': status,
      'message': message,
    };
  }
}