-- Test functions
function test_movement(frame)
  if frame == 1 then
    test_log("=== MOVEMENT TEST ===", "info")
    init_game()
    player.x = 64
    player.y = 64
  end

  if frame == 30 then
    -- Simulate right movement
    player.dx = player.speed
    update_player()

    if player.x > 64 then
      test_log("✓ MOVEMENT: Player moves right", "info")
    else
      test_log("✗ MOVEMENT: Player did not move", "error")
    end
  end

  if frame >= subtests[current_subtest].duration then
    next_subtest()
  end
end

function test_collision(frame)
  if frame == 1 then
    test_log("=== COLLISION TEST ===", "info")
    init_game()
    player.x = 64
    player.y = 64
    add(enemies, { x = 68, y = 64, color = 8 })
  end

  if frame == 30 then
    local collision = check_collisions()
    if collision then
      test_log("✓ COLLISION: Detected when enemy is close", "info")
    else
      test_log("✗ COLLISION: Not detected", "error")
    end
  end

  if frame >= subtests[current_subtest].duration then
    next_subtest()
  end
end

function test_input(frame)
  if frame == 1 then
    test_log("=== INPUT TEST ===", "info")
    test_log("Testing button state utilities", "info")
    init_game()
    test_clear_button_states()
  end

  if frame == 10 then
    test_log("Testing button press (right)...", "debug")
    -- Simulate pressing right button (button 1)
    test_set_button_state(1, true)

    -- Check button state was set
    local btn1_state = test_get_button_state(1)
    if btn1_state == true then
      test_log("✓ INPUT: Button 1 (right) press detected", "info")
    else
      test_log("✗ INPUT: Button 1 press not detected", "error")
    end
  end

  if frame == 30 then
    test_log("Testing button release...", "debug")
    -- Release right button
    test_set_button_state(1, false)

    local btn1_state = test_get_button_state(1)
    if btn1_state == false then
      test_log("✓ INPUT: Button 1 (right) release detected", "info")
    else
      test_log("✗ INPUT: Button 1 release not detected", "error")
    end
  end

  if frame == 50 then
    test_log("Testing multiple buttons...", "debug")
    -- Press multiple buttons
    test_set_button_state(0, true) -- left
    test_set_button_state(2, true) -- up

    local btn0_state = test_get_button_state(0)
    local btn2_state = test_get_button_state(2)

    if btn0_state == true and btn2_state == true then
      test_log("✓ INPUT: Multiple button presses tracked", "info")
    else
      test_log("✗ INPUT: Multiple buttons not tracked correctly", "error")
    end
  end

  if frame == 70 then
    test_log("Testing button state query for unset button...", "debug")
    -- Query button that was never set
    local btn5_state = test_get_button_state(5)

    if btn5_state == nil then
      test_log("✓ INPUT: Unset button returns nil", "info")
    else
      test_log("✗ INPUT: Unset button should return nil", "error")
    end
  end

  if frame == 90 then
    test_log("Testing clear all button states...", "debug")
    test_clear_button_states()

    -- Check all buttons are cleared
    local btn0_state = test_get_button_state(0)
    local btn1_state = test_get_button_state(1)
    local btn2_state = test_get_button_state(2)

    if btn0_state == nil and btn1_state == nil and btn2_state == nil then
      test_log("✓ INPUT: All button states cleared", "info")
    else
      test_log("✗ INPUT: Button states not properly cleared", "error")
    end
  end

  if frame >= subtests[current_subtest].duration then
    next_subtest()
  end
end

