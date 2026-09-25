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

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Tools\Bootstrap-Unreal.ps1"

if errorlevel 1 (
    echo.
    echo SETUP HATASI
    pause
    exit /b 1
)

echo.
echo Starter content hazir.
echo RakenSandboxV2.uproject dosyasini Unreal Engine ile acabilirsin.
echo.
pause
