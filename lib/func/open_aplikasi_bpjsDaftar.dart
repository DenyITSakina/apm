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

enum SidikJariStatus { selesai, popupError, timeout }

const String _namaScriptOtomatis = 'sidik_jari_otomatis.ps1';
const String _namaScriptBacaTeks = 'sidik_jari_baca_teks.ps1';

/// Teks UI After.exe yang menandakan sidik jari berhasil tersimpan.
const List<String> _kunciSukses = [
  'data berhasil disimpan',
  'sidik jari berhasil disimpan',
  'berhasil disimpan',
  'verifikasi berhasil',
];

/// Teks UI After.exe yang menandakan penolakan atas nomor yang dikirim.
const List<String> _kunciGagal = [
  'data gagal disimpan',
  'gagal disimpan',
  'tidak ditemukan',
  'tidak bisa dikenali',
  'belum terdaftar',
  'tidak sesuai',
  'harus 13 digit',
  'format no',
  'sudah terdaftar',
  'penolakan',
];

/// Kondisi lingkungan (bukan penolakan nomor). Hanya untuk pesan informatif.
const List<String> _kunciPeringatan = [
  'mesin fingerprint terhubung', // "Pastikan Mesin Fingerprint Terhubung..."
];

/// Klasifikasi teks UI After.exe. Null = belum ada petunjuk.
SidikJariStatus? _klasifikasiTeksUi(String teks) {
  final t = teks.toLowerCase();
  if (_kunciSukses.any(t.contains)) {
    return SidikJariStatus.selesai;
  }
  if (_kunciGagal.any(t.contains)) {
    return SidikJariStatus.popupError;
  }
  return null;
}

/// Teks UI terakhir yang terbaca, dipakai untuk pesan error.
String? lastTeksSidikJari;

/// Ambil bagian teks yang mencurigakan (error/sukses/peringatan).
String _ringkasTeks(String teks) {
  final bagian = teks.split('~').map((e) => e.trim());
  final mencurigakan = bagian.where((e) {
    final t = e.toLowerCase();
    return _kunciGagal.any(t.contains) ||
        _kunciSukses.any(t.contains) ||
        _kunciPeringatan.any(t.contains);
  }).toList();
  if (mencurigakan.isEmpty) {
    return 'teks UI tidak terbaca';
  }
  return mencurigakan.join(' | ');
}

/// Menunggu sidik jari selesai dengan membaca teks UI After.exe.
///
/// Dua penanda sukses: aplikasi menampilkan teks berhasil, atau aplikasi
/// menutup dirinya sendiri (After.exe menutup diri setelah nomor diproses).
/// Teks error/penolakan menghasilkan kegagalan lebih awal.
Future<SidikJariStatus> waitSidikJariSelesai(Duration timeout) async {
  const interval = Duration(milliseconds: 1500);
  final stopwatch = Stopwatch()..start();
  var sudahBacaTeks = false;

  while (true) {
    final teks = await bacaTeksSidikJari();

    if (teks == null) {
      _logSidikJari(
        sudahBacaTeks
            ? "Aplikasi menutup diri -> sidik jari selesai"
            : "Aplikasi menutup diri (${stopwatch.elapsed.inSeconds} dtk setelah nomor dikirim)",
      );
      return SidikJariStatus.selesai;
    }

    sudahBacaTeks = true;
    lastTeksSidikJari = _ringkasTeks(teks);
    final status = _klasifikasiTeksUi(teks);

    if (status == SidikJariStatus.selesai) {
      _logSidikJari("Teks sukses terdeteksi: $lastTeksSidikJari");
      return SidikJariStatus.selesai;
    }

    if (status == SidikJariStatus.popupError) {
      _logSidikJari("Teks penolakan terdeteksi: $lastTeksSidikJari");
      return SidikJariStatus.popupError;
    }

    if (stopwatch.elapsed >= timeout) {
      return SidikJariStatus.timeout;
    }

    await Future<void>.delayed(interval);
  }
}

