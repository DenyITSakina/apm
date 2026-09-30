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

/// Batas waktu menunggu After.exe muncul di tasklist.
const Duration _sidikJariLaunchTimeout = Duration(seconds: 6);

/// Batas waktu menunggu After.exe selesai (pasien selesai sidik jari).
const Duration _sidikJariExitTimeout = Duration(seconds: 180);

Future<bool> isSidikJariRunning() async {
  if (kIsWeb) {
    debugPrint('Fitur proses native tidak tersedia di web');
    return false;
  }

  final result = await Process.run('tasklist', [], runInShell: true);
  return result.stdout.toString().contains("After.exe");
}

/// Polling cepat sampai [condition] terpenuhi atau [timeout] habis.
Future<bool> waitUntil(
  Future<bool> Function() condition, {
  required Duration timeout,
  Duration interval = const Duration(milliseconds: 150),
}) async {
  final stopwatch = Stopwatch()..start();
  while (true) {
    if (await condition()) {
      return true;
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

  await Process.run('taskkill', ['/IM', 'After.exe', '/F'], runInShell: true);
}

String _escapePowerShell(String value) => value.replaceAll("'", "''");

bool isWindowOpen(String windowTitle) {
  if (kIsWeb) {
    return false;
  }

  final script =
      '''
  Add-Type -AssemblyName System.Windows.Forms
  \$title = '${_escapePowerShell(windowTitle)}'
  \$process = Get-Process | Where-Object {
    \$_.MainWindowTitle -like "*\$title*" -or \$_.ProcessName -like "*\$title*"
  } | Select-Object -First 1
  if (\$process) { exit 0 } else { exit 1 }
  ''';

  final result = Process.runSync('powershell.exe', [
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-Command',
    script,
  ]);

  return result.exitCode == 0;
}

void focusWindow(String windowTitle) {
  if (kIsWeb) {
    debugPrint('Fokus window tidak tersedia di web');
    return;
  }

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
  \$title = '${_escapePowerShell(windowTitle)}'
  \$process = Get-Process | Where-Object {
    \$_.MainWindowTitle -like "*\$title*" -or \$_.ProcessName -like "*\$title*"
  } | Select-Object -First 1

  if (\$process -and \$process.MainWindowHandle -ne 0) {
    \$handle = \$process.MainWindowHandle
    if ([Win32]::IsIconic(\$handle)) {
      [Win32]::ShowWindow(\$handle, 9) | Out-Null
    }
    [Win32]::SetForegroundWindow(\$handle) | Out-Null
  }
  ''';

  Process.runSync('powershell.exe', [
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-Command',
    script,
  ]);
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

  sendKeys(key);
}

void sendKeys(String text) {
  if (kIsWeb || text.isEmpty) {
    return;
  }

  final script =
      '''
  Add-Type -AssemblyName System.Windows.Forms
  [System.Windows.Forms.SendKeys]::SendWait('${_escapePowerShell(text)}')
  ''';

  Process.runSync('powershell.exe', [
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-Command',
    script,
  ]);
}

void pressEnter() => sendVirtualKey(vkReturn);
void pressTab() => sendVirtualKey(vkTab);

Future<void> sendAutoLogin({
  required String username,
  required String password,
}) async {
  await Future.delayed(const Duration(milliseconds: 250));
  sendKeys(username);
  pressTab();
  sendKeys(password);
  pressEnter();
}

/// Dialog proses sidik jari, dipanggil di halaman cek-in.
void showSidikJariProgress(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Memproses sidik jari",
    barrierColor: Colors.black.withOpacity(0.45),
    pageBuilder: (_, _, _) => const SizedBox.shrink(),
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
}

Future<bool> openExeFromMap(
  BuildContext context,
  Map<String, dynamic> pasien,
) async {
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
    return await openExe(context, nomor);
  } catch (e) {
    TopToast.error(context, "Gagal membuka aplikasi BPJS");
    return false;
  }
}

/// Menjalankan After.exe, login otomatis, input nomor, lalu menunggu proses selesai.
///
/// Mengembalikan `true` bila sidik jari berhasil diproses, `false` bila gagal.
Future<bool> openExe(BuildContext context, String noPeserta) async {
  void gagal(String pesan) {
    if (context.mounted) {
      TopToast.error(context, pesan);
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
    final sudahBerjalan = await isSidikJariRunning();

    if (sudahBerjalan) {
      debugPrint("After.exe sudah berjalan -> tidak membuka instance lagi");
    } else {
      if (!File(sidikJariExePath).existsSync()) {
        gagal("Aplikasi sidik jari tidak ditemukan. Silakan coba lagi.");
        return false;
      }

      process = await Process.start(
        sidikJariExePath,
        [],
        runInShell: true,
        mode: ProcessStartMode.normal,
      );

      // Tunggu proses muncul (polling cepat, bukan delay tetap).
      final muncul = await waitUntil(
        isSidikJariRunning,
        timeout: _sidikJariLaunchTimeout,
      );

      if (!muncul) {
        gagal("Aplikasi sidik jari gagal dibuka. Silakan coba lagi.");
        return false;
      }
    }

    // Beri waktu window siap difokuskan tanpa delay panjang.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    focusWindow("After.exe");

    final accounts = await VclaimApiService.getVclaimAccounts();
    if (accounts.isEmpty) {
      gagal("Data VClaim accounts kosong. Auto-login dihentikan. Silakan coba lagi.");
      return false;
    }

    final account = accounts.first;
    if (account.username.isEmpty || account.password.isEmpty) {
      gagal("Username/password VClaim tidak valid. Silakan coba lagi.");
      return false;
    }

    await sendAutoLogin(username: account.username, password: account.password);

    await Future.delayed(const Duration(milliseconds: 800));
    if (!context.mounted) {
      return false;
    }
    await sendNoPeserta(context, noPeserta);

    if (process == null) {
      // Setelah.exe sudah berjalan sebelumnya, tidak ada proses yang dipantau.
      return true;
    }

    // Tunggu After.exe selesai (pasien selesai sidik jari).
    try {
      final code = await process.exitCode.timeout(_sidikJariExitTimeout);
      debugPrint("After.exe selesai, exit code: $code");
      return code == 0;
    } on TimeoutException {
      // Masih berjalan melewati batas waktu: proses dianggap sedang jalan.
      debugPrint("After.exe masih berjalan, lanjut ke tahap berikutnya");
      return true;
    }
  } catch (e) {
    debugPrint("Error: $e");
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
  String normalizedNomor = normalizeNomor(nomor);
  String tipe = detectNomorType(normalizedNomor);

  if (tipe == "UNKNOWN") {
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

    if (await isSidikJariRunning()) {
      await closeSidikJariExe();
    }
    return;
  }

  await Future.delayed(const Duration(milliseconds: 100));

  focusWindow("After.exe");
  for (int i = 0; i < 5; i++) {
    sendKeys("{ESC}");
  }

  sendKeys("{TAB}");
  for (int i = 0; i < 10; i++) {
    sendKeys("+{TAB}");
  }

  if (tipe == "BPJS") {
    sendKeys("{TAB}");
    sendKeys("{TAB}");
    sendKeys(" ");
  } else if (tipe == "NIK") {
    sendKeys("{TAB}");
    sendKeys("{TAB}");
    sendKeys("{TAB}");
    sendKeys(" ");
  }

  sendKeys("{TAB}");
  sendKeys("{HOME}");
  sendKeys("+{END}");
  sendKeys("{DELETE}");

  sendKeys(normalizedNomor);

  // import 'package:flutter/services.dart';
  // await Clipboard.setData(ClipboardData(text: normalizedNomor));
  // sendKeys("^{V}");
  sendKeys("{ENTER}");
  // await Future.delayed(const Duration(milliseconds: 50));
}
