#!/usr/bin/env bash

# Test that `ptd generate` uses templates and renders placeholders
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PTD="$ROOT_DIR/ptd"

TMPDIR="$ROOT_DIR/tmp_generate_test"
rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"

echo "Running ptd generate using templates into $TMPDIR"

"$PTD" generate -d "$TMPDIR" -n sample_test >/dev/null 2>&1

P8_FILE="$TMPDIR/sample_test.p8"
LUA_FILE="$TMPDIR/sample_test.lua"

if [ ! -f "$P8_FILE" ]; then
  echo "FAIL: $P8_FILE not created"
  exit 2
fi

if [ ! -f "$LUA_FILE" ]; then
  echo "FAIL: $LUA_FILE not created"
  exit 2
fi

grep -F "#include sample_test.lua" "$P8_FILE" >/dev/null || { echo "FAIL: $P8_FILE should include sample_test.lua"; exit 2; }

# Ensure placeholders were rendered (no '{{' braces left)
if grep -q "{{" "$P8_FILE" || grep -q "{{" "$LUA_FILE"; then
  echo "FAIL: Template placeholders left unrendered"
  exit 2
fi

echo "PASS: generate wrote templated files and rendered placeholders"

# Clean up
rm -rf "$TMPDIR"

exit 0