/// Script PowerShell: isi field + klik tombol lewat UI Automation (WPF).
///
/// Field After.exe ( AutomationId ): am=username, an=password, ao=Login,
/// ar/as=radio BPJS/NIK, au=input nomor (aktif setelah login diterima).
/// Kredensial lewat environment variable supaya tidak terlihat di task manager.
const String _isiScriptOtomatis = r'''
$ErrorActionPreference = 'Stop'
$User = $env:SIDIK_USER
$Password = $env:SIDIK_PASS
$Nomor = $env:SIDIK_NOMOR
$Mode = $env:SIDIK_MODE
$WindowTimeoutSec = if ($env:SIDIK_WIN_TIMEOUT) { [int]$env:SIDIK_WIN_TIMEOUT } else { 10 }
$LoginTimeoutSec = if ($env:SIDIK_LOGIN_TIMEOUT) { [int]$env:SIDIK_LOGIN_TIMEOUT } else { 20 }

Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -AssemblyName System.Windows.Forms
$sig = @"
using System;
using System.Runtime.InteropServices;
public static class Fg {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
}
"@
Add-Type -TypeDefinition $sig

function Find-AfterWindow {
  Get-Process -Name After -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowHandle -ne 0 } |
    Sort-Object { $_.MainWindowTitle -like '*Sidik Jari*' } -Descending |
    Select-Object -First 1
}

# After.exe buddakan 2 proses; pilih yang benar-benar punya form login (id 'ao').
function Find-AfterForm {
  foreach ($p in (Get-Process -Name After -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowHandle -ne 0 })) {
    try {
      $r = [System.Windows.Automation.AutomationElement]::FromHandle($p.MainWindowHandle)
      $cond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::AutomationIdProperty, 'ao')
      $found = $r.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $cond)
      if ($found) { return $p }
    } catch { }
  }
  return (Find-AfterWindow)
}

function Get-Root($proc) {
  [System.Windows.Automation.AutomationElement]::FromHandle($proc.MainWindowHandle)
}
function Get-El($root, [string]$id) {
  $cond = New-Object System.Windows.Automation.PropertyCondition(
    [System.Windows.Automation.AutomationElement]::AutomationIdProperty, $id)
  $root.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $cond)
}
function Get-Texts($root) {
  $all = $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
  $out = @()
  foreach ($e in $all) {
    $n = $e.Current.Name
    if ($n -and $n.Length -gt 2) { $out += $n }
  }
  return $out
}
function Send-Text([string]$text) {
  $e = $text.Replace('(', '{(}').Replace(')', '{)}').Replace('+', '{+}').Replace('^', '{^}').Replace('%', '{%}').Replace('~', '{~}').Replace('{', '{{}').Replace('}', '{}}')
  [System.Windows.Forms.SendKeys]::SendWait($e)
}
function Activate-After($proc) {
  $hh = $proc.MainWindowHandle
  if ([Fg]::IsIconic($hh)) { [Fg]::ShowWindow($hh, 9) | Out-Null }
  [Fg]::SetForegroundWindow($hh) | Out-Null
}

$deadline = (Get-Date).AddSeconds($WindowTimeoutSec)
$proc = $null
while ((Get-Date) -lt $deadline) {
  $proc = Find-AfterWindow
  if ($proc) { break }
  Start-Sleep -Milliseconds 100
}
if (-not $proc) { Write-Output 'STEP=WINDOW_NOT_FOUND'; exit 2 }

# Tunggu form login benar-benar siap (bukan hanya window splash).
$deadline = (Get-Date).AddSeconds($WindowTimeoutSec)
$formSiap = $false
while ((Get-Date) -lt $deadline) {
  $proc = Find-AfterForm
  if ($proc) {
    $root = Get-Root $proc
    if (Get-El $root 'ao') { $formSiap = $true; break }
  }
  Start-Sleep -Milliseconds 150
}
if (-not $formSiap) { Write-Output 'STEP=FIELDS_NOT_FOUND'; exit 3 }
Write-Output ("STEP=WINDOW_OK " + $proc.MainWindowTitle)

$h = $proc.MainWindowHandle
if ([Fg]::IsIconic($h)) { [Fg]::ShowWindow($h, 9) | Out-Null }
[Fg]::SetForegroundWindow($h) | Out-Null
Start-Sleep -Milliseconds 120

$root = Get-Root $proc
$editUser = Get-El $root 'am'
$editPass = Get-El $root 'an'
$btnLogin = Get-El $root 'ao'
$editNomor = Get-El $root 'au'
$radioId = if ($Mode -eq 'NIK') { 'as' } else { 'ar' }
$radio = Get-El $root $radioId

if (-not $editUser -or -not $editPass -or -not $btnLogin -or -not $editNomor) {
  Write-Output 'STEP=FIELDS_NOT_FOUND'
  exit 3
}
Write-Output 'STEP=FIELDS_OK'

# Pre-flight 1: After.ini ideally punya WSURL. Tidak boleh memblokir alur —
# pada mesin tanpa WSURL login tetap berhasil, jadi hanya dicatat sebagai warning.
$ini = Join-Path (Split-Path $proc.Path) 'After.ini'
if (Test-Path $ini) {
  $line = Select-String -Path $ini -Pattern '^\s*WSURL\s*=\s*(.*)$' | Select-Object -First 1
  $wsurl = ''
  if ($line -and $line.Matches.Count -gt 0) { $wsurl = $line.Matches[0].Groups[1].Value.Trim() }
  if ($wsurl -eq '') { Write-Output 'STEP=WARN_NO_SERVER' } else { Write-Output 'STEP=SERVER_OK' }
} else {
  Write-Output 'STEP=WARN_NO_INI'
}

# Pre-flight 2: reader sidik jari. Banner "Pastikan Mesin Fingerprint ..." bisa
# muncul sesaat, jadi hanya warning — penolakan asli dibaca dari teks UI akhir.
$readerProblem = ''
foreach ($t in (Get-Texts $root)) {
  if ($t -like '*Mesin Fingerprint*') { $readerProblem = $t; break }
}
if ($readerProblem -ne '') { Write-Output ("STEP=WARN_READER " + $readerProblem) } else { Write-Output 'STEP=READER_OK' }

try {
  $editUser.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).SetValue($User)
  Write-Output 'STEP=USER_OK'
} catch {
  Write-Output ("STEP=USER_FAIL " + $_.Exception.Message)
  exit 4
}

# Password: WPF PasswordBox menolak SetFocus saat window belum aktif, jadi
# fokuskan field username lalu pindah dengan TAB.
$passOk = $false
$viaTab = $false
for ($i = 0; $i -lt 6; $i++) {
  Activate-After $proc
  Start-Sleep -Milliseconds 150
  try {
    $editPass.SetFocus()
    $passOk = $true
    break
  } catch {
    try {
      $editUser.SetFocus()
      Start-Sleep -Milliseconds 120
      $passOk = $true
      $viaTab = $true
      break
    } catch { }
    Start-Sleep -Milliseconds 150
  }
}
if (-not $passOk) {
  Write-Output 'STEP=PASS_FAIL tidak bisa memfokuskan field password'
  exit 5
}

Start-Sleep -Milliseconds 120
if ($viaTab) {
  [System.Windows.Forms.SendKeys]::SendWait('{TAB}')
  Start-Sleep -Milliseconds 80
} else {
  [System.Windows.Forms.SendKeys]::SendWait('^a')
  Start-Sleep -Milliseconds 50
}
Send-Text $Password
Write-Output 'STEP=PASS_OK'

try {
  $btnLogin.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern).Invoke()
  Write-Output 'STEP=LOGIN_CLICKED'
} catch {
  Write-Output ("STEP=LOGIN_FAIL " + $_.Exception.Message)
  exit 6
}

$deadline = (Get-Date).AddSeconds($LoginTimeoutSec)
$siap = $false
while ((Get-Date) -lt $deadline) {
  Start-Sleep -Milliseconds 200
  $proc = Find-AfterWindow
  if (-not $proc) { Write-Output 'STEP=APP_CLOSED_DURING_LOGIN'; exit 7 }
  $root = Get-Root $proc
  $found = Get-El $root 'au'
  if ($found -and $found.Current.IsEnabled) { $siap = $true; break }
}
if (-not $siap) { Write-Output 'STEP=LOGIN_TIMEOUT'; exit 8 }
Write-Output 'STEP=LOGIN_OK'

if ($radio) {
  try {
    $sp = $radio.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern)
    if (-not $sp.Current.IsSelected) { $sp.Select(); Start-Sleep -Milliseconds 200; Write-Output ('STEP=MODE_SET ' + $Mode) }
    else { Write-Output 'STEP=MODE_OK' }
  } catch {
    Write-Output ("STEP=MODE_FAIL " + $_.Exception.Message)
  }
}

try {
  $editNomor = Get-El $root 'au'
  $editNomor.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).SetValue($Nomor)
  $editNomor.SetFocus()
  Start-Sleep -Milliseconds 150
  [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
  Write-Output 'STEP=NOMOR_OK'
} catch {
  Write-Output ("STEP=NOMOR_FAIL " + $_.Exception.Message)
  exit 9
}
exit 0
''';

