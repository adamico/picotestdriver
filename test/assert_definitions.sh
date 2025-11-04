#!/usr/bin/env bash
# Common assertion helpers for picotestdriver tests

# Colors (defaults if not set by caller)
RED=${RED:-'\033[0;31m'}
GREEN=${GREEN:-'\033[0;32m'}
YELLOW=${YELLOW:-'\033[1;33m'}
BLUE=${BLUE:-'\033[0;34m'}
NC=${NC:-'\033[0m'}

# Ensure counters exist
: ${TESTS_RUN:=0}
: ${TESTS_PASSED:=0}
: ${TESTS_FAILED:=0}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Expected '$expected', got '$actual'}"

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
    local message="${2:-Expected true, got false}"

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
    local message="${2:-Expected false, got true}"

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
    local message="${3:-Expected '$haystack' to contain '$needle'}"

    ((TESTS_RUN++))
    if printf '%s' "$haystack" | grep -F -- "$needle" >/dev/null 2>&1; then
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
    local message="${3:-Expected exit code $expected}"

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

assert_file_exists() {
    local f="$1"
    local message="${2:-file $f exists}"
    ((TESTS_RUN++))
    if [ -f "$f" ]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✓ PASS${NC}: $message"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}✗ FAIL${NC}: $message"
        echo "  Missing: $f"
    fi
}

return 0
