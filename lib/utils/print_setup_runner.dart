import 'dart:io';

class PrintSetupRunner {
  static Future<void> runScript(String scriptName) async {
    final scriptPath = 'python_scripts/$scriptName';

    final result = await Process.run('python', [scriptPath], runInShell: false);

    if (result.exitCode != 0) {
      throw ProcessException(
        'python',
        [scriptPath],
        'Script failed. exitCode=${result.exitCode}\n'
            'stdout=${result.stdout}\n'
            'stderr=${result.stderr}',
        result.exitCode,
      );
    }
  }
}
