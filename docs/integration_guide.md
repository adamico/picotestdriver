# PICO-8 Test Framework Integration Guide

This guide shows how to integrate the PICO-8 Automated Testing Framework into your existing projects.

## Quick Integration (5 minutes)

### Step 1: Add Framework Files

Copy these files to your project directory:
- `test_framework.lua`
- `test_utils.lua`
- `run_test.sh` (optional, for command-line testing)

### Step 2: Include in Your Cartridge

Add these lines at the top of your `__lua__` section:

```lua
#include test_framework.lua
#include test_utils.lua
```

### Step 3: Initialize Framework

In your `_init()` function, add:

```lua
function _init()
    -- Your existing initialization
    init_game()

    -- Add test framework initialization
    test_init({
        phases = {"movement", "collision", "combat"},
        default_phase = "all",
        debug_level = "info"
    })
end
```

### Step 4: Update Game Loop

Modify your `_update60()` function:

```lua
function _update60()
    test_update_frame()

    -- Check if we're running tests
    local phase = test_get_phase()

    if phase == "movement" then
        test_movement()
    elseif phase == "collision" then
        test_collision()
    elseif phase == "combat" then
        test_combat()
    elseif phase == "all" then
        -- Normal game update
        update_game()
    end
end
```

### Step 5: Create Test Functions

Add test functions for each phase:

```lua
function test_movement()
    test_log("Testing player movement", "info")

    -- Setup
    player.x = 64
    player.y = 64

    -- Test movement (requires testable input wrapper in game)
    test_set_button_state(1, true)  -- Right
    update_player()
    test_assert(player.x > 64, "Player should move right")

    test_complete()
end
```

# Step 6: Run Tests

```bash
# Run all tests (use the public CLI)
./ptd test

# Run specific test
./ptd test movement

# Run with longer timeout
./ptd test collision 60

# List available test phases (preferred)
./ptd list -c my_test.p8
```

#### Discovering Test Phases

Use the `ptd list` command to see all available test phases in your cartridge:

```bash
./ptd list -c my_test.p8
```

This will scan your cartridge and included `.lua` files to find all defined test phases. Example output:

```
Available test phases in 'test_cart.p8':
  movement - Test phase
  collision - Test phase
  input - Test phase
  boundary - Test phase
```

This is especially useful when:
- Working with complex test suites
- Collaborating with other developers
- Debugging which phases are available
- Integrating with CI/CD pipelines

## Complete Example

Here's a minimal working example:

```lua
-- test_example.p8
#include test_framework.lua
#include test_utils.lua

-- Game state
player = {x = 64, y = 64, speed = 1}

function init_game()
    player.x = 64
    player.y = 64
end

function update_player()
    if btn(0) then player.x -= player.speed end
    if btn(1) then player.x += player.speed end
    if btn(2) then player.y -= player.speed end
    if btn(3) then player.y += player.speed end
end

-- Test functions
function test_movement()
    test_log("Testing movement", "info")

    init_game()
    test_assert_equal(player.x, 64, "Player starts at center")

    test_set_button_state(1, true)  -- Right
    update_player()
    test_assert(player.x > 64, "Player moves right")

    test_complete()
end

function _init()
    init_game()
    test_init({
        phases = {"movement"},
        default_phase = "all"
    })
end

function _update60()
    test_update_frame()

    if test_get_phase() == "movement" then
        test_movement()
    else
        update_player()
    end
end

function _draw()
    cls(1)
    circfill(player.x, player.y, 4, 7)

    print("Phase: " .. test_get_phase(), 2, 2, 7)
    print("Frame: " .. test_get_frame_count(), 2, 10, 7)
end
```

## Advanced Integration

### Conditional Compilation

For production builds without tests:

```lua
--#if TEST_BUILD
#include test_framework.lua
#include test_utils.lua
--#endif

function _init()
    init_game()
--#if TEST_BUILD
    test_init({phases = {"test1", "test2"}})
--#endif
end
```

### Test Data Management

```lua
function setup_test_data()
    -- Create test enemies, items, etc.
    enemies = {}
    add(enemies, {x = 32, y = 32, hp = 10})
    add(enemies, {x = 96, y = 96, hp = 10})
end

function test_combat()
    setup_test_data()

    -- Test combat logic
    damage_enemy(enemies[1], 5)
    test_assert_equal(enemies[1].hp, 5, "Enemy takes damage")

    damage_enemy(enemies[1], 6)
    test_assert_equal(enemies[1].hp, 0, "Enemy dies")
    test_assert_false(enemies[1].alive, "Enemy marked as dead")

    test_complete()
end
```

### Performance Testing

```lua
function test_ai_performance()
    setup_test_data()

    local result = test_measure_performance(function()
        for enemy in all(enemies) do
            update_enemy_ai(enemy)
        end
    end, 100, "Enemy AI")

    test_assert(result.avg_frames < 1, "AI should be fast")
    test_complete()
end
```

### Input Sequence Testing

```lua
function test_input_sequence()
    test_log("Testing input sequences", "info")

    -- Test jump sequence (requires testable input wrapper)
    test_set_button_state(2, true)     -- Up (jump)
    test_wait_frames(10, function()    -- Hold for jump
        test_set_button_state(2, false)  -- Release
    end)

    test_assert(player.jumping, "Player starts jumping")
    test_wait_frames(20, function()
        test_assert_false(player.jumping, "Jump completes")
        test_complete()
    end)
end
```

## Best Practices

### Test Organization

- Group related tests into phases
- Use descriptive test names
- Keep tests focused on single behaviors
- Clean up test data between tests

### Test Structure

```lua
function test_feature_name()
    -- 1. Setup - prepare test scenario
    setup_test_data()

    -- 2. Execute - run the code being tested
    perform_action()

    -- 3. Assert - verify expected results
    test_assert(expected_condition, "Clear failure message")

    -- 4. Cleanup - optional
    test_complete()
end
```

### Naming Conventions

- Test functions: `test_feature_name()`
- Setup functions: `setup_feature()`
- Helper functions: `helper_name()`
- Use descriptive assertion messages

### Debug Levels

```lua
-- For development
test_init({debug_level = "debug"})

-- For production testing
test_init({debug_level = "info"})

-- For silent testing
test_init({debug_level = "none"})
```

## Troubleshooting

### Tests Not Running

1. Check that framework files are included
2. Verify `test_init()` is called
3. Ensure `test_update_frame()` is in `_update60()`
4. Check PICO-8 console for error messages

### Assertions Failing

1. Use `test_log()` to debug values
2. Check timing - tests run in `_update60()`
3. Verify game state is set correctly
4. Use `test_assert_equal()` for exact comparisons

### Performance Issues

1. Tests add overhead - use selectively
2. Increase timeout for slow tests
3. Profile with `test_measure_performance()`
4. Use `--verbose` flag for detailed timing

## Migration from Manual Testing

If you currently test manually:

1. **Identify test scenarios** - What do you test manually?
2. **Create test functions** - Convert manual steps to code
3. **Add assertions** - Verify expected behavior
4. **Run automatically** - Use the framework to run tests

Example migration:

**Before (manual)**: "Load game, press right, check player moves"

**After (automated)**:
```lua
function test_movement()
    init_game()
    test_set_button_state(1, true)
    update_player()
    test_assert(player.x > 64, "Player moves right")
    test_complete()
end
```

## Next Steps

- Read the [API Reference](api_reference.md) for detailed function docs
- Check [Best Practices](best_practices.md) for advanced patterns
- Join the community discussion on the PICO-8 BBS
- Contribute improvements back to the framework

Happy testing! 🎮