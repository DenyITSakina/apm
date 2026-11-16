import 'dart:convert';

import 'package:apm/api/api_config.dart';
import 'package:http/http.dart' as http;

/// Layanan asisten AI (Gemini) untuk bantuan check-in APM.
/// - Hanya membantu navigasi/panduan check-in (BPJS/Umum).
/// - Tidak boleh membagikan/meminta data sensitif (nomor kartu, NIK, RM, nama, alamat, dll).
class AiAssistantService {
  static const String _systemInstruction =
      'Anda adalah asisten bantuan khusus Anjungan Pendaftaran Mandiri (APM) RSU Sakina Idaman. '
      'Fungsi Anda WAJIB dan HANYA membantu pasien memilih serta menuntun proses check-in: Cek-in BPJS atau Cek-in Umum. '
      'Anda tidak memiliki fungsi lain. '
      'Aturan mutlak (tidak boleh dilanggar): '
      '1) SELALU bantu dan arahkan pengguna terkait proses check-in BPJS/Umum dengan langkah yang jelas. '
      '2) TOLAK semua permintaan di luar bantuan/panduan check-in APM (mis. percakapan umum, hiburan, opini, pengetahuan umum, diagnosis, saran medis, administrasi lain, teknis di luar APM, atau permintaan apa pun yang tidak terkait check-in). '
      'Saat menolak, jawab singkat bahwa Anda hanya membantu check-in APM, lalu langsung bantu memilih/menuntun Cek-in BPJS atau Umum. '
      '3) Jangan pernah meminta, menyebutkan, mengulang, menyimpan, atau membagikan data sensitif/pribadi pasien '
      '(nomor BPJS, NIK, nomor rekam medis, nomor booking, nama, alamat, tanggal lahir, nomor telepon, data medis, atau data krusial lainnya). '
      'Jika pengguna mengirim data tersebut, jangan mengulangnya; ingatkan agar tidak dibagikan dan tetap bantu langkah check-in tanpa data itu. '
      '4) Berikan jawaban singkat, jelas, ramah dalam Bahasa Indonesia. '
      '5) Panduan Cek-in BPJS: pilih Cek-in BPJS, siapkan kartu BPJS/NIK/No. RM, masukkan/scan nomor di halaman Cek-in BPJS, tekan CEK BPJS, periksa data, ikuti petunjuk sidik jari/Frista bila diminta, lalu lanjut ke Poli atau Loket sesuai arahan. '
      '6) Panduan Cek-in Umum: pilih Cek-in Umum, masukkan/scan No. RM/NIK/No. Booking, tekan CARI DATA, periksa data, lalu ikuti petunjuk di layar/ke Poli atau Loket. '
      '7) Jika niat pengguna tidak jelas, tanyakan dengan sopan: ingin Cek-in BPJS atau Cek-in Umum, lalu pandu langkahnya.';

  static const String _fallbackHelp =
      'Saya khusus membantu panduan check-in APM (tidak melayani hal lain).\n'
      'Silakan pilih layanan:\n'
      '- Cek-in BPJS: untuk peserta BPJS Kesehatan.\n'
      '- Cek-in Umum: untuk pasien non-BPJS.\n'
      'Ketik/pilih salah satu, saya akan menuntun langkahnya. Jangan bagikan nomor kartu/NIK/RM/data pribadi kepada saya.';

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

      final generationConfig = <String, dynamic>{
        'temperature': ApiConfig.geminiTemperature,
        'topP': ApiConfig.geminiTopP,
        'topK': ApiConfig.geminiTopK,
        'maxOutputTokens': ApiConfig.geminiMaxOutputTokens,
      };
      if (ApiConfig.geminiEnableThinking) {
        generationConfig['thinkingConfig'] = {
          'thinkingBudget': ApiConfig.geminiThinkingBudget,
        };
      }

      final body = jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': _systemInstruction},
          ],
        },
        'contents': contents,
        'generationConfig': generationConfig,
      });

      final uri = Uri.parse(
        '${ApiConfig.geminiEndpoint}?key=${ApiConfig.geminiApiKey}',
      );

      http.Response? resp;
      final attempts =
          (ApiConfig.geminiMaxRetries < 0 ? 0 : ApiConfig.geminiMaxRetries) + 1;
      for (var i = 0; i < attempts; i++) {
        try {
          resp = await http
              .post(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: body,
              )
              .timeout(Duration(seconds: ApiConfig.geminiTimeoutSeconds));
          if (resp.statusCode == 200) break;
          // retry on transient server/rate-limit errors
          if (resp.statusCode != 429 && resp.statusCode < 500) break;
        } catch (_) {
          if (i == attempts - 1) rethrow;
        }
      }

      if (resp == null || resp.statusCode != 200) {
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
