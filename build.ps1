# build.ps1
# Build aplikasi APM (default: Windows) dengan versi yang otomatis bertambah.
#
# Setiap kali dijalankan, skrip akan:
#   1. Membaca versi dari pubspec.yaml (format: x.y.z+N)
#   2. Menaikkan bagian patch (x.y.z -> x.y.z+1) DAN build number (+N -> +N+1)
#   3. Menulis kembali versi baru ke pubspec.yaml
#   4. Menyinkronkan AppInfo.version di lib/theme/app_tokens.dart agar tampil di UI
#   5. Menjalankan `flutter build <mode>`
#
# Contoh penggunaan (PowerShell):
#   .\build.ps1                       # build Windows, versi naik otomatis
#   .\build.ps1 -DryRun               # cek versi baru tanpa build & tanpa ubah file
#   .\build.ps1 -BumpOnly             # hanya naikkan versi (tanpa build); dipakai hook flutter
#   .\build.ps1 apk                   # build Android APK
#   .\build.ps1 windows --release     # teruskan argumen ekstra ke flutter build
#
# Hook otomatis (function flutter di profil PowerShell) menjalankan:
#   .\build.ps1 -BumpOnly   lalu   flutter build <...>
# sehingga perintah `flutter build windows` biasa langsung menaikkan versi.
#
# Jika ExecutionPolicy memblokir, jalankan:
#   powershell -ExecutionPolicy Bypass -File .\build.ps1

param(
    [string]$Mode = "windows",
    [switch]$DryRun,
    [switch]$BumpOnly,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs = @()
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $root

$pubspecPath    = Join-Path $root "pubspec.yaml"
$appTokensPath  = Join-Path $root "lib/theme/app_tokens.dart"

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

# --- 1. Baca versi saat ini dari pubspec.yaml ---
$pubspecRaw = [System.IO.File]::ReadAllText($pubspecPath)
$versionMatch = [regex]::Match($pubspecRaw, '(?m)^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$')
if (-not $versionMatch.Success) {
    Write-Host "ERROR: Baris 'version: x.y.z+N' tidak ditemukan di pubspec.yaml" -ForegroundColor Red
    exit 1
}

$curName  = $versionMatch.Groups[1].Value
$curBuild = [int]$versionMatch.Groups[2].Value
$parts    = $curName.Split('.')
$major    = [int]$parts[0]
$minor    = [int]$parts[1]
$patch    = [int]$parts[2]

# --- 2. Naikkan patch + build number ---
$newPatch  = $patch + 1
$newBuild  = $curBuild + 1
$newName   = "$major.$minor.$newPatch"
$newVersion = "$newName+$newBuild"

Write-Host "Versi  : $curName+$curBuild  ->  $newVersion" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "[DryRun] Tidak ada file yang diubah dan build tidak dijalankan." -ForegroundColor Yellow
    exit 0
}

# --- 3. Tulis kembali ke pubspec.yaml ---
$newPubspec = [regex]::Replace(
    $pubspecRaw,
    '(?m)^version:\s*[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+\s*$',
    "version: $newVersion"
)
Write-Utf8NoBom -Path $pubspecPath -Content $newPubspec

# --- 4. Sinkronkan AppInfo.version di app_tokens.dart ---
if (Test-Path -LiteralPath $appTokensPath) {
    $tokensRaw = [System.IO.File]::ReadAllText($appTokensPath)
    $newTokens = [regex]::Replace(
        $tokensRaw,
        "(static const String version = ')[^']*(';)",
        "`${1}$newName`${2}"
    )
    if ($newTokens -ne $tokensRaw) {
        Write-Utf8NoBom -Path $appTokensPath -Content $newTokens
        Write-Host "AppInfo : version -> $newName (tampil sebagai v$newName di UI)" -ForegroundColor Cyan
    } else {
        Write-Host "AppInfo : pola tidak cocok, dilewati." -ForegroundColor Yellow
    }
} else {
    Write-Host "AppInfo : $appTokensPath tidak ditemukan, dilewati." -ForegroundColor Yellow
}

# --- 5. Build ( dilewati jika -BumpOnly ) ---
if ($BumpOnly) {
    Write-Host "[BumpOnly] Versi dinaikkan ke $newVersion. Build dilewati." -ForegroundColor Green
    exit 0
}

Write-Host "Menjalankan: flutter build $Mode $($ExtraArgs -join ' ')" -ForegroundColor Green
& flutter build $Mode @ExtraArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build gagal (exit code $LASTEXITCODE)." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Selesai. Versi build: $newVersion" -ForegroundColor Green