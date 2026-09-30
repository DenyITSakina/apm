// ignore: file_names
import 'dart:async';
import 'dart:io';

import 'package:apm/dialog/top_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:apm/api/vclaim_api_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

const int vkReturn = 0x0D;
const int vkTab = 0x09;

const String sidikJariExePath =
    r"C:\Program Files (x86)\BPJS Kesehatan\Aplikasi Sidik Jari BPJS Kesehatan\After.exe";

const Duration _sidikJariLaunchTimeout = Duration(seconds: 10);
const Duration _sidikJariExitTimeout = Duration(seconds: 180);

Future<bool> isSidikJariRunning() async {
  if (kIsWeb) {
    debugPrint('Fitur proses native tidak tersedia di web');
    return false;
  }

  try {
    final result = await Process.run('tasklist', [
      '/FI',
      'IMAGENAME eq After.exe',
      '/NH',
    ], runInShell: true);
    final output = result.stdout.toString();
    if (!output.contains("After.exe")) {
      _logSidikJari("After.exe tidak berjalan");
    }
    return output.contains("After.exe");
  } catch (e) {
    debugPrint("Gagal cek proses After.exe: $e");
    return false;
  }
}

Future<bool> waitUntil(
  Future<bool> Function() condition, {
  required Duration timeout,
  Duration interval = const Duration(milliseconds: 300),
}) async {
  final stopwatch = Stopwatch()..start();
  while (true) {
    try {
      if (await condition()) {
        return true;
      }
    } catch (e) {
      debugPrint("waitUntil error: $e");
    }
    if (stopwatch.elapsed >= timeout) {
      return false;
    }
    await Future<void>.delayed(interval);
  }
}

Future<void> closeSidikJariExe() async {
  if (kIsWeb) {
    return;
  }

  try {
    await Process.run('taskkill', ['/IM', 'After.exe', '/F'], runInShell: true);
  } catch (e) {
    debugPrint("Gagal menutup After.exe: $e");
  }
}

String _escapePowerShell(String value) => value.replaceAll("'", "''");

bool isWindowOpen(String windowTitle) {
  if (kIsWeb) {
    return false;
  }

  final pattern = windowTitle
      .toLowerCase()
      .replaceAll('.exe', '')
      .replaceAll('after', 'sidik jari');

  final script =
      '''
  \$pattern = '${_escapePowerShell(pattern)}'
  \$process = Get-Process | Where-Object {
    \$_.MainWindowHandle -ne 0 -and (
      \$_.MainWindowTitle -like "*\$pattern*" -or
      \$_.ProcessName -eq 'After'
    )
  } | Select-Object -First 1
  if (\$process) { exit 0 } else { exit 1 }
  ''';

  try {
    final result = Process.runSync('powershell.exe', [
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-Command',
      script,
    ]);

    return result.exitCode == 0;
  } catch (e) {
    debugPrint("isWindowOpen error: $e");
    return false;
  }
}

/// Fokuskan window aplikasi sidik jari. Non-blocking, mengembalikan `true`
/// bila window ditemukan.
Future<bool> focusWindow(String windowTitle) async {
  if (kIsWeb) {
    debugPrint('Fokus window tidak tersedia di web');
    return false;
  }

  final pattern = windowTitle
      .toLowerCase()
      .replaceAll('.exe', '')
      .replaceAll('after', 'sidik jari');

  final script =
      '''
  \$source = @"
  using System;
  using System.Runtime.InteropServices;
  public static class Win32 {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")]
    public static extern bool IsIconic(IntPtr hWnd);
  }
  "@
  Add-Type -TypeDefinition \$source
  \$pattern = '${_escapePowerShell(pattern)}'
  \$process = Get-Process | Where-Object {
    \$_.MainWindowHandle -ne 0 -and (
      \$_.MainWindowTitle -like "*\$pattern*" -or
      \$_.ProcessName -eq 'After'
    )
  } | Select-Object -First 1

  if (\$process) {
    \$handle = \$process.MainWindowHandle
    if ([Win32]::IsIconic(\$handle)) {
      [Win32]::ShowWindow(\$handle, 9) | Out-Null
    }
    [Win32]::SetForegroundWindow(\$handle) | Out-Null
    exit 0
  }
  exit 1
  ''';

  try {
    final result = await Process.run('powershell.exe', [
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-Command',
      script,
    ]);
    return result.exitCode == 0;
  } catch (e) {
    debugPrint("focusWindow error: $e");
    return false;
  }
}

void sendVirtualKey(int keyCode) {
  final key = switch (keyCode) {
    vkReturn => '{ENTER}',
    vkTab => '{TAB}',
    _ => null,
  };

  if (key == null) {
    debugPrint('Key tidak didukung: $keyCode');
    return;
  }

  unawaited(sendKeySequence([key]));
}

