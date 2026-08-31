# Render a document. The PDF is written next to its source. Windows PowerShell.
#
#   .\render.ps1 260819offPRL002a                                 compile once
#   .\render.ps1 -Watch 260819offPRL002a                          live preview
#   .\render.ps1 documents\2608_prl\260819offPRL002a.typ          an explicit path also works
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

# A bare document number is searched for under documents/, at any depth: project folders
# organise the tree and the number says nothing about where its file sits. The number is
# unique across the repository, so exactly one file may match.
if ($Document -match '[\\/]') {
  $source = $Document
  if (-not (Test-Path $source)) {
    Write-Error "no such document: $source"
    exit 1
  }
} else {
  $matched = @(Get-ChildItem -Path "documents" -Recurse -File -Filter "$Document.typ")
  if ($matched.Count -eq 0) {
    Write-Error "no such document under documents/: $Document"
    exit 1
  }
  if ($matched.Count -gt 1) {
    Write-Error @"
document number $Document is not unique, $($matched.Count) files carry it:
$($matched.FullName -join "`n")
"@
    exit 1
  }
  $source = $matched[0].FullName
}

$name = [System.IO.Path]::GetFileNameWithoutExtension($source)
$target = Join-Path (Split-Path -Parent (Resolve-Path $source)) "$name.pdf"

$command = if ($Watch) { 'watch' } else { 'compile' }
& typst $command --font-path assets/fonts --root . --input "document=$name" $source $target
exit $LASTEXITCODE
