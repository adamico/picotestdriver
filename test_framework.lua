-- PicoTestDriver - Automated Testing Framework
-- Core library for test management and execution

local test_framework = {
    subtest = nil,
    completed = false,
    frame_count = 0,
    options = {},
    overrides = {} -- Store original functions for restoration
}

-- Calculate total timeout based on subtest durations
-- subtests: array of {name="test1", duration=120} tables or simple string array
-- buffer: optional safety buffer in frames (default: 180 frames = 3 seconds)
function test_calculate_timeout(subtests, buffer)
    buffer = buffer or 180
    local total = 0
    local has_durations = false
    
    if not subtests then
        return 1800 -- Default 30 seconds if no subtests provided
    end
    
    for i = 1, #subtests do
        if type(subtests[i]) == "table" and subtests[i].duration then
            total = total + subtests[i].duration
            has_durations = true
        end
    end
    
    -- If no durations found, return default timeout
    if not has_durations then
        return 1800 -- Default 30 seconds
    end
    
    return total + buffer
end

-- Initialize the test framework
-- options: {
--   subtests = {"subtest1", "subtest2", ...} or [{name="test1", duration=120}, ...],
--   default_subtest = "subtest1",              -- Default subtest if none specified
--   timeout_frames = nil,                      -- Optional: manual timeout override
--   timeout_buffer = 180,                      -- Optional: safety buffer for auto-calculated timeout (default: 3 seconds)
--   timeout_seconds = nil,                     -- Optional: override with seconds from command line
--   debug_level = "info",                      -- "none", "info", "debug"
--   log_file = nil,                            -- Optional: filename to save logs (e.g., "test.log")
--   export_format = nil,                       -- Optional: "json", "csv", or "markdown" for structured export
--   cart_name = nil                            -- Optional: prefix for export filenames (default: "test_cart")
-- }
function test_init(options)
    test_framework.options = options or {}
    test_framework.options.subtests = test_framework.options.subtests or {}
    test_framework.options.default_subtest = test_framework.options.default_subtest or "default"
    test_framework.options.debug_level = test_framework.options.debug_level or "info"
    test_framework.options.cart_name = test_framework.options.cart_name or "test_cart"
    
    -- Debug: show if log_file is set
    if test_framework.options.log_file then
        printh("Log file configured: " .. test_framework.options.log_file)
    end
    
    -- Auto-calculate timeout if not explicitly set and subtests have durations
    if not test_framework.options.timeout_frames then
        local buffer = test_framework.options.timeout_buffer or 180
        test_framework.options.timeout_frames = test_calculate_timeout(test_framework.options.subtests, buffer)
        test_log("Auto-calculated timeout: " .. test_framework.options.timeout_frames .. " frames", "debug")
    end

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
                test_framework.options.timeout_frames = timeout_sec * 60 -- Convert seconds to frames
                test_framework.options.timeout_seconds = timeout_sec
                test_log(
                "Timeout set from command line: " ..
                timeout_sec .. "s (" .. test_framework.options.timeout_frames .. " frames)", "debug")
            end
        end
    end

    -- Validate subtest
    if test_framework.subtest and test_framework.subtest ~= "" and test_framework.subtest ~= "timeout" then
        local valid_subtest = false
        for i = 1, #test_framework.options.subtests do
            local subtest = test_framework.options.subtests[i]
            -- Handle both string arrays and {name, duration} tables
            local subtest_name = type(subtest) == "table" and subtest.name or subtest
            if subtest_name == test_framework.subtest then
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
        local timeout_msg = "TIMEOUT: Test execution exceeded time limit"
        if test_framework.options.timeout_seconds then
            timeout_msg = timeout_msg .. " (" .. test_framework.options.timeout_seconds .. "s)"
        else
            timeout_msg = timeout_msg .. " (" .. test_framework.frame_count .. " frames)"
        end
        test_log(timeout_msg, "error")
        stop("Test timed out - increase timeout if needed")
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

    local formatted_message = prefix .. message

    -- Output to console (terminal)
    printh(formatted_message)

    -- Optionally save to log file
    if test_framework.options.log_file then
        printh(formatted_message, test_framework.options.log_file, false) -- append mode
    end
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
        test_func() -- Direct call, no pcall in PICO-8
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
        break -- Let the main loop handle frame progression
    end
end

-- Schedule a callback at specific frame
function test_at_frame(target_frame, callback)
    if test_framework.frame_count == target_frame then
        callback()
    end
end

-- Get cart name for export filename prefixing
function test_get_cart_name()
    return test_framework.options.cart_name or "test_cart"
end
