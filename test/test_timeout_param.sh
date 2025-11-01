#!/bin/bash

# Unit tests for timeout parameter functionality
# Tests the new feature where timeout is passed to PICO-8 via command line

echo "Testing build_command with timeout parameter..."

# Test timeout parameter with specific phase
result=$(build_command "test.p8" "tap_test" "30" "false")
expected="pico8 -run test.p8 -p tap_test:30"
assert_equals "$expected" "$result" "build_command should include timeout in phase parameter"

# Test timeout parameter with different timeout value
result=$(build_command "test.p8" "movement_test" "60" "false")
expected="pico8 -run test.p8 -p movement_test:60"
assert_equals "$expected" "$result" "build_command should work with different timeout values"

# Test timeout parameter with "all" phase
result=$(build_command "test.p8" "all" "45" "false")
expected="pico8 -run test.p8 -p timeout:45"
assert_equals "$expected" "$result" "build_command should use 'timeout' prefix when phase is 'all'"

# Test verbose flag still works
result=$(build_command "test.p8" "boundary_test" "120" "true" 2>&1 | tail -1)
expected="pico8 -run test.p8 -p boundary_test:120"
assert_equals "$expected" "$result" "build_command verbose output should still work with timeout"

echo
echo "Testing parse_arguments with timeout values..."

# Test that timeout is properly parsed and passed through
result=$(parse_arguments "tap_test" "90")
expected="tap_test|90|false|false|test_cart.p8"
assert_equals "$expected" "$result" "parse_arguments should handle phase and timeout"

# Test timeout with cartridge argument
result=$(parse_arguments "-c" "custom.p8" "input_test" "120")
expected="input_test|120|false|false|custom.p8"
assert_equals "$expected" "$result" "parse_arguments should handle cart, phase, and timeout"

echo
echo "All timeout parameter tests completed!"