void sendKeys(String text) {
  if (text.isEmpty) {
    return;
  }
  unawaited(sendKeySequence([text]));
}

void pressEnter() => sendVirtualKey(vkReturn);
void pressTab() => sendVirtualKey(vkTab);

/// Escape karakter khusus SendKeys pada teks biasa (username/password).
String _escapeSendKeysText(String text) {
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    if ('+^%~(){}[]'.contains(char)) {
      buffer.write('{$char}');
    } else {
      buffer.write(char);
    }
  }
  return buffer.toString();
}

/// Mengirim seluruh rangkaian tombol dalam SATU proses PowerShell.
///
/// Sebelumnya tiap tombol spawn `powershell.exe` sendiri (~23 kali), sehingga
/// UI membeku 7-10 detik. Sekarang satu spawn untuk semua tombol.
Future<void> sendKeySequence(
  List<String> keys, {
  int jedaMs = 25,
}) async {
  if (kIsWeb || keys.isEmpty) {
    return;
  }

  final buffer = StringBuffer('Add-Type -AssemblyName System.Windows.Forms\n');
  for (final key in keys) {
    buffer.writeln(
      "[System.Windows.Forms.SendKeys]::SendWait('${_escapePowerShell(key)}')",
    );
    if (jedaMs > 0) {
      buffer.writeln('Start-Sleep -Milliseconds $jedaMs');
    }
  }

  try {
    await Process.run('powershell.exe', [
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-Command',
      buffer.toString(),
    ]);
  } catch (e) {
    debugPrint("sendKeySequence error: $e");
  }
}

Future<void> sendAutoLogin({
  required String username,
  required String password,
}) async {
  await Future.delayed(const Duration(milliseconds: 250));
  await sendKeySequence([
    _escapeSendKeysText(username),
    '{TAB}',
    _escapeSendKeysText(password),
    '{ENTER}',
  ]);
}

