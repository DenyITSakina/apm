import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class VclaimAccount {
  final int id;
  final String username;
  final String password;

  VclaimAccount({
    required this.id,
    required this.username,
    required this.password,
  });

  factory VclaimAccount.fromJson(Map<String, dynamic> json) {
    return VclaimAccount(
      id: (json['id'] as num).toInt(),
      username: json['username']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
    );
  }
}

class VclaimApiService {
  static Future<List<VclaimAccount>> getVclaimAccounts() async {
    final url = '${ApiConfig.baseUrl}/apm/get-vclaim-accounts';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final jsonResp = jsonDecode(response.body);

    if (jsonResp is Map<String, dynamic>) {
      final code = jsonResp['code'];
      if (code != null && code != 200) {
        throw Exception(
          jsonResp['message']?.toString() ?? 'Gagal mengambil akun',
        );
      }

      final data = jsonResp['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => VclaimAccount.fromJson(e))
            .toList();
      }

      throw Exception('Format response tidak valid: data bukan List');
    }

    throw Exception('Format response tidak valid');
  }
}
