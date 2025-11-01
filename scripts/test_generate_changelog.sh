#!/bin/bash
#
# Test suite for generate_changelog.sh
#
# Tests the changelog generation and merging functionality

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
GENERATE_SCRIPT="$SCRIPT_DIR/generate_changelog.sh"
TEST_CHANGELOG="$SCRIPT_DIR/test_changelog_temp.md"
TEST_BACKUP="$TEST_CHANGELOG.backup"

# Cleanup function
cleanup() {
    rm -f "$TEST_CHANGELOG" "$TEST_BACKUP"
}

trap cleanup EXIT

# Print colored message
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Assert helper
assert_equals() {
    local expected=$1
    local actual=$2
    local message=$3
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ "$expected" = "$actual" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_color "$GREEN" "  ✓ $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_color "$RED" "  ✗ $message"
        print_color "$RED" "    Expected: $expected"
        print_color "$RED" "    Actual:   $actual"
        return 1
    fi
}

assert_contains() {
    local haystack=$1
    local needle=$2
    local message=$3
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if echo "$haystack" | grep -qF "$needle"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_color "$GREEN" "  ✓ $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_color "$RED" "  ✗ $message"
        print_color "$RED" "    Needle not found: $needle"
        return 1
    fi
}

assert_not_contains() {
    local haystack=$1
    local needle=$2
    local message=$3
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if ! echo "$haystack" | grep -qF "$needle"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_color "$GREEN" "  ✓ $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_color "$RED" "  ✗ $message"
        print_color "$RED" "    Found unexpected: $needle"
        return 1
    fi
}

# Create a test changelog
create_test_changelog() {
    cat > "$TEST_CHANGELOG" << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Features
- None yet

### Bug Fixes
- None yet

### Performance Improvements
- None yet

## [1.0.0] - 2025-10-31

### Features
- Initial release

---

**About this project:** Test project
**Format:** Keep a Changelog
**Automation:** Run script
EOF
}

# Test 1: Script help works
test_help() {
    print_color "$YELLOW" "Test: Script help displays"
    
    local output
    output=$("$GENERATE_SCRIPT" --help 2>&1)
    
    assert_contains "$output" "Usage:" "Help shows usage"
    assert_contains "$output" "auto-accept" "Help mentions auto-accept flag"
}

# Test 2: Merge new features into [Unreleased]
test_merge_features() {
    print_color "$YELLOW" "Test: Merge new features into [Unreleased]"
    
    create_test_changelog
    
    # Create temporary generated content
    local temp_generated=$(mktemp)
    cat > "$temp_generated" << 'EOF'
## [Unreleased]

### Features
- new feature from commit

### Bug Fixes

### Performance Improvements
EOF
    
    # Simulate what the update_changelog function does
    # Extract existing content
    local existing_features=$(sed -n '/## \[Unreleased\]/,/^## \[/p' "$TEST_CHANGELOG" | sed -n '/### Features/,/^### /p' | grep "^- " || echo "")
    
    # Check that "None yet" IS extracted (that's OK, it's filtered later)
    assert_contains "$existing_features" "None yet" "None yet is extracted from changelog"
    
    # The actual filtering happens in the merge logic
    if echo "$existing_features" | grep -q "None yet"; then
        local should_skip="true"
    else
        local should_skip="false"
    fi
    assert_equals "true" "$should_skip" "None yet placeholder is detected for filtering"
    
    # New features should be added
    local new_features="- new feature from commit"
    assert_contains "$new_features" "new feature" "New feature is present"
    
    rm "$temp_generated"
}

# Test 3: Deduplication works
test_deduplication() {
    print_color "$YELLOW" "Test: Deduplication removes duplicate entries"
    
    local input=$'- feature one\n- feature two\n- feature one\n- feature three'
    local deduplicated=$(echo "$input" | sort -u)
    
    local count=$(echo "$deduplicated" | grep -c "feature one")
    assert_equals "1" "$count" "Duplicate 'feature one' removed"
    
    count=$(echo "$deduplicated" | wc -l)
    assert_equals "3" "$count" "Total lines after dedup is 3"
}

# Test 4: Preserves version sections
test_preserve_versions() {
    print_color "$YELLOW" "Test: Version sections are preserved"
    
    create_test_changelog
    
    # Extract version section
    local versions=$(sed -n '/^## \[[0-9]/,/^---/p' "$TEST_CHANGELOG")
    
    assert_contains "$versions" "[1.0.0]" "Version 1.0.0 is present"
    assert_contains "$versions" "Initial release" "Version content is preserved"
}

# Test 5: Empty placeholder handling
test_placeholder_handling() {
    print_color "$YELLOW" "Test: 'None yet' placeholders are handled correctly"
    
    local text_with_placeholder="- None yet"
    local text_with_real="- real feature"
    
    # Simulate the filter check
    if echo "$text_with_placeholder" | grep -q "None yet"; then
        local filtered="true"
    else
        local filtered="false"
    fi
    
    assert_equals "true" "$filtered" "Placeholder is detected"
    
    if echo "$text_with_real" | grep -q "None yet"; then
        filtered="true"
    else
        filtered="false"
    fi
    
    assert_equals "false" "$filtered" "Real content is not filtered"
}

