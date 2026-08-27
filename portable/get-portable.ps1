# DrawPen Portable - downloader for Windows
#
# Downloads the latest portable ZIP (DrawPen.exe + DLLs + resources) from the
# stable "portable" GitHub Release and extracts it next to this script.
#
# Usage:
#   .\get-portable.ps1                  # download + extract into ./DrawPen-Portable
#   .\get-portable.ps1 -OutputDir C:\Tools\DrawPen
#
# Requires PowerShell 5.1+ (ships with Windows 10/11). Uses only built-in
# cmdlets - no git, no winget, no npm needed.

param(
    [string]$OutputDir = $(if ($PSScriptRoot) {
        Join-Path $PSScriptRoot 'DrawPen-Portable'
    } else {
        Join-Path (Get-Location) 'DrawPen-Portable'
    })
)

$ErrorActionPreference = 'Stop'

$Repo       = 'Tauseefexe/DrawPenFork'
$ReleaseTag = 'portable'
$ZipName    = 'DrawPen-Portable-win32-x64.zip'
$BaseUrl    = "https://github.com/$Repo/releases/download/$ReleaseTag"
$ZipUrl     = "$BaseUrl/$ZipName"
$HashUrl    = "$BaseUrl/$ZipName.sha256"

Write-Host "DrawPen Portable downloader"
Write-Host "  Source : $ZipUrl"
Write-Host "  Target : $OutputDir"
Write-Host ""

# 1. Download the ZIP (and its checksum) to a temp location
$tempRoot = Join-Path $env:TEMP ("DrawPen-Portable-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

$zipPath = Join-Path $tempRoot $ZipName
$hashPath = Join-Path $tempRoot "$ZipName.sha256"

Write-Host "Downloading $ZipName ..."
Invoke-WebRequest -Uri $ZipUrl  -OutFile $zipPath -UseBasicParsing
Invoke-WebRequest -Uri $HashUrl -OutFile $hashPath -UseBasicParsing

# 2. Verify SHA-256
$expected = (Get-Content $hashPath -Raw).Trim().Split(' ')[0].Trim().ToLower()
$actual   = (Get-FileHash $zipPath -Algorithm SHA256).Hash.ToLower()

if ($expected -ne $actual) {
    Remove-Item -Recurse -Force $tempRoot
    throw "SHA-256 mismatch!`nExpected: $expected`nActual:   $actual`nDownload may be corrupted or tampered with."
}

Write-Host "SHA-256 verified: $actual"

# 3. Extract into OutputDir (remove previous copy only if it exists)
if (Test-Path $OutputDir) {
    Write-Host "Removing previous copy at $OutputDir ..."
    Remove-Item -Recurse -Force $OutputDir
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
Write-Host "Extracting ..."
Expand-Archive -Path $zipPath -DestinationPath $OutputDir -Force

# 4. Cleanup
Remove-Item -Recurse -Force $tempRoot -ErrorAction SilentlyContinue

$exe = Get-ChildItem -Path $OutputDir -Filter 'DrawPen.exe' -Recurse |
       Select-Object -First 1

if (-not $exe) {
    throw "DrawPen.exe not found after extraction - unexpected package layout."
}

Write-Host ""
Write-Host "Done. Launch it with:"
Write-Host "  $($exe.FullName)"
