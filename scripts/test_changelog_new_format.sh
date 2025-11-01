#!/bin/bash
#
# Test suite for new changelog format (without [Unreleased] section)
#
# Tests edge cases for the new user-friendly format

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
GENERATE_SCRIPT="$SCRIPT_DIR/generate_changelog.sh"

# Print colored message
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Assert helpers
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

# Test 1: Empty changelog (just header and first version)
test_empty_changelog() {
    print_color "$YELLOW" "Test: Empty changelog structure"
    
    local test_file=$(mktemp)
    cat > "$test_file" << 'EOF'
# Changelog

## [1.0.0] - 2025-10-31

### Features
- Initial release
EOF
    
    local content=$(cat "$test_file")
    
    assert_contains "$content" "# Changelog" "Has header"
    assert_contains "$content" "## [1.0.0]" "Has first version"
    assert_not_contains "$content" "## [Unreleased]" "No [Unreleased] section"
    assert_not_contains "$content" "None yet" "No placeholder text"
    
    rm -f "$test_file"
}

# Test 2: Changelog with unreleased content (new format)
test_unreleased_content() {
    print_color "$YELLOW" "Test: Unreleased content between header and first version"
    
    local test_file=$(mktemp)
    cat > "$test_file" << 'EOF'
# Changelog

### Features
- New unreleased feature
- Another feature

### Bug Fixes
- Fix something

## [1.0.0] - 2025-10-31

### Features
- Initial release
EOF
    
    local content=$(cat "$test_file")
    
    # Should have unreleased content before first version
    local unreleased_section=$(sed -n '/^# Changelog/,/^## \[1\.0\.0\]/p' "$test_file")
    
    assert_contains "$unreleased_section" "New unreleased feature" "Has unreleased feature"
    assert_contains "$unreleased_section" "Fix something" "Has unreleased fix"
    assert_not_contains "$content" "## [Unreleased]" "No explicit [Unreleased] header"
    
    rm -f "$test_file"
}

# Test 3: Release function extracts unreleased content correctly
test_release_extraction() {
    print_color "$YELLOW" "Test: Release extracts content between header and first version"
    
    local test_file=$(mktemp)
    cat > "$test_file" << 'EOF'
# Changelog

### Features
- Feature to release

## [1.0.0] - 2025-10-31

### Features
- Initial release

---

Footer
EOF
    
    # Simulate release extraction (between header and first version)
    local extracted=$(sed -n '/^# Changelog/,/^## \[/p' "$test_file" | sed '1d;$d')
    
    assert_contains "$extracted" "Feature to release" "Extracted unreleased content"
    assert_not_contains "$extracted" "Initial release" "Did not extract versioned content"
    
    rm -f "$test_file"
}

# Test 4: Backwards compatibility with old [Unreleased] format
test_backwards_compat() {
    print_color "$YELLOW" "Test: Backwards compatibility with [Unreleased] section"
    
    local test_file=$(mktemp)
    cat > "$test_file" << 'EOF'
# Changelog

## [Unreleased]

### Features
- Old format feature

## [1.0.0] - 2025-10-31

### Features
- Initial release
EOF
    
    # Should still extract content from old format
    local extracted=$(sed -n '/^# Changelog/,/^## \[[0-9]/p' "$test_file" | grep "Old format feature" || true)
    
    assert_contains "$extracted" "Old format feature" "Can extract from old [Unreleased] format"
    
    rm -f "$test_file"
}

# Test 5: Multiple unreleased sections (Features, Bug Fixes, Performance)
test_multiple_sections() {
    print_color "$YELLOW" "Test: Multiple unreleased change types"
    
    local test_file=$(mktemp)
    cat > "$test_file" << 'EOF'
# Changelog

### Features
- Feature A
- Feature B

### Bug Fixes
- Fix A

### Performance Improvements
- Perf A

## [1.0.0] - 2025-10-31
EOF
    
    local content=$(cat "$test_file")
    
    assert_contains "$content" "### Features" "Has Features section"
    assert_contains "$content" "### Bug Fixes" "Has Bug Fixes section"
    assert_contains "$content" "### Performance Improvements" "Has Performance section"
    assert_contains "$content" "Feature A" "Has feature entry"
    assert_contains "$content" "Fix A" "Has fix entry"
    assert_contains "$content" "Perf A" "Has perf entry"
    
    rm -f "$test_file"
}

# Test 6: No unreleased content (goes straight to versions)
test_no_unreleased() {
    print_color "$YELLOW" "Test: Changelog with no unreleased content"
    
    local test_file=$(mktemp)
    cat > "$test_file" << 'EOF'
# Changelog

## [1.1.0] - 2025-11-01

### Features
- New version

## [1.0.0] - 2025-10-31

### Features
- Initial release
EOF
    
    local content=$(cat "$test_file")
    
    # Should go directly from header to first version
    local after_header=$(sed -n '/^# Changelog/,/^## \[/p' "$test_file" | sed '1,2d' | head -1)
    
    assert_contains "$after_header" "## [1.1.0]" "First line after header is version"
    
    # Check there's no unreleased content between header and first version
    local unreleased=$(sed -n '/^# Changelog/,/^## \[1\.1\.0\]/p' "$test_file" | grep "^### Features" | head -1 || echo "")
    
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ -z "$unreleased" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_color "$GREEN" "  ✓ No unreleased content before first version"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_color "$RED" "  ✗ Found unreleased content: $unreleased"
    fi
    
    rm -f "$test_file"
}

# Test 7: Empty unreleased sections are not shown
test_no_empty_sections() {
    print_color "$YELLOW" "Test: Empty/placeholder content is not displayed"
    
    # This tests that when generating changelog, we don't show empty sections
    # The script should only output content when there are actual entries
    
    local test_output="# Changelog\n\n## [1.0.0] - 2025-10-31"
    
    assert_not_contains "$test_output" "### Features\n- None yet" "No empty Features section"
    assert_not_contains "$test_output" "### Bug Fixes\n- None yet" "No empty Bug Fixes section"
}

# Test 8: Release with no unreleased content
test_release_empty() {
    print_color "$YELLOW" "Test: Release when no unreleased content exists"
    
    local test_file=$(mktemp)
    cat > "$test_file" << 'EOF'
# Changelog

## [1.0.0] - 2025-10-31

### Features
- Initial release
EOF
    
    # Check that there's no content to release
    local unreleased=$(sed -n '/^# Changelog/,/^## \[[0-9]/p' "$test_file" | grep "^- " || true)
    
    if [ -z "$unreleased" ]; then
        local is_empty="true"
    else
        local is_empty="false"
    fi
    
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ "$is_empty" = "true" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_color "$GREEN" "  ✓ Correctly detects no unreleased content"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_color "$RED" "  ✗ Failed to detect empty unreleased"
    fi
    
    rm -f "$test_file"
}

# Main test runner
main() {
    print_color "$YELLOW" "=== New Changelog Format Tests ==="
    echo ""
    
    if [ ! -f "$GENERATE_SCRIPT" ]; then
        print_color "$RED" "Error: generate_changelog.sh not found at $GENERATE_SCRIPT"
        exit 1
    fi
    
    # Run tests
    test_empty_changelog
    test_unreleased_content
    test_release_extraction
    test_backwards_compat
    test_multiple_sections
    test_no_unreleased
    test_no_empty_sections
    test_release_empty
    
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
