import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/models/apm/apm_antrian_model.dart';

class ApiConfig {
  static const String baseURL =
    'http://10.30.0.16/api_dev/public/index.php/api';


  static const String antrianApm = '$baseURL/apm-antrian';
  static const String antrianApmLoket = '$baseURL/apm-antrian-loket';
  static const String antrianApmPoli = '$baseURL/apm-antrian-poli';

  static const String poliListApm = '$baseURL/apm-poli';
  static const String dokterJadwalApm = '$baseURL/apm-jadwal-dokter';
  static const String daftarApmRegPoli = '$baseURL/apm-reg-poli';
  static const String antrianFarmasi = '$baseURL/antrian-farmasi-scan';
}


class ApiResponse {
  final bool success;
  final String message;
  final String? noAntrian;

  ApiResponse({required this.success, required this.message, this.noAntrian});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      noAntrian: json['noAntrian'],
    );
  }
}

class ApiService {
  static const String baseUrl = "http://10.30.0.16/api_dev/public/index.php/api";
  static Future<List<PoliModel>> getPoliList() async {
    final url = Uri.parse('$baseUrl/apm-poli');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      final List<dynamic> data = jsonResponse['data'];

      return data.map((e) => PoliModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data poli (${response.statusCode})');
    }
  }

  static Future<ApiResponse> submitPendaftaran({
    required String idPasien,
    required String tipePasien,
    required String poliId,
    required String tanggal, 
  }) async {
    try {
      final endpoint = tipePasien.toLowerCase() == 'umum'
          ? '/apm-antrian/pendaftaran'
          : '/apm-reg-poli/pendaftaran';

      final url = Uri.parse('$baseUrl$endpoint');

      final body = {
        'idPasien': idPasien,
        'poliId': poliId,
        'tanggal': tanggal,
        'tipePasien': tipePasien,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.fromJson(data);
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Exception: $e',
      );
    }
  }
}
