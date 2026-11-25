#!/usr/bin/env bash
# Run every gate, in the order CI runs them. Stops at the first failure.
#
#   scripts/check.sh
set -euo pipefail
cd "$(dirname "$0")/.."

step() { printf '\n==> %s\n' "$*"; }

step "dart format (check)"
dart format --output=none --set-exit-if-changed lib test

step "flutter analyze"
flutter analyze

step "flutter test"
flutter test

step "version"
scripts/version.sh check

printf '\nAll gates passed.\n'
