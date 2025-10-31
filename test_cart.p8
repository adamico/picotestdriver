pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
#include test_framework.lua
#include test_utils.lua

-- Example PICO-8 game with automated testing
-- Demonstrates the testing framework capabilities

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
        local dist = sqrt(dx*dx + dy*dy)

        if dist > 0 then
            enemy.x += dx/dist * 0.5
            enemy.y += dy/dist * 0.5
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
        if sqrt(dx*dx + dy*dy) < 8 then
            -- Collision detected
            return true
        end
    end
    return false
end

-- Test functions
function test_movement()
    test_log("=== MOVEMENT TEST ===", "info")

    -- Setup
    init_game()
    player.x = 64
    player.y = 64

    -- Test initial position
    test_assert_equal(player.x, 64, "Player starts at center X")
    test_assert_equal(player.y, 64, "Player starts at center Y")

    -- Simulate right movement by directly setting input and updating
    -- Note: In PICO-8, we can't easily simulate btn() calls, so we test the logic directly
    player.dx = player.speed  -- Simulate right movement
    update_player()

    test_assert(player.x > 64, "Player moves right when dx is positive")

    -- Test boundary clamping
    player.x = 120
    player.dx = 2  -- Moving right fast
    update_player()
    test_assert(player.x <= 123, "Player stays within right boundary")

    player.x = 10
    player.dx = -2  -- Moving left fast
    update_player()
    test_assert(player.x >= 4, "Player stays within left boundary")

    test_log("Movement test completed successfully", "info")
    test_complete()
end

function test_collision()
    test_log("=== COLLISION TEST ===", "info")

    -- Setup
    init_game()
    player.x = 64
    player.y = 64

    -- Add enemy near player
    add(enemies, {x = 68, y = 64, color = 8})

    -- Test collision detection
    local collision = check_collisions()
    test_assert_true(collision, "Collision detected when enemy is close")

    -- Move enemy away
    enemies[1].x = 100
    collision = check_collisions()
    test_assert_false(collision, "No collision when enemy is far")

    test_log("Collision test completed successfully", "info")
    test_complete()
end

function test_input()
    test_log("=== INPUT TEST ===", "info")

    -- Setup
    init_game()

    -- Test button simulation helpers
    test_press_button(0)  -- Left
    test_assert_true(btn(0), "Left button press detected")

    test_release_button(0)
    test_assert_false(btn(0), "Left button release detected")

    test_log("Input test completed successfully", "info")
    test_complete()
end

function test_boundary()
    test_log("=== BOUNDARY TEST ===", "info")

    -- Setup
    init_game()
    player.x = 64
    player.y = 64

    -- Test right boundary
    player.x = 122
    player.dx = 2  -- Moving right fast
    update_player()

    test_assert(player.x <= 123, "Player clamped at right boundary")

    -- Test left boundary
    player.x = 6
    player.dx = -2  -- Moving left fast
    update_player()

    test_assert(player.x >= 4, "Player clamped at left boundary")

    test_log("Boundary test completed successfully", "info")
    test_complete()
end

function _init()
    init_game()

    -- Initialize test framework
    test_init({
        phases = {"movement", "collision", "input", "boundary"},
        default_phase = "all",
        timeout_frames = 1800,  -- 30 seconds
        debug_level = "info"
    })

    -- Run appropriate test based on phase
    local phase = test_get_phase()

    if phase == "movement" then
        test_movement()
    elseif phase == "collision" then
        test_collision()
    elseif phase == "input" then
        test_input()
    elseif phase == "boundary" then
        test_boundary()
    elseif phase == "all" then
        -- Run all tests in sequence
        test_log("Running all tests sequentially", "info")
    end
end

function _update60()
    test_update_frame()

    local phase = test_get_phase()

    if phase == "all" then
        -- Run tests in sequence based on frame count
        if test_get_frame_count() == 1 then
            test_movement()
        elseif test_get_frame_count() == 120 then  -- After movement test
            test_collision()
        elseif test_get_frame_count() == 240 then  -- After collision test
            test_input()
        elseif test_get_frame_count() == 360 then  -- After input test
            test_boundary()
        end
    else
        -- For specific phase tests, just run normal game if test completed
        if not test_is_completed() then
            return  -- Wait for test to complete
        end

        -- Normal game update
        update_player()
        update_enemies()
        update_bullets()

        -- Check for collisions
        if check_collisions() then
            -- Game over - reset
            init_game()
        end
    end
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

    -- Draw UI
    print("PICO-8 TEST FRAMEWORK", 2, 2, 7)
    print("Phase: " .. test_get_phase(), 2, 10, 7)
    print("Frame: " .. test_get_frame_count(), 2, 18, 7)

    if test_is_completed() then
        print("TEST COMPLETED", 2, 26, 11)
    else
        print("TEST RUNNING...", 2, 26, 8)
    end

    -- Instructions
    print("Use arrow keys to move", 2, 120, 6)
    print("Avoid red enemies", 2, 126, 6)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000