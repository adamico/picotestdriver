#!/bin/bash

# PICO-8 Test File Generator
# Generates test.p8 cartridge and test.lua files with boilerplate code

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

show_help() {
    cat << EOF
PICO-8 Test File Generator

Generates test cartridge and test file with boilerplate code.

USAGE:
    ./generate_test.sh [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -d, --dir DIR           Output directory (default: current directory)
    -n, --name NAME         Test file base name (default: test)
    -s, --subtests LIST     Comma-separated list of subtest names
                           (default: movement,collision,input,boundary)
    -t, --timeout SECONDS   Default timeout in seconds (default: 30)
    --framework-path PATH   Path to test_framework.lua (default: ../lib/picotestdriver/test_framework.lua)

EXAMPLES:
    ./generate_test.sh
        Generate test files in current directory with defaults

    ./generate_test.sh -d tests -n my_test
        Generate my_test.p8 and my_test.lua in tests/ directory

    ./generate_test.sh -s "player,enemy,bullet" -t 60
        Generate test files with custom subtests and 60s timeout

    ./generate_test.sh --framework-path ./test_framework.lua
        Use custom path to test framework

GENERATED FILES:
    {name}.p8       - PICO-8 cartridge with #include statements
    {name}.lua      - Test implementation with subtest boilerplate

EOF
}

# Default values
OUTPUT_DIR="."
TEST_NAME="test"
SUBTESTS="movement,collision,input,boundary"
TIMEOUT=30
FRAMEWORK_PATH="../lib/picotestdriver/test_framework.lua"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -n|--name)
            TEST_NAME="$2"
            shift 2
            ;;
        -s|--subtests)
            SUBTESTS="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --framework-path)
            FRAMEWORK_PATH="$2"
            shift 2
            ;;
        *)
            print_color $RED "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate timeout
if ! [[ $TIMEOUT =~ ^[0-9]+$ ]] || [ $TIMEOUT -le 0 ]; then
    print_color $RED "Error: Invalid timeout '$TIMEOUT'. Must be a positive integer."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# File paths
P8_FILE="$OUTPUT_DIR/${TEST_NAME}.p8"
LUA_FILE="$OUTPUT_DIR/${TEST_NAME}.lua"

print_color $BLUE "=== PICO-8 Test File Generator ==="
echo "Output directory: $OUTPUT_DIR"
echo "Test name: $TEST_NAME"
echo "Subtests: $SUBTESTS"
echo "Timeout: ${TIMEOUT}s"
echo "Framework path: $FRAMEWORK_PATH"
echo ""

# Check if files already exist
if [ -f "$P8_FILE" ]; then
    print_color $YELLOW "Warning: $P8_FILE already exists. Overwrite? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_color $YELLOW "Aborted."
        exit 0
    fi
fi

if [ -f "$LUA_FILE" ]; then
    print_color $YELLOW "Warning: $LUA_FILE already exists. Overwrite? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_color $YELLOW "Aborted."
        exit 0
    fi
fi

# Generate .p8 cartridge file
print_color $GREEN "Generating $P8_FILE..."
cat > "$P8_FILE" << EOF
pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- ${TEST_NAME}.p8
-- generated test cartridge

#include ${FRAMEWORK_PATH}
#include ${TEST_NAME}.lua

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
EOF

print_color $GREEN "✓ Created $P8_FILE"

# Generate .lua test file
print_color $GREEN "Generating $LUA_FILE..."

# Build subtest table
SUBTEST_TABLE=""
IFS=',' read -ra SUBTEST_ARRAY <<< "$SUBTESTS"
for subtest in "${SUBTEST_ARRAY[@]}"; do
    subtest=$(echo "$subtest" | xargs)  # trim whitespace
    SUBTEST_TABLE="${SUBTEST_TABLE}  { name = \"${subtest}\", duration = 180 },  -- 3 seconds\n"
done

# Build subtest function stubs
SUBTEST_FUNCTIONS=""
for subtest in "${SUBTEST_ARRAY[@]}"; do
    subtest=$(echo "$subtest" | xargs)
    SUBTEST_FUNCTIONS="${SUBTEST_FUNCTIONS}