Future<void> Function() showSidikJariProgress(BuildContext context) {
  VoidCallback? closer;

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Memproses sidik jari",
    barrierColor: Colors.black.withOpacity(0.45),
    pageBuilder: (dialogContext, _, _) {
      return Builder(
        builder: (context) {
          closer = () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          };
          return const SizedBox.shrink();
        },
      );
    },
    transitionBuilder: (context, anim, _, child) {
      return Opacity(
        opacity: anim.value,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingAnimationWidget.fourRotatingDots(
                  color: const Color(0xFF0ABF68),
                  size: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  "Memproses Sidik Jari",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Mohon takeover dan letakkan sidik jari pada reader.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
  );

  return () async {
    closer?.call();
  };
}

String lastSidikJariReason = '';

void _logSidikJari(String pesan) {
  debugPrint("[SidikJari] $pesan");
}

Future<bool> openExeFromMap(
  BuildContext context,
  Map<String, dynamic> pasien, {
  bool tampilkanToast = true,
}) async {
  final nomor = pasien["nomor"]?.toString().trim() ?? "";

  if (nomor.isEmpty) {
    TopToast.error(context, "Nomor tidak boleh kosong!");
    return false;
  }

  if (!isBpjs(nomor) && !isNik(nomor)) {
    TopToast.error(context, "Nomor harus 13 digit (BPJS)");
    return false;
  }

  debugPrint("Nomor dipakai: $nomor");

  try {
    return await openExe(context, nomor, tampilkanToast: tampilkanToast);
  } catch (e) {
    debugPrint("openExeFromMap error: $e");
    if (context.mounted) {
      TopToast.error(context, "Gagal membuka aplikasi BPJS");
    }
    return false;
  }
}

Future<bool> openExe(
  BuildContext context,
  String noPeserta, {
  bool tampilkanToast = true,
}) async {
  lastSidikJariReason = '';

  void gagal(String alasan, [String? pesan]) {
    lastSidikJariReason = '$alasan${pesan != null ? ' ($pesan)' : ''}';
    _logSidikJari("GAGAL: $lastSidikJariReason");
    if (tampilkanToast && context.mounted) {
      TopToast.error(
        context,
        pesan == null
            ? "Sidik jari gagal diproses. Silakan coba lagi."
            : "$pesan Silakan coba lagi.",
      );
    }
  }

  if (kIsWeb) {
    if (context.mounted) {
      TopToast.error(context, 'Fitur ini hanya tersedia di aplikasi desktop');
    }
    return false;
  }

  Process? process;

  try {
    _logSidikJari("Mulai proses, nomor: $noPeserta");
    final sudahBerjalan = await isSidikJariRunning();

    if (sudahBerjalan) {
      _logSidikJari("After.exe sudah berjalan -> tidak membuka instance baru");
    } else {
      if (!File(sidikJariExePath).existsSync()) {
        gagal("exe tidak ditemukan", "Aplikasi sidik jari tidak ditemukan.");
        return false;
      }

      process = await Process.start(
        sidikJariExePath,
        [],
        runInShell: true,
        mode: ProcessStartMode.normal,
      );
      _logSidikJari("After.exe dijalankan, menunggu proses muncul");

      final muncul = await waitUntil(
        isSidikJariRunning,
        timeout: _sidikJariLaunchTimeout,
      );

      if (!muncul) {
        gagal(
          "proses tidak muncul dalam ${_sidikJariLaunchTimeout.inSeconds} dtk",
        );
        return false;
      }
    }

    final windowSiap = await waitUntil(
      () async => isWindowOpen(sidikJariExePath),
      timeout: _sidikJariLaunchTimeout,
      interval: const Duration(milliseconds: 200),
    );

    if (!windowSiap) {
      _logSidikJari("Window After.exe belum siap, lanjut mencoba fokus");
    }

    await Future<void>.delayed(const Duration(milliseconds: 200));
    final terfokus = await focusWindow(sidikJariExePath);
    _logSidikJari("Window After.exe difokuskan: $terfokus");

    List<VclaimAccount> accounts;
    try {
      accounts = await VclaimApiService.getVclaimAccounts();
    } catch (e) {
      gagal("gagal ambil akun VClaim", "Data akun VClaim tidak dapat diakses.");
      _logSidikJari("Exception API: $e");
      return false;
    }

    if (accounts.isEmpty) {
      gagal("akun VClaim kosong", "Data akun VClaim kosong.");
      return false;
    }

    final account = accounts.first;
    if (account.username.isEmpty || account.password.isEmpty) {
      gagal("akun VClaim tidak lengkap");
      return false;
    }

    _logSidikJari("Auto login: user=${account.username}");
    await sendAutoLogin(username: account.username, password: account.password);

    await Future.delayed(const Duration(milliseconds: 800));
    if (!context.mounted) {
      return false;
    }
    await sendNoPeserta(context, noPeserta);
    _logSidikJari("Nomor dikirim, menunggu After.exe selesai");

    if (process == null) {
      _logSidikJari("Dipantau proses yang sudah berjalan sebelumnya");
    }

    final berhenti = await waitUntil(
      () async => !(await isSidikJariRunning()),
      timeout: _sidikJariExitTimeout,
      interval: const Duration(seconds: 2),
    );

    if (berhenti) {
      _logSidikJari("After.exe selesai -> dianggap sukses");
      return true;
    }

    gagal(
      "belum selesai dalam ${_sidikJariExitTimeout.inMinutes} menit",
      "Sidik jari belum selesai diproses.",
    );
    return false;
  } catch (e) {
    lastSidikJariReason = 'error tidak terduga: $e';
    _logSidikJari("GAGAL: $lastSidikJariReason");
    return false;
  }
}

String detectNomorType(String nomor) {
  if (isBpjs(nomor)) return "BPJS";
  if (isNik(nomor)) return "NIK";
  return "UNKNOWN";
}

bool isBpjs(String nomor) {
  String cleanNomor = nomor.replaceAll(RegExp(r'[^\d]'), '');
  return cleanNomor.length == 13;
}

bool isNik(String nomor) {
  String cleanNomor = nomor.replaceAll(RegExp(r'[^\d]'), '');
  return cleanNomor.length == 16;
}

String normalizeNomor(String nomor) {
  return nomor.replaceAll(RegExp(r'[^\d]'), '');
}

Future<void> sendNoPeserta(BuildContext context, String nomor) async {
  try {
    String normalizedNomor = normalizeNomor(nomor);
    String tipe = detectNomorType(normalizedNomor);

    if (tipe == "UNKNOWN") {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nomor harus 13 digit (BPJS) atau 16 digit (NIK)',
              style: TextStyle(fontSize: 14),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }

      if (await isSidikJariRunning()) {
        await closeSidikJariExe();
      }
      return;
    }

    await Future.delayed(const Duration(milliseconds: 100));

    await focusWindow(sidikJariExePath);

    // Seluruh urutan tombol dikirim dalam satu proses PowerShell.
    final keys = <String>[
      for (int i = 0; i < 5; i++) "{ESC}",
      "{TAB}",
      for (int i = 0; i < 10; i++) "+{TAB}",
      if (tipe == "BPJS") ...["{TAB}", "{TAB}", " "] else if (tipe == "NIK") ...["{TAB}", "{TAB}", "{TAB}", " "],
      "{TAB}",
      "{HOME}",
      "+{END}",
      "{DELETE}",
      normalizedNomor,
      "{ENTER}",
    ];

    await sendKeySequence(keys);
  } catch (e) {
    debugPrint("sendNoPeserta error: $e");
  }
}
