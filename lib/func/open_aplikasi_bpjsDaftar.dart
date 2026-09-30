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

const int _maxLogBytes = 2 * 1024 * 1024;

File? _logFile;

/// Lokasi log: folder aplikasi bila bisa ditulis, jika tidak ke folder TEMP.
File _resolusiLogFile() {
  final cached = _logFile;
  if (cached != null) {
    return cached;
  }

  final kandidat = <File>[
    File(
      '${Directory.current.path}${Platform.pathSeparator}sidik_jari_log.txt',
    ),
    File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}sidik_jari_log.txt',
    ),
  ];

  for (final file in kandidat) {
    try {
      file.writeAsStringSync('', mode: FileMode.append);
      _logFile = file;
      return file;
    } catch (_) {
      // coba lokasi berikutnya
    }
  }

  _logFile = kandidat.last;
  return _logFile!;
}

/// Log ke console + file `sidik_jari_log.txt` supaya bisa dicek di lapangan
/// tanpa membuka debug console.
void _logSidikJari(String pesan) {
  final stamp = DateTime.now().toIso8601String();
  final baris = "[$stamp] $pesan";
  debugPrint("[SidikJari] $pesan");

  try {
    final file = _resolusiLogFile();
    if (file.existsSync() && file.lengthSync() > _maxLogBytes) {
      file.writeAsStringSync('');
    }
    file.writeAsStringSync('$baris\n', mode: FileMode.append, flush: true);
  } catch (e) {
    debugPrint("Gagal menulis log sidik jari: $e");
  }
}

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

/// Judul semua window milik proses After.exe (termasuk dialog/popup).
Future<List<String>> getSidikJariWindowTitles() async {
  if (kIsWeb) {
    return const [];
  }

  final script = r'''
$sig = @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public class WndEnum {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc cb, IntPtr l);
  [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
}
"@
Add-Type -TypeDefinition $sig
$targets = @(Get-Process -Name After -ErrorAction SilentlyContinue | ForEach-Object { $_.Id })
if ($targets.Count -eq 0) { Write-Output ""; exit 0 }
$found = New-Object System.Collections.ArrayList
$cb = [WndEnum+EnumProc]{
  param($h, $l)
  $procId = 0
  [WndEnum]::GetWindowThreadProcessId($h, [ref]$procId) | Out-Null
  if ($targets -contains $procId) {
    $sb = New-Object System.Text.StringBuilder 512
    [WndEnum]::GetWindowText($h, $sb, 512) | Out-Null
    if ($sb.Length -gt 0) { $found.Add($sb.ToString()) | Out-Null }
  }
  return $true
}
[WndEnum]::EnumWindows($cb, [IntPtr]::Zero) | Out-Null
Write-Output ($found -join '~')
''';

  try {
    final result = await Process.run('powershell.exe', [
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-Command',
      script,
    ]);

    final output = result.stdout.toString().trim();
    if (output.isEmpty) {
      return const [];
    }
    return output
        .split('~')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  } catch (e) {
    debugPrint("Gagal membaca judul window: $e");
    return const [];
  }
}

const List<String> _kunciPopupError = [
  'error',
  'gagal',
  'tidak ditemukan',
  'perhatian',
  'invalid',
  'failed',
  'salah',
  'penolakan',
  'ditolak',
];

/// Window bantu Windows/IME yang ikut muncul tapi bukan popup aplikasi.
const List<String> _abaikanWindow = [
  'ime',
  'cicero',
  'msctf',
  'med(context',
  'systemresourcenotifywindow',
  'applicationframewindow',
  'default ime',
];

bool _adalahPopupError(String title) {
  final lower = title.toLowerCase();
  if (_abaikanWindow.any(lower.contains)) {
    return false;
  }
  return _kunciPopupError.any(lower.contains);
}

enum SidikJariStatus { selesai, popupError, timeout }

/// Menunggu After.exe selesai, sekaligus mendeteksi popup error lebih cepat
/// (selama ini popup hanya membuat kita menunggu sampai 3 menit).
Future<SidikJariStatus> waitSidikJariSelesai(Duration timeout) async {
  const interval = Duration(seconds: 2);
  const cekPopup = Duration(seconds: 5);
  final stopwatch = Stopwatch()..start();
  var nextCekPopup = Duration.zero;

  while (true) {
    if (!(await isSidikJariRunning())) {
      return SidikJariStatus.selesai;
    }

    if (stopwatch.elapsed >= nextCekPopup) {
      nextCekPopup = stopwatch.elapsed + cekPopup;
      final judul = await getSidikJariWindowTitles();
      for (final title in judul) {
        if (_adalahPopupError(title)) {
          _logSidikJari("Popup error terdeteksi: $title");
          return SidikJariStatus.popupError;
        }
      }
    }

    if (stopwatch.elapsed >= timeout) {
      return SidikJariStatus.timeout;
    }

    await Future<void>.delayed(interval);
  }
}

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

/// Samarkan nomor untuk log (jangan tulis nomor BPJS penuh ke file).
String maskNomorLog(String? nomor) {
  final value = (nomor ?? '').trim();
  if (value.length < 8) return value;
  return "${value.substring(0, 4)}****${value.substring(value.length - 4)}";
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
  int? pid;

  try {
    _logSidikJari(
      "Mulai proses | nomor=${maskNomorLog(noPeserta)} | app=${Directory.current.path}",
    );
    _logSidikJari("Log file: ${_resolusiLogFile().path}");
    final sudahBerjalan = await isSidikJariRunning();

    if (sudahBerjalan) {
      _logSidikJari(
        "PERINGATAN: After.exe sudah berjalan dari sesi sebelumnya, "
        "nomor diketik ke window yang ada",
      );
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
      pid = process.pid;
      _logSidikJari("After.exe dijalankan (pid=$pid), menunggu proses muncul");

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

    // Tunggu window siap. Spasi 500 ms: isWindowOpen spawn PowerShell (~300 ms).
    final windowSiap = await waitUntil(
      () async => isWindowOpen(sidikJariExePath),
      timeout: _sidikJariLaunchTimeout,
      interval: const Duration(milliseconds: 500),
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

    _logSidikJari("Auto login dikirim: user=${account.username}");
    final swLogin = Stopwatch()..start();
    await sendAutoLogin(
      username: account.username,
      password: account.password,
    );
    _logSidikJari("Auto login terkirim (${swLogin.elapsedMilliseconds} ms)");

    await Future.delayed(const Duration(milliseconds: 800));
    if (!context.mounted) {
      return false;
    }
    final swNomor = Stopwatch()..start();
    await sendNoPeserta(context, noPeserta);
    _logSidikJari(
      "Nomor dikirim (${swNomor.elapsedMilliseconds} ms), "
      "menunggu After.exe selesai",
    );

    if (process == null) {
      _logSidikJari("Dipantau proses yang sudah berjalan sebelumnya");
    }

    final swTunggu = Stopwatch()..start();
    final status = await waitSidikJariSelesai(_sidikJariExitTimeout);
    _logSidikJari(
      "Status setelah ${swTunggu.elapsed.inSeconds} detik: $status",
    );

    switch (status) {
      case SidikJariStatus.selesai:
        _logSidikJari("After.exe selesai -> dianggap sukses");
        return true;
      case SidikJariStatus.popupError:
        gagal(
          "popup error di aplikasi sidik jari",
          "Aplikasi sidik jari menampilkan pesan error.",
        );
        return false;
      case SidikJariStatus.timeout:
        gagal(
          "belum selesai dalam ${_sidikJariExitTimeout.inMinutes} menit",
          "Sidik jari belum selesai diproses.",
        );
        return false;
    }
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