/// Script PowerShell: baca seluruh teks UI After.exe (dipakai memastikan hasil
/// sidik jari, bukan menebak dari proses yang menutup).
const String _isiScriptBacaTeks = r'''
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
$chosen = $null
foreach ($p in (Get-Process -Name After -ErrorAction SilentlyContinue |
  Where-Object { $_.MainWindowHandle -ne 0 })) {
  try {
    $r = [System.Windows.Automation.AutomationElement]::FromHandle($p.MainWindowHandle)
    $cond = New-Object System.Windows.Automation.PropertyCondition(
      [System.Windows.Automation.AutomationElement]::AutomationIdProperty, 'ao')
    if ($r.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $cond)) { $chosen = $r; break }
    if (-not $chosen) { $chosen = $r }
  } catch { }
}
if (-not $chosen) { Write-Output 'APP_CLOSED'; exit 1 }
$all = $chosen.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
$texts = @()
foreach ($e in $all) {
  $n = $e.Current.Name
  if ($n -and $n.Length -gt 2) { $texts += $n }
}
Write-Output ($texts -join ' ~ ')
exit 0
''';

/// Tulis script ke temp sekali saja, lalu jalankan.
Future<String> _jalankanScriptPs({
  required String nama,
  required String isi,
  Map<String, String> environment = const {},
}) async {
  final file = File(
    '${Directory.systemTemp.path}${Platform.pathSeparator}$nama',
  );

  if (!file.existsSync() || file.lengthSync() != isi.length) {
    await file.writeAsString(isi, flush: true);
  }

  final result = await Process.run(
    'powershell.exe',
    ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', file.path],
    environment: environment,
    runInShell: false,
  );

  return result.stdout.toString();
}

