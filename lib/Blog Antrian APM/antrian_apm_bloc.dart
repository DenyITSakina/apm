// import 'dart:convert';
// import 'package:colorful_print/colorful_print.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
// import 'package:my_app/config/api_config.dart';
// import 'package:my_app/data/models/apm/apm_antrian_model.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// abstract class AntrianApmEvent {}
// class ValidateAntrianEvent extends AntrianApmEvent {
//   final String noAntrian, jenisAntrian; 
//   final String? noIdentitas;
//   ValidateAntrianEvent(this.noAntrian, this.jenisAntrian, {this.noIdentitas});
// }
// class LanjutKePoliEvent extends AntrianApmEvent {
//   final String noBoking, jenisAntrian;
//   LanjutKePoliEvent(this.noBoking, this.jenisAntrian);
// }
// class LanjutKeLoketEvent extends AntrianApmEvent {
//   final ApmAntrianModel apmData;
//   final String jenisAntrian;
//   LanjutKeLoketEvent(this.apmData, this.jenisAntrian);
// }
// class LanjutKePendaftaranEvent extends AntrianApmEvent {
//   final String? rm;
//   final String jaminan;
//   final String? idJadwalDokter;
//   final int? idLayanan; 
//   final String jenisAntrian;
//   LanjutKePendaftaranEvent({
//     required this.rm,
//     required this.jaminan,
//     required this.idJadwalDokter,
//     required this.idLayanan,
//     // required this.idDokter,
//     required this.jenisAntrian,
//   });
// }
// class FetchPoliListEvent extends AntrianApmEvent {}
// class FetchDokterEvent extends AntrianApmEvent {
//   final int idLayanan;
//   final String grupJaminan;
//   FetchDokterEvent(this.idLayanan, this.grupJaminan);
// }
// class ResetValidationEvent extends AntrianApmEvent {}

// abstract class AntrianApmState {}
// class AntrianApmInitial extends AntrianApmState {}
// class AntrianApmLoading extends AntrianApmState {}
// class AntrianApmValidated extends AntrianApmState {
//   final ApmAntrianModel apmData;
//   final String jenisAntrian;
//   final bool isBatalBooking;
//   AntrianApmValidated(this.apmData, this.jenisAntrian, {this.isBatalBooking = false});
// }
// class AntrianApmPrinting extends AntrianApmState {}
// class AntrianApmPrinted extends AntrianApmState {
//   final String message;
//   final String noAntrian;
//   AntrianApmPrinted(this.message, {this.noAntrian = ''});
// }
// class AntrianApmError extends AntrianApmState {
//   final String pesan;
//   AntrianApmError(this.pesan);
// }
// class AntrianApmReset extends AntrianApmState {}
// class PoliListLoaded extends AntrianApmState {
//   final List<PoliModel> poliList;
//   PoliListLoaded(this.poliList);

//   get dokterList => null;
// }
// class DokterLoaded extends AntrianApmState {
//   final List<DokterModel> dokterList;
//   DokterLoaded(this.dokterList);
// }
// class PendaftaranSuccess extends AntrianApmState {
//   final PendaftaranPoliModel pendaftaranData;
//   PendaftaranSuccess(this.pendaftaranData);
// }


// class AntrianApmBloc extends Bloc<AntrianApmEvent, AntrianApmState> {
//   AntrianApmBloc() : super(AntrianApmInitial()) {
//     on<ValidateAntrianEvent>(_onValidateAntrian);
//     on<LanjutKePoliEvent>(_onLanjutKePoli);
//     on<LanjutKeLoketEvent>(_onLanjutKeLoket);
//     on<LanjutKePendaftaranEvent>(_onLanjutKePendaftaran);
//     on<FetchPoliListEvent>(_onFetchPoliList);
//     on<FetchDokterEvent>(_onFetchDokter);
//     on<ResetValidationEvent>(_onResetValidation);
//   }

//   //HTTP
//   Future<Map<String, dynamic>> _requestPost(String url, Map<String, String> body) async {
//     printColor('POST $url | Body: $body', textColor: TextColor.cyan);
//     final response = await http.post(Uri.parse(url),
//         headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: body);
//     final jsonResp = json.decode(response.body);
//     printColor('Response: $jsonResp', textColor: TextColor.yellow);
//     return jsonResp;
//   }

//   Future<List<T>> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) async {
//     return (data as List).map((e) => fromJson(e)).toList();
//   }

//   //EVENT HANDLERS
//   Future<void> _onValidateAntrian(
//       ValidateAntrianEvent event, Emitter<AntrianApmState> emit) async {
//     emit(AntrianApmLoading());
//     try {
//       final resp = await _requestPost('${ApiConfig.antrianApm}/${event.jenisAntrian}', {'no': event.noAntrian});
//       if (resp['code'] == 200) {
//         final apmData = ApmAntrianModel.fromJson(resp['data']);
//         emit(AntrianApmValidated(apmData, event.jenisAntrian, isBatalBooking: apmData.isDibatalkan));
//         printColor('Validated:', textColor: TextColor.green);
//       } else {
//         emit(AntrianApmError(resp['message'] ?? 'Gagal validasi'));
//       }
//     } catch (e) {
//       emit(AntrianApmError('Error validate: $e'));
//     }
//   }

