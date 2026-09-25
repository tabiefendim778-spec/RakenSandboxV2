param(
    [switch]$InstallTemplates
)

$ErrorActionPreference = "Stop"

$Version = "4.7.2"
$Tag = "$Version-stable"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$ToolsRoot = Join-Path $RepoRoot ".raken_tools"
$GodotRoot = Join-Path $ToolsRoot "godot-$Version"
$GodotZip = Join-Path $ToolsRoot "godot-$Version.zip"

New-Item -ItemType Directory -Force -Path $ToolsRoot | Out-Null
New-Item -ItemType Directory -Force -Path $GodotRoot | Out-Null

$GodotExe = Get-ChildItem -LiteralPath $GodotRoot -Filter "Godot_v*-stable_win64.exe" -File -ErrorAction SilentlyContinue |
    Select-Object -First 1 -ExpandProperty FullName

if (-not $GodotExe) {
    $EngineUrl = "https://github.com/godotengine/godot/releases/download/$Tag/Godot_v$Tag" + "_win64.exe.zip"

    Write-Host "Godot $Version portable motor indiriliyor..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $EngineUrl -OutFile $GodotZip -UseBasicParsing

    Write-Host "Motor aciliyor..." -ForegroundColor Cyan
    Expand-Archive -LiteralPath $GodotZip -DestinationPath $GodotRoot -Force
    Remove-Item -LiteralPath $GodotZip -Force -ErrorAction SilentlyContinue

    $GodotExe = Get-ChildItem -LiteralPath $GodotRoot -Filter "Godot_v*-stable_win64.exe" -File |
        Select-Object -First 1 -ExpandProperty FullName
}

if (-not $GodotExe) {
    throw "Godot executable bulunamadi."
}

if ($InstallTemplates) {
    $TemplateDir = Join-Path $env:APPDATA "Godot\export_templates\$Version.stable"
    $WindowsTemplate = Join-Path $TemplateDir "windows_release_x86_64.exe"

    if (-not (Test-Path -LiteralPath $WindowsTemplate)) {
        $TemplateUrl = "https://github.com/godotengine/godot/releases/download/$Tag/Godot_v$Tag" + "_export_templates.tpz"
        $TemplateArchive = Join-Path $ToolsRoot "templates-$Version.zip"
        $TemplateTemp = Join-Path $ToolsRoot "templates-$Version-temp"

        Write-Host "Windows export icin Godot template paketi indiriliyor..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $TemplateUrl -OutFile $TemplateArchive -UseBasicParsing

        Remove-Item -LiteralPath $TemplateTemp -Recurse -Force -ErrorAction SilentlyContinue
        New-Item -ItemType Directory -Force -Path $TemplateTemp | Out-Null
        Expand-Archive -LiteralPath $TemplateArchive -DestinationPath $TemplateTemp -Force

        New-Item -ItemType Directory -Force -Path $TemplateDir | Out-Null

        $SourceTemplates = Join-Path $TemplateTemp "templates"
        if (-not (Test-Path -LiteralPath $SourceTemplates)) {
            throw "Export template arsiv yapisi beklenenden farkli."
        }

        Copy-Item -Path (Join-Path $SourceTemplates "*") -Destination $TemplateDir -Recurse -Force

        Remove-Item -LiteralPath $TemplateArchive -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $TemplateTemp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Output $GodotExe
