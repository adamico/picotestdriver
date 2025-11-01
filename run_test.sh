#!/bin/bash

# PICO-8 Automated Testing Framework Runner
# Allows running specific test phases by passing parameters to PICO-8
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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/VERSION"

# Read version from VERSION file if it exists, otherwise use fallback
if [ -f "$VERSION_FILE" ]; then
    SCRIPT_VERSION=$(cat "$VERSION_FILE")
else
    SCRIPT_VERSION="1.0.0"
fi

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
    ./run_test.sh [OPTIONS] [SUBTEST] [TIMEOUT]

ARGUMENTS:
    SUBTEST     Test subtest to run (default: all)
                Common subtests: movement, collision, input, boundary
    TIMEOUT     Maximum runtime in seconds (default: ${DEFAULT_TIMEOUT})

OPTIONS:
    -h, --help      Show this help message
    -c, --cart      Specify the test cartridge file (default: test_cart.p8)
    -d, --demo      Run the demo test cartridge (test_cart.p8 from this directory)
    -l, --list      List available test subtests (requires cartridge)
    -v, --version   Show version information
    --verbose       Enable verbose output

EXAMPLES:
    ./run_test.sh -d
        Run the demo test cartridge

    ./run_test.sh -c my_test.p8
        Run tests in my_test.p8 cartridge

    ./run_test.sh -c my_test.p8 movement_test
        Run only movement tests

    ./run_test.sh -c my_test.p8 collision_test 60
        Run collision tests with 60 second timeout

    ./run_test.sh -c my_test.p8 --list
        List all available test subtests

GETTING STARTED:
    Generate test files for your project:
        ./generate_test.sh -d tests -n my_game_test

    Then run your tests:
        ./run_test.sh -c tests/my_game_test.p8

    See 'generate_test.sh --help' for more options.

REQUIREMENTS:
    - PICO-8 executable must be in PATH
    - Test cartridge must include test_framework.lua

EXIT CODES:
    0   Success
    1   Invalid arguments
    2   PICO-8 not found
    3   Test cartridge not found
    124 Timeout reached

For more information, visit: https://github.com/adamico/picotestdriver
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
handle_list_subtests() {
    local cart_file=$1
    print_color $BLUE "Available test subtests in '$cart_file':"
    echo ""

    # Get the directory of the cartridge file
    local cart_dir
    cart_dir=$(dirname "$cart_file")

    # Collect all subtests from cartridge and included files
    local all_subtests=""
    local found_subtests=false

    # Function to extract subtest names from a file
    extract_subtests() {
        local file=$1
        # Look for: local subtests = { followed by { name = "xxx", ... } entries
        # Extract subtest names from table definitions
        local names
        names=$(awk '/local subtests\s*=\s*\{/,/^\}/ {
            if ($0 ~ /name\s*=\s*"[^"]+"|name\s*=\s*'\''[^'\'']+'\''/) {
                match($0, /(name\s*=\s*["'\''])([^"'\'']+)(["'\''])/, arr)
                if (arr[2] != "") print arr[2]
            }
        }' "$file")
        echo "$names"
    }

    # First check the cartridge file itself
    local cart_subtests
    cart_subtests=$(extract_subtests "$cart_file")
    if [ -n "$cart_subtests" ]; then
        all_subtests="$cart_subtests"
        found_subtests=true
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

    if [ "$found_subtests" = true ]; then
        # Remove duplicates and sort
        local unique_subtests
        unique_subtests=$(echo "$all_subtests" | sort | uniq)

        while IFS= read -r subtest; do
            if [ -n "$subtest" ]; then
                echo "  $subtest"
            fi
        done <<< "$unique_subtests"
    else
        print_color $YELLOW "No local subtests table found in cartridge or included files."
        echo "  all"
        echo ""
        print_color $YELLOW "Make sure your test file includes: local subtests = { { name = \"test_name\", ... }, ... }"
    fi

    echo ""
    print_color $BLUE "Usage: $0 [-c CART_FILE] SUBTEST"
    print_color $BLUE "Example: $0 -c test_cart.p8 movement"
}

# Parse command line arguments
SUBTEST="all"
TIMEOUT=$DEFAULT_TIMEOUT
VERBOSE=false
LIST_SUBTESTS=false
CART_FILE=""
DEMO_MODE=false
ARGS_PROVIDED=$#

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "PicoTestDriver v${SCRIPT_VERSION}"
            exit 0
            ;;
        -c|--cart)
            CART_FILE="$2"
            shift
            shift
            ;;
        -d|--demo)
            DEMO_MODE=true
            CART_FILE="$SCRIPT_DIR/test_cart.p8"
            shift
            ;;
        -l|--list)
            LIST_SUBTESTS=true
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
                SUBTEST=$1
            fi
            shift
            ;;
    esac
done

# Show usage if no arguments provided
if [ $ARGS_PROVIDED -eq 0 ]; then
    print_color $YELLOW "No arguments provided."
    echo ""
    echo "Usage: $0 [OPTIONS] [SUBTEST] [TIMEOUT]"
    echo ""
    echo "Quick start:"
    echo "  $0 -d                         Run the demo test cartridge"
    echo "  $0 -c my_test.p8              Run tests from your cartridge"
    echo "  $0 --help                     Show full help"
    echo ""
    echo "New to testing? Generate test files:"
    echo "  ./generate_test.sh -d tests -n my_game_test"
    echo ""
    exit 1
fi

# Set default cartridge if none specified and not in demo mode
if [ -z "$CART_FILE" ]; then
    CART_FILE="test_cart.p8"
fi

# Validate timeout
if ! [[ $TIMEOUT =~ ^[0-9]+$ ]] || [ $TIMEOUT -le 0 ]; then
    print_color $RED "Error: Invalid timeout '$TIMEOUT'. Must be a positive integer."
    exit 1
fi

# Check prerequisites
check_pico8
check_cartridge "$CART_FILE"

# Handle list subtests option
if $LIST_SUBTESTS; then
    handle_list_subtests "$CART_FILE"
    exit 0
fi

# Show configuration
print_color $BLUE "=== PicoTestDriver v${SCRIPT_VERSION} ==="
echo "Cartridge: $CART_FILE"
echo "Subtest: $SUBTEST"
echo "Timeout: ${TIMEOUT}s"
if $VERBOSE; then
    echo "Verbose: enabled"
fi
echo ""

# Build command
CMD="pico8 -run $CART_FILE"

if [ "$SUBTEST" != "all" ]; then
    CMD="$CMD -p $SUBTEST"
fi

# Pass timeout to PICO-8 as a parameter (SUBTEST:TIMEOUT format)
if [ "$SUBTEST" != "all" ]; then
    CMD="pico8 -run $CART_FILE -p ${SUBTEST}:${TIMEOUT}"
else
    CMD="pico8 -run $CART_FILE -p timeout:${TIMEOUT}"
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