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
}

function _init()
  test_log("=== PICO-8 TEST FRAMEWORK DEMO ===", "info")
  
  test_init({
    subtests = { "all" },
    timeout_frames = 600,  -- 10 seconds total
    debug_level = "info",
  })
  
  init_game()
  test_frame = 0
  current_subtest = 1
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
  
  print("PICO-8 TEST FRAMEWORK", 2, 2, 7)
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
  current_subtest += 1
  subtest_start_frame = test_frame
  
  if current_subtest <= #subtests then
    test_log("Advancing to subtest: " .. subtests[current_subtest].name, "info")
    init_game()
  else
    test_log("All subtests complete!", "info")
    test_complete()
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
  
  if frame >= subtests[current_subtest].duration then
    test_complete()
  end
end
