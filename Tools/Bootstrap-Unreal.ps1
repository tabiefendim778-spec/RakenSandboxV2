param(
    [string]$UnrealRoot = $env:UE_ROOT
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ProjectFile = Join-Path $ProjectRoot "RakenSandboxV2.uproject"
$PythonFile = Join-Path $PSScriptRoot "CreateStarterContent.py"

function Find-UnrealRoot {
    param([string]$Explicit)

    if ($Explicit -and (Test-Path $Explicit)) {
        return (Resolve-Path $Explicit).Path
    }

    $Candidates = @(
        "C:\Program Files\Epic Games\UE_5.8",
        "D:\Epic Games\UE_5.8"
    )

    foreach ($Candidate in $Candidates) {
        if (Test-Path $Candidate) {
            return $Candidate
        }
    }

    throw "Unreal Engine 5.8 bulunamadi. UE_ROOT ortam degiskenini Unreal klasorune ayarla."
}

$EngineRoot = Find-UnrealRoot $UnrealRoot
$EditorCmd = Join-Path $EngineRoot "Engine\Binaries\Win64\UnrealEditor-Cmd.exe"

if (-not (Test-Path $EditorCmd)) {
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
