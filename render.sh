#!/bin/sh
# Render a document. The PDF is written next to its source.
# macOS, Linux, and Git Bash / WSL on Windows.
#
#   ./render.sh 260819offPRL002a                            compile once
#   ./render.sh --watch 260819offPRL002a                    live preview
#   ./render.sh documents/2608_prl/260819offPRL002a.typ     an explicit path also works
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

# A bare document number is searched for under documents/, at any depth: project folders
# organise the tree and the number says nothing about where its file sits. The number is
# unique across the repository, so exactly one file may match.
case "$document" in
  */*)
    source=$document
    if [ ! -f "$source" ]; then
      echo "no such document: $source" >&2
      exit 1
    fi
    ;;
  *)
    matched=$(find documents -type f -name "$document.typ")
    count=$(printf '%s' "$matched" | grep -c '^' || true)
    if [ "$count" -eq 0 ]; then
      echo "no such document under documents/: $document" >&2
      exit 1
    fi
    if [ "$count" -gt 1 ]; then
      echo "document number $document is not unique, $count files carry it:" >&2
      echo "$matched" >&2
      exit 1
    fi
    source=$matched
    ;;
esac

name=$(basename "$source" .typ)
target="$(dirname "$source")/$name.pdf"

exec typst "$command" --font-path assets/fonts --root . --input "document=$name" "$source" "$target"
