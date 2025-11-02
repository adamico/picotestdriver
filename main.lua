-- Game state
local player = {
  x = 64,
  y = 64,
  dx = 0,
  dy = 0,
  speed = 1,
  color = 7
}

local enemies = {}
local bullets = {}

-- Test state
local test_frame = 0
local current_subtest = 1
local subtest_start_frame = 0

-- Subtest definitions
local subtests = {
  { name = "movement",         duration = 120 },
  { name = "collision",        duration = 120 },
  { name = "input",            duration = 120 },
  { name = "boundary",         duration = 120 },
  { name = "assertions",       duration = 120 },
  { name = "timing",           duration = 180 },
  { name = "edge_cases",       duration = 120 },
  { name = "test_utils",       duration = 240 },
  { name = "timeout_calc",     duration = 120 },
}

function _init()
  test_log("=== PICOTESTDRIVER DEMO ===", "info")

  -- Pass subtests with durations to test_init
  -- Timeout will be auto-calculated based on total duration + buffer
  test_init({
    subtests = subtests,  -- Pass full subtest table with durations
    timeout_buffer = 180, -- 3 second safety buffer (default, can be omitted)
    debug_level = "info",
    log_file = "test_demo.log"  -- Save all logs to this file
  })

  init_game()
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
  if subtest.name == "movement" then
    test_movement(subtest_frame)
  elseif subtest.name == "collision" then
    test_collision(subtest_frame)
  elseif subtest.name == "input" then
    test_input(subtest_frame)
  elseif subtest.name == "boundary" then
    test_boundary(subtest_frame)
  elseif subtest.name == "assertions" then
    test_assertions(subtest_frame)
  elseif subtest.name == "timing" then
    test_timing(subtest_frame)
  elseif subtest.name == "edge_cases" then
    test_edge_cases(subtest_frame)
  elseif subtest.name == "test_utils" then
    test_utils_functions(subtest_frame)
  elseif subtest.name == "timeout_calc" then
    test_timeout_calculation(subtest_frame)
  end

  -- Update game (if needed for tests)
  update_player()
  update_enemies()
  update_bullets()
end

function _draw()
  cls(1)

  -- Draw player
  circfill(player.x, player.y, 4, player.color)

  -- Draw enemies
  for enemy in all(enemies) do
    circfill(enemy.x, enemy.y, 3, enemy.color)
  end

  -- Draw bullets
  for bullet in all(bullets) do
    circfill(bullet.x, bullet.y, 1, 10)
  end

  -- Test info
  local subtest = subtests[current_subtest]
  local subtest_name = subtest and subtest.name or "COMPLETE"
  local subtest_frame = test_frame - subtest_start_frame

  print("PICOTESTDRIVER DEMO", 2, 2, 7)
  print("TEST: " .. subtest_name, 2, 10, 7)
  print("FRAME: " .. subtest_frame, 2, 18, 7)
  print("(" .. current_subtest .. "/" .. #subtests .. ")", 60, 18, 6)

  if not subtest then
    print("ALL TESTS DONE!", 30, 60, 11)
  else
    print("RUNNING...", 2, 26, 8)
  end
end

-- Game functions
function init_game()
  player.x = 64
  player.y = 64
  player.dx = 0
  player.dy = 0
  enemies = {}
  bullets = {}
end

function update_player()
  -- Simple movement
  if btn(0) then player.dx = -player.speed end -- left
  if btn(1) then player.dx = player.speed end  -- right
  if btn(2) then player.dy = -player.speed end -- up
  if btn(3) then player.dy = player.speed end  -- down

  -- Apply movement
  player.x += player.dx
  player.y += player.dy

  -- Friction
  player.dx *= 0.8
  player.dy *= 0.8

  -- Boundary checking
  player.x = mid(4, player.x, 123)
  player.y = mid(4, player.y, 123)
end

function update_enemies()
  -- Simple enemy AI
  for enemy in all(enemies) do
    -- Move toward player
    local dx = player.x - enemy.x
    local dy = player.y - enemy.y
    local dist = sqrt(dx * dx + dy * dy)

    if dist > 0 then
      enemy.x += dx / dist * 0.5
      enemy.y += dy / dist * 0.5
    end
  end
end

function update_bullets()
  for bullet in all(bullets) do
    bullet.x += bullet.dx
    bullet.y += bullet.dy

    -- Remove off-screen bullets
    if bullet.x < 0 or bullet.x > 128 or bullet.y < 0 or bullet.y > 128 then
      del(bullets, bullet)
    end
  end
end

function check_collisions()
  -- Player vs enemies
  for enemy in all(enemies) do
    local dx = player.x - enemy.x
    local dy = player.y - enemy.y
    if sqrt(dx * dx + dy * dy) < 8 then
      -- Collision detected
      return true
    end
  end
  return false
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
    init_game()
  else
    test_log("All subtests complete!", "info")
    
    -- Export test results in multiple formats
    test_export_json("test_results.json")
    test_export_csv("test_results.csv")
    test_export_markdown("test_results.md")
    
    test_complete("All subtests complete")
  end
end

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
    test_set_button_state(0, true)  -- left
    test_set_button_state(2, true)  -- up
    
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
    local test_subtests = {"test1", "test2", "test3"}
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
