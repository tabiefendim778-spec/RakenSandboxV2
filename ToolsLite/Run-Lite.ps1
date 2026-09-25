$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ProjectDir = Join-Path $RepoRoot "Lite"
$GetGodot = Join-Path $PSScriptRoot "Get-Godot.ps1"

try {
    $GodotExe = & $GetGodot

    Write-Host ""
    Write-Host "RAKEN SANDBOX LITE baslatiliyor..." -ForegroundColor Green
    Write-Host "Engine: $GodotExe" -ForegroundColor DarkGray
    Write-Host ""

    & $GodotExe --path $ProjectDir --rendering-method gl_compatibility

    if ($LASTEXITCODE -ne 0) {
        throw "RAKEN runtime hata kodu: $LASTEXITCODE"
    }
}
catch {
    Write-Host ""
    Write-Host "RAKEN LITE BASLATMA HATASI" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Read-Host "Kapatmak icin Enter"
    exit 1
}
