#!/usr/bin/env bash

#!/usr/bin/env bash

# Test that `ptd generate` uses templates and renders placeholders
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PTD="$ROOT_DIR/ptd"

TMPDIR="$ROOT_DIR/tmp_generate_test"
rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"

echo "Running ptd generate using templates into $TMPDIR"

# If the test runner provided assertion helpers, use them. Otherwise define
# lightweight ones that print the same PASS/FAIL markers used by other tests.
source "$(cd "$(dirname "$0")" && pwd)/assert_definitions.sh"

# If the test runner provided assert functions but not assert_file_exists, create a thin wrapper
if declare -F assert_contains >/dev/null 2>&1 && ! declare -F assert_file_exists >/dev/null 2>&1; then
  assert_file_exists() {
    local f="$1"
    local message="${2:-file $f exists}"
    if [ -f "$f" ]; then
      assert_true 0 "$message"
    else
      assert_true 1 "$message"
    fi
    return 0
  }
fi

"$PTD" generate -d "$TMPDIR" -n sample_test >/dev/null 2>&1

P8_FILE="$TMPDIR/sample_test.p8"
LUA_FILE="$TMPDIR/sample_test.lua"

assert_file_exists "$P8_FILE" "generate wrote .p8 file"
assert_file_exists "$LUA_FILE" "generate wrote .lua file"

p8_content=""
if [ -f "$P8_FILE" ]; then
  p8_content=$(cat "$P8_FILE")
fi

assert_contains "$p8_content" "#include sample_test.lua" "$P8_FILE should include sample_test.lua"

# Ensure placeholders were rendered (no '{{' braces left)
combined_content="$p8_content"
if [ -f "$LUA_FILE" ]; then
  combined_content="$combined_content\n$(cat "$LUA_FILE")"
fi
if printf '%s' "$combined_content" | grep -q "{{"; then
  echo "✗ FAIL: Template placeholders left unrendered"
else
  echo "✓ PASS: generate rendered placeholders"
fi

# Clean up
rm -rf "$TMPDIR"

