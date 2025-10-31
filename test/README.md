# Unit Testing for run_test.sh

This directory contains unit tests for the PICO-8 testing framework runner script.

## Overview

The testing framework provides:
- Unit tests for individual functions
- Integration tests for function interactions
- End-to-end tests for overall script behavior
- A simple test runner that works without external dependencies

## Test Structure

```
test/
├── test_runner.sh      # Main test runner script
├── test_functions.sh   # Unit tests for individual functions
├── test_integration.sh # Integration tests
├── test_e2e.sh         # End-to-end tests
└── README.md          # This file
```

## Running Tests

### Run All Tests
```bash
./test/test_runner.sh
```

### Run Specific Test Files
```bash
./test/test_runner.sh test/test_functions.sh
./test/test_runner.sh test/test_integration.sh test/test_e2e.sh
```

## Test Categories

### 1. Function Unit Tests (`test_functions.sh`)
Tests individual functions in isolation:
- `validate_timeout()` - timeout validation
- `check_cartridge()` - cartridge file existence
- `parse_arguments()` - command line argument parsing
- `build_command()` - PICO-8 command construction
- `check_pico8()` - PICO-8 availability

### 2. Integration Tests (`test_integration.sh`)
Tests how functions work together:
- Help and version output
- Configuration display
- List phases functionality
- Error handling scenarios
- Argument parsing edge cases

### 3. End-to-End Tests (`test_e2e.sh`)
Tests overall script behavior:
- Main function orchestration
- Error condition handling
- External dependency checking

## Test Framework

The test framework provides these assertion functions:

- `assert_equals expected actual [message]` - Test equality
- `assert_true condition [message]` - Test truthiness
- `assert_false condition [message]` - Test falsiness
- `assert_contains haystack needle [message]` - Test substring presence
- `assert_exit_code expected_code command [message]` - Test command exit codes

## Testable Script Version

The tests use `run_test_testable.sh` which is a refactored version of `run_test.sh` that:
- Extracts functions for individual testing
- Uses environment variables for colors (testable without terminal output)
- Returns exit codes instead of calling `exit` directly
- Separates parsing from execution logic

## Writing New Tests

### Basic Test Structure
```bash
#!/bin/bash

# Source the testable script
source ../run_test_testable.sh

echo "Testing my_function..."

# Test cases
result=$(my_function "input")
assert_equals "expected_output" "$result" "my_function should work correctly"

# More tests...
```

### Adding Test Files
1. Create `test/test_new_feature.sh`
2. Make it executable: `chmod +x test/test_new_feature.sh`
3. Add tests using the assertion functions
4. Run with: `./test/test_runner.sh test/test_new_feature.sh`

## Test Coverage

Current tests cover:
- ✅ Argument parsing (all options and edge cases)
- ✅ Timeout validation
- ✅ Cartridge file validation
- ✅ PICO-8 availability checking
- ✅ Command building
- ✅ Help and version output
- ✅ Configuration display
- ✅ List phases functionality
- ✅ Error handling and exit codes

## Limitations

- External command execution (PICO-8) is mocked for testing
- Some integration tests require temporary files
- Full end-to-end testing with actual PICO-8 execution would require a proper test environment

## Future Improvements

- Add Bats framework support for more advanced testing
- Add performance tests for command execution
- Add tests for different PICO-8 versions
- Add mock framework for better external command testing
- Add code coverage reporting

## Running Tests in CI/CD

To run tests in a CI environment:

```bash
cd lib/picotestdriver
./test/test_runner.sh
```

The test runner returns appropriate exit codes for CI integration.