/// Hasil menjalankan otomasi UI.
class HasilOtomatis {
  final bool berhasil;
  final List<String> langkah;
  final String alasan;

  const HasilOtomatis({
    required this.berhasil,
    required this.langkah,
    required this.alasan,
  });
}

/// Mengisi username/password, login, dan nomor lewat UI Automation.
Future<HasilOtomatis> jalankanOtomatisSidikJari({
  required String username,
  required String password,
  required String nomor,
  required String tipe,
  int loginTimeoutDetik = 20,
}) async {
  try {
    final output = await _jalankanScriptPs(
      nama: _namaScriptOtomatis,
      isi: _isiScriptOtomatis,
      environment: {
        'SIDIK_USER': username,
        'SIDIK_PASS': password,
        'SIDIK_NOMOR': nomor,
        'SIDIK_MODE': tipe,
        'SIDIK_WIN_TIMEOUT': _sidikJariLaunchTimeout.inSeconds.toString(),
        'SIDIK_LOGIN_TIMEOUT': loginTimeoutDetik.toString(),
      },
    );

    final langkah = output
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.startsWith('STEP='))
        .toList();

    _logSidikJari("Otomasi UI: ${langkah.join(' | ')}");

    if (langkah.contains('STEP=NOMOR_OK')) {
      return HasilOtomatis(berhasil: true, langkah: langkah, alasan: '');
    }

    return HasilOtomatis(
      berhasil: false,
      langkah: langkah,
      alasan: _alasanDariLangkah(langkah),
    );
  } catch (e) {
    return HasilOtomatis(
      berhasil: false,
      langkah: const [],
      alasan: 'otomasi UI gagal dijalankan: $e',
    );
  }
}

String _alasanDariLangkah(List<String> langkah) {
  String? cari(String prefix) {
    for (final l in langkah) {
      if (l.startsWith(prefix)) {
        return l.substring(prefix.length).trim();
      }
    }
    return null;
  }

  if (cari('STEP=WINDOW_NOT_FOUND') != null) {
    return 'jendela aplikasi sidik jari tidak muncul';
  }
  if (cari('STEP=FIELDS_NOT_FOUND') != null) {
    return 'field login tidak ditemukan (versi aplikasi berubah?)';
  }
  if (cari('STEP=WARN_NO_SERVER') != null) {
    return 'After.ini WSURL kosong (login tetap dicoba)';
  }
  if (cari('STEP=WARN_READER') != null) {
    return 'mesin fingerprint dilaporkan belum terhubung';
  }
  if (cari('STEP=USER_FAIL') != null) return 'username gagal diisi';
  if (cari('STEP=PASS_FAIL') != null) return 'password gagal diisi';
  if (cari('STEP=LOGIN_FAIL') != null) return 'tombol login gagal ditekan';
  if (cari('STEP=APP_CLOSED_DURING_LOGIN') != null) {
    return 'aplikasi sidik jari tertutup saat login';
  }
  if (cari('STEP=LOGIN_TIMEOUT') != null) {
    return 'login ditolak (periksa akun VClaim dan jaringan)';
  }
  if (cari('STEP=NOMOR_FAIL') != null) return 'nomor gagal diisi';
  return 'langkah otomasi tidak lengkap';
}

