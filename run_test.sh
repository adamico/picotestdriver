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