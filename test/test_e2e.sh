#!/bin/bash

# End-to-end tests for run_test.sh script
# Note: test_helper.sh is sourced by the test runner

echo "Testing main function with help flag..."

# Test help flag (should exit with code 0 and show help)
# We can't easily capture exit codes in this test framework, but we can test the parsing

echo
echo "Testing main function argument parsing..."

# Test that main calls parse_arguments correctly
# This is more of a smoke test since we can't easily mock the entire main function

echo "Note: Full end-to-end testing would require mocking external commands"
echo "and is better done with a proper test framework like Bats."

echo
echo "Testing error conditions..."

# Test invalid timeout via main function
# This would normally exit, but we can test the validation function it calls
echo "Testing timeout validation (called by main)..."
validate_timeout "25"
assert_true $? "valid timeout should pass"

validate_timeout "0"
assert_false $? "zero timeout should fail"

echo
echo "Testing cartridge validation..."

# Create temporary test cartridge
echo "test content" > /tmp/test_cart.p8

check_cartridge "/tmp/test_cart.p8"
assert_true $? "existing cartridge should pass validation"

check_cartridge "/tmp/missing_cart.p8"
assert_false $? "missing cartridge should fail validation"

# Clean up
rm -f /tmp/test_cart.p8

echo
echo "Testing PICO-8 availability check..."

# Mock command function to simulate pico8 not being available
original_command=$(command -v command 2>/dev/null || echo "command_not_found")
command() {
    if [ "$1" = "-v" ] && [ "$2" = "pico8" ]; then
        return 1  # Simulate not found
    else
        $original_command "$@"
    fi
}

check_pico8
result=$?
assert_false $result "check_pico8 should fail when pico8 not in PATH"

# Restore original command function
if [ "$original_command" != "command_not_found" ]; then
    command() {
        $original_command "$@"
    }
else
    unset -f command
fi

echo
echo "All end-to-end tests completed."