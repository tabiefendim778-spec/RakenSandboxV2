param(
    [string]$UnrealRoot = $env:UE_ROOT
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ProjectFile = Join-Path $ProjectRoot "RakenSandboxV2.uproject"

function Find-UnrealRoot {
    param([string]$Explicit)

    if ($Explicit -and (Test-Path -LiteralPath $Explicit)) {
        return (Resolve-Path -LiteralPath $Explicit).Path
    }

    $Candidates = @()

    foreach ($Base in @("C:\Program Files\Epic Games", "D:\Epic Games")) {
        if (Test-Path -LiteralPath $Base) {
            $Candidates += Get-ChildItem -LiteralPath $Base -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -like "UE_*" } |
                Select-Object -ExpandProperty FullName
        }
    }

    $Valid = $Candidates |
        Where-Object {
            Test-Path (Join-Path $_ "Engine\Build\BatchFiles\Build.bat")
        } |
        Sort-Object -Descending

    if ($Valid.Count -gt 0) {
        return $Valid[0]
    }

    throw "Unreal Engine bulunamadi. UE5 kur veya UE_ROOT ortam degiskenini ayarla."
}

$EngineRoot = Find-UnrealRoot $UnrealRoot
$BuildBat = Join-Path $EngineRoot "Engine\Build\BatchFiles\Build.bat"
$Bootstrap = Join-Path $PSScriptRoot "Bootstrap-Unreal.ps1"

Write-Host "[1/2] RAKEN C++ editor modulu derleniyor..." -ForegroundColor Yellow

& $BuildBat RakenSandboxV2Editor Win64 Development "-Project=$ProjectFile" -WaitMutex

if ($LASTEXITCODE -ne 0) {
    throw "RAKEN editor C++ build basarisiz. ExitCode=$LASTEXITCODE"
}

Write-Host "[2/2] Starter Unreal assets/map olusturuluyor..." -ForegroundColor Yellow

& $Bootstrap -UnrealRoot $EngineRoot

if ($LASTEXITCODE -ne 0) {
    throw "RAKEN bootstrap basarisiz. ExitCode=$LASTEXITCODE"
}

Write-Host "RAKEN SANDBOX V2 proje hazirligi tamamlandi." -ForegroundColor Green
