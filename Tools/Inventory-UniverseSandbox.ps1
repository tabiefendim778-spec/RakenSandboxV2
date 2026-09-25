param(
    [Parameter(Mandatory=$true)]
    [string]$SourceRoot
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SourceRoot)) {
    throw "Kaynak klasor bulunamadi: $SourceRoot"
}

$SourceRoot = (Resolve-Path -LiteralPath $SourceRoot).Path
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$OutputDir = Join-Path $ProjectRoot "PortingInventory"

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$InterestingExtensions = @(
    ".cs", ".dll", ".shader", ".compute", ".hlsl", ".cginc",
    ".mat", ".asset", ".json", ".xml", ".yaml", ".yml", ".txt",
    ".png", ".jpg", ".jpeg", ".tga", ".exr", ".hdr", ".dds",
    ".fbx", ".obj", ".wav", ".ogg", ".mp3", ".bytes", ".dat",
    ".bundle", ".manifest"
)

$Files = Get-ChildItem -LiteralPath $SourceRoot -File -Recurse -ErrorAction SilentlyContinue |
    Where-Object {
        $InterestingExtensions -contains $_.Extension.ToLowerInvariant() -or
        $_.Name -in @("UnityPlayer.dll", "globalgamemanagers", "resources.assets", "sharedassets0.assets")
    } |
    ForEach-Object {
        [PSCustomObject]@{
            RelativePath = $_.FullName.Substring($SourceRoot.Length).TrimStart("\")
            Extension = $_.Extension.ToLowerInvariant()
            SizeBytes = $_.Length
            LastWriteTimeUtc = $_.LastWriteTimeUtc
            SHA256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
        }
    }

$Csv = Join-Path $OutputDir "UniverseSandbox_inventory.csv"
$Json = Join-Path $OutputDir "UniverseSandbox_inventory.json"

$Files | Sort-Object RelativePath | Export-Csv -LiteralPath $Csv -NoTypeInformation -Encoding UTF8
$Files | Sort-Object RelativePath | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $Json -Encoding UTF8

$Managed = $Files | Where-Object { $_.RelativePath -match "\\Managed\\" }
$Shaders = $Files | Where-Object { $_.Extension -in @(".shader", ".compute", ".hlsl", ".cginc") }
$Textures = $Files | Where-Object { $_.Extension -in @(".png", ".jpg", ".jpeg", ".tga", ".exr", ".hdr", ".dds") }
$Audio = $Files | Where-Object { $_.Extension -in @(".wav", ".ogg", ".mp3") }

Write-Host "RAKEN V2 porting inventory tamamlandi." -ForegroundColor Green
Write-Host "Toplam dosya: $($Files.Count)"
Write-Host "Managed/kod: $($Managed.Count)"
Write-Host "Shader: $($Shaders.Count)"
Write-Host "Texture: $($Textures.Count)"
Write-Host "Audio: $($Audio.Count)"
Write-Host "CSV: $Csv"
Write-Host "JSON: $Json"
