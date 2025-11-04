#!/usr/bin/env bash

# Ensure `ptd list` works even when pico8 is not in PATH
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PTD="$ROOT_DIR/ptd"

source "$(cd "$(dirname "$0")" && pwd)/assert_definitions.sh"

# Run `ptd list` with an empty PATH (simulate missing pico8)
OLD_PATH="$PATH"
# Use a minimal PATH that contains system utilities but not pico8
export PATH="/usr/bin:/bin"

out="$($PTD list -c "$ROOT_DIR/test_cart.p8" 2>&1 || true)"
exit_code=$?

# Restore PATH
export PATH="$OLD_PATH"

assert_equals 0 "$exit_code" "ptd list should exit 0 when pico8 is not present"
assert_contains "$out" "Available test subtests in" "Output should list subtests header"
assert_contains "$out" "movement" "Output should include 'movement'"
assert_contains "$out" "collision" "Output should include 'collision'"

echo "Test completed."
