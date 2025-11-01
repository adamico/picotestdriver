#!/bin/bash

# Tests for generate_test.sh script
# Note: test_helper.sh is sourced by the test runner

echo "Testing test generator script..."

# Test directory for generated files
TEST_GEN_DIR="/tmp/picotestdriver_generator_test_$$"

# Cleanup function
cleanup_test_dir() {
    rm -rf "$TEST_GEN_DIR"
}

# Ensure cleanup on exit
trap cleanup_test_dir EXIT

echo
echo "Testing generator script existence and permissions..."

# Test that generator script exists
if [ -f "./generate_test.sh" ]; then
    assert_true 0 "generate_test.sh should exist"
else
    assert_true 1 "generate_test.sh should exist"
fi

# Test that generator is executable
if [ -x "./generate_test.sh" ]; then
    assert_true 0 "generate_test.sh should be executable"
else
    assert_true 1 "generate_test.sh should be executable"
fi

echo
echo "Testing basic file generation..."

# Test generating files with defaults
mkdir -p "$TEST_GEN_DIR"
./generate_test.sh -d "$TEST_GEN_DIR" -n basic_test -s "test1,test2" -t 10 --framework-path test_framework.lua > /dev/null 2>&1
exit_code=$?

assert_equals "0" "$exit_code" "generator should exit with code 0"

# Test that .p8 file was created
if [ -f "$TEST_GEN_DIR/basic_test.p8" ]; then
    assert_true 0 "should create .p8 cartridge file"
else
    assert_true 1 "should create .p8 cartridge file"
fi

# Test that .lua file was created
if [ -f "$TEST_GEN_DIR/basic_test.lua" ]; then
    assert_true 0 "should create .lua test file"
else
    assert_true 1 "should create .lua test file"
fi

echo
echo "Testing .p8 cartridge file content..."

if [ -f "$TEST_GEN_DIR/basic_test.p8" ]; then
    p8_content=$(cat "$TEST_GEN_DIR/basic_test.p8")
    
    # Test for pico-8 header
    assert_contains "$p8_content" "pico-8 cartridge" ".p8 should contain pico-8 header"
    
    # Test for #include statements
    assert_contains "$p8_content" "#include test_framework.lua" ".p8 should include test_framework.lua"
    assert_contains "$p8_content" "#include basic_test.lua" ".p8 should include test file"
    
    # Test for graphics section
    assert_contains "$p8_content" "__gfx__" ".p8 should contain graphics section"
fi

echo
echo "Testing .lua test file content..."

if [ -f "$TEST_GEN_DIR/basic_test.lua" ]; then
    lua_content=$(cat "$TEST_GEN_DIR/basic_test.lua")
    
    # Test for required functions
    assert_contains "$lua_content" "function _init()" ".lua should contain _init function"
    assert_contains "$lua_content" "function _update60()" ".lua should contain _update60 function"
    assert_contains "$lua_content" "function _draw()" ".lua should contain _draw function"
    
    # Test for test framework integration
    assert_contains "$lua_content" "test_init(" ".lua should call test_init"
    assert_contains "$lua_content" "test_update_frame()" ".lua should call test_update_frame"
    assert_contains "$lua_content" "test_log(" ".lua should use test_log"
    
    # Test for subtests array
    assert_contains "$lua_content" "local subtests = {" ".lua should define subtests array"
    assert_contains "$lua_content" 'name = "test1"' ".lua should include test1 subtest"
    assert_contains "$lua_content" 'name = "test2"' ".lua should include test2 subtest"
    
    # Test for timeout configuration
    assert_contains "$lua_content" "timeout_frames = 600" ".lua should set timeout to 600 frames (10s)"
    
    # Test for test functions
    assert_contains "$lua_content" "function test_test1(frame)" ".lua should define test_test1 function"
    assert_contains "$lua_content" "function test_test2(frame)" ".lua should define test_test2 function"
    
    # Test for next_subtest helper
    assert_contains "$lua_content" "function next_subtest()" ".lua should define next_subtest helper"
    
    # Test for subtest completion logic
    assert_contains "$lua_content" "test_complete(" ".lua should call test_complete"
fi

echo
echo "Testing custom subtest generation..."

# Clean up and regenerate with different subtests
rm -rf "$TEST_GEN_DIR"
mkdir -p "$TEST_GEN_DIR"
./generate_test.sh -d "$TEST_GEN_DIR" -n custom_test -s "player,enemy,bullet,collision" -t 30 --framework-path test_framework.lua > /dev/null 2>&1

if [ -f "$TEST_GEN_DIR/custom_test.lua" ]; then
    custom_content=$(cat "$TEST_GEN_DIR/custom_test.lua")
    
    # Test for all custom subtests
    assert_contains "$custom_content" 'name = "player"' "should include player subtest"
    assert_contains "$custom_content" 'name = "enemy"' "should include enemy subtest"
    assert_contains "$custom_content" 'name = "bullet"' "should include bullet subtest"
    assert_contains "$custom_content" 'name = "collision"' "should include collision subtest"
    
    # Test for custom timeout (30s = 1800 frames)
    assert_contains "$custom_content" "timeout_frames = 1800" "should set custom timeout to 1800 frames (30s)"
    
    # Test for corresponding test functions
    assert_contains "$custom_content" "function test_player(frame)" "should define test_player function"
    assert_contains "$custom_content" "function test_enemy(frame)" "should define test_enemy function"
    assert_contains "$custom_content" "function test_bullet(frame)" "should define test_bullet function"
    assert_contains "$custom_content" "function test_collision(frame)" "should define test_collision function"
