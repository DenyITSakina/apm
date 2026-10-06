// ignore: file_names
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Logger berstandar `sidik_jari_log.txt` untuk alur BPJS / pembuatan SEP.
///
/// Mirip `_logSidikJari` pada `open_aplikasi_bpjsDaftar.dart`, namun reusable
/// sehingga dapat dipakai oleh alur check-in BPJS tanpa bergantung ke kode
/// sidik-jari. Menulis berurutan (append) ke `bpjs_checkin_log.txt` di folder
/// kerja; beralih ke direktori TEMP bila lokasi utama tidak dapat ditulis.
class AppLog {
  AppLog._();

  static const String _fileName = 'bpjs_checkin_log.txt';
  static const int _maxLogBytes = 2 * 1024 * 1024;

  File? _cachedFile;

  /// Singleton lazim untuk app-wide logger.
  static final AppLog instance = AppLog._();

  File _resolveFile() {
    final cached = _cachedFile;
    if (cached != null) {
      return cached;
    }

    final kandidat = <File>[
      File(
        '${Directory.current.path}${Platform.pathSeparator}$_fileName',
      ),
      File(
        '${Directory.systemTemp.path}${Platform.pathSeparator}$_fileName',
      ),
    ];

    for (final file in kandidat) {
      try {
        file.writeAsStringSync('', mode: FileMode.append);
        _cachedFile = file;
        return file;
      } catch (_) {
        // coba lokasi berikutnya
      }
    }

    _cachedFile = kandidat.last;
    return _cachedFile!;
  }

  String get logPath => _resolveFile().path;

  /// Samarkan nomor peserta/NIK/BPJS supaya tidak dituliskan penuh ke file.
  static String maskNomor(String? nomor) {
    final value = (nomor ?? '').trim();
    if (value.length < 8) return value;
    return "${value.substring(0, 4)}****${value.substring(value.length - 4)}";
  }

  void write(String message) {
    final stamp = DateTime.now().toIso8601String();
    final baris = "[$stamp] $message";
    debugPrint("[BPJSCheckIn] $message");

    try {
      final file = _resolveFile();
      if (file.existsSync() && file.lengthSync() > _maxLogBytes) {
        file.writeAsStringSync('');
      }
      file.writeAsStringSync('$baris\n', mode: FileMode.append, flush: true);
    } catch (e) {
      debugPrint("Gagal menulis log BPJS check-in: $e");
    }
  }
}
