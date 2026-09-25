param(
    [string]$UnrealRoot = $env:UE_ROOT
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ProjectFile = Join-Path $ProjectRoot "RakenSandboxV2.uproject"
$PythonFile = Join-Path $PSScriptRoot "CreateStarterContent.py"

function Find-UnrealRoot {
    param([string]$Explicit)

    if ($Explicit -and (Test-Path -LiteralPath $Explicit)) {
        return (Resolve-Path -LiteralPath $Explicit).Path
    }

    $Candidates = @()

    if (Test-Path "C:\Program Files\Epic Games") {
        $Candidates += Get-ChildItem "C:\Program Files\Epic Games" -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like "UE_*" } |
            Select-Object -ExpandProperty FullName
    }

    if (Test-Path "D:\Epic Games") {
        $Candidates += Get-ChildItem "D:\Epic Games" -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like "UE_*" } |
            Select-Object -ExpandProperty FullName
    }

    if ($Candidates.Count -gt 0) {
        $Valid = $Candidates |
            Where-Object {
                Test-Path (Join-Path $_ "Engine\Binaries\Win64\UnrealEditor-Cmd.exe")
            } |
            Sort-Object -Descending

        if ($Valid.Count -gt 0) {
            return $Valid[0]
        }
    }

    throw @"
Unreal Engine bulunamadi.

Cozum:
1) Epic Games Launcher > Unreal Engine > Library bolumunden bir UE5 surumu kur.
2) Unreal farkli bir diske kuruluysa bu BAT'i PowerShell'den su sekilde calistir:
   .\Tools\Bootstrap-Unreal.ps1 -UnrealRoot "X:\Epic Games\UE_5.x"

Alternatif olarak UE_ROOT ortam degiskenini Unreal klasorune ayarla.
"@
}

$EngineRoot = Find-UnrealRoot $UnrealRoot
$EditorCmd = Join-Path $EngineRoot "Engine\Binaries\Win64\UnrealEditor-Cmd.exe"

if (-not (Test-Path -LiteralPath $EditorCmd)) {
    throw "UnrealEditor-Cmd.exe bulunamadi: $EditorCmd"
}

Write-Host "RAKEN SANDBOX V2 bootstrap basliyor..." -ForegroundColor Cyan
Write-Host "Engine: $EngineRoot"
Write-Host "Project: $ProjectFile"

& $EditorCmd $ProjectFile "-ExecutePythonScript=$PythonFile" -unattended -nop4 -nosplash

if ($LASTEXITCODE -ne 0) {
    throw "Starter content olusturulamadi. ExitCode=$LASTEXITCODE"
}

Write-Host "Starter map hazir: /Game/Maps/L_Startup" -ForegroundColor Green
