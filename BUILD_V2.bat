@echo off
setlocal
cd /d "%~dp0"
chcp 65001 >nul
title RAKEN SANDBOX V2 - WINDOWS BUILD

echo ============================================================
echo                  RAKEN SANDBOX V2
echo                    WINDOWS BUILD
echo ============================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Tools\Build-Windows.ps1"

if errorlevel 1 (
    echo.
    echo BUILD HATASI
    echo Pencere kapatilmayacak.
    pause
    exit /b 1
)

echo.
echo BUILD TAMAMLANDI
echo Build\Windows klasorunu kontrol et.
echo.
pause
