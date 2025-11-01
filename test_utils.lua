-- PicoTestDriver Test Utilities
-- Helper functions for common testing patterns

-- Input simulation utilities
-- PICO-8's btn() function reads hardware state directly, so we can't override it.
-- Instead, provide utilities to help create testable input systems.

-- Button state tracker for custom input systems
local btn_state_override = {}

function test_set_button_state(button, pressed)
    -- Store button state for games that use custom input wrappers
    -- Usage in game code:
    --   function my_btn(b)
    --       if test_get_button_state then
    --           local override = test_get_button_state(b)
    --           if override ~= nil then return override end
    --       end
    --       return btn(b)
    --   end
    btn_state_override[button] = pressed and true or false
    test_log("Button " .. button .. " " .. (pressed and "pressed" or "released"), "debug")
end

function test_get_button_state(button)
    -- Games can query this to get overridden button state
    -- Returns nil if no override set (use real btn())
    return btn_state_override[button]
end

function test_clear_button_states()
    -- Clear all button state overrides
    btn_state_override = {}
end

-- Example: Simulating a button sequence
-- function test_simulate_button_sequence(button, press_frames, release_frames)
--     test_set_button_state(button, true)
--     test_wait_frames(press_frames, function()
--         test_set_button_state(button, false)
--         test_wait_frames(release_frames, function()
--             test_log("Button sequence complete", "debug")
--         end)
--     end)
-- end

-- Frame-based waiting (cooperative with main loop)
local wait_frames_remaining = 0
local wait_callback = nil

function test_wait_frames(count, callback)
    wait_frames_remaining = count
    wait_callback = callback
    test_log("Waiting for " .. count .. " frames", "debug")
end

function test_update_wait()
    if wait_frames_remaining > 0 then
        wait_frames_remaining = wait_frames_remaining - 1
        if wait_frames_remaining == 0 and wait_callback then
            wait_callback()
            wait_callback = nil
        end
        return true  -- Still waiting
    end
    return false  -- Not waiting
end

-- Assertion helpers
function test_assert(condition, message)
    if not condition then
        test_log("ASSERTION FAILED: " .. (message or "No message"), "error")
        return false
    else
        test_log("Assertion passed: " .. (message or "No message"), "debug")
        return true
    end
end

function test_assert_equal(actual, expected, message)
    if actual ~= expected then
        test_log("ASSERTION FAILED: Expected " .. tostr(expected) .. ", got " .. tostr(actual) ..
                (message and " - " .. message or ""), "error")
        return false
    else
        test_log("Assertion passed: " .. tostr(actual) .. " == " .. tostr(expected), "debug")
        return true
    end
end

function test_assert_not_equal(actual, unexpected, message)
    if actual == unexpected then
        test_log("ASSERTION FAILED: Expected not " .. tostr(unexpected) .. ", got " .. tostr(actual) ..
                (message and " - " .. message or ""), "error")
        return false
    else
        test_log("Assertion passed: " .. tostr(actual) .. " != " .. tostr(unexpected), "debug")
        return true
    end
end

function test_assert_true(condition, message)
    return test_assert(condition, message or "Expected true")
end

function test_assert_false(condition, message)
    return test_assert(not condition, message or "Expected false")
end

function test_assert_nil(value, message)
    return test_assert(value == nil, message or "Expected nil")
end

function test_assert_not_nil(value, message)
    return test_assert(value ~= nil, message or "Expected not nil")
end

-- Range assertions
function test_assert_in_range(value, min_val, max_val, message)
    local in_range = value >= min_val and value <= max_val
    if not in_range then
        test_log("ASSERTION FAILED: Value " .. tostr(value) .. " not in range [" ..
                tostr(min_val) .. ", " .. tostr(max_val) .. "]" ..
                (message and " - " .. message or ""), "error")
        return false
    else
        test_log("Assertion passed: " .. tostr(value) .. " in range [" ..
                tostr(min_val) .. ", " .. tostr(max_val) .. "]", "debug")
        return true
    end
end

-- Approximate equality for floating point
function test_assert_approx_equal(actual, expected, tolerance, message)
    tolerance = tolerance or 0.01
    local diff = abs(actual - expected)
    if diff > tolerance then
        test_log("ASSERTION FAILED: Expected approx " .. tostr(expected) ..
                ", got " .. tostr(actual) .. " (diff: " .. tostr(diff) .. ")" ..
                (message and " - " .. message or ""), "error")
        return false
    else
        test_log("Assertion passed: " .. tostr(actual) .. " ≈ " .. tostr(expected), "debug")
        return true
    end
