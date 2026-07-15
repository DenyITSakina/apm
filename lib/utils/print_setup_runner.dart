import 'dart:io';

class PrintSetupRunner {
  static Future<void> runScript(String scriptName) async {
    // Struktur yang diharapkan saat Windows build:
    // - data/python/python.exe
    // - data/python_scripts/<scriptName>
    //
    // Base folder aplikasi untuk windows "in-place" diasumsikan sama dengan
    // folder tempat exe berada.
    final appDir = Directory.current;
    final dataDir = Directory('${appDir.path}${Platform.pathSeparator}data');

    final pythonExe = File(
      '${dataDir.path}${Platform.pathSeparator}python${Platform.pathSeparator}python.exe',
    );
    final scriptPath =
        '${dataDir.path}${Platform.pathSeparator}python_scripts${Platform.pathSeparator}$scriptName';

    if (!pythonExe.existsSync()) {
      throw ProcessException(
        pythonExe.path,
        [scriptPath],
        'Python runtime tidak ditemukan. Harap pastikan data/python/python.exe tersedia. '
        'Lokasi yang dicek: ${pythonExe.path}',
        -1,
      );
    }

    if (!File(scriptPath).existsSync()) {
      throw ProcessException(
        pythonExe.path,
        [scriptPath],
        'Script python tidak ditemukan: $scriptPath',
        -1,
      );
    }

    final result = await Process.run(pythonExe.path, [
      scriptPath,
    ], runInShell: false);

    if (result.exitCode != 0) {
      throw ProcessException(
        pythonExe.path,
        [scriptPath],
        'Script failed. exitCode=${result.exitCode}\n'
        'stdout=${result.stdout}\n'
        'stderr=${result.stderr}',
        result.exitCode,
      );
    }
  }
}
