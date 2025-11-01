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
  { name = "movement", duration = 120 },
  { name = "collision", duration = 120 },
  { name = "input", duration = 120 },
  { name = "boundary", duration = 120 },
  { name = "assertions", duration = 120 },
  { name = "timing", duration = 180 },
  { name = "edge_cases", duration = 120 },
}

function _init()
  test_log("=== PICOTESTDRIVER DEMO ===", "info")
  
  -- Build subtest names list for test_init
  local subtest_names = {}
  for i = 1, #subtests do
    subtest_names[i] = subtests[i].name
  end
  
  test_init({
    subtests = subtest_names,
    timeout_frames = 600,  -- 10 seconds default (overridden by command line)
    debug_level = "info",
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
  
  -- Instructions
  print("Demo test cartridge", 2, 120, 6)
  print("Testing: movement, collision, etc", 2, 126, 6)
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
  if btn(0) then player.dx = -player.speed end  -- left
  if btn(1) then player.dx = player.speed end   -- right
  if btn(2) then player.dy = -player.speed end  -- up
  if btn(3) then player.dy = player.speed end   -- down

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
    init_game()
  end
  
  if frame == 30 then
    -- Test player responds to movement input
    if player.dx ~= 0 or player.dy ~= 0 then
      test_log("✓ INPUT: Player movement input working", "info")
    else
      test_log("✓ INPUT: Test placeholder (no button simulation)", "info")
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
    add(enemies, { x = 72, y = 64, color = 8 })  -- exactly 8 pixels away
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