end

-- Test timing helpers
local test_start_time = 0
local test_end_time = 0

function test_start_timer()
    test_start_time = test_get_frame_count()
    test_log("Test timer started at frame " .. test_start_time, "debug")
end

function test_end_timer()
    test_end_time = test_get_frame_count()
    local duration = test_end_time - test_start_time
    test_log("Test timer ended at frame " .. test_end_time .. " (duration: " .. duration .. " frames)", "info")
    return duration
end

-- Performance testing
function test_measure_performance(test_func, iterations, name)
    name = name or "performance test"
    test_log("Starting performance test: " .. name, "info")

    local start_time = test_get_frame_count()
    for i = 1, iterations do
        test_func()
    end
    local end_time = test_get_frame_count()
    local total_frames = end_time - start_time
    local avg_frames = total_frames / iterations

    test_log("Performance test '" .. name .. "' completed:", "info")
    test_log("  Iterations: " .. iterations, "info")
    test_log("  Total frames: " .. total_frames, "info")
    test_log("  Avg frames/iteration: " .. tostr(avg_frames), "info")

    return {
        iterations = iterations,
        total_frames = total_frames,
        avg_frames = avg_frames
    }
end

-- Memory usage logging using PICO-8's stat(0)
-- stat(0) returns Lua memory usage in bytes
function test_log_memory_usage(label)
    local mem_bytes = stat(0)
    local mem_kb = flr(mem_bytes / 1024 * 10) / 10  -- Round to 1 decimal
    test_log("Memory: " .. mem_kb .. "kb (" .. (label or "current") .. ")", "debug")
end

-- CPU usage logging using PICO-8's stat(1)
-- stat(1) returns CPU usage (1.0 = 100%)
function test_log_cpu_usage(label)
    local cpu = stat(1)
    local cpu_pct = flr(cpu * 1000) / 10  -- Convert to percentage with 1 decimal
    test_log("CPU: " .. cpu_pct .. "% (" .. (label or "current") .. ")", "debug")
end

-- Test result collection
local test_results = {
    passed = 0,
    failed = 0,
    total = 0,
    failures = {}
}

function test_reset_results()
    test_results.passed = 0
    test_results.failed = 0
    test_results.total = 0
    test_results.failures = {}
end

function test_record_result(passed, test_name, failure_message)
    test_results.total = test_results.total + 1
    if passed then
        test_results.passed = test_results.passed + 1
        test_log("[PASS] " .. (test_name or "Test"), "info")
    else
        test_results.failed = test_results.failed + 1
        local failure = {
            name = test_name or "Unknown test",
            message = failure_message or "No details",
            frame = test_get_frame_count()
        }
        add(test_results.failures, failure)
        test_log("[FAIL] " .. failure.name .. ": " .. failure.message, "error")
    end
end

function test_print_results()
    test_log("=== TEST RESULTS ===", "info")
    test_log("Total tests: " .. test_results.total, "info")
    test_log("Passed: " .. test_results.passed, "info")
    test_log("Failed: " .. test_results.failed, "info")

    if #test_results.failures > 0 then
        test_log("Failures:", "error")
        for failure in all(test_results.failures) do
            test_log("  " .. failure.name .. ": " .. failure.message ..
                    " (frame " .. failure.frame .. ")", "error")
        end
    end

    local success_rate = test_results.total > 0 and (test_results.passed / test_results.total * 100) or 0
    test_log("Success rate: " .. tostr(success_rate) .. "%", "info")
end

-- Export functions (global in PICO-8)
test_set_button_state = test_set_button_state
test_get_button_state = test_get_button_state
test_clear_button_states = test_clear_button_states
test_wait_frames = test_wait_frames
test_update_wait = test_update_wait
test_assert = test_assert
test_assert_equal = test_assert_equal
test_assert_not_equal = test_assert_not_equal
test_assert_true = test_assert_true
test_assert_false = test_assert_false
test_assert_nil = test_assert_nil
test_assert_not_nil = test_assert_not_nil
test_assert_in_range = test_assert_in_range
test_assert_approx_equal = test_assert_approx_equal
test_start_timer = test_start_timer
test_end_timer = test_end_timer
test_measure_performance = test_measure_performance
test_log_memory_usage = test_log_memory_usage
test_log_cpu_usage = test_log_cpu_usage
test_reset_results = test_reset_results
test_record_result = test_record_result
test_print_results = test_print_results