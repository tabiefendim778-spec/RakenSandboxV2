@echo off
setlocal
cd /d "%~dp0"
title RAKEN SANDBOX V2 - UNREAL CHECK
echo ============================================================
echo               RAKEN SANDBOX V2
echo                UNREAL DETECTOR
echo ============================================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
"$p = Join-Path '%~dp0Tools' 'Prepare-Project.ps1'; " ^
"$text = Get-Content -LiteralPath $p -Raw; " ^
"$marker = '$EngineRoot = Find-RakenUnrealRoot $UnrealRoot'; " ^
"$prefix = $text.Substring(0, $text.IndexOf($marker)); " ^
"Invoke-Expression $prefix; " ^
"$root = Find-RakenUnrealRoot $env:UE_ROOT; " ^
"if ($root) { Write-Host ('BULUNDU: ' + $root) -ForegroundColor Green } else { Write-Host 'UNREAL ENGINE BULUNAMADI' -ForegroundColor Red; Write-Host 'Epic Games Launcher > Unreal Engine > Library bolumunde motorun kurulu olup olmadigini kontrol et.' }"
echo.
pause