function test_boundary(frame)
  if frame == 1 then
    test_log("=== BOUNDARY TEST ===", "info")
    init_game()
  end

  if frame == 30 then
    -- Test right boundary
    player.x = 122
    player.dx = 2
    update_player()

    if player.x <= 123 then
      test_log("✓ BOUNDARY: Right boundary clamping works", "info")
    else
      test_log("✗ BOUNDARY: Player exceeded right boundary", "error")
    end
  end

  if frame == 60 then
    -- Test left boundary
    player.x = 6
    player.dx = -2
    update_player()

    if player.x >= 4 then
      test_log("✓ BOUNDARY: Left boundary clamping works", "info")
    else
      test_log("✗ BOUNDARY: Player exceeded left boundary", "error")
    end
  end

  if frame >= subtests[current_subtest].duration then
    next_subtest()
  end
end

function test_assertions(frame)
  if frame == 1 then
    test_log("=== ASSERTION TEST ===", "info")
    test_log("Demonstrating various assertion patterns", "info")
    init_game()
  end

  if frame == 10 then
    -- Test equality assertions
    local expected_x = 64
    local actual_x = player.x
    if actual_x == expected_x then
      test_log("✓ ASSERTION: Player X position equals " .. expected_x, "info")
    else
      test_log("✗ ASSERTION: Expected X=" .. expected_x .. ", got X=" .. actual_x, "error")
    end
  end

  if frame == 30 then
    -- Test range assertions
    local min_speed = 0
    local max_speed = 2
    if player.speed >= min_speed and player.speed <= max_speed then
      test_log("✓ ASSERTION: Player speed in valid range [" .. min_speed .. "," .. max_speed .. "]", "info")
    else
      test_log("✗ ASSERTION: Player speed " .. player.speed .. " outside valid range", "error")
    end
  end

  if frame == 50 then
    -- Test collection assertions
    local enemy_count = #enemies
    if enemy_count == 0 then
      test_log("✓ ASSERTION: Enemy count is zero (as expected)", "info")
    else
      test_log("✗ ASSERTION: Expected 0 enemies, found " .. enemy_count, "error")
    end
  end

  if frame == 70 then
    -- Test type assertions
    if type(player.x) == "number" then
      test_log("✓ ASSERTION: Player X is number type", "info")
    else
      test_log("✗ ASSERTION: Player X has wrong type: " .. type(player.x), "error")
    end
  end

  if frame >= subtests[current_subtest].duration then
    next_subtest()
  end
end

function test_timing(frame)
  if frame == 1 then
    test_log("=== TIMING TEST ===", "info")
    test_log("Testing frame-dependent behavior", "info")
    init_game()
    -- Mark test start time
    player.color = 7
  end

  if frame == 60 then
    -- Test at 1 second mark (60 frames @ 60fps)
    test_log("✓ TIMING: Reached 1 second mark (frame 60)", "info")
  end

  if frame == 120 then
    -- Test at 2 second mark
    test_log("✓ TIMING: Reached 2 second mark (frame 120)", "info")

    -- Simulate adding an enemy after delay
    add(enemies, { x = 100, y = 100, color = 8 })
  end

  if frame == 140 then
    -- Verify enemy was added in previous frame
    if #enemies > 0 then
      test_log("✓ TIMING: Enemy spawned after delay", "info")
    else
      test_log("✗ TIMING: Enemy spawn failed", "error")
    end
  end

  if frame >= subtests[current_subtest].duration then
    next_subtest()
  end
end

