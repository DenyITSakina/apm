import 'dart:convert';

import 'package:apm/api/api_config.dart';
import 'package:http/http.dart' as http;

/// Layanan asisten AI (Gemini) untuk bantuan check-in APM.
/// - Hanya membantu navigasi/panduan check-in (BPJS/Umum).
/// - Tidak boleh membagikan/meminta data sensitif (nomor kartu, NIK, RM, nama, alamat, dll).
class AiAssistantService {
  static const String _systemInstruction =
      'Anda adalah asisten bantuan untuk Anjungan Pendaftaran Mandiri (APM) RSU Sakina Idaman. '
      'Tugas Anda HANYA membantu pasien memilih dan menuntun proses check-in yang tersedia: '
      'Cek-in BPJS dan Cek-in Umum. '
      'Aturan ketat: '
      '1) Jangan pernah meminta, menyebutkan, mengulang, atau membagikan data sensitif/pribadi pasien '
      '(nomor BPJS, NIK, nomor rekam medis, nomor booking, nama, alamat, tanggal lahir, nomor telepon, atau data medis). '
      '2) Jangan melakukan hal di luar bantuan navigasi/panduan check-in APM. Tolak permintaan lain dengan sopan dan arahkan ke petugas. '
      '3) Berikan jawaban singkat, jelas, ramah dalam Bahasa Indonesia. '
      '4) Jika pasien ingin check-in BPJS, sarankan membuka layanan Cek-in BPJS dan jelaskan langkahnya: '
      'siapkan kartu/NIK/RM, masukkan/scan nomor di halaman Cek-in BPJS, tekan CEK BPJS, periksa data, lalu ikuti petunjuk (sidik jari/Frista jika diminta) dan lanjut ke poli/loket sesuai arahan. '
      '5) Jika pasien ingin check-in Umum, sarankan membuka layanan Cek-in Umum dan jelaskan langkah serupa. '
      '6) Jika niat pengguna tidak jelas, tanyakan apakah ingin Cek-in BPJS atau Cek-in Umum.';

  static const String _fallbackHelp =
      'Saya hanya dapat membantu panduan check-in APM.\n'
      '- Cek-in BPJS: untuk peserta BPJS Kesehatan.\n'
      '- Cek-in Umum: untuk pasien non-BPJS.\n'
      'Pilih layanan yang sesuai, lalu ikuti petunjuk di layar. Jangan bagikan nomor kartu/NIK/RM kepada saya.';

  /// Kembalikan (reply, action). action: "bpjs", "umum", atau null.
  static Future<({String reply, String? action})> sendMessage(
    String userMessage, {
    List<Map<String, String>> history = const [],
  }) async {
    if (ApiConfig.geminiApiKey.trim().isEmpty) {
      final action = _detectIntentLocal(userMessage);
      return (reply: _localReply(action), action: action);
    }

    try {
      final contents = <Map<String, dynamic>>[];
      for (final h in history) {
        final role = h['role'] == 'user' ? 'user' : 'model';
        final text = _sanitizeOutgoing(h['text'] ?? '');
        if (text.isEmpty) continue;
        contents.add({
          'role': role,
          'parts': [
            {'text': text},
          ],
        });
      }
      contents.add({
        'role': 'user',
        'parts': [
          {'text': _sanitizeOutgoing(userMessage)},
        ],
      });

      final body = jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': _systemInstruction},
          ],
        },
        'contents': contents,
        'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 256},
      });

      final uri = Uri.parse(
        '${ApiConfig.geminiEndpoint}?key=${ApiConfig.geminiApiKey}',
      );
      final resp = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 15));

      if (resp.statusCode != 200) {
        final action = _detectIntentLocal(userMessage);
        return (reply: _localReply(action), action: action);
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      final text = candidates != null && candidates.isNotEmpty
          ? (((candidates.first as Map)['content'] as Map?)?['parts'] as List?)
                    ?.firstWhere(
                      (p) => p is Map && p['text'] != null,
                      orElse: () => null,
                    )
                as Map?
          : null;
      var reply = (text?['text'] as String?)?.trim();
      if (reply == null || reply.isEmpty) {
        reply = _fallbackHelp;
      }
      reply = _sanitizeReply(reply);
      final action = _detectIntent(reply) ?? _detectIntentLocal(userMessage);
      return (reply: reply, action: action);
    } catch (_) {
      final action = _detectIntentLocal(userMessage);
      return (reply: _localReply(action), action: action);
    }
  }

  /// Deteksi niat dari teks balasan/pesan (bpjs/umum) untuk aksi navigasi.
  static String? _detectIntent(String text) {
    final t = text.toLowerCase();
    final hasBpjs = t.contains('bpjs') || t.contains('jkn');
    final hasUmum =
        t.contains('umum') || t.contains('non-bpjs') || t.contains('non bpjs');
    if (hasBpjs && !hasUmum) return 'bpjs';
    if (hasUmum && !hasBpjs) return 'umum';
    return null;
  }

  static String? _detectIntentLocal(String text) {
    final t = text.toLowerCase();
    if (t.contains('bpjs') || t.contains('jkn')) return 'bpjs';
    if (t.contains('umum') || t.contains('non')) return 'umum';
    return null;
  }

  static String _localReply(String? action) {
    switch (action) {
      case 'bpjs':
        return 'Baik, saya bantu ke Cek-in BPJS.\n'
            'Langkah: 1) Masukkan/scan nomor kartu BPJS, NIK, atau No. RM. '
            '2) Tekan CEK BPJS. 3) Periksa data lalu pilih Lanjut ke Poli atau ke Loket sesuai arahan. '
            'Saya akan membuka halaman Cek-in BPJS.';
      case 'umum':
        return 'Baik, saya bantu ke Cek-in Umum.\n'
            'Langkah: 1) Masukkan/scan No. RM, NIK, atau No. Booking. '
            '2) Tekan CARI DATA. 3) Periksa data lalu ikuti petunjuk di layar. '
            'Saya akan membuka halaman Cek-in Umum.';
      default:
        return _fallbackHelp;
    }
  }

  /// Hapus deretan digit panjang dari teks keluar (jaga-jaga agar tidak bocor).
  static String _sanitizeOutgoing(String text) {
    if (text.trim().isEmpty) return '';
    // Redaksi urutan digit >= 6 (kemungkinan nomor sensitif)
    return text.replaceAllMapped(
      RegExp(r'\b\d{6,}\b'),
      (m) => '[disembunyikan]',
    );
  }

  static String _sanitizeReply(String text) {
    return text.replaceAllMapped(
      RegExp(r'\b\d{6,}\b'),
      (m) => '[nomor disembunyikan]',
    );
  }
}