//   Future<void> _onLanjutKePoli(LanjutKePoliEvent event, Emitter<AntrianApmState> emit) async {
//     emit(AntrianApmPrinting());
//     try {
//       final resp = await _requestPost('${ApiConfig.antrianApmPoli}/${event.jenisAntrian}', {'no': event.noBoking});
//       if (resp['code'] == 200) {
//         final apmPoliData = ApmAntrianPoliModel.fromJson(resp['data']);
//         await _printToThermalPrinterPoli(apmPoliData, event.jenisAntrian);
//         emit(AntrianApmPrinted('Berhasil lanjut ke Poli', noAntrian: apmPoliData.noAntrianPoli));
//       } else {
//         emit(AntrianApmError(resp['message'] ?? 'Gagal lanjut ke Poli'));
//       }
//     } catch (e) {
//       emit(AntrianApmError('Error lanjut ke Poli: $e'));
//     }
//   }

//   Future<void> _onLanjutKeLoket(
//   LanjutKeLoketEvent event,
//   Emitter<AntrianApmState> emit,
// ) async {
//   emit(AntrianApmPrinting());

//   try {
//     final url = '${ApiConfig.antrianApmLoket}/${event.apmData.id}';
//     print("POST -> $url");

//     final resp = await _requestPost(
//       url,
//       {
//         "id_pendaftaran": event.apmData.id,
//         "jenis_antrian": event.jenisAntrian,
//       },
//     );

//     print("RESPONSE RAW: $resp");

//     if (resp['code'] == 200) {
//       final noAntrianLoket = resp['data'].toString();

//       await _printToThermalPrinterLoket(
//         event.apmData,
//         event.jenisAntrian,
//         noAntrianLoket,
//       );

//       emit(AntrianApmPrinted(
//         'Berhasil lanjut ke Loket',
//         noAntrian: noAntrianLoket,
//       ));
//     } else {
//       emit(AntrianApmError(resp['message'] ?? 'Gagal lanjut ke Loket'));
//     }
//   } catch (e) {
//     emit(AntrianApmError('Error lanjut ke Loket: $e'));
//   }
// }

// // Future<void> _onLanjutKeLoket(
// //   LanjutKeLoketEvent event,
// //   Emitter<AntrianApmState> emit,
// // ) async {
// //   emit(AntrianApmPrinting());

// //   try {
// //     final fullUrl = '${ApiConfig.antrianApmPoli}/${event.jenisAntrian}';
// //     print("===== POST TO SERVER =====");
// //     print("URL : $fullUrl");
    

// //     final respRaw = await http.post(
// //       Uri.parse(fullUrl),
// //       body: {
// //         'no': event.jenisAntrian,
// //       },
// //     );

// //     print("STATUS CODE: ${respRaw.statusCode}");
// //     print("RAW RESPONSE BODY:");
// //     print(respRaw.body);

// //     // Cek apakah response JSON valid
// //     dynamic resp;
// //     try {
// //       resp = json.decode(respRaw.body);
// //     } catch (e) {
// //       print("ERROR PARSE JSON: $e");
// //       emit(AntrianApmError("Response bukan JSON\n${respRaw.body}"));
// //       return;
// //     }

// //     // Kalau sukses
// //     print("PARSED RESPONSE: $resp");

// //     // TODO: lanjut proses sesuai kebutuhan
// //     // emit(...);

// //   } catch (e) {
// //     print("REQUEST ERROR: $e");
// //     emit(AntrianApmError(e.toString()));
// //   }
// // }

  

//   Future<void> _onFetchPoliList(FetchPoliListEvent event, Emitter<AntrianApmState> emit) async {
//     emit(AntrianApmLoading());
//     try {
//       final response = await http.get(Uri.parse(ApiConfig.poliListApm));
//       if (response.statusCode == 200) {
//         final jsonResp = json.decode(response.body);
//         if (jsonResp['code'] == 200) {
//           final poliList = await _parseList(jsonResp['data'], (e) => PoliModel.fromJson(e));
//           emit(PoliListLoaded(poliList));
//         } else {
//           emit(AntrianApmError(jsonResp['message'] ?? 'Gagal fetch poli'));
//         }
//       } else {
//         emit(AntrianApmError('Server error: ${response.statusCode}'));
//       }
//     } catch (e) {
//       emit(AntrianApmError('Error fetch poli: $e'));
//     }
//   }

