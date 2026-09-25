$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ProjectDir = Join-Path $RepoRoot "Lite"
$BuildDir = Join-Path $RepoRoot "BuildLite"
$GetGodot = Join-Path $PSScriptRoot "Get-Godot.ps1"

try {
    $GodotExe = & $GetGodot -InstallTemplates

    New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null

    Write-Host ""
    Write-Host "[1/2] Proje headless kontrol ediliyor..." -ForegroundColor Yellow
    & $GodotExe --headless --path $ProjectDir --editor --quit --rendering-method gl_compatibility

    if ($LASTEXITCODE -ne 0) {
        throw "Godot proje kontrolu basarisiz. ExitCode=$LASTEXITCODE"
    }

    Write-Host "[2/2] Windows EXE olusturuluyor..." -ForegroundColor Yellow
    & $GodotExe --headless --path $ProjectDir --export-release "Windows Desktop" --rendering-method gl_compatibility

    if ($LASTEXITCODE -ne 0) {
        throw "Windows export basarisiz. ExitCode=$LASTEXITCODE"
    }

    $Output = Join-Path $BuildDir "RAKEN_SANDBOX.exe"

    if (-not (Test-Path -LiteralPath $Output)) {
        throw "Export tamamlandi ama RAKEN_SANDBOX.exe bulunamadi."
    }

    Write-Host ""
    Write-Host "BUILD TAMAMLANDI:" -ForegroundColor Green
    Write-Host $Output -ForegroundColor Green
    Write-Host ""
    Read-Host "Kapatmak icin Enter"
}
catch {
    Write-Host ""
    Write-Host "RAKEN LITE BUILD HATASI" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Read-Host "Kapatmak icin Enter"
    exit 1
}
