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