fi

echo
echo "Testing subtest dispatch logic..."

if [ -f "$TEST_GEN_DIR/custom_test.lua" ]; then
    custom_content=$(cat "$TEST_GEN_DIR/custom_test.lua")
    
    # Test for if/elseif dispatch structure
    assert_contains "$custom_content" 'if subtest.name == "player"' "should dispatch player subtest"
    assert_contains "$custom_content" 'elseif subtest.name == "enemy"' "should dispatch enemy subtest"
    assert_contains "$custom_content" 'elseif subtest.name == "bullet"' "should dispatch bullet subtest"
    assert_contains "$custom_content" 'elseif subtest.name == "collision"' "should dispatch collision subtest"
fi

echo
echo "Testing invalid timeout handling..."

# Test with invalid timeout (should fail)
rm -rf "$TEST_GEN_DIR"
mkdir -p "$TEST_GEN_DIR"
./generate_test.sh -d "$TEST_GEN_DIR" -n invalid_test -t 0 --framework-path test_framework.lua > /dev/null 2>&1
exit_code=$?

assert_equals "1" "$exit_code" "generator should reject zero timeout"

# Test with non-numeric timeout
./generate_test.sh -d "$TEST_GEN_DIR" -n invalid_test -t abc --framework-path test_framework.lua > /dev/null 2>&1
exit_code=$?

assert_equals "1" "$exit_code" "generator should reject non-numeric timeout"

echo
echo "Testing help option..."

# Test that help displays without errors
help_output=$(./generate_test.sh --help 2>&1)
exit_code=$?

assert_equals "0" "$exit_code" "generator --help should exit with code 0"
assert_contains "$help_output" "USAGE:" "help should contain usage section"
assert_contains "$help_output" "OPTIONS:" "help should contain options section"
assert_contains "$help_output" "EXAMPLES:" "help should contain examples section"
assert_contains "$help_output" "--subtests" "help should document --subtests option"
assert_contains "$help_output" "--timeout" "help should document --timeout option"
assert_contains "$help_output" "--framework-path" "help should document --framework-path option"

echo
echo "Testing subtest-specific test structure..."

if [ -f "$TEST_GEN_DIR/custom_test.lua" ]; then
    custom_content=$(cat "$TEST_GEN_DIR/custom_test.lua")
    
    # Test that each test function has proper structure
    # Should have frame == 1 initialization
    assert_contains "$custom_content" "if frame == 1 then" "test functions should check frame == 1"
    
    # Should have test logging
    assert_contains "$custom_content" 'test_log("===' "test functions should log test name"
    
    # Should have frame check for test execution
    assert_contains "$custom_content" "if frame == 30 then" "test functions should have test execution frame"
    
    # Should have duration check
    assert_contains "$custom_content" "if frame >= subtests[current_subtest].duration then" "test functions should check duration"
    
    # Should call next_subtest
    assert_contains "$custom_content" "next_subtest()" "test functions should call next_subtest"
fi

echo
echo "Testing requested subtest selection logic..."

if [ -f "$TEST_GEN_DIR/custom_test.lua" ]; then
    custom_content=$(cat "$TEST_GEN_DIR/custom_test.lua")
    
    # Test for command line subtest selection
    assert_contains "$custom_content" "local requested_subtest = test_get_subtest()" "should get requested subtest from command line"
    
    # Test for subtest finding logic
    assert_contains "$custom_content" 'if requested_subtest ~= "default" and requested_subtest ~= "all"' "should check for specific subtest request"
    
    # Test for subtest search loop
    assert_contains "$custom_content" "for i = 1, #subtests do" "should search through subtests"
    assert_contains "$custom_content" "if subtests[i].name == requested_subtest then" "should match requested subtest"
    
    # Test for not found handling
    assert_contains "$custom_content" "if not found then" "should handle subtest not found"
fi

echo
echo "Testing next_subtest function logic..."

if [ -f "$TEST_GEN_DIR/custom_test.lua" ]; then
    custom_content=$(cat "$TEST_GEN_DIR/custom_test.lua")
    
    # Test for specific subtest mode handling
    assert_contains "$custom_content" 'if requested_subtest ~= "default" and requested_subtest ~= "all" then' "next_subtest should handle specific subtest mode"
    assert_contains "$custom_content" 'test_complete("Subtest complete")' "next_subtest should complete after single subtest"
    
    # Test for advancing logic
    assert_contains "$custom_content" "current_subtest += 1" "next_subtest should increment counter"
    assert_contains "$custom_content" "subtest_start_frame = test_frame" "next_subtest should reset frame counter"
    
    # Test for completion check
    assert_contains "$custom_content" "if current_subtest <= #subtests then" "next_subtest should check for more subtests"
    assert_contains "$custom_content" 'test_complete("All subtests complete")' "next_subtest should complete when done"
fi

echo
echo "All generator tests completed!"
