# Shared Functions Library

## Overview

The `lib/test_functions.sh` file contains shared functions used across PicoTestDriver. This prevents code duplication and desync errors between different components.

## Architecture

```
lib/picotestdriver/
├── lib/
│   └── test_functions.sh     # Shared function library
├── run_test.sh               # Main test runner (sources lib)
├── run_test_testable.sh      # Testable version (sources lib)
└── test/
    ├── test_helper.sh        # Test utilities (sources lib)
    └── test_*.sh             # Individual test files
```

## Sourcing the Library

```bash
# Get the directory of your script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"  # or adjust path as needed

# Source the shared functions library
source "$LIB_DIR/test_functions.sh"
```

## Available Functions

### Core Functions

- `print_color(color, message)` - Print colored output
- `validate_timeout(timeout)` - Validate timeout value
- `check_cartridge(cart_file)` - Check if cartridge exists
- `check_pico8()` - Check if PICO-8 is available

### Command Building

- `parse_arguments(args...)` - Parse command line arguments
  - Returns: `"phase|timeout|verbose|list_phases|cart_file"`
- `build_command(cart_file, phase, timeout, verbose)` - Build PICO-8 command
  - **Key Feature**: Passes timeout to PICO-8 via `-p phase:timeout` format

### Display Functions

- `show_help()` - Show help message
- `show_configuration(cart_file, phase, timeout, verbose)` - Show configuration
- `handle_list_phases(cart_file)` - Handle list phases option

## Timeout Parameter Feature

The `build_command` function implements timeout passing to PICO-8:

```bash
# For specific phases
pico8 -run test.p8 -p tap_test:30

# For "all" phases
pico8 -run test.p8 -p timeout:30
```

The test framework's `test_framework.lua` parses this format and uses it to:
1. Set timeout frames automatically (seconds × 60)
2. Call `stop()` when timeout is reached
3. Make timeout value available to test cartridges

## Benefits

### 1. Single Source of Truth
- Functions defined once in `lib/test_functions.sh`
- No code duplication between runner and tests
- Changes propagate automatically to all components

### 2. Prevents Desync Errors
- Before: `run_test_testable.sh`, `test_helper.sh`, and `run_test.sh` had duplicate functions
- After: All source the same library
- Function signature changes only need to be made once

### 3. Easier Testing
- Test suite uses same functions as production code
- Confidence that tests validate actual behavior
- Simplified test maintenance

### 4. Better Maintainability
- Clear separation of concerns
- Easy to add new shared functions
- Consistent behavior across components

## Adding New Shared Functions

1. Add function to `lib/test_functions.sh`
2. Document it in this file
3. Update components that need it (they already source the library)
4. Add tests in `test/test_functions.sh` or create new test file

Example:

```bash
# In lib/test_functions.sh
my_new_function() {
    local param=$1
    # Implementation
    echo "result"
}

# Automatically available in:
# - run_test.sh
# - run_test_testable.sh  
# - test/test_helper.sh
# - All test files (via test_helper.sh)
```

## Testing

The test suite validates all shared functions:

```bash
./test/test_runner.sh
```

Key test files:
- `test/test_functions.sh` - Tests core functions
- `test/test_timeout_param.sh` - Tests timeout parameter feature
- `test/test_integration.sh` - Tests function interactions

## Version History

- **v1.0.0** - Initial extraction of shared functions
  - Extracted common functions from duplicated code
  - Implemented timeout parameter passing
  - Added comprehensive test coverage
