#!/usr/bin/env bash

# Ensure `ptd list` works even when pico8 is not in PATH
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PTD="$ROOT_DIR/ptd"

# Lightweight assertions (so this file can be run standalone)
if ! declare -F assert_contains >/dev/null 2>&1; then
    assert_contains() {
        local hay="$1"; local needle="$2"; local msg="$3"
        if printf '%s' "$hay" | grep -F -- "$needle" >/dev/null 2>&1; then
            echo "PASS: ${msg:-contains $needle}"
        else
            echo "FAIL: ${msg:-contains $needle}"
            echo "  Needle: $needle"
            return 1
        fi
        return 0
    }

    assert_equals() {
        local exp="$1"; local act="$2"; local msg="$3"
        if [ "$exp" = "$act" ]; then
            echo "PASS: ${msg:-equals}"
            return 0
        else
            echo "FAIL: ${msg:-equals}"
            echo "  Expected: $exp"
            echo "  Actual:   $act"
            return 1
        fi
    }
fi

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
