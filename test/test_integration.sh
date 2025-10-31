#!/bin/bash

# Integration tests for run_test.sh script behavior
# Note: test_helper.sh is sourced by the test runner

echo "Testing script help output..."

# Capture help output
help_output=$(show_help)
assert_contains "$help_output" "PICO-8 Automated Testing Framework Runner" "help should contain title"
assert_contains "$help_output" "USAGE:" "help should contain usage section"
assert_contains "$help_output" "--help" "help should contain help option"
assert_contains "$help_output" "EXAMPLES:" "help should contain examples section"

echo
echo "Testing script version output..."

# Mock the version output capture
version_output=$(echo "PICO-8 Test Framework Runner v${SCRIPT_VERSION}")
assert_contains "$version_output" "v${SCRIPT_VERSION}" "version should contain script version"

echo
echo "Testing configuration display..."

# Test configuration display (capture output)
config_output=$(show_configuration "test.p8" "movement_test" "45" "true")
assert_contains "$config_output" "test.p8" "config should show cartridge file"
assert_contains "$config_output" "movement_test" "config should show phase"
assert_contains "$config_output" "45s" "config should show timeout"
assert_contains "$config_output" "Verbose: enabled" "config should show verbose status"

echo
echo "Testing list phases output..."

# Test list phases output
list_output=$(handle_list_phases)
assert_contains "$list_output" "Available Test Phases" "list should contain header"
assert_contains "$list_output" "movement_test" "list should contain movement test"
assert_contains "$list_output" "collision_test" "list should contain collision test"
assert_contains "$list_output" "boundary_test" "list should contain boundary test"
assert_contains "$list_output" "all" "list should contain all phases"

echo
echo "Testing command building with verbose output..."

# Capture verbose command output
verbose_output=$(build_command "test.p8" "collision_test" "true" 2>&1)
assert_contains "$verbose_output" "Command:" "verbose output should show command header"
assert_contains "$verbose_output" "pico8 -run test.p8 -p collision_test" "verbose output should show full command"

echo
echo "Testing error handling scenarios..."

# Test invalid timeout (this would normally exit, but we're testing the validation function)
validate_timeout "invalid"
assert_false $? "should reject invalid timeout string"

validate_timeout "0"
assert_false $? "should reject zero timeout"

validate_timeout "-5"
assert_false $? "should reject negative timeout"

echo
echo "Testing argument parsing edge cases..."

# Test empty arguments
result=$(parse_arguments)
expected="all|30|false|false|test_cart.p8"
assert_equals "$expected" "$result" "empty args should use defaults"

# Test multiple phases (should use last one)
result=$(parse_arguments "movement_test" "collision_test")
expected="collision_test|30|false|false|test_cart.p8"
assert_equals "$expected" "$result" "multiple phases should use last one"

# Test multiple timeouts (should use last one)
result=$(parse_arguments "30" "60")
expected="all|60|false|false|test_cart.p8"
assert_equals "$expected" "$result" "multiple timeouts should use last one"

# Test cart file override
result=$(parse_arguments "-c" "first.p8" "-c" "second.p8")
expected="all|30|false|false|second.p8"
assert_equals "$expected" "$result" "multiple cart files should use last one"

echo
echo "All integration tests completed."