//   Future<void> _onFetchDokter(FetchDokterEvent event, Emitter<AntrianApmState> emit) async {
//     emit(AntrianApmLoading());
//     try {
//       final resp = await _requestPost(ApiConfig.dokterJadwalApm, {'id_layanan': event.idLayanan.toString()});
//       if (resp['code'] == 200) {
//         final dokterList = await _parseList(resp['data'], (e) => DokterModel.fromJson(e));
//         emit(DokterLoaded(dokterList));
//       } else {
//         emit(AntrianApmError(resp['message'] ?? 'Gagal fetch dokter'));
//       }
//     } catch (e) {
//       emit(AntrianApmError('Error fetch dokter: $e'));
//     }
//   }

//   Future<void> _onLanjutKePendaftaran(LanjutKePendaftaranEvent event, Emitter<AntrianApmState> emit) async {
//     emit(AntrianApmPrinting());
//     try {
//       final jenisAntrianFinal = event.jenisAntrian.isNotEmpty ? event.jenisAntrian : 'pendaftaran';
//       final url = '${ApiConfig.daftarApmRegPoli}/$jenisAntrianFinal';
//       final resp = await _requestPost(url, {
//         'rm': event.rm ?? '',
//         'jaminan': event.jaminan,
//         'id_jadwal_dokter': event.idJadwalDokter ?? '',
//         'id_layanan': event.idLayanan?.toString() ?? '',
//         // 'id_dokter': event.idDokter?.toString() ?? '',
//       });
//       if (resp['code'] == 200) {
//         final pendaftaranData = PendaftaranPoliModel.fromJson(resp['data']);
//         await _printToThermalPrinterPendaftaran(pendaftaranData, jenisAntrianFinal, event.jaminan);
//         emit(PendaftaranSuccess(pendaftaranData));
//       } else {
//         emit(AntrianApmError(resp['message'] ?? 'Gagal daftar poli'));
//       }
//     } catch (e) {
//       emit(AntrianApmError('Error pendaftaran: $e'));
//     }
//   }

//   void _onResetValidation(ResetValidationEvent event, Emitter<AntrianApmState> emit) {
//     printColor('Reset state', textColor: TextColor.cyan);
//     emit(AntrianApmReset());
//   }


//   //PRINTING METHODS

//   Future<void> _printToThermalPrinterPoli(
//     ApmAntrianPoliModel apmPoliModel,
//     String jenisAntrian,
//   ) async {
//     try {
//       final pdf = pw.Document();
//       final now = DateTime.now();
//       final formattedDate = _formatDate(now);
//       final formattedTime = _formatTime(now);

//       final qrData = json.encode(apmPoliModel.rmPoli);

//       pdf.addPage(
//         pw.Page(
//           pageFormat: const PdfPageFormat(72 * PdfPageFormat.mm, 120 * PdfPageFormat.mm),
//           margin: const pw.EdgeInsets.all(12),
//           build: (context) {
//             return _buildPoliTicket(
//               apmPoliModel,
//               qrData,
//               formattedDate,
//               formattedTime,
//             );
//           },
//         ),
//       );

//       await Printing.layoutPdf(
//         onLayout: (PdfPageFormat format) async => pdf.save(),
//       );
      
//       printColor('Tiket Poli berhasil dicetak', textColor: TextColor.green);
//     } catch (e) {
//       printColor('Error printing Poli: $e', textColor: TextColor.red);
//       throw Exception('Gagal mencetak tiket Poli: $e');
//     }
//   }

//   Future<void> _printToThermalPrinterLoket(
//     ApmAntrianModel apmData,
//     String jenisAntrian,
//     String noAntrianLoket,
//   ) async {
//     try {
//       final pdf = pw.Document();
//       final now = DateTime.now();
//       final formattedDate = _formatDate(now);
//       final formattedTime = _formatTime(now);

//       final qrData = json.encode(apmData.rm);

//       pdf.addPage(
//         pw.Page(
//           pageFormat: const PdfPageFormat(72 * PdfPageFormat.mm, 120 * PdfPageFormat.mm),
//           margin: const pw.EdgeInsets.all(12),
//           build: (context) {
//             return _buildLoketTicket(
//               apmData,
//               qrData,
//               noAntrianLoket,
//               formattedDate,
//               formattedTime,
//             );
//           },
//         ),
//       );

//       await Printing.layoutPdf(
//         onLayout: (PdfPageFormat format) async => pdf.save(),
//       );
      
//       printColor('Tiket Loket berhasil dicetak', textColor: TextColor.green);
//     } catch (e) {
//       printColor('Error printing Loket: $e', textColor: TextColor.red);
//       throw Exception('Gagal mencetak tiket Loket: $e');
//     }
//   }

//   Future<void> _printToThermalPrinterPendaftaran(
//     PendaftaranPoliModel pendaftaranData,
//     String jenisAntrian,
//     String jaminan,
//   ) async {
//     try {
//       final pdf = pw.Document();
//       final now = DateTime.now();
//       final formattedDate = _formatDate(now);
//       final formattedTime = _formatTime(now);

//       final qrData = json.encode(pendaftaranData.rm);

