param(
    [string]$UnrealRoot = $env:UE_ROOT
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ProjectFile = Join-Path $ProjectRoot "RakenSandboxV2.uproject"
$PythonFile = Join-Path $PSScriptRoot "BootstrapProject.py"

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
    throw "Unreal Engine bulunamadi. Epic Games Launcher uzerinden UE5 kur veya UE_ROOT belirt."
}

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