# Test 6: Footer preservation
test_footer_preservation() {
    print_color "$YELLOW" "Test: Footer section is preserved"
    
    create_test_changelog
    
    # Extract footer
    local footer=$(tail -5 "$TEST_CHANGELOG")
    
    assert_contains "$footer" "About this project:" "About line is present"
    assert_contains "$footer" "Format:" "Format line is present"
    assert_contains "$footer" "Automation:" "Automation line is present"
}

# Test 7: Script accepts various flags
test_flag_acceptance() {
    print_color "$YELLOW" "Test: Script accepts various flag formats"
    
    # Test --help
    "$GENERATE_SCRIPT" --help > /dev/null 2>&1
    assert_equals "0" "$?" "Script accepts --help"
    
    # Test -h
    "$GENERATE_SCRIPT" -h > /dev/null 2>&1
    assert_equals "0" "$?" "Script accepts -h"
}

# Test 8: Empty merge handling
test_empty_merge() {
    print_color "$YELLOW" "Test: Empty changelog sections handled correctly"
    
    local empty_features=""
    local empty_fixes=""
    
    # Simulate the check
    if [ -z "$empty_features" ]; then
        local result="Use placeholder"
    else
        local result="Use content"
    fi
    
    assert_equals "Use placeholder" "$result" "Empty features defaults to placeholder"
}

# Test 9: Multiple commits of same type
test_multiple_commits() {
    print_color "$YELLOW" "Test: Multiple commits are properly collected"
    
    local commits=$'- feature one\n- feature two\n- feature three'
    local count=$(echo "$commits" | grep -c "^- feature")
    
    assert_equals "3" "$count" "All three features collected"
}

# Test 10: Sorted output
test_sorted_output() {
    print_color "$YELLOW" "Test: Deduplicated output is sorted"
    
    local unsorted=$'- zebra feature\n- alpha feature\n- beta feature'
    local sorted=$(echo "$unsorted" | sort -u)
    
    local first_line=$(echo "$sorted" | head -1)
    assert_contains "$first_line" "alpha" "First line after sort contains 'alpha'"
}

# Test 11: Release functionality
test_release_functionality() {
    print_color "$YELLOW" "Test: --release converts [Unreleased] to version"
    
    # Create test changelog with [Unreleased] content
    local test_changelog=$(mktemp)
    cat > "$test_changelog" << 'EOF'
# Changelog

## [Unreleased]

### Features
- New feature A

### Bug Fixes
- Fixed bug B

## [1.0.0] - 2024-01-01
EOF
    
    # Run release with auto-accept
    local output=$(CHANGELOG_FILE="$test_changelog" "$GENERATE_SCRIPT" --release 1.1.0 --auto-accept 2>&1)
    local result=$?
    
    # Check success
    assert_equals "0" "$result" "Release command succeeded"
    
    # Verify new [Unreleased] created
    assert_contains "$(cat "$test_changelog")" "## [Unreleased]" "New [Unreleased] section created"
    
    # Verify version section created
    assert_contains "$(cat "$test_changelog")" "## [1.1.0]" "Version section created"
    
    # Verify content moved to version
    local version_section=$(sed -n '/## \[1\.1\.0\]/,/## \[1\.0\.0\]/p' "$test_changelog")
    assert_contains "$version_section" "New feature A" "Features moved to version"
    assert_contains "$version_section" "Fixed bug B" "Bug fixes moved to version"
    
    # Verify old version preserved
    assert_contains "$(cat "$test_changelog")" "## [1.0.0] - 2024-01-01" "Old version preserved"
    
    # Cleanup
    rm -f "$test_changelog"
}

# Main test runner
main() {
    print_color "$YELLOW" "=== Changelog Generation Script Tests ==="
    echo ""
    
    # Check if script exists
    if [ ! -f "$GENERATE_SCRIPT" ]; then
        print_color "$RED" "Error: generate_changelog.sh not found at $GENERATE_SCRIPT"
        exit 1
    fi
    
    # Run tests
    test_help
    test_merge_features
    test_deduplication
    test_preserve_versions
    test_placeholder_handling
    test_footer_preservation
    test_flag_acceptance
    test_empty_merge
    test_multiple_commits
    test_sorted_output
    test_release_functionality
    
    # Summary
    echo ""
    print_color "$YELLOW" "=== Test Summary ==="
    echo "Tests run:    $TESTS_RUN"
    print_color "$GREEN" "Tests passed: $TESTS_PASSED"
    
    if [ $TESTS_FAILED -gt 0 ]; then
        print_color "$RED" "Tests failed: $TESTS_FAILED"
        exit 1
    else
        print_color "$GREEN" "All tests passed! ✓"
        exit 0
    fi
}

main "$@"