//       pdf.addPage(
//         pw.Page(
//           pageFormat: const PdfPageFormat(72 * PdfPageFormat.mm, 120 * PdfPageFormat.mm),
//           margin: const pw.EdgeInsets.all(12),
//           build: (context) {
//             return _buildPendaftaranTicket(
//               pendaftaranData,
//               qrData,
//               jaminan,
//               formattedDate,
//               formattedTime,
//             );
//           },
//         ),
//       );

//       await Printing.layoutPdf(
//         onLayout: (PdfPageFormat format) async => pdf.save(),
//       );
      
//       printColor('Tiket Pendaftaran berhasil dicetak', textColor: TextColor.green);
//     } catch (e) {
//       printColor('Error printing Pendaftaran: $e', textColor: TextColor.red);
//       throw Exception('Gagal mencetak tiket Pendaftaran: $e');
//     }
//   }

//   //HELPER METHODS

//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}-'
//            '${date.month.toString().padLeft(2, '0')}-'
//            '${date.year}';
//   }

//   String _formatTime(DateTime date) {
//     return '${date.hour.toString().padLeft(2, '0')}:'
//            '${date.minute.toString().padLeft(2, '0')}:'
//            '${date.second.toString().padLeft(2, '0')}';
//   }

//   String _formatTanggal(String tanggal) {
//     try {
//       if (tanggal.isEmpty) return '-';
//       final date = DateTime.parse(tanggal);
//       return _formatDate(date);
//     } catch (e) {
//       return tanggal;
//     }
//   }

//   //PDF BUILDING METHODS

//   pw.Widget _buildPoliTicket(
//     ApmAntrianPoliModel apmPoliModel,
//     String qrData,
//     String formattedDate,
//     String formattedTime,
//   ) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.center,
//       children: [
//         _buildHeader(),
//         pw.SizedBox(height: 6),
        
//         // Patient Info + QR Code
//         pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text(
//                   apmPoliModel.namaPasien.toUpperCase(),
//                   style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
//                 ),
//                 pw.Text('RM: $qrData', style: const pw.TextStyle(fontSize: 8)),
//                 // pw.Text(apmPoliModel.noBoking, style: const pw.TextStyle(fontSize: 8)),
//               ],
//             ),
//             pw.SizedBox(
//               width: 50,
//               height: 50,
//               child: pw.BarcodeWidget(
//                 barcode: pw.Barcode.qrCode(),
//                 data: qrData,
//               ),
//             ),
//           ],
//         ),
//         pw.SizedBox(height: 8),
//         pw.Divider(thickness: 1),
//         pw.SizedBox(height: 6),

//         // Queue Number
//         pw.Text('No. Antrian Poli', style: const pw.TextStyle(fontSize: 9)),
//         pw.SizedBox(height: 4),
//         pw.Text(
//           apmPoliModel.noAntrianPoli,
//           style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold),
//         ),
//         pw.SizedBox(height: 4),

//         // Poli Info
//         pw.Text(
//           apmPoliModel.namaPoli.toUpperCase(),
//           style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
//         ),
//         pw.SizedBox(height: 8),

//         // Date & Time
//         pw.Text('$formattedDate / $formattedTime', style: const pw.TextStyle(fontSize: 8)),
//       ],
//     );
//   }

  // pw.Widget _buildLoketTicket(
  //   ApmAntrianModel apmData,
  //   String qrData,
  //   String noAntrianLoket,
  //   String formattedDate,
  //   String formattedTime,
  // ) {
  //   return pw.Column(
  //     crossAxisAlignment: pw.CrossAxisAlignment.center,
  //     children: [
  //       _buildHeader(),
  //       pw.SizedBox(height: 6),
        
  //       // Patient Info + QR Code
  //       pw.Row(
  //         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //         crossAxisAlignment: pw.CrossAxisAlignment.start,
  //         children: [
  //           pw.Column(
  //             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //             children: [
  //               pw.Text(
  //                 apmData.pasien.toUpperCase(),
  //                 style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
  //               ),
  //               pw.Text('RM: $qrData', style: const pw.TextStyle(fontSize: 8)),
  //               pw.Text(
  //                 'Tgl lahir: ${_formatTanggal(apmData.tglLahir)}',
  //                 style: const pw.TextStyle(fontSize: 8),
  //               ),
  //             ],
  //           ),
  //           pw.SizedBox(
  //             width: 50,
  //             height: 50,
  //             child: pw.BarcodeWidget(
  //               barcode: pw.Barcode.qrCode(),
  //               data: qrData,
  //             ),
  //           ),
  //         ],
  //       ),
  //       pw.SizedBox(height: 8),
  //       pw.Divider(thickness: 0.5),
  //       pw.SizedBox(height: 6),

  //       // Queue Number
  //       pw.Text('No. Antrian Loket', style: const pw.TextStyle(fontSize: 9)),
  //       pw.SizedBox(height: 4),
  //       pw.Text(
  //         noAntrianLoket,
  //         style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold),
  //       ),
  //       pw.SizedBox(height: 4),

  //       // Address
  //       pw.Text(
  //         apmData.alamat,
  //         textAlign: pw.TextAlign.center,
  //         style: pw.TextStyle(fontSize: 9),
  //       ),
  //       pw.SizedBox(height: 10),
  //       pw.Divider(thickness: 1),
        
  //       // Date & Time
  //       pw.Text('$formattedDate / $formattedTime', style: const pw.TextStyle(fontSize: 8)),
  //     ],
  //   );
  // }

