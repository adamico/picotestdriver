#!/usr/bin/env bash

# Integration tests for ptd CLI
# This script exercises the public `ptd` command (located at repo root) rather than internal helper functions.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PTD="$ROOT_DIR/ptd"

# Load test assertions/helpers from test_helper if available
if [ -f "$SCRIPT_DIR/test_helper.sh" ]; then
	# shellcheck source=/dev/null
	source "$SCRIPT_DIR/test_helper.sh"
fi

source "$(cd "$(dirname "$0")" && pwd)/assert_definitions.sh"

echo "Preparing fake pico8 in PATH so tests don't require real PICO-8..."
TMPBIN=$(mktemp -d)
cat > "$TMPBIN/pico8" <<'EOF'
#!/usr/bin/env bash
# simple pico8 stub: accept args and exit 0 quickly
echo "pico8-stub $@" >/dev/null
exit 0
EOF
chmod +x "$TMPBIN/pico8"
export PATH="$TMPBIN:$PATH"

echo "Testing main help output..."
help_output=$($PTD 2>&1 || true)
assert_contains "$help_output" "PicoTestDriver v" "help should contain title"
assert_contains "$help_output" "USAGE:" "help should contain usage section"
assert_contains "$help_output" "COMMANDS:" "help should list commands"

echo
echo "Testing version output..."
version_output=$($PTD version 2>&1)
assert_contains "$version_output" "PicoTestDriver v" "version should contain script version"

echo
echo "Testing configuration display (ptd test prints cartridge/subtest/timeout)..."
# create temporary cartridge files
TMPDIR=$(mktemp -d)
touch "$TMPDIR/test.p8"
touch "$TMPDIR/first.p8"
touch "$TMPDIR/second.p8"

config_output=$($PTD test -c "$TMPDIR/test.p8" --verbose movement_test 45 2>&1 || true)
assert_contains "$config_output" "Cartridge: $TMPDIR/test.p8" "config should show cartridge file"
assert_contains "$config_output" "Subtest: movement_test" "config should show phase"
assert_contains "$config_output" "Timeout: 45s" "config should show timeout"
assert_contains "$config_output" "Verbose: enabled" "config should show verbose status"

echo
echo "Testing list subtests output..."
# use the repository example cartridge which contains subtests
list_output=$($PTD list -c "$ROOT_DIR/test_cart.p8" 2>&1 || true)
assert_contains "$list_output" "Available test subtests in" "list should show cartridge-specific subtests"
assert_contains "$list_output" "movement" "list should contain movement test"
assert_contains "$list_output" "collision" "list should contain collision test"
assert_contains "$list_output" "input" "list should contain input test"
assert_contains "$list_output" "boundary" "list should contain boundary test"

echo
echo "Testing verbose command printing..."
verbose_output=$($PTD test -c "$TMPDIR/test.p8" --verbose collision_test 30 2>&1 || true)
assert_contains "$verbose_output" "Command:" "verbose output should show command header"
assert_contains "$verbose_output" "pico8 -run $TMPDIR/test.p8 -p collision_test:30" "verbose output should show full command"

echo
echo "Testing invalid timeout handling (current behavior: non-numeric positional is treated as subtest)..."
# ptd treats a non-numeric positional argument as a subtest name (not a timeout).
# Expect Subtest to be set to the non-numeric value and Timeout to remain the default (30s).
invalid_output=$($PTD test -c "$ROOT_DIR/test_cart.p8" movement_test invalid 2>&1 || true)
assert_contains "$invalid_output" "Subtest: invalid" "non-numeric positional should be treated as subtest"
assert_contains "$invalid_output" "Timeout: 30s" "timeout should remain default when non-numeric positional is given"

echo
echo "Testing argument parsing edge cases via CLI..."

# Default behaviour: explicit cart but no subtest/timeout -> subtest=all timeout=30
default_output=$($PTD test -c "$ROOT_DIR/test_cart.p8" 2>&1 || true)
assert_contains "$default_output" "Subtest: all" "default subtest should be 'all'"
assert_contains "$default_output" "Timeout: 30s" "default timeout should be 30s"

# Multiple positional subtests -> last one wins
multi_sub_output=$($PTD test -c "$ROOT_DIR/test_cart.p8" movement_test collision_test 2>&1 || true)
assert_contains "$multi_sub_output" "Subtest: collision_test" "multiple phases should use last one"

# Multiple numeric timeouts -> last numeric wins
multi_timeout_output=$($PTD test -c "$ROOT_DIR/test_cart.p8" 30 60 2>&1 || true)
assert_contains "$multi_timeout_output" "Timeout: 60s" "multiple timeouts should use last one"

# Multiple cart flags -> last one wins
cart_override_output=$($PTD test -c "$TMPDIR/first.p8" -c "$TMPDIR/second.p8" 2>&1 || true)
assert_contains "$cart_override_output" "Cartridge: $TMPDIR/second.p8" "multiple carts should use last one"

echo
echo "All integration tests completed."

# cleanup
rm -rf "$TMPDIR" || true
rm -rf "$TMPBIN" || true