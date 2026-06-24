import 'dart:convert';
import 'package:apm/models/ApmPasienSosialModel.dart';
import 'package:apm/models/apm_antrian_model.dart';
import 'package:apm/models/apm_antrian_poli_model.dart';
import 'package:apm/models/dokter_model.dart';
import 'package:apm/models/pendaftaran_poli_model.dart';
import 'package:apm/models/poli_model.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://127.0.0.1:8000/api';
  //'http://10.30.0.16/api_dev/public/index.php/api';

  static const String antrianApm = '$baseUrl/apm-antrian';

  static const String antrianApmLoket = '$baseUrl/apm-antrian-loket';

  static const String antrianApmPoli = '$baseUrl/apm-antrian-poli';

  static const String poliListApm = '$baseUrl/apm-poli';

  static const String dokterJadwalApm = '$baseUrl/apm-jadwal-dokter';

  static const String daftarApmRegPoli = '$baseUrl/apm-reg-poli';

  static const String bpjsCekRujukan = '$baseUrl/bpjs/cek-rujukan';

  static const String bookingUpdateStatus = '$baseUrl/booking/update-status';

  static const String getDaftar = '$baseUrl/apm-get-sosial';

  static String bookingPasienBaru(int jenis) => '$baseUrl/pasien-baru/$jenis';
}

class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({required this.code, required this.message, this.data});

  bool get isSuccess => code == 200;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? parser,
  ) {
    return ApiResponse<T>(
      code: json['code'] ?? 500,
      message: json['message'] ?? '',
      data: parser != null && json['data'] != null
          ? parser(json['data'])
          : null,
    );
  }
}

class ApiService {
  ApiService._();

  //HELPER
  static Future<Map<String, dynamic>> _post(
    String url,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body.map((k, v) => MapEntry(k, v.toString())),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  //VALIDASI APM
  static Future<ApiResponse<dynamic>> validateAntrian({
    required String jenis,
    required String no,
  }) async {
    final jsonResp = await _post('${ApiConfig.antrianApm}/$jenis', {'no': no});

    return ApiResponse.fromJson(jsonResp, (data) {
      if (data['status_booking'] != null) {
        return ApmAntrianModel.fromJson(data);
      }
      return ApmPasienSosialModel.fromJson(data);
    });
  }

  //POLI LIST
  static Future<List<PoliModel>> getPoliList() async {
    final response = await http.get(Uri.parse(ApiConfig.poliListApm));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final jsonResp = jsonDecode(response.body);
    if (jsonResp['code'] != 200) {
      throw Exception(jsonResp['message']);
    }

    return (jsonResp['data'] as List)
        .map((e) => PoliModel.fromJson(e))
        .toList();
  }

  //DOKTER BY POLI
  static Future<List<DokterModel>> getDokterByPoli(int idLayanan) async {
    final jsonResp = await _post(ApiConfig.dokterJadwalApm, {
      'id_layanan': idLayanan,
    });

    if (jsonResp['code'] != 200) {
      throw Exception(jsonResp['message']);
    }

    return (jsonResp['data'] as List)
        .map((e) => DokterModel.fromJson(e))
        .toList();
  }

  //LANJUT KE POLI
  static Future<ApiResponse<ApmAntrianPoliModel>> lanjutKePoli({
    required String jenis,
    String? noBooking,
    String? rm,
    String? noKtp,
  }) async {
    final body = <String, dynamic>{};

    if (noBooking?.isNotEmpty == true) body['no'] = noBooking;
    if (rm?.isNotEmpty == true) body['rm'] = rm;
    if (noKtp?.isNotEmpty == true) body['no_ktp'] = noKtp;

    final jsonResp = await _post('${ApiConfig.antrianApmPoli}/$jenis', body);

    return ApiResponse.fromJson(
      jsonResp,
      (data) => ApmAntrianPoliModel.fromJson(data),
    );
  }

  static Future<ApiResponse<PendaftaranPoliModel>> daftarPoli({
    required String jenis,
    required String rm,
    required String jaminan,
    required String idJadwalDokter,
    required String idLayanan,
  }) async {
    final jsonResp = await _post('${ApiConfig.daftarApmRegPoli}/$jenis', {
      'rm': rm,
      'jaminan': jaminan,
      'id_jadwal_dokter': idJadwalDokter,
      'id_layanan': idLayanan,
    });

    return ApiResponse.fromJson(
      jsonResp,
      (data) => PendaftaranPoliModel.fromJson(data),
    );
  }
}
