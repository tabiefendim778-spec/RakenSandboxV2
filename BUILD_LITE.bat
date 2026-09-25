@echo off
setlocal
cd /d "%~dp0"
chcp 65001 >nul
title RAKEN SANDBOX LITE - BUILD

echo ============================================================
echo                 RAKEN SANDBOX
echo                 WINDOWS BUILD
echo ============================================================
echo.
echo Ilk build sirasinda Godot export template paketi indirilir.
echo Unreal Engine gerekmez.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ToolsLite\Build-Lite.ps1"

if errorlevel 1 (
    echo.
    echo BUILD BASARISIZ.
    pause
    exit /b 1
)
