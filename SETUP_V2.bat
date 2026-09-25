@echo off
setlocal
cd /d "%~dp0"
chcp 65001 >nul
title RAKEN SANDBOX V2 - SETUP

echo ============================================================
echo                 RAKEN SANDBOX V2
echo                   UNREAL SETUP
echo ============================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Tools\Prepare-Project.ps1"

if errorlevel 1 (
    echo.
    echo SETUP HATASI
    echo Pencere kapatilmayacak.
    pause
    exit /b 1
)

echo.
echo RAKEN SANDBOX V2 proje hazir.
echo Artik RakenSandboxV2.uproject dosyasini acabilirsin.
echo.
pause
