#!/bin/bash

# Unit tests for run_test.sh functions
# Note: test_helper.sh is sourced by the test runner

echo "Testing print_color function..."
# Test print_color (hard to test output directly, but we can test it doesn't crash)
print_color "$GREEN" "Test message" > /dev/null
assert_true $? "print_color should not fail"

echo
echo "Testing validate_timeout function..."

# Test valid timeouts
validate_timeout 30
assert_true $? "validate_timeout should accept 30"

validate_timeout 1
assert_true $? "validate_timeout should accept 1"

validate_timeout 999
assert_true $? "validate_timeout should accept 999"

# Test invalid timeouts
validate_timeout 0
assert_false $? "validate_timeout should reject 0"

validate_timeout -1
assert_false $? "validate_timeout should reject -1"

validate_timeout "abc"
assert_false $? "validate_timeout should reject non-numeric"

validate_timeout ""
assert_false $? "validate_timeout should reject empty string"

echo
echo "Testing check_cartridge function..."

# Create a temporary test file
echo "test" > /tmp/test_cart.p8

# Test existing file
check_cartridge "/tmp/test_cart.p8"
assert_true $? "check_cartridge should accept existing file"

# Test non-existing file
check_cartridge "/tmp/nonexistent.p8"
assert_false $? "check_cartridge should reject non-existing file"

# Clean up
rm -f /tmp/test_cart.p8

echo
echo "Testing parse_arguments function..."

# Test default arguments
result=$(parse_arguments)
expected="all|30|false|false|test_cart.p8"
assert_equals "$expected" "$result" "parse_arguments with no args should return defaults"

# Test phase argument
result=$(parse_arguments "movement_test")
expected="movement_test|30|false|false|test_cart.p8"
assert_equals "$expected" "$result" "parse_arguments should parse phase"

# Test timeout argument
result=$(parse_arguments "60")
expected="all|60|false|false|test_cart.p8"
assert_equals "$expected" "$result" "parse_arguments should parse timeout"

# Test cart file argument
result=$(parse_arguments "-c" "my_test.p8")
expected="all|30|false|false|my_test.p8"
assert_equals "$expected" "$result" "parse_arguments should parse cart file"

# Test verbose flag
result=$(parse_arguments "--verbose")
expected="all|30|true|false|test_cart.p8"
assert_equals "$expected" "$result" "parse_arguments should parse verbose flag"

# Test list phases flag
result=$(parse_arguments "--list")
expected="all|30|false|true|test_cart.p8"
assert_equals "$expected" "$result" "parse_arguments should parse list flag"

# Test combined arguments
result=$(parse_arguments "-c" "custom.p8" "boundary_test" "45" "--verbose")
expected="boundary_test|45|true|false|custom.p8"
assert_equals "$expected" "$result" "parse_arguments should parse combined arguments"

echo
echo "Testing build_command function..."

# Test basic command with timeout
result=$(build_command "test.p8" "all" "30" "false")
expected="pico8 -run test.p8 -p timeout:30"
assert_equals "$expected" "$result" "build_command should build basic command with timeout"

# Test with phase and timeout
result=$(build_command "test.p8" "movement_test" "45" "false")
expected="pico8 -run test.p8 -p movement_test:45"
assert_equals "$expected" "$result" "build_command should include phase with timeout"

echo
echo "Testing check_pico8 function..."

# This will depend on whether pico8 is actually installed
# For testing purposes, we'll mock the command check
original_command=$(command -v command)
command() {
    if [ "$1" = "-v" ] && [ "$2" = "pico8" ]; then
        return 1  # Simulate pico8 not found
    else
        $original_command "$@"
    fi
}

check_pico8
assert_false $? "check_pico8 should fail when pico8 not found"

# Restore original command
command() {
    $original_command "$@"
}

echo
echo "All basic function tests completed."