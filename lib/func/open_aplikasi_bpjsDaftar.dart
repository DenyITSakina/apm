// ignore: file_names
import 'dart:io';

import 'package:apm/dialog/top_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:apm/api/vclaim_api_service.dart';

const int vkReturn = 0x0D;
const int vkTab = 0x09;

Future<bool> isSidikJariRunning() async {
  if (kIsWeb) {
    debugPrint('Fitur proses native tidak tersedia di web');
    return false;
  }

  final result = await Process.run('tasklist', [], runInShell: true);
  return result.stdout.toString().contains("After.exe");
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
  await Future.delayed(const Duration(milliseconds: 400));
  sendKeys(username);
  pressTab();
  sendKeys(password);
  pressEnter();
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
    await openExe(context, nomor);
    return true;
  } catch (e) {
    TopToast.error(context, "Gagal membuka aplikasi BPJS");
    return false;
  }
}

Future<void> openExe(BuildContext context, String noPeserta) async {
  if (kIsWeb) {
    if (context.mounted) {
      TopToast.error(context, 'Fitur ini hanya tersedia di aplikasi desktop');
    }
    return;
  }

  const exePath =
      r"C:\Program Files (x86)\BPJS Kesehatan\Aplikasi Sidik Jari BPJS Kesehatan\After.exe";

  try {
    Process? process;

    // Cegah dobel: hanya buka After.exe jika belum berjalan
    if (await isSidikJariRunning()) {
      debugPrint("After.exe sudah berjalan -> tidak membuka instance lagi");
    } else {
      process = await Process.start(
        exePath,
        [],
        runInShell: true,
        mode: ProcessStartMode.normal,
      );
    }

    await Future.delayed(const Duration(seconds: 2));
    focusWindow("After.exe");

    // await sendAutoLogin(username: "cicifitria", password: "Idaman10!");

    final accounts = await VclaimApiService.getVclaimAccounts();
    if (accounts.isEmpty) {
      if (context.mounted) {
        TopToast.error(
          context,
          "Data VClaim accounts kosong. Auto-login dihentikan.",
        );
      }
      return;
    }

    final account = accounts.first;
    if (account.username.isEmpty || account.password.isEmpty) {
      if (context.mounted) {
        TopToast.error(
          context,
          "Username/password VClaim tidak valid. Auto-login dihentikan.",
        );
      }
      return;
    }

    await sendAutoLogin(username: account.username, password: account.password);

    await Future.delayed(const Duration(seconds: 2));
    await sendNoPeserta(context, noPeserta);

    if (process != null) {
      await process.exitCode;
      debugPrint("EXE menutup sendiri.");
    }
  } catch (e) {
    debugPrint("Error: $e");
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

  print('Auto-detection: $nomor -> $tipe');

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
      print("Nomor salah → EXE akan ditutup otomatis");
      await closeSidikJariExe();
    }
    return;
  }

  await Future.delayed(const Duration(milliseconds: 1000));

  print('Reset fokus ke awal form...');
  for (int i = 0; i < 3; i++) {
    sendKeys("+{TAB}");
    await Future.delayed(const Duration(milliseconds: 200));
  }

  print('Memilih radio button $tipe...');
  if (tipe == "BPJS") {
    await Future.delayed(const Duration(milliseconds: 400));
    sendKeys(" ");
    print('Radio BPJS dipilih');
  } else if (tipe == "NIK") {
    sendKeys("{TAB}");
    await Future.delayed(const Duration(milliseconds: 300));
    sendKeys("{TAB}");
    await Future.delayed(const Duration(milliseconds: 400));
    sendKeys(" ");
    print('Radio NIK dipilih');
  }

  await Future.delayed(const Duration(milliseconds: 400));

  print('Pindah ke field input nomor...');
  sendKeys("{TAB}");
  await Future.delayed(const Duration(milliseconds: 300));

  print('Mengisi nomor: $normalizedNomor');
  sendKeys(normalizedNomor);
  await Future.delayed(const Duration(milliseconds: 800));

  print('Submit form...');
  pressEnter();

  await Future.delayed(const Duration(milliseconds: 500));
  print("Form $tipe selesai diisi");
}