/// Baca teks UI After.exe. Null bila aplikasi sudah tertutup.
Future<String?> bacaTeksSidikJari() async {
  try {
    final output = await _jalankanScriptPs(
      nama: _namaScriptBacaTeks,
      isi: _isiScriptBacaTeks,
    );

    if (output.contains('APP_CLOSED')) {
      return null;
    }
    return output.trim();
  } catch (e) {
    debugPrint("Gagal membaca teks UI: $e");
    return null;
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
Future<void> sendKeySequence(List<String> keys, {int jedaMs = 25}) async {
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

    // Ambil akun VClaim (network) bersamaan dengan persiapan window.
    final futureAkun = _ambilAkunVclaim();
    final nomor = normalizeNomor(noPeserta);
    final tipe = detectNomorType(nomor);

    final swOto = Stopwatch()..start();
    final akun = await futureAkun;
    if (!akun.berhasil) {
      gagal(akun.alasan, "Data akun VClaim tidak dapat diakses.");
      return false;
    }

    // Jalur cepat: kendalikan UI After.exe langsung (bukan mengetik buta).
    final hasilOto = await jalankanOtomatisSidikJari(
      username: akun.username!,
      password: akun.password!,
      nomor: nomor,
      tipe: tipe,
    );
    _logSidikJari("Otomasi UI selesai (${swOto.elapsedMilliseconds} ms)");

    var sukses = hasilOto.berhasil;
    if (!sukses &&
        hasilOto.alasan.contains('field login tidak ditemukan')) {
      // Struktur UI berubah: pakai jalur ketik lama.
      _logSidikJari("Fallback ke input keyboard");
      if (!context.mounted) {
        return false;
      }
      sukses = await _jalankanViaKetik(
        context: context,
        username: akun.username!,
        password: akun.password!,
        nomor: nomor,
      );
    }

    if (!sukses) {
      gagal(hasilOto.alasan, "Sidik jari gagal diproses.");
      return false;
    }

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
        _logSidikJari("Sidik jari terverifikasi dari UI aplikasi");
        return true;
      case SidikJariStatus.popupError:
        gagal(
          "ditolak aplikasi: ${lastTeksSidikJari ?? 'pesan tidak terbaca'}",
          "Aplikasi sidik jari menolak proses.",
        );
        return false;
      case SidikJariStatus.timeout:
        gagal(
          "belum selesai dalam ${_sidikJariExitTimeout.inMinutes} menit"
              "${lastTeksSidikJari != null && lastTeksSidikJari != 'teks UI tidak terbaca' ? ' ($lastTeksSidikJari)' : ''}",
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

class _AkunVclaim {
  final bool berhasil;
  final String? username;
  final String? password;
  final String alasan;

  const _AkunVclaim({
    required this.berhasil,
    this.username,
    this.password,
    required this.alasan,
  });
}

Future<_AkunVclaim> _ambilAkunVclaim() async {
  try {
    final accounts = await VclaimApiService.getVclaimAccounts();
    if (accounts.isEmpty) {
      return const _AkunVclaim(berhasil: false, alasan: 'akun VClaim kosong');
    }
    final a = accounts.first;
    if (a.username.isEmpty || a.password.isEmpty) {
      return const _AkunVclaim(
        berhasil: false,
        alasan: 'akun VClaim tidak lengkap',
      );
    }
    return _AkunVclaim(
      berhasil: true,
      username: a.username,
      password: a.password,
      alasan: '',
    );
  } catch (e) {
    _logSidikJari("Exception API akun: $e");
    return const _AkunVclaim(
      berhasil: false,
      alasan: 'API akun tidak dapat diakses',
    );
  }
}

/// Jalur cadangan: fokus window + ketik seperti versi lama.
Future<bool> _jalankanViaKetik({
  required BuildContext context,
  required String username,
  required String password,
  required String nomor,
}) async {
  await focusWindow(sidikJariExePath);
  await sendAutoLogin(username: username, password: password);
  await Future<void>.delayed(const Duration(milliseconds: 800));
  if (!context.mounted) {
    return false;
  }
  await sendNoPeserta(context, nomor);
  return true;
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
      if (tipe == "BPJS") ...[
        "{TAB}",
        "{TAB}",
        " ",
      ] else if (tipe == "NIK") ...[
        "{TAB}",
        "{TAB}",
        "{TAB}",
        " ",
      ],
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
