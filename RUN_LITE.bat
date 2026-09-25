@echo off
setlocal
cd /d "%~dp0"
chcp 65001 >nul
title RAKEN SANDBOX LITE

echo ============================================================
echo                 RAKEN SANDBOX
echo              PORTABLE LITE EDITION
echo ============================================================
echo.
echo Unreal gerekmez.
echo Godot 4.7.2 portable motor ilk calistirmada otomatik indirilir.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ToolsLite\Run-Lite.ps1"

if errorlevel 1 (
    echo.
    echo RAKEN baslatilamadi.
    pause
    exit /b 1
)
