#!/bin/bash

# PICO-8 Automated Testing Framework Runner - Testable Version
# This version sources shared functions for better testability and maintainability

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

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


# Additional functions specific to the testable version:

# Function to run the test execution
run_test() {
    local cmd=$1
    local timeout=$2

    print_color $GREEN "Starting test execution..."
    echo "Press Ctrl+C to abort"
    echo ""

    # Execute with timeout
    timeout "$timeout" $cmd
    local exit_code=$?

    echo ""

    if [ $exit_code -eq 124 ]; then
        print_color $YELLOW "Test execution timed out after ${timeout} seconds"
    elif [ $exit_code -eq 0 ]; then
        print_color $GREEN "Test execution completed successfully"
    else
        print_color $RED "Test execution failed with exit code $exit_code"
    fi

    return $exit_code
}

# Main function
main() {
    # Parse arguments
    local parsed
    parsed=$(parse_arguments "$@")
    local exit_code=$?

    if [ $exit_code -ne 0 ]; then
        return $exit_code
    fi

    # Extract parsed values
    IFS='|' read -r PHASE TIMEOUT VERBOSE LIST_PHASES CART_FILE <<< "$parsed"

    # Validate timeout
    if ! validate_timeout "$TIMEOUT"; then
        return 1
    fi

    # Handle list phases option
    if [ "$LIST_PHASES" = "true" ]; then
        handle_list_subtests "$CART_FILE"
        return 0
    fi

    # Check prerequisites
    if ! check_pico8; then
        return 2
    fi

    if ! check_cartridge "$CART_FILE"; then
        return 3
    fi

    # Show configuration
    show_configuration "$CART_FILE" "$PHASE" "$TIMEOUT" "$VERBOSE"

    # Build command
    local CMD
    CMD=$(build_command "$CART_FILE" "$PHASE" "$TIMEOUT" "$VERBOSE")

    # Run the test
    run_test "$CMD" "$TIMEOUT"
}

# Only run main if not being sourced for testing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
    exit $?
fi