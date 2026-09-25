@echo off
setlocal
cd /d "%~dp0"
chcp 65001 >nul
title RAKEN V2 - UNIVERSE SANDBOX INVENTORY

echo ============================================================
echo        RAKEN V2 - UNIVERSE SANDBOX INVENTORY
echo ============================================================
echo.

set "SRC=%~1"

if not defined SRC (
    set /p SRC=Universe Sandbox ana klasor yolunu yapistir: 
)

if not exist "%SRC%" (
    echo.
    echo HATA: Klasor bulunamadi:
    echo %SRC%
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Tools\Inventory-UniverseSandbox.ps1" -SourceRoot "%SRC%"

if errorlevel 1 (
    echo.
    echo INVENTORY HATASI
    pause
    exit /b 1
)

echo.
echo PortingInventory klasoru hazir.
pause
