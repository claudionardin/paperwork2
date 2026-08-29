# Render a document to out/. Windows PowerShell.
#
#   .\render.ps1 260819offPRL002a                          compile once
#   .\render.ps1 -Watch 260819offPRL002a                   live preview
#   .\render.ps1 documents\2026\260819offPRL002a.typ        an explicit path also works
#
# The POSIX equivalent is render.sh. Keep the two in step.

param(
  [Parameter(Mandatory = $true, Position = 0)][string]$Document,
  [switch]$Watch
)

$ErrorActionPreference = 'Stop'
$MinVersion = [version]'0.15'

if (-not (Get-Command typst -ErrorAction SilentlyContinue)) {
  Write-Error @'
typst not found. It is the only dependency of this project.
  Windows   winget install Typst.Typst
  macOS     brew install typst
  Linux     https://github.com/typst/typst#installation
If you just installed it, open a new terminal so PATH is picked up.
'@
  exit 1
}

# Typst changes syntax between releases, so an old binary fails in ways that look like
# broken documents. Refuse early instead.
$version = [version](((typst --version) -split ' ')[1] -replace '[^0-9.].*$', '')
if ($version -lt $MinVersion) {
  Write-Error "typst $version is too old, this project needs $MinVersion or later."
  exit 1
}

# A bare document number resolves to documents\<year>\<number>.typ; the year is its first
# two digits, as defined in NUMBERING.md.
$source = if ($Document -match '[\\/]') {
  $Document
} else {
  Join-Path "documents" (Join-Path "20$($Document.Substring(0, 2))" "$Document.typ")
}

if (-not (Test-Path $source)) {
  Write-Error "no such document: $source"
  exit 1
}

$name = [System.IO.Path]::GetFileNameWithoutExtension($source)
if (-not (Test-Path "out")) { New-Item -ItemType Directory "out" | Out-Null }

$command = if ($Watch) { 'watch' } else { 'compile' }
& typst $command --font-path assets/fonts --root . --input "document=$name" $source "out/$name.pdf"
exit $LASTEXITCODE