//   pw.Widget _buildPendaftaranTicket(
//     PendaftaranPoliModel pendaftaranData,
//     String qrData,
//     String jaminan,
//     String formattedDate,
//     String formattedTime,
//   ) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.center,
//       children: [
//         _buildHeader(),
//         pw.SizedBox(height: 6),
        
//         // Patient Info + QR Code
//         pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text(
//                   pendaftaranData.nama.toUpperCase(),
//                   style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
//                 ),
//                 pw.Text('RM: ${pendaftaranData.rm}', style: const pw.TextStyle(fontSize: 8)),
//                 pw.Text(
//                   'No. Registrasi: ${pendaftaranData.id}',
//                   style: const pw.TextStyle(fontSize: 8),
//                 ),
//                 pw.Text('Jaminan: $jaminan', style: const pw.TextStyle(fontSize: 8)),
//               ],
//             ),
//             pw.SizedBox(
//               width: 50,
//               height: 50,
//               child: pw.BarcodeWidget(
//                 barcode: pw.Barcode.qrCode(),
//                 data: qrData,
//               ),
//             ),
//           ],
//         ),
//         pw.SizedBox(height: 8),
//         pw.Divider(thickness: 1),
//         pw.SizedBox(height: 6),

//         // Queue Number
//         pw.Text('No. Antrian Pendaftaran', style: const pw.TextStyle(fontSize: 9)),
//         pw.SizedBox(height: 4),
//         pw.Text(
//           pendaftaranData.noAntrian,
//           style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold),
//         ),
//         pw.SizedBox(height: 4),

//         // Success Message
//         pw.Text('BERHASIL DAFTAR', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
//         pw.Text('Silakan menunggu panggilan', style: const pw.TextStyle(fontSize: 8)),
//         pw.SizedBox(height: 8),

//         // Date & Time
//         pw.Text('$formattedDate / $formattedTime', style: const pw.TextStyle(fontSize: 8)),
//       ],
//     );
//   }

//   pw.Widget _buildHeader() {
//     return pw.Column(
//       children: [
//         pw.Text(
//           'RSU SAKINA IDAMAN',
//           style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
//         ),
//         pw.Text(
//           'Jl. Nyi Tjondro Loekito No. 60',
//           style: pw.TextStyle(fontSize: 8),
//         ),
//         pw.Text(
//           'Phone: 0274 543 8021 - 0274 542 9090',
//           style: pw.TextStyle(fontSize: 8),
//         ),
//         pw.Divider(thickness: 1),
//       ],
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:colorful_print/colorful_print.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/Services/api_service_config.dart';
import 'package:my_app/models/apm/apm_antrian_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

//EVENTS
abstract class AntrianApmEvent {}

class ValidateAntrianEvent extends AntrianApmEvent {
  final String noAntrian, jenisAntrian; 
  final String? noIdentitas;
  ValidateAntrianEvent(this.noAntrian, this.jenisAntrian, {this.noIdentitas});
}

class PrintStrukEvent extends AntrianApmEvent {
  final PendaftaranPoliModel pendaftaranData;
  final String jenisAntrian;
  final String jaminan;

  PrintStrukEvent({
    required this.pendaftaranData,
    required this.jenisAntrian,
    required this.jaminan,
  });

  @override
  List<Object> get props => [pendaftaranData, jenisAntrian, jaminan];
}

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
  final String idLayanan;
  final String jenisAntrian;
  

  LanjutKePendaftaranEvent({
    required this.rm,
    required this.jaminan,
    required this.idJadwalDokter,
    required this.idLayanan,
    required this.jenisAntrian,
  });
}

class FetchPoliListEvent extends AntrianApmEvent {}

class FetchDokterEvent extends AntrianApmEvent {
  final int idLayanan;
  final int? groupJaminan;

  FetchDokterEvent({
    required this.idLayanan,
    this.groupJaminan,
  });
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

  const DokterLoaded({
    required this.dokter,
    required this.poliklinik,
  });
}

class PendaftaranSuccess extends AntrianApmState {
  final PendaftaranPoliModel pendaftaranData;
  
  const PendaftaranSuccess(this.pendaftaranData);
}

