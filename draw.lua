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