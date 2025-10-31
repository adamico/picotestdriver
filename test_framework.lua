-- PICO-8 Automated Testing Framework
-- Core library for test management and execution
-- Version 1.0.0

local test_framework = {
    version = "1.0.0",
    phase = nil,
    completed = false,
    frame_count = 0,
    options = {},
    overrides = {}  -- Store original functions for restoration
}

-- Initialize the test framework
-- options: {
--   phases = {"phase1", "phase2", ...},  -- Available test phases
--   default_phase = "phase1",            -- Default phase if none specified
--   timeout_frames = 1800,               -- Default timeout (30 seconds at 60fps)
--   debug_level = "info"                 -- "none", "info", "debug"
-- }
function test_init(options)
    test_framework.options = options or {}
    test_framework.options.phases = test_framework.options.phases or {}
    test_framework.options.default_phase = test_framework.options.default_phase or "default"
    test_framework.options.timeout_frames = test_framework.options.timeout_frames or 1800
    test_framework.options.debug_level = test_framework.options.debug_level or "info"

    -- Read command line parameters
    local cmd_args = stat(6)
    test_framework.phase = cmd_args

    -- Validate phase
    if test_framework.phase and test_framework.phase ~= "" then
        local valid_phase = false
        for _, phase in ipairs(test_framework.options.phases) do
            if phase == test_framework.phase then
                valid_phase = true
                break
            end
        end
        if not valid_phase and test_framework.phase ~= "all" then
            printh("WARNING: Unknown test phase '" .. test_framework.phase .. "'")
            test_framework.phase = test_framework.options.default_phase
        end
    else
        test_framework.phase = test_framework.options.default_phase
    end

    test_log("Test framework initialized - Phase: " .. test_framework.phase, "info")
    -- Note: table.concat not available in PICO-8, skip phase listing
end

-- Get current test phase
function test_get_phase()
    return test_framework.phase
end

-- Check if test is completed
function test_is_completed()
    return test_framework.completed
end

-- Mark test as completed
function test_complete()
    test_framework.completed = true
    test_log("Test completed successfully", "info")
end

-- Get current frame count
function test_get_frame_count()
    return test_framework.frame_count
end

-- Increment frame counter (call this in _update60)
function test_update_frame()
    test_framework.frame_count = test_framework.frame_count + 1

    -- Check for timeout
    if test_framework.frame_count > test_framework.options.timeout_frames then
        test_log("Test timed out after " .. test_framework.frame_count .. " frames", "error")
        test_complete()
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

-- Run a test phase (simplified for PICO-8)
function test_run_phase(phase_name, test_func)
    if test_framework.phase == phase_name or test_framework.phase == "all" then
        test_log("Running test phase: " .. phase_name, "info")
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