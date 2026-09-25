$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ProjectDir = Join-Path $RepoRoot "Lite"
$GetGodot = Join-Path $PSScriptRoot "Get-Godot.ps1"

try {
    $GodotExe = & $GetGodot

    Write-Host ""
    Write-Host "RAKEN SANDBOX baslatiliyor..." -ForegroundColor Green
    Write-Host "Engine: $GodotExe" -ForegroundColor DarkGray
    Write-Host ""

    $Arguments = @("--path", ('"' + $ProjectDir + '"'), "--rendering-method", "gl_compatibility")
    $Process = Start-Process -FilePath $GodotExe -ArgumentList $Arguments -NoNewWindow -Wait -PassThru

    if ($Process.ExitCode -ne 0) {
        throw "RAKEN runtime hata kodu: $($Process.ExitCode)"
    }
}
catch {
    Write-Host ""
    Write-Host "RAKEN BASLATMA HATASI" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Read-Host "Kapatmak icin Enter"
    exit 1
}
