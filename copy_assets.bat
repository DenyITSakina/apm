@echo off
REM Path source asset
set SRC=assets\After.exe

REM Path target folder build release
set DEST=build\windows\runner\Release\assets

REM Buat folder target kalau belum ada
if not exist "%DEST%" (
    mkdir "%DEST%"
)

REM Copy file
copy "%SRC%" "%DEST%" /Y

echo Asset copied to %DEST%