function test_edge_cases(frame)
  if frame == 1 then
    test_log("=== EDGE CASE TEST ===", "info")
    test_log("Testing boundary conditions and corner cases", "info")
    init_game()
  end

  if frame == 10 then
    -- Test zero movement
    player.dx = 0
    player.dy = 0
    local start_x = player.x
    update_player()

    if player.x == start_x then
      test_log("✓ EDGE CASE: Zero movement handled correctly", "info")
    else
      test_log("✗ EDGE CASE: Player moved with zero velocity", "error")
    end
  end

  if frame == 30 then
    -- Test negative coordinates (should be clamped)
    player.x = -10
    player.y = -10
    update_player()

    if player.x >= 4 and player.y >= 4 then
      test_log("✓ EDGE CASE: Negative coordinates clamped to minimum", "info")
    else
      test_log("✗ EDGE CASE: Negative coordinates not handled", "error")
    end
  end

  if frame == 50 then
    -- Test maximum coordinates (should be clamped)
    player.x = 200
    player.y = 200
    update_player()

    if player.x <= 123 and player.y <= 123 then
      test_log("✓ EDGE CASE: Excessive coordinates clamped to maximum", "info")
    else
      test_log("✗ EDGE CASE: Excessive coordinates not handled", "error")
    end
  end

  if frame == 70 then
    -- Test empty collections
    enemies = {}
    local collision = check_collisions()

    if not collision then
      test_log("✓ EDGE CASE: No collision with empty enemy list", "info")
    else
      test_log("✗ EDGE CASE: False collision with empty list", "error")
    end
  end

  if frame == 90 then
    -- Test exact boundary collision (on the edge)
    player.x = 64
    player.y = 64
    add(enemies, { x = 72, y = 64, color = 8 }) -- exactly 8 pixels away
    local collision = check_collisions()

    if collision then
      test_log("✓ EDGE CASE: Collision detected at exact boundary distance", "info")
    else
      test_log("⚠ EDGE CASE: No collision at boundary (< 8 required)", "warn")
    end
  end

  if frame >= subtests[current_subtest].duration then
    next_subtest()
  end
end

-- Test test_utils.lua functions
function test_utils_functions(frame)
  if frame == 1 then
    test_log("=== TEST_UTILS TEST ===", "info")
    test_log("Testing utility functions from test_utils.lua", "info")
    init_game()
    test_reset_results()
  end

  -- Test assertion functions
  if frame == 10 then
    test_log("Testing assertion functions...", "info")
    test_assert_equal(5, 5, "5 equals 5")
    test_assert_not_equal(5, 10, "5 not equals 10")
    test_assert_true(true, "true is true")
    test_assert_false(false, "false is false")
    test_assert_nil(nil, "nil is nil")
    test_assert_not_nil(player, "player exists")
  end

  if frame == 30 then
    test_log("Testing range assertions...", "info")
    test_assert_in_range(player.x, 0, 128, "player x in screen bounds")
    test_assert_approx_equal(1.0, 1.001, 0.01, "approximate equality")
  end

  -- Test button state functions
  if frame == 50 then
    test_log("Testing button state utilities...", "info")
    test_clear_button_states()

    -- Set button 0 pressed
    test_set_button_state(0, true)
    local btn0_state = test_get_button_state(0)
    test_assert_equal(btn0_state, true, "button 0 should be pressed")

    -- Set button 0 released
    test_set_button_state(0, false)
    btn0_state = test_get_button_state(0)
    test_assert_equal(btn0_state, false, "button 0 should be released")

    -- Test unset button returns nil
    local btn5_state = test_get_button_state(5)
    test_assert_nil(btn5_state, "unset button should return nil")
  end

  -- Test timer functions
  if frame == 70 then
    test_log("Testing timer functions...", "info")
    test_start_timer()
  end

  if frame == 100 then
    local duration = test_end_timer()
    test_assert_in_range(duration, 25, 35, "timer duration should be ~30 frames")
  end

  -- Test memory and CPU logging
  if frame == 120 then
    test_log("Testing performance logging...", "info")
    test_log_memory_usage("before operations")

    -- Do some work
    for i = 1, 100 do
      local temp = {}
      for j = 1, 10 do
        add(temp, j * i)
      end
    end

    test_log_memory_usage("after operations")
    test_log_cpu_usage("current frame")
  end

  -- Test performance measurement
  if frame == 150 then
    test_log("Testing performance measurement...", "info")
    local perf = test_measure_performance(
      function()
        -- Simple function to measure
        local sum = 0
        for i = 1, 100 do
          sum += i
        end
        return sum
      end,
      10,
      "sum calculation"
    )

    test_assert_not_nil(perf, "performance results exist")
    test_assert_equal(perf.iterations, 10, "correct iteration count")
  end

  -- Test result tracking
  if frame == 180 then
    test_log("Testing result tracking...", "info")
    test_record_result(true, "test_pass", nil)
    test_record_result(false, "test_fail", "intentional failure")
    test_record_result(true, "another_pass", nil)
  end

  if frame == 200 then
    test_log("Printing accumulated test results...", "info")
    test_print_results()

    -- Verify results were tracked
    local results = test_get_results()
    local results_exist = results and results.total > 0
    if results_exist then
      test_log("✓ TEST_UTILS: Result tracking works", "info")
    else
      test_log("✗ TEST_UTILS: Result tracking failed", "error")
    end
  end

  if frame >= subtests[current_subtest].duration then
    next_subtest()
  end
