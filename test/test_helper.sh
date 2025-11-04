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
    ./ptd test [OPTIONS] [SUBTEST] [TIMEOUT]

ARGUMENTS:
    SUBTEST     Test subtest to run (default: all)
                Common subtests: movement, collision, input, boundary
    TIMEOUT     Maximum runtime in seconds (default: ${DEFAULT_TIMEOUT})

OPTIONS:
    -h, --help      Show this help message
    -c, --cart      Specify the test cartridge file (default: test_cart.p8)
    -l, --list      List available test phases (no PICO-8 required)
    -v, --version   Show version information
    --verbose       Enable verbose output

EXAMPLES:
    ./ptd test -d
        Run the demo test cartridge

    ./ptd test -c my_test.p8 movement
        Run only movement tests

    ./ptd test -c my_test.p8 collision 60
        Run collision tests with 60 second timeout

    ./ptd test -c my_test.p8
        Run all tests in my_test.p8 cartridge

    ./ptd list -c my_test.p8
        List all available test subtests

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

    if [ -z "$phase" ]; then
        phase="all"
    fi

    print_color $BLUE "=== PicoTestDriver v${SCRIPT_VERSION} ==="
    echo "Cartridge: $cart_file"
    echo "Phase: $phase"
    echo "Timeout: ${timeout}s"
    if [ "$verbose" = "true" ]; then
        echo "Verbose: enabled"
    fi
    echo ""
}

# Note: `handle_list_subtests()` is provided by the shared library
# `lib/test_functions.sh`. The test helper sources that library at the
# top of this file, so we intentionally do not duplicate the implementation
# here to avoid drift. If you need to override listing behavior in tests,
# mock or wrap `handle_list_subtests()` in your test harness.