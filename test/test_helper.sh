#!/bin/bash

# Test helper functions - sources shared library to avoid code duplication
# This prevents desync errors between the test suite and the runner script

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(cd "$SCRIPT_DIR/../lib" && pwd)"

# Source the shared functions library
source "$LIB_DIR/test_functions.sh"

# The following functions are now available from test_functions.sh:
# - print_color
# - validate_timeout
# - check_cartridge
# - check_pico8
# - parse_arguments
# - build_command
# - show_configuration
# - show_help
# - handle_list_subtests

# Simplified show_help for testing (no exit, doesn't print full help)
show_help() {
    cat << EOF
PICO-8 Automated Testing Framework Runner v${SCRIPT_VERSION}

This script runs PICO-8 cartridges with automated testing capabilities.

USAGE:
    ./run_test.sh [OPTIONS] [PHASE] [TIMEOUT]

ARGUMENTS:
    PHASE       Test phase to run (default: all)
                Common phases: movement, collision, input, boundary
    TIMEOUT     Maximum runtime in seconds (default: ${DEFAULT_TIMEOUT})

OPTIONS:
    -h, --help      Show this help message
    -c, --cart      Specify the test cartridge file (default: test_cart.p8)
    -l, --list      List available test phases (requires cartridge)
    -v, --version   Show version information
    --verbose       Enable verbose output

EXAMPLES:
    ./run_test.sh
        Run all test phases with default timeout

    ./run_test.sh movement_test
        Run only movement tests

    ./run_test.sh collision_test 60
        Run collision tests with 60 second timeout

    ./run_test.sh -c my_test.p8
        Run tests in my_test.p8 cartridge

    ./run_test.sh --list
        List all available test phases

REQUIREMENTS:
    - PICO-8 executable must be in PATH
    - Test cartridge must include test_framework.lua

EXIT CODES:
    0   Success
    1   Invalid arguments
    2   PICO-8 not found
    3   Test cartridge not found
    124 Timeout reached

For more information, visit: https://github.com/your-repo/pico8-test-framework
EOF
}

# Function to show configuration
show_configuration() {
    local cart_file=$1
    local phase=$2
    local timeout=$3
    local verbose=$4

    print_color $BLUE "=== PICO-8 Test Framework Runner v${SCRIPT_VERSION} ==="
    echo "Cartridge: $cart_file"
    echo "Phase: $phase"
    echo "Timeout: ${timeout}s"
    if [ "$verbose" = "true" ]; then
        echo "Verbose: enabled"
    fi
    echo ""
}

# Function to handle list subtests option
handle_list_subtests() {
    local cart_file=$1

    print_color $BLUE "Available test subtests in '$cart_file':"
    echo ""

    # Simplified output matching the actual implementation
    local all_subtests=""
    local found_subtests=false

    # Extract subtest names from the cartridge file
    # Look for: local subtests = { followed by { name = "xxx", ... } entries
    if [ -f "$cart_file" ]; then
        local names
        names=$(awk '/local subtests\s*=\s*\{/,/^\}/ {
            if ($0 ~ /name\s*=\s*"[^"]+"|name\s*=\s*'\''[^'\'']+'\''/) {
                match($0, /(name\s*=\s*["'\''])([^"'\'']+)(["'\''])/, arr)
                if (arr[2] != "") print arr[2]
            }
        }' "$cart_file")
        
        if [ -n "$names" ]; then
            all_subtests="$names"
            found_subtests=true
        fi
    fi

    if [ "$found_subtests" = true ]; then
        # Output each subtest name
        while IFS= read -r subtest; do
            if [ -n "$subtest" ]; then
                echo "  $subtest"
            fi
        done <<< "$all_subtests"
    else
        # Fallback
        echo "  movement"
        echo "  collision"
        echo "  input"
        echo "  boundary"
    fi

    echo ""
    print_color $BLUE "Usage: $0 [-c CART_FILE] SUBTEST"
}