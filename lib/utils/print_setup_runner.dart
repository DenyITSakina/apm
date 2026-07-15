import 'dart:io';
import 'package:path/path.dart' as p;

class PrintSetupRunner {
  static Future<String> runScript(String scriptName) async {
    final appDir = Directory.current;

    final pythonExeData = File(
      p.join(appDir.path, 'data', 'python', 'python.exe'),
    );
    final scriptFileData = File(
      p.join(appDir.path, 'data', 'python_scripts', scriptName),
    );

    final pythonExeRuntime = File(
      p.join(appDir.path, 'python_runtime', 'python.exe'),
    );
    final scriptFileScripts = File(
      p.join(appDir.path, 'python_scripts', scriptName),
    );

    final pythonExe = await pythonExeData.exists()
        ? pythonExeData
        : pythonExeRuntime;
    final scriptFile = await scriptFileData.exists()
        ? scriptFileData
        : scriptFileScripts;

    print('App directory: ${appDir.path}');
    print('Python path: ${pythonExe.path}');
    print('Script path: ${scriptFile.path}');

    if (!await pythonExe.exists()) {
      throw Exception(
        'Python runtime tidak ditemukan.\n'
        'Coba cek salah satu lokasi berikut:\n'
        '- ${pythonExeData.path}\n'
        '- ${pythonExeRuntime.path}',
      );
    }

    if (!await scriptFile.exists()) {
      throw Exception(
        'Script tidak ditemukan: $scriptName\n'
        'Coba cek salah satu lokasi berikut:\n'
        '- ${scriptFileData.path}\n'
        '- ${scriptFileScripts.path}',
      );
    }

    final result = await Process.run(
      pythonExe.path,
      [scriptFile.path],
      workingDirectory: p.dirname(scriptFile.path),
      runInShell: Platform.isWindows,
    );

    if (result.exitCode != 0) {
      throw Exception(
        'Script gagal dijalankan\n'
        'Exit Code: ${result.exitCode}\n'
        'Stdout: ${result.stdout}\n'
        'Stderr: ${result.stderr}',
      );
    }

    print('Output: ${result.stdout}');
    return result.stdout.toString();
  }
}
