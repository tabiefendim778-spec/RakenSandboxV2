param(
    [string]$UnrealRoot = $env:UE_ROOT
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ProjectFile = Join-Path $ProjectRoot "RakenSandboxV2.uproject"

function Find-RakenUnrealRoot {
    param([string]$Explicit)

    $Candidates = New-Object System.Collections.Generic.List[string]

    function Add-Candidate([string]$Path) {
        if ([string]::IsNullOrWhiteSpace($Path)) { return }
        try {
            $Full = [System.IO.Path]::GetFullPath($Path.Trim('"'))
            if (-not $Candidates.Contains($Full)) {
                $Candidates.Add($Full)
            }
        } catch {}
    }

    if ($Explicit) {
        Add-Candidate $Explicit
    }

    # Epic Games Launcher manifests know the real install location,
    # including custom drives such as E:, F:, external SSDs, etc.
    $ManifestDir = Join-Path $env:ProgramData "Epic\EpicGamesLauncher\Data\Manifests"
    if (Test-Path -LiteralPath $ManifestDir) {
        Get-ChildItem -LiteralPath $ManifestDir -Filter "*.item" -File -ErrorAction SilentlyContinue |
            ForEach-Object {
                try {
                    $Manifest = Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json
                    $LooksLikeUE = ($Manifest.AppName -like "UE_*") -or
                                   ($Manifest.DisplayName -like "Unreal Engine*")
                    if ($LooksLikeUE -and $Manifest.InstallLocation) {
                        Add-Candidate $Manifest.InstallLocation
                    }
                } catch {}
            }
    }

    # Standard and common custom locations on all mounted filesystem drives.
    foreach ($Drive in [System.IO.DriveInfo]::GetDrives()) {
        if (-not $Drive.IsReady) { continue }
        if ($Drive.DriveType -notin @(
            [System.IO.DriveType]::Fixed,
            [System.IO.DriveType]::Removable
        )) { continue }

        $Root = $Drive.RootDirectory.FullName

        foreach ($BaseRelative in @(
            "Program Files\Epic Games",
            "Epic Games",
            "Games\Epic Games",
            "Unreal",
            "Unreal Engine"
        )) {
            $Base = Join-Path $Root $BaseRelative
            if (Test-Path -LiteralPath $Base) {
                Get-ChildItem -LiteralPath $Base -Directory -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -like "UE_*" } |
                    ForEach-Object { Add-Candidate $_.FullName }
            }
        }
    }

    # Registry build registrations (source/custom builds can appear here).
    foreach ($RegistryPath in @(
        "HKCU:\SOFTWARE\Epic Games\Unreal Engine\Builds",
        "HKLM:\SOFTWARE\EpicGames\Unreal Engine",
        "HKLM:\SOFTWARE\WOW6432Node\EpicGames\Unreal Engine"
    )) {
        if (Test-Path $RegistryPath) {
            try {
                $Props = Get-ItemProperty $RegistryPath -ErrorAction Stop
                foreach ($Property in $Props.PSObject.Properties) {
                    if ($Property.Value -is [string]) {
                        Add-Candidate $Property.Value
                    }
                }
            } catch {}
        }
    }

    $Valid = @(
        $Candidates |
            Where-Object {
                (Test-Path (Join-Path $_ "Engine\Build\BatchFiles\Build.bat")) -and
                (Test-Path (Join-Path $_ "Engine\Binaries\Win64\UnrealEditor-Cmd.exe"))
            } |
            Sort-Object -Unique -Descending
    )

    if ($Valid.Count -gt 0) {
        return $Valid[0]
    }

    return $null
}

$EngineRoot = Find-RakenUnrealRoot $UnrealRoot
if (-not $EngineRoot) {
    throw @"
Unreal Engine bu bilgisayarda bulunamadi.

Epic Games Launcher'da Unreal Engine 5.x kuruluysa Launcher'i bir kez acip kapat ve SETUP_V2.bat'i tekrar calistir.
Kurulu degilse once Epic Games Launcher > Unreal Engine > Library > Install Engine ile UE5 kurman gerekiyor.

RAKEN setup; C:, D:, E:, F: ve diger takili diskleri, Epic manifestlerini ve registry kayitlarini otomatik taradi.
"@
}

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
