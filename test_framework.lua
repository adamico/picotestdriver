-- PICO-8 Automated Testing Framework
-- Core library for test management and execution
-- Version 1.0.0

local test_framework = {
    version = "1.0.0",
    subtest = nil,
    completed = false,
    frame_count = 0,
    options = {},
    overrides = {}  -- Store original functions for restoration
}

-- Initialize the test framework
-- options: {
--   subtests = {"subtest1", "subtest2", ...},  -- Available test subtests
--   default_subtest = "subtest1",              -- Default subtest if none specified
--   timeout_frames = 1800,                     -- Default timeout (30 seconds at 60fps)
--   timeout_seconds = nil,                     -- Optional: override with seconds from command line
--   debug_level = "info"                       -- "none", "info", "debug"
-- }
function test_init(options)
    test_framework.options = options or {}
    test_framework.options.subtests = test_framework.options.subtests or {}
    test_framework.options.default_subtest = test_framework.options.default_subtest or "default"
    test_framework.options.timeout_frames = test_framework.options.timeout_frames or 1800
    test_framework.options.debug_level = test_framework.options.debug_level or "info"

    -- Read command line parameters (format: "subtest:timeout" or just "subtest")
    local cmd_args = stat(6)
    test_framework.subtest = cmd_args
    
    -- Parse subtest and timeout from command line
    if cmd_args and cmd_args ~= "" then
        local colon_pos = 0
        for i = 1, #cmd_args do
            if sub(cmd_args, i, i) == ":" then
                colon_pos = i
                break
            end
        end
        
        if colon_pos > 0 then
            test_framework.subtest = sub(cmd_args, 1, colon_pos - 1)
            local timeout_str = sub(cmd_args, colon_pos + 1)
            local timeout_sec = tonum(timeout_str)
            if timeout_sec and timeout_sec > 0 then
                test_framework.options.timeout_frames = timeout_sec * 60  -- Convert seconds to frames
                test_framework.options.timeout_seconds = timeout_sec
                test_log("Timeout set from command line: " .. timeout_sec .. "s (" .. test_framework.options.timeout_frames .. " frames)", "debug")
            end
        end
    end

    -- Validate subtest
    if test_framework.subtest and test_framework.subtest ~= "" and test_framework.subtest ~= "timeout" then
        local valid_subtest = false
        for _, subtest in ipairs(test_framework.options.subtests) do
            if subtest == test_framework.subtest then
                valid_subtest = true
                break
            end
        end
        if not valid_subtest and test_framework.subtest ~= "all" then
            printh("WARNING: Unknown test subtest '" .. test_framework.subtest .. "'")
            test_framework.subtest = test_framework.options.default_subtest
        end
    else
        test_framework.subtest = test_framework.options.default_subtest
    end

    test_log("Test framework initialized - Subtest: " .. test_framework.subtest, "info")
    -- Note: table.concat not available in PICO-8, skip subtest listing
end

-- Get current test subtest
function test_get_subtest()
    return test_framework.subtest
end

-- Check if test is completed
function test_is_completed()
    return test_framework.completed
end

-- Mark test as completed
function test_complete(message)
    test_framework.completed = true
    local msg = message or "Test completed successfully"
    test_log(msg, "info")
    -- Stop PICO-8 execution when test is complete
    stop()
end

-- Get current frame count
function test_get_frame_count()
    return test_framework.frame_count
end

-- Get timeout in frames
function test_get_timeout_frames()
    return test_framework.options.timeout_frames
end

-- Get timeout in seconds (if set from command line)
function test_get_timeout_seconds()
    return test_framework.options.timeout_seconds
end

-- Increment frame counter (call this in _update60)
function test_update_frame()
    test_framework.frame_count = test_framework.frame_count + 1

    -- Check for timeout
    if test_framework.frame_count >= test_framework.options.timeout_frames then
        local timeout_msg = "TIMEOUT: Test execution timed out after " .. test_framework.frame_count .. " frames"
        if test_framework.options.timeout_seconds then
            timeout_msg = timeout_msg .. " (" .. test_framework.options.timeout_seconds .. "s)"
        end
        test_log(timeout_msg, "error")
        test_complete("Test timed out")
    end
end

-- Logging utility with levels
function test_log(message, level)
    level = level or "info"

    if test_framework.options.debug_level == "none" then
        return
    elseif test_framework.options.debug_level == "info" and level == "debug" then
        return
    end

    local prefix = ""
    if level == "error" then
        prefix = "[ERROR] "
    elseif level == "warn" then
        prefix = "[WARN] "
    elseif level == "debug" then
        prefix = "[DEBUG] "
    else
        prefix = "[INFO] "
    end

    printh(prefix .. message)
end

-- Override a function for testing/debugging
-- Note: PICO-8 limitations - manual restoration required
function test_override_function(func_name, new_func)
    test_log("Function override not fully implemented for PICO-8 - use direct assignment", "warn")
    -- In practice, users should do: original_func = some_function; some_function = debug_version
end

-- Restore a function (simplified for PICO-8)
function test_restore_function(func_name)
    test_log("Function restoration not implemented - manually restore functions", "warn")
end

-- Restore all overridden functions (simplified)
function test_restore_all_functions()
    test_log("Function restoration not implemented - manually restore functions", "warn")
end

-- Run a test subtest (simplified for PICO-8)
function test_run_subtest(subtest_name, test_func)
    if test_framework.subtest == subtest_name or test_framework.subtest == "all" then
        test_log("Running test subtest: " .. subtest_name, "info")
        test_func()  -- Direct call, no pcall in PICO-8
        return true
    end
    return true
end

-- Wait for specified number of frames
function test_wait_frames(count)
    local start_frame = test_framework.frame_count
    while test_framework.frame_count < start_frame + count do
        -- This would be called from the main loop
        -- In practice, this is handled by the main _update60 loop
        test_log("Waiting... frame " .. test_framework.frame_count .. "/" .. (start_frame + count), "debug")
        break  -- Let the main loop handle frame progression
    end
end

-- Schedule a callback at specific frame
function test_at_frame(target_frame, callback)
    if test_framework.frame_count == target_frame then
        callback()
    end
end