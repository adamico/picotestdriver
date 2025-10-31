#!/bin/bash

# Simple Bash Unit Testing Framework
# Usage: ./test_runner.sh [test_file]

# Don't use set -e as it will exit on any failed assertion
# set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-"Expected '$expected', got '$actual'"}"

    ((TESTS_RUN++))
    if [ "$expected" = "$actual" ]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓ PASS${NC}: $message"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗ FAIL${NC}: $message"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
    fi
}

assert_true() {
    local condition="$1"
    local message="${2:-"Expected true, got false"}"

    ((TESTS_RUN++))
    if [ "$condition" = "true" ] || [ "$condition" -eq 0 ] 2>/dev/null; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓ PASS${NC}: $message"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗ FAIL${NC}: $message"
    fi
}

assert_false() {
    local condition="$1"
    local message="${2:-"Expected false, got true"}"

    ((TESTS_RUN++))
    if [ "$condition" = "false" ] || [ "$condition" -ne 0 ] 2>/dev/null; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓ PASS${NC}: $message"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗ FAIL${NC}: $message"
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-"Expected '$haystack' to contain '$needle'"}"

    ((TESTS_RUN++))
    if [[ "$haystack" == *"$needle"* ]]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓ PASS${NC}: $message"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗ FAIL${NC}: $message"
    fi
}

assert_exit_code() {
    local expected="$1"
    local command="$2"
    local message="${3:-"Expected exit code $expected"}"

    ((TESTS_RUN++))
    if eval "$command"; then
        actual_exit=0
    else
        actual_exit=$?
    fi

    if [ "$actual_exit" -eq "$expected" ]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓ PASS${NC}: $message"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗ FAIL${NC}: $message"
        echo "  Expected exit code: $expected"
        echo "  Actual exit code:   $actual_exit"
    fi
}

# Run a test file
run_test_file() {
    local test_file="$1"
    echo -e "${BLUE}Running tests from: $test_file${NC}"
    echo

    # Source the test helper first to define functions
    if [ -f "test/test_helper.sh" ]; then
        source "test/test_helper.sh"
    fi

    # Source the test file
    source "$test_file"

    echo
}

# Print summary
print_summary() {
    echo -e "${BLUE}=== Test Summary ===${NC}"
    echo "Tests run: $TESTS_RUN"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed.${NC}"
        return 1
    fi
}

# Main execution
if [ $# -eq 0 ]; then
    echo "Usage: $0 <test_file> [test_file...]"
    echo "Run all test files in test/ directory if no arguments provided"
    # Run all test files in test directory
    for test_file in test/*.sh; do
        # Skip the test runner itself
        if [ "$(basename "$test_file")" != "test_runner.sh" ] && [ -f "$test_file" ]; then
            run_test_file "$test_file"
        fi
    done
else
    # Run specified test files
    for test_file in "$@"; do
        if [ -f "$test_file" ]; then
            run_test_file "$test_file"
        else
            echo -e "${RED}Test file not found: $test_file${NC}"
        fi
    done
fi

print_summary