// TAMBAHKAN STATE INI - pindahkan dari events
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
  AntrianApmBloc() : super(const AntrianApmInitial()) {
    on<ValidateAntrianEvent>(_onValidateAntrian);
    on<LanjutKePoliEvent>(_onLanjutKePoli);
    on<LanjutKeLoketEvent>(_onLanjutKeLoket);
    on<LanjutKePendaftaranEvent>(_onLanjutKePendaftaran);
    on<FetchPoliListEvent>(_onFetchPoliList);
    on<FetchDokterEvent>(_onFetchDokter);
    on<ResetValidationEvent>(_onResetValidation);
    on<PrintStrukEvent>(_onPrintStruk);
  }
  
  //HTTP
  Future<Map<String, dynamic>> _requestPost(String url, Map<String, dynamic> body) async {
    printColor('POST $url | Body: $body', textColor: TextColor.cyan);

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: body.map((key, value) => MapEntry(key, value.toString())), // pastikan semua String
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
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
  Future<void> _onValidateAntrian(ValidateAntrianEvent event, Emitter<AntrianApmState> emit) async {
    emit(const AntrianApmLoading());
    try {
      final resp = await _requestPost('${ApiConfig.antrianApm}/${event.jenisAntrian}', {'no': event.noAntrian});

      if (resp['code'] == 200) {
        final apmData = ApmAntrianModel.fromJson(resp['data']);
        emit(AntrianApmValidated(apmData: apmData, jenisAntrian: event.jenisAntrian, isBatalBooking: apmData.isDibatalkan));
      } else {
        emit(AntrianApmError(resp['message'] ?? 'Gagal validasi'));
      }
    } catch (e) {
      emit(AntrianApmError('Error validate: $e'));
    }
  }

  // Future<void> _onLanjutKePoli(LanjutKePoliEvent event, Emitter<AntrianApmState> emit) async {
  //   emit(const AntrianApmPrinting());
  //   try {
  //     final resp = await _requestPost('${ApiConfig.antrianApmPoli}/${event.jenisAntrian}', {'no': event.noBoking});
  //     if (resp['code'] == 200) {
  //       final apmPoliData = ApmAntrianPoliModel.fromJson(resp['data']);
  //       await _printToThermalPrinterPoli(apmPoliData, event.jenisAntrian);
  //       emit(AntrianApmPrinted('Berhasil lanjut ke Poli', noAntrian: apmPoliData.noAntrianPoli));
  //     } else {
  //       emit(AntrianApmError(resp['message'] ?? 'Gagal lanjut ke Poli'));
  //     }
  //   } catch (e) {
  //     emit(AntrianApmError('Error lanjut ke Poli: $e'));
  //   }
  // }

  Future<void> _onLanjutKePoli(
    LanjutKePoliEvent event,
    Emitter<AntrianApmState> emit,
  ) async {
    emit(const AntrianApmPrinting());

    // Minimal ada satu identitas
    if ((event.noBoking == null || event.noBoking!.isEmpty) &&
        (event.noRm == null || event.noRm!.isEmpty) &&
        (event.noKtp == null || event.noKtp!.isEmpty)) {
      emit(const AntrianApmError('Nomor booking, RM, atau KTP harus diisi'));
      return;
    }

    try {
      final body = <String, dynamic>{};
      if (event.noBoking != null && event.noBoking!.isNotEmpty) {
        body['no'] = event.noBoking;
      }
      if (event.noRm != null && event.noRm!.isNotEmpty) {
        body['rm'] = event.noRm;
      }
      if (event.noKtp != null && event.noKtp!.isNotEmpty) {
        body['no_ktp'] = event.noKtp;
      }

      // Request POST
      final resp = await _requestPost(
        '${ApiConfig.antrianApmPoli}/${event.jenisAntrian}',
        body,
      );

      if (resp['code'] == 200 && resp['data'] != null) {
        final apmPoliData = ApmAntrianPoliModel.fromJson(resp['data']);

        // Print ke thermal printer
        await _printToThermalPrinterPoli(apmPoliData, event.jenisAntrian);

        // Emit sukses
        emit(AntrianApmPrinted(
          'Berhasil lanjut ke Poli',
          noAntrian: apmPoliData.noAntrianPoli,
        ));
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
      final url = '${ApiConfig.antrianApmLoket}/${event.apmData.id}';
      printColor('POST -> $url');

      final resp = await _requestPost(
        url,
        {
          'no': event.noBooking,
          'jenis_antrian': event.jenisAntrian,
        },
      );

      if (resp['code'] == 200) {
        final noLoket = resp['data'].toString();

        await _printToThermalPrinterLoket(
          event.apmData,
          event.jenisAntrian,
          noLoket,
        );

        emit(AntrianApmPrinted(
          'Berhasil lanjut ke Loket',
          noAntrian: noLoket,
        ));
      } else {
        emit(AntrianApmError(resp['message'] ?? 'Gagal lanjut ke Loket'));
      }
    } catch (e) {
      emit(AntrianApmError('Tiket Sudah Keluar'));
    }
  }

  // Future<void> _onLanjutKeLoket(
  // LanjutKeLoketEvent event,
  // Emitter<AntrianApmState> emit,
  // ) async {
  //   emit(const AntrianApmPrinting());

  //   if (event.apmData.noBooking.isEmpty) {
  //     emit(const AntrianApmError('Nomor booking belum ada'));
  //     return;
  //   }

  //   try {
  //     final url = ApiConfig.antrianApmLoket;
  //     printColor('POST -> $url');

  //     final resp = await _requestPost(
  //       url,
  //       {
  //         'no': event.apmData.noBooking, 
  //         'jenis_antrian': event.jenisAntrian.toUpperCase(),
  //       },
  //     );

  //     if (resp['code'] == 200) {
  //       final noLoket = resp['data'].toString();

  //       await _printToThermalPrinterLoket(
  //         event.apmData,
  //         event.jenisAntrian,
  //         noLoket,
  //       );

  //       emit(AntrianApmPrinted(
  //         'Berhasil lanjut ke Loket',
  //         noAntrian: noLoket,
  //       ));
  //     } else {
  //       emit(AntrianApmError(resp['message'] ?? 'Gagal lanjut ke Loket'));
  //     }
  //   } catch (e, st) {
  //     debugPrint('Error lanjut ke Loket: $e\n$st');
  //     emit(AntrianApmError('Error lanjut ke Loket: $e'));
  //   }
  // }


  Future<void> _onFetchPoliList(FetchPoliListEvent event, Emitter<AntrianApmState> emit) async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.poliListApm)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final jsonResp = json.decode(response.body);
        if (jsonResp['code'] == 200) {
          final poliList = (jsonResp['data'] as List).map((e) => PoliModel.fromJson(e)).toList();
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
      final resp = await _requestPost(
        ApiConfig.dokterJadwalApm,
        {
          "id_layanan": event.idLayanan.toString(),
        },
      );

      if (resp['code'] == 200) {
        final data = resp['data'];

        List<DokterModel> dokterList = [];

        if (data is List) {
          dokterList = data
              .map((e) => DokterModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList();
        }

        else if (data is Map) {
          dokterList = [
            DokterModel.fromJson(
              Map<String, dynamic>.from(data),
            ),
          ];
        }

        emit(
          DokterLoaded(
            dokter: dokterList,
            poliklinik: [],
          ),
        );
      } else {
        emit(
          AntrianApmError(
            resp['message'] ?? 'Gagal fetch dokter',
          ),
        );
      }
    } catch (e) {
      emit(
        AntrianApmError('Error fetch dokter: $e'),
      );
    }
  }

Future<void> _onLanjutKePendaftaran(
  LanjutKePendaftaranEvent event,
  Emitter<AntrianApmState> emit,
) async {
  emit(const AntrianApmLoading());

  try {
    // Validasi
    if (event.rm.isEmpty) {
      throw Exception('Nomor rekam medis (RM) harus diisi');
    }

    if (event.idJadwalDokter.isEmpty) {
      throw Exception('Jadwal dokter belum dipilih');
    }

    final jenisAntrianFinal =
        event.jenisAntrian.isNotEmpty ? event.jenisAntrian : 'pendaftaran';

    final url = '${ApiConfig.daftarApmRegPoli}/$jenisAntrianFinal';

    final resp = await _requestPost(url, {
      'rm': event.rm,
      'jaminan': event.jaminan,
      'id_jadwal_dokter': event.idJadwalDokter,
      'id_layanan': event.idLayanan,
    });

    if (resp['code'] == 200) {
      // Ambil data pendaftaran
      final pendaftaranData = PendaftaranPoliModel.fromJson(resp['data']);

      // Emit state success TANPA langsung print
      emit(PendaftaranSuccessWaitingPrint(
        pendaftaranData: pendaftaranData,
        jenisAntrian: jenisAntrianFinal,
        jaminan: event.jaminan,
      ));
      
    } else {
      emit(AntrianApmError(
        resp['message'] ?? 'Gagal melakukan pendaftaran poli',
      ));
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
    );

    // Setelah print selesai, kembali ke state success
    emit(PendaftaranSuccess(event.pendaftaranData));
  } catch (e) {
    // Jika print gagal, tetap tampilkan success tapi dengan error print
    emit(PendaftaranSuccess(event.pendaftaranData));
    // Anda bisa tambahkan log error atau notifikasi lain di sini
    print('Error printing: $e');
  }
}

  void _onResetValidation(ResetValidationEvent event, Emitter<AntrianApmState> emit) {
    printColor('Reset state', textColor: TextColor.cyan);
    emit(const AntrianApmReset());
  }

  //PRINTING
  Future<void> _printToThermalPrinterPoli(ApmAntrianPoliModel apmPoliModel, String jenisAntrian) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final qrData = json.encode(apmPoliModel.rmPoli);

    pdf.addPage(pw.Page(
      pageFormat: const PdfPageFormat(72 * PdfPageFormat.mm, 120 * PdfPageFormat.mm),
      margin: const pw.EdgeInsets.all(12),
      build: (context) => _buildPoliTicket(apmPoliModel, qrData, _formatDate(now), _formatTime(now)),
    ));

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _printToThermalPrinterLoket(ApmAntrianModel apmData, String jenisAntrian, String noAntrianLoket) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final qrData = json.encode(apmData.rm);

    pdf.addPage(pw.Page(
      pageFormat: const PdfPageFormat(72 * PdfPageFormat.mm, 120 * PdfPageFormat.mm),
      margin: const pw.EdgeInsets.all(12),
      build: (context) => _buildLoketTicket(apmData, qrData, noAntrianLoket, _formatDate(now), _formatTime(now)),
    ));

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _printToThermalPrinterPendaftaran(PendaftaranPoliModel data, String jenisAntrian, String jaminan) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final qrData = json.encode(data.rm);

    pdf.addPage(pw.Page(
      pageFormat: const PdfPageFormat(72 * PdfPageFormat.mm, 120 * PdfPageFormat.mm),
      margin: const pw.EdgeInsets.all(12),
      build: (context) => _buildPendaftaranTicket(data, qrData, jaminan, _formatDate(now), _formatTime(now)),
    ));

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  //HELPERS
  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2,'0')}-${date.month.toString().padLeft(2,'0')}-${date.year}';
  String _formatTime(DateTime date) => '${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}:${date.second.toString().padLeft(2,'0')}';
  String _formatTanggal(String tanggal) {
    try { return tanggal.isEmpty ? '-' : _formatDate(DateTime.parse(tanggal)); } 
    catch (_) { return tanggal; }
  }

  //PDF TICKETS
  pw.Widget _buildHeader() => pw.Column(
    children: [
      pw.Text('RSU SAKINA IDAMAN', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      pw.Text('Jl. Nyi Tjondro Loekito No. 60', style: const pw.TextStyle(fontSize: 8)),
      pw.Text('Telp. (0274) 5018221, 5029090', style: const pw.TextStyle(fontSize: 8)),
      pw.Divider(thickness: 1),
    ],
  );

  pw.Widget _buildPoliTicket(ApmAntrianPoliModel m, String qrData, String date, String time) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        _buildHeader(),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(m.namaPasien.toUpperCase(), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text('RM: ${m.rmPoli}', style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            ),
            pw.SizedBox(width: 50, height: 50, child: pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: qrData)),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 1),
        pw.Text('No. Antrian Poli', style: const pw.TextStyle(fontSize: 9)),
        pw.Text(m.namaPoli, style: const pw.TextStyle(fontSize: 7)),
        pw.SizedBox(height: 4),
        pw.Text(m.noAntrianPoli, style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        // pw.Text(m.namaPoli.toUpperCase(), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('$date / $time', style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }

 pw.Widget _buildLoketTicket(ApmAntrianModel m,String qrData,String no,String date,String time,) {
    return pw.Container(
      width: double.infinity,
      alignment: pw.Alignment.center,
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'RSU SAKINA IDAMAN',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),

          pw.SizedBox(height: 2),
          pw.Text(
            'Jl. Nyi Tjondro Loekito, Yogyakarta',
            style: pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            'Telp. (0274) 5018221, 5029090',
            style: pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),

          pw.SizedBox(height: 2),
          pw.Text(
            '----------------------------------------------',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 8),
          ),

          pw.SizedBox(height: 5),
          pw.Text(
            'No. Antrian Loket :',
            style: pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),

          pw.SizedBox(height: 2),
          pw.Text(
            no,
            style: pw.TextStyle(
              fontSize: 36,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),

          pw.SizedBox(height: 2),
          pw.Text(
            '$date / $time',
            style: pw.TextStyle(fontSize: 9),
            textAlign: pw.TextAlign.center,
          ),

          //pw.SizedBox(height: 10),
          // pw.Text(
          //   'TIKET ANTRIAN',
          //   style: pw.TextStyle(fontSize: 9),
          //   textAlign: pw.TextAlign.center,
          // ),

          pw.SizedBox(height: 5),
          pw.Text(
            '----------------------------------------------',
            style: pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),

          pw.SizedBox(height: 2),
          pw.Text(
            'Silahkan Tunggu No Antrian Anda Dipanggil',
            style: pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            'Jagalah Kebersihan',
            style: pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),

          pw.SizedBox(height: 2),
          pw.Text(
            '----------------------------------------------',
            style: pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPendaftaranTicket(PendaftaranPoliModel m, String qrData, String jaminan, String date, String time) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        _buildHeader(),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(m.nama, style:  pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text('RM: ${m.rm}', style: const pw.TextStyle(fontSize: 8)),
                  // pw.Text('Jaminan: $jaminan', style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            ),
            pw.SizedBox(width: 50, height: 50, child: pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: qrData)),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 1),
        pw.Text('No. Antrian Poli ${m.namaPoli}', style: const pw.TextStyle(fontSize: 9)),
        pw.Text(m.namaPoli, style: const pw.TextStyle(fontSize: 7)),
        pw.SizedBox(height: 4),
        pw.Text(m.noAntrian, style:pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold)),
        // pw.SizedBox(height: 4),
        // pw.Text(m.idUnit.toUpperCase(), style:pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('$date / $time', style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }
}
