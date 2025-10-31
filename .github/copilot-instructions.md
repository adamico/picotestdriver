# Copilot Instructions for Pico Test Driver (PICO-8 automated game testing framework)

## Project Overview
Pico Test Driver is a comprehensive automated testing framework for PICO-8 cartridges, enabling developers to create, run, and debug tests with detailed output and command-line integration. The framework works within PICO-8's strict constraints: 8192 token limit, limited Lua standard library, no exception handling, and global scope by default.

These instructions help AI assistants understand the framework's patterns and constraints. While AI can accelerate development, remember that PICO-8's unique environment requires human expertise to ensure compatibility with its limitations and design philosophy.

## Key Files
- **`test_framework.lua`** - Core framework managing test phases, frame counting, logging, and initialization
- **`test_utils.lua`** - Testing utilities including assertions, performance measurement, input simulation, and result collection
- **`run_test.sh`** - Bash script for command-line test execution with timeout and parameter passing
- **`test_cart.p8`** - Example cartridge demonstrating framework integration and test patterns

## Architecture & Patterns

### Frame-Based Execution Model
All testing occurs within PICO-8's 60 FPS game loop. Tests are frame-aware and use cooperative scheduling:

```lua
function _update60()
    test_update_frame()  -- Must be called first to advance frame counter

    local phase = test_get_phase()
    if phase == "movement" then
        test_movement()
    elseif phase == "all" then
        update_game()  -- Normal game logic
    end
end
```

### Phase-Based Test Organization
Tests are organized into named phases for isolated execution. Use command-line parameters to run specific phases:

```bash
./run_test.sh movement_test    # Run only movement tests
./run_test.sh collision_test   # Run only collision tests
./run_test.sh                  # Run all tests (default)
```

### PICO-8 Constraint Adaptations
- **No exceptions**: Use return values and `test_log()` for error indication
- **Global scope**: All functions are global; use descriptive naming to avoid conflicts
- **Limited stdlib**: No `pcall`, `table.concat`, `table.unpack` - framework adapts accordingly
- **Single parameter**: Command-line args passed via `stat(6)` as one string

### Function Override Pattern
For testing modified behavior, manually override functions (PICO-8 limitation prevents automatic restoration):

```lua
-- Manual override with documented restoration
original_update = update_player
update_player = function()
    test_log("Debug: player update called", "debug")
    return original_update()
end
-- Remember to restore: update_player = original_update
```

## Developer Workflows

### Basic Integration (5 minutes)
1. **Include framework files** at top of `__lua__` section:
   ```lua
   #include test_framework.lua
   #include test_utils.lua
   ```

2. **Initialize in `_init()`**:
   ```lua
   function _init()
       init_game()
       test_init({
           phases = {"movement", "collision", "combat"},
           default_phase = "all",
           timeout_frames = 1800,  -- 30 seconds at 60fps
           debug_level = "info"
       })
   end
   ```

3. **Update `_update60()`** for test execution:
   ```lua
   function _update60()
       test_update_frame()

       local phase = test_get_phase()
       if phase == "movement" then
           test_movement()
       elseif phase == "all" then
           update_game()  -- Normal game loop
       end
   end
   ```

4. **Run tests** via command line:
   ```bash
   ./run_test.sh                    # All tests, 30s timeout
   ./run_test.sh movement_test      # Specific phase
   ./run_test.sh collision_test 60  # Custom timeout
   ```

### Test Structure Pattern
Follow this consistent structure for all test functions:

```lua
function test_feature_name()
    test_log("Testing specific behavior", "info")

    -- Setup: Prepare test scenario
    setup_test_data()

    -- Execute: Run code being tested
    perform_action_under_test()

    -- Assert: Verify expected results
    test_assert(condition, "Clear failure description")
    test_assert_equal(actual, expected, "Values should match")

    -- Cleanup: Mark test complete
    test_complete()
end
```

### Assertion Patterns
Use descriptive assertion messages and the most appropriate assertion type:

```lua
-- Value comparisons
test_assert_equal(player.x, 64, "Player starts at center")
test_assert_not_equal(score, 0, "Score changed after action")

-- Boolean conditions
test_assert_true(collision_detected, "Collision detected when objects overlap")
test_assert_false(player.dead, "Player survives normal damage")

-- Range validation
test_assert_in_range(damage, 1, 10, "Damage is within expected bounds")

-- Approximate floating point
test_assert_approx_equal(velocity, 2.5, 0.1, "Velocity within tolerance")
```

### Performance Testing
Measure frame-based performance for game-critical code:

```lua
local result = test_measure_performance(function()
    update_enemy_ai()
    check_collisions()
end, 100, "Game logic update")

test_assert(result.avg_frames < 2, "Game logic runs within 2 frames")
```

### Input Simulation
Test input-dependent behavior by simulating button states:

```lua
-- Simulate button press for one frame
test_press_button(0)    -- Left arrow
update_player()
test_assert(player.x < 64, "Player moves left")

-- Test button sequences
test_press_button(2)    -- Up (jump)
test_wait_frames(10)    -- Hold for jump duration
test_release_button(2)  -- Release
test_assert(player.jumping, "Jump initiated")
```

## Project-Specific Conventions

### Naming Conventions
- **Test functions**: `test_feature_name()` (e.g., `test_player_movement()`)
- **Setup functions**: `setup_feature()` or `init_test_scenario()`
- **Global variables**: Use descriptive names to avoid conflicts
- **Log levels**: `"info"` for important events, `"debug"` for detailed tracing, `"error"` for failures

### Conditional Compilation
Exclude testing code from production builds:

```lua
--#if TEST_BUILD
#include test_framework.lua
#include test_utils.lua
--#endif

function _init()
    init_game()
--#if TEST_BUILD
    test_init({phases = {"combat"}})
--#endif
end
```

### Debug Output Standards
Use structured logging with consistent prefixes:

```
[INFO] Test framework initialized - Phase: movement_test
[DEBUG] Assertion passed: 64 == 64
[ERROR] ASSERTION FAILED: Expected 5, got 3 - Player took unexpected damage
```

### Token Management
Be mindful of PICO-8's 8192 token limit:
- Use concise variable names in test code
- Avoid unnecessary functions or deep nesting
- Consider selective inclusion of framework components

## Integration Points

### External Dependencies
- **PICO-8 executable**: Must be in PATH for `run_test.sh`
- **Bash shell**: For test runner script execution
- **Command-line timeout**: Uses `timeout` command for test duration limits

### Cross-Component Communication
- **Parameter passing**: Via `stat(6)` from command line to PICO-8
- **Logging output**: `printh()` for console output captured by runner
- **Exit codes**: Test success/failure communicated via PICO-8 exit codes

### Build Integration
- **Modular inclusion**: Framework files included via `#include` directives
- **Conditional builds**: Use `--if` flags for test vs production builds
- **Command-line automation**: `run_test.sh` integrates with CI/CD pipelines

---

*Update this file if you add new major systems, workflows, or conventions.*
