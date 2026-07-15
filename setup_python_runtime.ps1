Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Python Runtime Setup for Flutter (Konfigurasi by sakina)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$PythonVersion = "3.11.0"
$DownloadUrl = "https://www.python.org/ftp/python/$PythonVersion/python-$PythonVersion-embed-amd64.zip"
$ZipFile = "python-embed.zip"
$ExtractPath = "python_runtime"

# 1. Download
Write-Host "[1/4] Downloading Python $PythonVersion embeddable..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipFile -UseBasicParsing
    Write-Host "Download completed!" -ForegroundColor Green
} catch {
    Write-Host "Download failed: $_" -ForegroundColor Red
    exit 1
}

# 2. Ekstrak
Write-Host ""
Write-Host "[2/4] Extracting to $ExtractPath..." -ForegroundColor Yellow
if (Test-Path $ExtractPath) {
    Remove-Item -Path $ExtractPath -Recurse -Force
}
try {
    Expand-Archive -Path $ZipFile -DestinationPath $ExtractPath
    Write-Host "Extraction completed!" -ForegroundColor Green
} catch {
    Write-Host "Extraction failed: $_" -ForegroundColor Red
    exit 1
}

# 3. Bersihkan
Write-Host ""
Write-Host "[3/4] Cleaning up..." -ForegroundColor Yellow
Remove-Item -Path $ZipFile -Force
Write-Host "Cleanup completed!" -ForegroundColor Green

# 4. Verifikasi
Write-Host ""
Write-Host "[4/4] Verifying installation..." -ForegroundColor Yellow
$PythonExe = Join-Path $ExtractPath "python.exe"
if (Test-Path $PythonExe) {
    Write-Host "Python runtime successfully installed at $ExtractPath" -ForegroundColor Green
    
    # Test run
    Write-Host ""
    Write-Host "Testing Python version:" -ForegroundColor Cyan
    & $PythonExe --version
    
    # List contents
    Write-Host ""
    Write-Host "Contents of $ExtractPath:" -ForegroundColor Cyan
    Get-ChildItem $ExtractPath | Format-Table Name, Length
} else {
    Write-Host "Installation failed! python.exe not found." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Setup completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Edit $ExtractPath\python311._pth (add 'Lib' and 'site-packages')" -ForegroundColor White
Write-Host "2. Install required packages:" -ForegroundColor White
Write-Host "   cd $ExtractPath" -ForegroundColor Gray
Write-Host "   .\python.exe -m ensurepip" -ForegroundColor Gray
Write-Host "   .\python.exe -m pip install numpy pandas -t ." -ForegroundColor Gray
Write-Host "3. Build Flutter app:" -ForegroundColor White
Write-Host "   flutter clean && flutter build windows" -ForegroundColor Gray