end

-- Test test_calculate_timeout helper function
function test_timeout_calculation(frame)
  if frame == 1 then
    test_log("=== TIMEOUT CALCULATION TEST ===", "info")
    test_log("Testing test_calculate_timeout() helper function", "info")
  end

  if frame == 10 then
    test_log("Testing with subtests that have durations...", "info")

    -- Test with duration tables
    local test_subtests = {
      { name = "test1", duration = 100 },
      { name = "test2", duration = 200 },
      { name = "test3", duration = 150 },
    }

    local timeout = test_calculate_timeout(test_subtests, 50)
    local expected = 100 + 200 + 150 + 50 -- 500 frames total

    if timeout == expected then
      test_log("✓ TIMEOUT_CALC: Calculated " .. timeout .. " frames (expected " .. expected .. ")", "info")
    else
      test_log("✗ TIMEOUT_CALC: Got " .. timeout .. ", expected " .. expected, "error")
    end
  end

  if frame == 30 then
    test_log("Testing with string array (no durations)...", "info")

    -- Test with string array
    local test_subtests = { "test1", "test2", "test3" }
    local timeout = test_calculate_timeout(test_subtests, 100)

    -- Should return default timeout (1800) since no durations
    if timeout == 1800 then
      test_log("✓ TIMEOUT_CALC: Returns default 1800 for string arrays", "info")
    else
      test_log("✗ TIMEOUT_CALC: Expected 1800, got " .. timeout, "error")
    end
  end

  if frame == 50 then
    test_log("Testing with nil subtests...", "info")

    local timeout = test_calculate_timeout(nil, 100)

    if timeout == 1800 then
      test_log("✓ TIMEOUT_CALC: Returns default 1800 for nil input", "info")
    else
      test_log("✗ TIMEOUT_CALC: Expected 1800, got " .. timeout, "error")
    end
  end

  if frame == 70 then
    test_log("Testing default buffer value...", "info")

    local test_subtests = {
      { name = "test1", duration = 120 },
    }

    -- Call without buffer parameter - should use default 180
    local timeout = test_calculate_timeout(test_subtests)
    local expected = 120 + 180 -- 300 frames

    if timeout == expected then
      test_log("✓ TIMEOUT_CALC: Default buffer (180) applied correctly", "info")
    else
      test_log("✗ TIMEOUT_CALC: Expected " .. expected .. ", got " .. timeout, "error")
    end
  end

  if frame == 90 then
    test_log("Testing current demo subtests calculation...", "info")

    -- Test with actual demo subtests
    local timeout = test_calculate_timeout(subtests, 180)

    -- Sum: 120+120+120+120+120+180+120+240+120 = 1260 + 180 buffer = 1440
    local expected = 1440

    if timeout == expected then
      test_log("✓ TIMEOUT_CALC: Demo subtests = " .. timeout .. " frames", "info")
    else
      test_log("✗ TIMEOUT_CALC: Expected " .. expected .. ", got " .. timeout, "error")
    end
  end

  if frame >= subtests[current_subtest].duration then
    next_subtest()
  end
end
