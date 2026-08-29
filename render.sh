#!/bin/sh
# Render a document to out/. macOS, Linux, and Git Bash / WSL on Windows.
#
#   ./render.sh 260819offPRL002a                          compile once
#   ./render.sh --watch 260819offPRL002a                  live preview
#   ./render.sh documents/2026/260819offPRL002a.typ       an explicit path also works
#
# The Windows equivalent is render.ps1. Keep the two in step.

set -eu

MIN_VERSION=0.15

if ! command -v typst >/dev/null 2>&1; then
  echo "typst not found. It is the only dependency of this project." >&2
  echo "  Windows   winget install Typst.Typst" >&2
  echo "  macOS     brew install typst" >&2
  echo "  Linux     https://github.com/typst/typst#installation" >&2
  exit 1
fi

# Typst changes syntax between releases, so an old binary fails in ways that look like
# broken documents. Refuse early instead.
version=$(typst --version | awk '{print $2}')
if [ "$(printf '%s\n%s\n' "$MIN_VERSION" "$version" | sort -V | head -n 1)" != "$MIN_VERSION" ]; then
  echo "typst $version is too old, this project needs $MIN_VERSION or later." >&2
  exit 1
fi

command=compile
if [ "${1:-}" = "--watch" ]; then
  command=watch
  shift
fi

document=${1:-}
if [ -z "$document" ]; then
  echo "usage: ./render.sh [--watch] <document-number|path>" >&2
  exit 1
fi

# A bare document number resolves to documents/<year>/<number>.typ; the year is its first
# two digits, as defined in NUMBERING.md.
case "$document" in
  */*) source=$document ;;
  *)   source="documents/20$(printf '%s' "$document" | cut -c1-2)/$document.typ" ;;
esac

if [ ! -f "$source" ]; then
  echo "no such document: $source" >&2
  exit 1
fi

name=$(basename "$source" .typ)
mkdir -p out

exec typst "$command" --font-path assets/fonts --root . --input "document=$name" "$source" "out/$name.pdf"