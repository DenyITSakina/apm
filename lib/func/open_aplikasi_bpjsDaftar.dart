// ignore: file_names
import 'dart:ffi';
import 'dart:io';

import 'package:apm/dialog/top_toast.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';

Future<bool> isSidikJariRunning() async {
  final result = await Process.run('tasklist', [], runInShell: true);
  return result.stdout.toString().contains("After.exe");
}

Future<void> closeSidikJariExe() async {
  await Process.run('taskkill', ['/IM', 'After.exe', '/F'], runInShell: true);
}

bool isWindowOpen(String windowTitle) {
  final titlePtr = windowTitle.toNativeUtf16();
  final hWnd = FindWindow(nullptr, titlePtr);
  calloc.free(titlePtr);
  return hWnd != 0;
}

void focusWindow(String windowTitle) {
  final titlePtr = windowTitle.toNativeUtf16();
  final hWnd = FindWindow(nullptr, titlePtr);

  if (hWnd != 0) {
    SetForegroundWindow(hWnd);
    debugPrint("Window ditemukan & difokuskan");
  } else {
    debugPrint("Window tidak ditemukan: $windowTitle");
  }

  calloc.free(titlePtr);
}

void sendVirtualKey(int keyCode) {
  final input = calloc<INPUT>();
  input.ref.type = INPUT_KEYBOARD;
  input.ref.ki.wVk = keyCode;
  SendInput(1, input, sizeOf<INPUT>());

  input.ref.ki.dwFlags = KEYEVENTF_KEYUP;
  SendInput(1, input, sizeOf<INPUT>());

  calloc.free(input);
}

void sendKeys(String text) {
  for (final rune in text.runes) {
    final input = calloc<INPUT>();
    input.ref.type = INPUT_KEYBOARD;
    input.ref.ki.wScan = rune;
    input.ref.ki.dwFlags = KEYEVENTF_UNICODE;
    SendInput(1, input, sizeOf<INPUT>());

    input.ref.ki.dwFlags = KEYEVENTF_UNICODE | KEYEVENTF_KEYUP;
    SendInput(1, input, sizeOf<INPUT>());

    calloc.free(input);
  }
}

void pressEnter() => sendVirtualKey(VK_RETURN);
void pressTab() => sendVirtualKey(VK_TAB);

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

    await sendAutoLogin(username: "cicifitria", password: "Idaman10!");

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