function test_${subtest}(frame)
  if frame == 1 then
    test_log(\"=== ${subtest^^} TEST ===\", \"info\")
    -- Initialize test
  end
  
  if frame == 30 then
    -- Test at frame 30 (0.5 seconds)
    test_log(\"✓ ${subtest^^}: Test placeholder\", \"info\")
  end
  
  if frame >= subtests[current_subtest].duration then
    next_subtest()
  end
end
"
done

# Build subtest dispatch in _update60
SUBTEST_DISPATCH=""
first=true
for subtest in "${SUBTEST_ARRAY[@]}"; do
    subtest=$(echo "$subtest" | xargs)
    if [ "$first" = true ]; then
        SUBTEST_DISPATCH="${SUBTEST_DISPATCH}  if subtest.name == \"${subtest}\" then\n"
        SUBTEST_DISPATCH="${SUBTEST_DISPATCH}    test_${subtest}(subtest_frame)\n"
        first=false
    else
        SUBTEST_DISPATCH="${SUBTEST_DISPATCH}  elseif subtest.name == \"${subtest}\" then\n"
        SUBTEST_DISPATCH="${SUBTEST_DISPATCH}    test_${subtest}(subtest_frame)\n"
    fi
done
SUBTEST_DISPATCH="${SUBTEST_DISPATCH}  end"

cat > "$LUA_FILE" << EOF
-- ${TEST_NAME}.lua
-- Automated tests for your PICO-8 project
-- Generated by picotestdriver test file generator

-- Test state
local test_frame = 0
local current_subtest = 1
local subtest_start_frame = 0

-- Subtest definitions
local subtests = {
$(echo -e "$SUBTEST_TABLE")}

function _init()
  test_log("=== AUTOMATED TEST SUITE ===", "info")
  
  -- Build subtest names list for test_init
  local subtest_names = {}
  for i = 1, #subtests do
    subtest_names[i] = subtests[i].name
  end
  
  test_init({
    subtests = subtest_names,
    timeout_frames = $(($TIMEOUT * 60)),  -- ${TIMEOUT} seconds
    debug_level = "info",
  })
  
  test_frame = 0
  
  -- Find which subtest to start with based on command line
  local requested_subtest = test_get_subtest()
  current_subtest = 1
  
  if requested_subtest ~= "default" and requested_subtest ~= "all" then
    -- Find the requested subtest
    local found = false
    for i = 1, #subtests do
      if subtests[i].name == requested_subtest then
        current_subtest = i
        found = true
        break
      end
    end
    
    if not found then
      test_log("Requested subtest '" .. requested_subtest .. "' not found, running all", "warn")
      current_subtest = 1
    end
  end
  
  subtest_start_frame = 0
  
  test_log("Starting subtest: " .. subtests[current_subtest].name, "info")
end

function _update60()
  test_update_frame()
  test_frame += 1
  
  -- Get current subtest
  local subtest = subtests[current_subtest]
  if not subtest then
    return -- All tests complete
  end
  
  local subtest_frame = test_frame - subtest_start_frame
  
  -- Run current subtest
$(echo -e "$SUBTEST_DISPATCH")
end

function _draw()
  cls(1)

  -- Test info
  local subtest = subtests[current_subtest]
  local subtest_name = subtest and subtest.name or "COMPLETE"
  local subtest_frame = test_frame - subtest_start_frame
  
  print("AUTOMATED TEST SUITE", 2, 2, 7)
  print("TEST: " .. subtest_name, 2, 10, 7)
  print("FRAME: " .. subtest_frame, 2, 18, 7)
  print("(" .. current_subtest .. "/" .. #subtests .. ")", 60, 18, 6)
  
  if not subtest then
    print("ALL TESTS DONE!", 30, 60, 11)
  else
    print("RUNNING...", 2, 26, 8)
  end
end

-- Helper functions
function next_subtest()
  local requested_subtest = test_get_subtest()
  
  -- If running a specific subtest, stop after it completes
  if requested_subtest ~= "default" and requested_subtest ~= "all" then
    test_log("Subtest '" .. requested_subtest .. "' complete!", "info")
    test_complete("Subtest complete")
    return
  end
  
  -- Otherwise, advance to next subtest
  current_subtest += 1
  subtest_start_frame = test_frame
  
  if current_subtest <= #subtests then
    test_log("Advancing to subtest: " .. subtests[current_subtest].name, "info")
  else
    test_log("All subtests complete!", "info")
    test_complete("All subtests complete")
  end
end

-- Test functions
$(echo -e "$SUBTEST_FUNCTIONS")
EOF

print_color $GREEN "✓ Created $LUA_FILE"

echo ""
print_color $BLUE "=== Generation Complete! ==="
echo ""
echo "Next steps:"
echo "  1. Edit $LUA_FILE to implement your tests"
echo "  2. Run tests with: ./run_test.sh -c $P8_FILE"
echo "  3. Run specific subtest: ./run_test.sh -c $P8_FILE <subtest_name>"
echo "  4. List subtests: ./run_test.sh -c $P8_FILE --list"
echo ""
print_color $GREEN "Happy testing!"
