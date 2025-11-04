#!/bin/bash

# PicoTestDriver - Shared Functions Library
# This file contains shared functions used across the test framework
# Source this file to avoid code duplication and desync issues

# Configuration
SCRIPT_VERSION="1.0.0"
DEFAULT_TIMEOUT=30

# Colors for output (can be overridden for testing)
RED=${RED:-'\033[0;31m'}
GREEN=${GREEN:-'\033[0;32m'}
YELLOW=${YELLOW:-'\033[1;33m'}
BLUE=${BLUE:-'\033[0;34m'}
NC=${NC:-'\033[0m'} # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to validate timeout value
validate_timeout() {
    local timeout=$1
    if ! [[ $timeout =~ ^[0-9]+$ ]] || [ $timeout -le 0 ]; then
        print_color $RED "Error: Invalid timeout '$timeout'. Must be a positive integer."
        return 1
    fi
    return 0
}

# Function to check if cartridge exists
check_cartridge() {
    local cart_file=$1
    if [ ! -f "$cart_file" ]; then
        print_color $RED "Error: Test cartridge '$cart_file' not found"
        return 3
    fi
    return 0
}

# Function to check if PICO-8 is available
check_pico8() {
    if ! command -v pico8 &> /dev/null; then
        print_color $RED "Error: PICO-8 executable not found in PATH"
        echo "Please ensure PICO-8 is installed and accessible."
        return 2
    fi
    return 0
}

# Function to parse command line arguments
# Returns: "phase|timeout|verbose|list_phases|cart_file"
parse_arguments() {
    local args=("$@")
    local phase="all"
    local timeout=$DEFAULT_TIMEOUT
    local verbose=false
    local list_phases=false
    local cart_file="test_cart.p8"
    
    # Get script directory for demo mode
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    while [[ ${#args[@]} -gt 0 ]]; do
        case ${args[0]} in
            -h|--help)
                show_help
                return 0
                ;;
            -v|--version)
                echo "PicoTestDriver v${SCRIPT_VERSION}"
                return 0
                ;;
            -c|--cart)
                cart_file="${args[1]}"
                args=("${args[@]:2}")
                ;;
            -d|--demo)
                cart_file="$script_dir/test_cart.p8"
                args=("${args[@]:1}")
                ;;
            -l|--list)
                list_phases=true
                args=("${args[@]:1}")
                ;;
            --verbose)
                verbose=true
                args=("${args[@]:1}")
                ;;
            *)
                # Check if it's a timeout value (number)
                if [[ ${args[0]} =~ ^[0-9]+$ ]]; then
                    timeout=${args[0]}
                else
                    phase=${args[0]}
                fi
                args=("${args[@]:1}")
                ;;
        esac
    done

    # Return parsed values
    echo "$phase|$timeout|$verbose|$list_phases|$cart_file"
}

# Function to build PICO-8 command
# Parameters: cart_file phase timeout verbose
# Returns: Complete pico8 command string
build_command() {
    local cart_file=$1
    local phase=$2
    local timeout=$3
    local verbose=$4

    local cmd="pico8 -run $cart_file"

    # Pass timeout to PICO-8 as a parameter (PHASE:TIMEOUT format)
    if [ "$phase" != "all" ]; then
        cmd="$cmd -p ${phase}:${timeout}"
    else
        cmd="$cmd -p timeout:${timeout}"
    fi

    if [ "$verbose" = "true" ]; then
        print_color $YELLOW "Command: $cmd"
        echo ""
    fi

    echo "$cmd"
}

# Function to show configuration
show_configuration() {
    local cart_file=$1
    local phase=$2
    local timeout=$3
    local verbose=$4

    print_color $BLUE "=== PicoTestDriver v${SCRIPT_VERSION} ==="
    echo "Cartridge: $cart_file"
    echo "Phase: $phase"
    echo "Timeout: ${timeout}s"
    if [ "$verbose" = "true" ]; then
        echo "Verbose: enabled"
    fi
    echo ""
}

# Function to show help
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
    -l, --list      List available test phases (no PICO-8 required)
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
        List available test phases (preferred: use 'ptd list -c <cartridge>')

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

# Function to handle list phases option
handle_list_phases() {
    local cart_file=$1

    print_color $BLUE "=== Available Test Phases ==="

    local cart_dir
    cart_dir=$(dirname "$cart_file")

    extract_subtests() {
        local file=$1
        # Extract name = "..." and name = '...' occurrences between the subtests table
        local names
        names=$( (sed -n -E 's/.*name[[:space:]]*=[[:space:]]*"(.*)".*/\1/p' "$file" 2>/dev/null || true; \
                  sed -n -E "s/.*name[[:space:]]*=[[:space:]]*'([^']+)'.*/\1/p" "$file" 2>/dev/null || true) | tr -d '\r')
        echo "$names"
    }

    local all_subtests=""
    local found_subtests=false

    if [ -f "$cart_file" ]; then
        local cart_subtests
        cart_subtests=$(extract_subtests "$cart_file")
        if [ -n "$cart_subtests" ]; then
            all_subtests="$cart_subtests"
            found_subtests=true
        fi

        local included_files
        included_files=$(grep "^#include" "$cart_file" | sed 's/#include //' | grep '\.lua$' | grep -v 'test_framework\.lua' | grep -v 'test_utils\.lua' || true)

        for lua_file in $included_files; do
            local resolved_path
            if [[ "$lua_file" == /* ]]; then
                resolved_path="$lua_file"
            else
                resolved_path="$cart_dir/$lua_file"
            fi

            if [ -f "$resolved_path" ]; then
                local file_subtests
                file_subtests=$(extract_subtests "$resolved_path")
                if [ -n "$file_subtests" ]; then
                    if [ -n "$all_subtests" ]; then
                        all_subtests="$all_subtests"$'\n'"$file_subtests"
                    else
                        all_subtests="$file_subtests"
                    fi
                    found_subtests=true
                fi
            fi
        done
    fi

    if [ "$found_subtests" = true ]; then
        local unique_subtests
        unique_subtests=$(echo "$all_subtests" | sort | uniq)
        echo "Available test phases in $cart_file:"
        echo "  - all              : Run all test phases"
        while IFS= read -r subtest; do
            if [ -n "$subtest" ]; then
                echo "  - $subtest          : Test phase"
            fi
        done <<< "$unique_subtests"
        echo ""
        echo "Use 'ptd test -c $cart_file <phase>' to run a specific test."
    else
        echo "The following test phases are commonly available:"
        echo "  - movement_test    : Test player movement mechanics"
        echo "  - collision_test   : Test collision detection"
        echo "  - input_test       : Test input handling and gestures"
        echo "  - boundary_test    : Test boundary crossing and reversal"
        echo "  - all              : Run all test phases"
        echo ""
        echo "Note: Available phases depend on the specific test cartridge implementation."
    echo "Use 'ptd test -c <cartridge> <phase>' to run a specific test."
    fi
}
