param(
    [string]$UnrealRoot = $env:UE_ROOT
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ProjectFile = Join-Path $ProjectRoot "RakenSandboxV2.uproject"
$ArchiveDir = Join-Path $ProjectRoot "Build\Windows"

function Find-UnrealRoot {
    param([string]$Explicit)

    if ($Explicit -and (Test-Path $Explicit)) {
        return (Resolve-Path $Explicit).Path
    }

    foreach ($Candidate in @(
        "C:\Program Files\Epic Games\UE_5.8",
        "D:\Epic Games\UE_5.8"
    )) {
        if (Test-Path $Candidate) {
            return $Candidate
        }
    }

    throw "Unreal Engine 5.8 bulunamadi. UE_ROOT ortam degiskenini ayarla."
}

$EngineRoot = Find-UnrealRoot $UnrealRoot
$BuildBat = Join-Path $EngineRoot "Engine\Build\BatchFiles\Build.bat"
$RunUAT = Join-Path $EngineRoot "Engine\Build\BatchFiles\RunUAT.bat"
$EditorCmd = Join-Path $EngineRoot "Engine\Binaries\Win64\UnrealEditor-Cmd.exe"

if (-not (Test-Path $BuildBat)) { throw "Build.bat bulunamadi." }
if (-not (Test-Path $RunUAT)) { throw "RunUAT.bat bulunamadi." }
if (-not (Test-Path $EditorCmd)) { throw "UnrealEditor-Cmd.exe bulunamadi." }

Write-Host "[1/4] C++ editor build..." -ForegroundColor Yellow
& $BuildBat RakenSandboxV2Editor Win64 Development "-Project=$ProjectFile" -WaitMutex -FromMsBuild
if ($LASTEXITCODE -ne 0) { throw "Editor C++ build basarisiz." }

Write-Host "[2/4] Physics automation tests..." -ForegroundColor Yellow
& $EditorCmd $ProjectFile -unattended -nop4 -nosplash '-ExecCmds=Automation RunTests RAKEN.Physics; Quit' '-TestExit=Automation Test Queue Empty'
if ($LASTEXITCODE -ne 0) { throw "Automation testleri basarisiz." }

Write-Host "[3/4] Windows Shipping package..." -ForegroundColor Yellow
if (Test-Path $ArchiveDir) { Remove-Item $ArchiveDir -Recurse -Force }

$UATArgs = @(
    "BuildCookRun",
    "-project=$ProjectFile",
    "-noP4",
    "-platform=Win64",
    "-clientconfig=Shipping",
    "-build",
    "-cook",
    "-stage",
    "-pak",
    "-archive",
    "-archivedirectory=$ArchiveDir"
)

& $RunUAT @UATArgs
if ($LASTEXITCODE -ne 0) { throw "Windows Shipping package basarisiz." }

Write-Host "[4/4] Paket hazir." -ForegroundColor Green
Write-Host $ArchiveDir -ForegroundColor Green
