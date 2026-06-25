import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';
import '../models/pasien_model.dart';
import '../models/dokter_model.dart';
import '../models/poli_model.dart';
import 'api_config.dart';

class BookingApiService {
  static const String baseUrl = ApiConfig.baseUrl;

  // Booking Pasien
  static Future<BookingResponse> bookingPasien({
    required String jenis,
    required BookingRequest request,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pasien-booking/$jenis'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: request.toJson().map((k, v) => MapEntry(k, v.toString())),
      );

      if (response.statusCode != 200) {
        print('Error Response: ${response.body}');
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final jsonResp = jsonDecode(response.body);
      return BookingResponse.fromJson(jsonResp);
    } catch (e) {
      return BookingResponse(
        success: false,
        message: 'Gagal melakukan booking: $e',
      );
    }
  }

  // Get Dokter Umum dengan tanggal
  static Future<List<DokterModel>> getDokterUmum({
    required int idLayanan,
    required String tanggal,
  }) async {
    try {
      print(
        'Getting dokter umum for id_layanan: $idLayanan, tanggal: $tanggal',
      );

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/jadwal-dokter-umum'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'id_layanan': idLayanan.toString(), 'tanggal': tanggal},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final jsonResp = jsonDecode(response.body);
      if (jsonResp['code'] != 200) {
        throw Exception(jsonResp['message'] ?? 'Gagal mengambil data dokter');
      }

      return (jsonResp['data'] as List)
          .map((e) => DokterModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Error getDokterUmum: $e');
      throw Exception('Gagal mengambil data dokter umum: $e');
    }
  }

  // Get Dokter JKN dengan tanggal
  static Future<List<DokterModel>> getDokterJkn({
    required int idLayanan,
    required String tanggal,
  }) async {
    try {
      print('Getting dokter JKN for id_layanan: $idLayanan, tanggal: $tanggal');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/jadwal-dokter-jkn'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'id_layanan': idLayanan.toString(), 'tanggal': tanggal},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final jsonResp = jsonDecode(response.body);
      if (jsonResp['code'] != 200) {
        throw Exception(jsonResp['message'] ?? 'Gagal mengambil data dokter');
      }

      return (jsonResp['data'] as List)
          .map((e) => DokterModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Error getDokterJkn: $e');
      throw Exception('Gagal mengambil data dokter JKN: $e');
    }
  }

  // Cek Pasien BPJS
  static Future<PasienBpjsResponse> cekPasienBpjs(String noBpjs) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/bpjs/cek-rujukan'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'no_peserta': noBpjs},
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final jsonResp = jsonDecode(response.body);
      return PasienBpjsResponse.fromJson(jsonResp);
    } catch (e) {
      return PasienBpjsResponse(
        status: false,
        message: 'Gagal cek data BPJS: $e',
      );
    }
  }

  // Get Poli List
  static Future<List<PoliModel>> getPoliList() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/apm-poli'),
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final jsonResp = jsonDecode(response.body);
      if (jsonResp['code'] != 200) {
        throw Exception(jsonResp['message'] ?? 'Gagal mengambil data poli');
      }

      return (jsonResp['data'] as List)
          .map((e) => PoliModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data poli: $e');
    }
  }
}
