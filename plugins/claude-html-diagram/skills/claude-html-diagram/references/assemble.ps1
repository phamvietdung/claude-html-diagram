# Assemble the final self-contained diagram: inline cf-style.css, diagram.js and
# logo.svg (all live next to this script) into an authored file.
#   usage: powershell -NoProfile -ExecutionPolicy Bypass -File assemble.ps1 -In <authored.html> -Out <out.html>
# Prints four verify counts; they must read 1 / >=1 / >=1 / 0.
param(
  [Parameter(Mandatory=$true)][string]$In,
  [Parameter(Mandatory=$true)][string]$Out
)
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -Path $In)) { Write-Host "ERROR: input not found: $In"; exit 2 }

$linkTag   = '<link rel="stylesheet" href="cf-style.css">'
$scriptTag = '<script src="diagram.js"></script>'
$logoTag   = '<img class="brand-logo" src="logo.svg" alt="Creative Force">'
$html = [System.IO.File]::ReadAllText($In)

if (-not $html.Contains($linkTag) -or -not $html.Contains($scriptTag)) {
  Write-Host "ERROR: no stylesheet/diagram.js markers in $In."
  Write-Host "This is probably an already-assembled file. Run this on the AUTHORED file."
  exit 1
}

$css  = [System.IO.File]::ReadAllText((Join-Path $PSScriptRoot 'cf-style.css'))
$js   = [System.IO.File]::ReadAllText((Join-Path $PSScriptRoot 'diagram.js'))
$logo = [System.IO.File]::ReadAllText((Join-Path $PSScriptRoot 'logo.svg'))
$html = $html.Replace($linkTag, "<style>`n$css</style>")
$html = $html.Replace($scriptTag, "<script>`n$js</script>")
$html = $html.Replace($logoTag, $logo)

$dir = Split-Path -Parent $Out
if ($dir -and -not (Test-Path -Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
[System.IO.File]::WriteAllText($Out, $html, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "verify (want 1 / >=1 / >=1 / 0):"
(Select-String -Path $Out -Pattern '</style>' | Measure-Object).Count
(Select-String -Path $Out -Pattern 'setFlow' | Measure-Object).Count
(Select-String -Path $Out -Pattern 'class="brand-logo"' | Measure-Object).Count
(Select-String -Path $Out -Pattern 'rel="stylesheet"|src="diagram.js"|src="logo.svg"' | Measure-Object).Count
exit 0
