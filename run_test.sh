#!/bin/bash

# PICO-8 Automated Testing Framework Runner
# Allows running specific test phases by passing parameters to PICO-8
# Version 1.0.0
#
# Usage: ./run_test.sh [phase] [timeout] [--help]
#   phase: Test phase name (default: all)
#   timeout: Seconds to run (default: 30)
#   --help: Show this help message
#
# Examples:
#   ./run_test.sh                    # Run all tests
#   ./run_test.sh movement_test      # Run movement tests only
#   ./run_test.sh collision_test 60  # Run collision tests with 60s timeout
#   ./run_test.sh --help             # Show help

# Configuration
SCRIPT_VERSION="1.0.0"
DEFAULT_TIMEOUT=30

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
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

# Function to check if PICO-8 is available
check_pico8() {
    if ! command -v pico8 &> /dev/null; then
        print_color $RED "Error: PICO-8 executable not found in PATH"
        echo "Please ensure PICO-8 is installed and accessible."
        exit 2
    fi
}

# Function to check if cartridge exists
check_cartridge() {
    local cart_file=$1
    if [ ! -f "$cart_file" ]; then
        print_color $RED "Error: Test cartridge '$cart_file' not found"
        exit 3
    fi
}

# Function to handle --list option
handle_list_phases() {
    local cart_file=$1
    print_color $BLUE "Available test phases in '$cart_file':"
    echo ""

    # Get the directory of the cartridge file
    local cart_dir
    cart_dir=$(dirname "$cart_file")

    # Collect all phases from cartridge and included files
    local all_phases=""
    local found_phases=false

    # First check the cartridge file itself
    local phases_line
    phases_line=$(grep -A 20 "test_init" "$cart_file" | grep "phases\s*=\s*{" | head -1)

    if [ -n "$phases_line" ]; then
        local phases_array
        phases_array=$(echo "$phases_line" | sed 's/.*phases\s*=\s*{//' | sed 's/}.*//')
        all_phases="$phases_array"
        found_phases=true
    fi

    # Then check included .lua files (excluding test_framework.lua and test_utils.lua)
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

    if [ "$found_phases" = true ]; then
        # Remove duplicates and split by comma and process each phase
        local unique_phases
        unique_phases=$(echo "$all_phases" | tr ',' '\n' | sort | uniq | tr '\n' ',' | sed 's/,$//')

        IFS=',' read -ra PHASE_ARRAY <<< "$unique_phases"

        for phase in "${PHASE_ARRAY[@]}"; do
            # Trim whitespace and quotes
            phase=$(echo "$phase" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sed 's/"//g' | sed "s/'//g")

            if [ -n "$phase" ]; then
                echo "  $phase - Test phase"
            fi
        done
    else
        print_color $YELLOW "No test_init function with phases found in cartridge or included files."
        echo "  all - Run all tests"
        echo ""
        print_color $YELLOW "Make sure your cartridge or included .lua files include a test_init call with a phases array."
    fi

    echo ""
    print_color $BLUE "Usage: $0 [-c CART_FILE] PHASE"
    print_color $BLUE "Example: $0 -c test_cart.p8 movement"
}

# Parse command line arguments
PHASE="all"
TIMEOUT=$DEFAULT_TIMEOUT
VERBOSE=false
LIST_PHASES=false
CART_FILE="test_cart.p8"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "PICO-8 Test Framework Runner v${SCRIPT_VERSION}"
            exit 0
            ;;
        -c|--cart)
            CART_FILE="$2"
            shift
            shift
            ;;
        -l|--list)
            LIST_PHASES=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        *)
            # Check if it's a timeout value (number)
            if [[ $1 =~ ^[0-9]+$ ]]; then
                TIMEOUT=$1
            else
                PHASE=$1
            fi
            shift
            ;;
    esac
done

# Validate timeout
if ! [[ $TIMEOUT =~ ^[0-9]+$ ]] || [ $TIMEOUT -le 0 ]; then
    print_color $RED "Error: Invalid timeout '$TIMEOUT'. Must be a positive integer."
    exit 1
fi

# Check prerequisites
check_pico8
check_cartridge "$CART_FILE"

# Handle list phases option
if $LIST_PHASES; then
    handle_list_phases "$CART_FILE"
    exit 0
fi

# Show configuration
print_color $BLUE "=== PICO-8 Test Framework Runner v${SCRIPT_VERSION} ==="
echo "Cartridge: $CART_FILE"
echo "Phase: $PHASE"
echo "Timeout: ${TIMEOUT}s"
if $VERBOSE; then
    echo "Verbose: enabled"
fi
echo ""

# Build command
CMD="pico8 -run $CART_FILE"

if [ "$PHASE" != "all" ]; then
    CMD="$CMD -p $PHASE"
fi

if $VERBOSE; then
    print_color $YELLOW "Command: $CMD"
    echo ""
fi

# Run the test
print_color $GREEN "Starting test execution..."
echo "Press Ctrl+C to abort"
echo ""

# Execute with timeout
timeout "$TIMEOUT" $CMD

# Check exit code
EXIT_CODE=$?
echo ""

if [ $EXIT_CODE -eq 124 ]; then
    print_color $YELLOW "Test execution timed out after ${TIMEOUT} seconds"
elif [ $EXIT_CODE -eq 0 ]; then
    print_color $GREEN "Test execution completed successfully"
else
    print_color $RED "Test execution failed with exit code $EXIT_CODE"
fi

exit $EXIT_CODE