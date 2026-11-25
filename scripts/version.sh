#!/usr/bin/env bash
# The app's version lives in pubspec.yaml as X.Y.Z+N: X.Y.Z is shown in the
# app (release builds pass it in with --dart-define), and N is Android's
# versionCode, which must grow with every release.
#
#   scripts/version.sh show          print the version, e.g. 0.1.0+1
#   scripts/version.sh check         fail if it is not X.Y.Z+N
#   scripts/version.sh bump X.Y.Z    set it to X.Y.Z, build number + 1, and
#                                    date the CHANGELOG's Unreleased
#                                    section as [X.Y.Z]
set -euo pipefail
cd "$(dirname "$0")/.."

full() { sed -n 's/^version: \(.*\)$/\1/p' pubspec.yaml; }

check() {
  local v
  v=$(full)
  if ! [[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$ ]]; then
    echo "pubspec.yaml version is '$v', want X.Y.Z+N" >&2
    exit 1
  fi
  echo "version: $v"
}

bump() {
  local next=$1
  if ! [[ "$next" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "not a version: $next (want X.Y.Z)" >&2
    exit 1
  fi
  if ! grep -q '^## \[Unreleased\]$' CHANGELOG.md; then
    echo "CHANGELOG.md has no '## [Unreleased]' section to release" >&2
    exit 1
  fi
  local build=$(( $(full | cut -d+ -f2) + 1 ))
  sed -i "s/^version: .*$/version: $next+$build/" pubspec.yaml
  sed -i "s/^## \[Unreleased\]$/## [Unreleased]\n\n## [$next] - $(date +%F)/" CHANGELOG.md
  check
  echo "now $next+$build; review CHANGELOG.md, then commit"
}

case "${1:-}" in
  show) full ;;
  check) check ;;
  bump) bump "${2:?usage: scripts/version.sh bump X.Y.Z}" ;;
  *)
    sed -n '2,10p' "$0" >&2
    exit 1
    ;;
esac
