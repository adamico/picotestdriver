#!/bin/bash

# Test helper functions - extracts just the functions we need to test
# This avoids sourcing the entire script which can cause issues

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

# Function to parse command line arguments
parse_arguments() {
    local args=("$@")
    local phase="all"
    local timeout=$DEFAULT_TIMEOUT
    local verbose=false
    local list_phases=false
    local cart_file="test_cart.p8"

    while [[ ${#args[@]} -gt 0 ]]; do
        case ${args[0]} in
            -h|--help)
                return 0
                ;;
            -v|--version)
                return 0
                ;;
            -c|--cart)
                cart_file="${args[1]}"
                args=("${args[@]:2}")
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
build_command() {
    local cart_file=$1
    local phase=$2
    local verbose=$3

    local cmd="pico8 -run $cart_file"

    if [ "$phase" != "all" ]; then
        cmd="$cmd -p $phase"
    fi

    if [ "$verbose" = "true" ]; then
        print_color $YELLOW "Command: $cmd"
        echo ""
    fi

    echo "$cmd"
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

# Function to handle list phases option
handle_list_phases() {
    local cart_file=$1

    print_color $BLUE "=== Available Test Phases ==="

    # Get the directory of the cartridge file
    local cart_dir
    cart_dir=$(dirname "$cart_file")

    # Collect all phases from cartridge and included files
    local all_phases=""
    local found_phases=false

    # First check the cartridge file itself
    if [ -f "$cart_file" ]; then
        local phases_line
        phases_line=$(grep -A 20 "test_init" "$cart_file" | grep "phases\s*=\s*{" | head -1)

        if [ -n "$phases_line" ]; then
            local phases_array
            phases_array=$(echo "$phases_line" | sed 's/.*phases\s*=\s*{//' | sed 's/}.*//')
            all_phases="$phases_array"
            found_phases=true
        fi
    fi

    # Then check included .lua files (excluding test_framework.lua and test_utils.lua)
    if [ -f "$cart_file" ]; then
        local included_files
        included_files=$(grep "^#include" "$cart_file" | sed 's/#include //' | grep '\.lua$' | grep -v 'test_framework\.lua' | grep -v 'test_utils\.lua')

        for lua_file in $included_files; do
            # Resolve the path relative to the cartridge file directory
            local resolved_path
            if [[ "$lua_file" == /* ]]; then
                # Absolute path
                resolved_path="$lua_file"
            else
                # Relative path
                resolved_path="$cart_dir/$lua_file"
            fi

            if [ -f "$resolved_path" ]; then
                phases_line=$(grep -A 20 "test_init" "$resolved_path" | grep "phases\s*=\s*{" | head -1)
                if [ -n "$phases_line" ]; then
                    local phases_array
                    phases_array=$(echo "$phases_line" | sed 's/.*phases\s*=\s*{//' | sed 's/}.*//')
                    if [ -n "$all_phases" ]; then
                        all_phases="$all_phases,$phases_array"
                    else
                        all_phases="$phases_array"
                    fi
                    found_phases=true
                fi
            fi
        done
    fi

    if [ "$found_phases" = true ]; then
        # Remove duplicates and split by comma and process each phase
        local unique_phases
        unique_phases=$(echo "$all_phases" | tr ',' '\n' | sort | uniq | tr '\n' ',' | sed 's/,$//')

        echo "Available test phases in $cart_file:"
        echo "  - all              : Run all test phases"

        IFS=',' read -ra PHASE_ARRAY <<< "$unique_phases"
        for phase in "${PHASE_ARRAY[@]}"; do
            # Trim whitespace and quotes
            phase=$(echo "$phase" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sed 's/"//g' | sed "s/'//g")

            if [ -n "$phase" ]; then
                echo "  - ${phase}          : Test phase"
            fi
        done
        echo ""
        echo "Use './run_test.sh -c $cart_file <phase>' to run a specific test."
    else
        # Fallback to generic list if parsing fails
        echo "The following test phases are commonly available:"
        echo "  - movement_test    : Test player movement mechanics"
        echo "  - collision_test   : Test collision detection"
        echo "  - input_test       : Test input handling and gestures"
        echo "  - boundary_test    : Test boundary crossing and reversal"
        echo "  - all              : Run all test phases"
        echo ""
        echo "Note: Available phases depend on the specific test cartridge implementation."
        echo "Use './run_test.sh -c <cartridge> <phase>' to run a specific test."
    fi
}