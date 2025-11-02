# PicoTestDriver

[![Version](https://img.shields.io/badge/version-3.0.3-blue.svg)](https://github.com/adamico/picotestdriver)
[![PICO-8](https://img.shields.io/badge/PICO--8-0.2.5+-red.svg)](https://www.lexaloffle.com/pico-8.php)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A comprehensive automated testing framework for PICO-8 cartridges, enabling developers to create, run, and debug tests with detailed output and command-line integration.

## Features

- **Automated Testing**: Run tests programmatically with detailed logging
- **Command-Line Integration**: Execute specific test subtests via script parameters
- **Test Generation**: Generate test files with boilerplate code in seconds
- **Debug Output**: Comprehensive logging with multiple verbosity levels
- **Assertion Library**: Rich set of assertions for validating game behavior
- **Performance Testing**: Measure frame rates and performance metrics
- **Easy Integration**: Drop-in framework for existing PICO-8 projects
- **Cross-Platform**: Works on Linux, macOS, and Windows (via WSL)

## Table of Contents

- [Quick Start](#-quick-start)
- [Documentation](#-documentation)
  - [Core API](#core-api)
  - [Command Line Usage](#command-line-usage)
- [Examples](#-examples)
- [Testing Your Tests](#-testing-your-tests)
- [Best Practices](#-best-practices)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

## Quick Start

### 1. Download the Framework

```bash
# Clone or download the framework files
git clone https://github.com/adamico/picotestdriver.git
cd picotestdriver
```

### 2. Run the Demo

```bash
# Run the demo test cartridge
./ptd test -d

# List available test subtests
./ptd test -d --list
# Available subtests:
#   - movement:    Player movement tests
#   - collision:   Collision detection tests
#   - input:       Input handling tests
#   - boundary:    Boundary clamping tests
#   - assertions:  Various assertion patterns
#   - timing:      Frame-dependent behavior tests
#   - edge_cases:  Boundary conditions and corner cases

# Run a specific subtest
./ptd test -d assertions
```

### 3. Generate Your Test Files

Create test files for your project with one command:

```bash
# Generate test files in a tests directory
./ptd generate -d tests -n my_game

# Generate with custom subtests and timeout
./ptd generate -d tests -n my_game \
  -s "player,enemy,bullet,collision" \
  -t 60

# See all options
./ptd help generate
```

This creates:
- `tests/my_game.p8` - Cartridge with #include statements
- `tests/my_game.lua` - Test file with subtest boilerplate

### 4. Run Your Tests

```bash
# Run all tests in your cartridge
./ptd test -c tests/my_game.p8

# Run a specific subtest
./ptd test -c tests/my_game.p8 player

# Run with custom timeout (60 seconds)
./ptd test -c tests/my_game.p8 collision 60

# List all available subtests
./ptd test -c tests/my_game.p8 --list
```

### 5. Manual Integration (Alternative)

Or add these lines to your cartridge manually:

```lua
#include test_framework.lua
#include test.lua

function _init()
    -- Initialize your game
    init_game()

    -- Initialize test framework
    local subtest_names = {}
    for i = 1, #subtests do
        subtest_names[i] = subtests[i].name
    end
    
    test_init({
        subtests = subtest_names,
        timeout_frames = 1800,  -- 30 seconds
        debug_level = "info"
    })
end

function _update60()
    test_update_frame()

    -- Run your test subtests
    local subtest = subtests[current_subtest]
    if subtest then
        local subtest_frame = test_frame - subtest_start_frame
        -- Dispatch to test functions...
    end
end
```

## Documentation

### Core API

#### Test Framework

```lua
-- Initialize the framework
test_init(options)
-- options: {
--   phases = {"phase1", "phase2", ...},
--   default_phase = "phase1",
--   timeout_frames = 1800,  -- Optional: defaults to 30s
--   debug_level = "info"    -- "none", "info", "debug"
-- }
-- Note: timeout_frames is automatically set from command line if provided

-- Get current test phase
local phase = test_get_phase()

-- Get timeout values (useful for test logic)
local timeout_frames = test_get_timeout_frames()
local timeout_seconds = test_get_timeout_seconds()  -- May be nil

-- Check if test is completed
if test_is_completed() then
    -- Test finished
end

-- Mark test as completed (automatically calls stop())
test_complete()

-- Update frame counter (call in _update60)
-- Automatically calls test_complete() when timeout is reached
test_update_frame()

-- Logging with levels
test_log("Message", "info")   -- General information (default)
test_log("Message", "debug")  -- Detailed debugging info
test_log("Message", "warn")   -- Warnings
test_log("Message", "error")  -- Errors
```

**Log Levels:**
- `debug_level = "none"` - Suppress all logging output
- `debug_level = "info"` - Show INFO, WARN, ERROR messages (default)
- `debug_level = "debug"` - Show all messages including DEBUG

When using `debug_level = "debug"`, you'll see detailed information about:
- Button state changes
- Frame-by-frame test execution
- Auto-calculated timeout values
- Internal test framework operations

Example output with debug level:
```
[DEBUG] Auto-calculated timeout: 1440 frames
[DEBUG] Button 1 pressed
[INFO] === MOVEMENT TEST ===
[INFO] ✓ MOVEMENT: Player moves right
[WARN] No collision expected at this position
[ERROR] Test failed: Expected value 10, got 5
```

#### Test Utilities

```lua
-- Assertions
test_assert(condition, "Should be true")
test_assert_equal(actual, expected, "Values should match")
test_assert_in_range(value, 0, 100, "Value out of range")

-- Button state utilities (for testable input systems)
test_set_button_state(0, true)   -- Mark button 0 as pressed
test_set_button_state(0, false)  -- Mark button 0 as released
local state = test_get_button_state(0)  -- Get override state (or nil)
test_clear_button_states()       -- Clear all overrides

-- Timing
test_start_timer()
-- ... run test code ...
local duration = test_end_timer()

-- Performance monitoring
test_log_memory_usage("Before initialization")
test_log_cpu_usage("After complex operation")
local result = test_measure_performance(my_function, 100, "My Function")
```

### Command Line Usage

The `ptd` command provides two main subcommands:

#### ptd test - Run Tests

```bash
# Basic usage - run the demo
./ptd test -d

# Run tests from your cartridge
./ptd test -c my_test.p8

# Run specific subtest
./ptd test -c my_test.p8 movement

# Custom timeout (in seconds)
./ptd test -c my_test.p8 combat 120

# List available test subtests
./ptd test -c my_test.p8 --list

# Help and options
./ptd test --help
./ptd test -c my_test.p8 --verbose
```

#### ptd generate - Generate Test Files

```bash
# Generate test files in current directory
./ptd generate -n my_test

# Generate in specific directory
./ptd generate -d tests -n my_game

# Custom subtests and timeout
./ptd generate -n my_test \
  -s "player,enemy,bullet,collision" \
  -t 60

# Custom framework path
./ptd generate -n my_test \
  --framework-path ./lib/test_framework.lua

# Help and options
./ptd help generate
```



#### Exit Codes

PicoTestDriver returns standard exit codes for automation and CI/CD integration:

- **`0`**: Success - tests completed normally
- **`1`**: Invalid arguments provided
- **`2`**: PICO-8 not found in PATH
- **`3`**: Test cartridge file not found
- **`124`**: Timeout reached during test execution

#### Command Line Options (ptd test)

- **`-h, --help`**: Display help information and usage examples
- **`-v, --version`**: Show the framework version
- **`-c, --cart FILE`**: Specify the test cartridge file (default: `test_cart.p8`)
- **`-d, --demo`**: Run the demo test cartridge
- **`-l, --list`**: List all available test subtests defined in the cartridge
- **`--verbose`**: Enable detailed output during test execution

#### Command Line Options (ptd generate)

- **`-h, --help`**: Display help information
- **`-d, --dir DIR`**: Output directory (default: current directory)
- **`-n, --name NAME`**: Test file base name (default: `test`)
- **`-s, --subtests LIST`**: Comma-separated list of subtest names (default: `movement,collision,input,boundary`)
- **`-t, --timeout SECONDS`**: Default timeout in seconds (default: `30`)
- **`--framework-path PATH`**: Path to test_framework.lua (default: `../lib/picotestdriver/test_framework.lua`)

#### The --list Option

The `--list` (or `-l`) option inspects your test cartridge and displays all available test subtests. It searches for subtest definitions in:

1. The cartridge file itself (`.p8`)
2. All included `.lua` files (excluding `test_framework.lua` and `test_utils.lua`)

This helps you discover what test subtests are available in your cartridge without having to examine the code manually.

**Examples:**

```bash
# List subtests in demo cartridge
./ptd test -d --list

# List subtests in specific cartridge
./ptd test -c my_game_tests.p8 --list

# Output example:
Available test subtests in 'test_cart.p8':
  assertions
  boundary
  collision
  edge_cases
  input
  movement
  timing

Usage: ptd test -c test_cart.p8 SUBTEST
```

### Example Test

```lua
function test_player_movement()
    test_log("Testing player movement", "info")

    -- Setup test scenario
    player.x = 64
    player.y = 64

    -- Test initial state
    test_assert_equal(player.x, 64, "Player starts at center")

    -- Simulate input with testable wrapper
    -- (Requires game code to check test_get_button_state())
    test_set_button_state(1, true)  -- Right button
    update_player()

    -- Verify movement
    test_assert(player.x > 64, "Player moves right")
    test_assert_in_range(player.x, 60, 70, "Movement is reasonable")

    test_complete()
end
```

## Architecture

PicoTestDriver uses a simple, unified architecture centered around the `ptd` command:

```
Command Line          PICO-8 Runtime          Test Cartridge
    (ptd)      →      (stat(6) params)  →    (test_framework.lua)
      ↓                      ↓                        ↓
  Subcommands           Parse timeout           Run subtests
  test/generate         Set frames              Log results
                        Monitor timeout         Auto-complete
```

### Timeout Parameter Flow

The framework passes timeout values from the shell to PICO-8 using stat(6):

1. **Command Layer** (`ptd test`):
   ```bash
   ptd test -c test.p8 tap_test 30
   # Generates: pico8 -run test.p8 -p tap_test:30
   ```

2. **PICO-8 Layer** (`test_framework.lua`):
   ```lua
   function test_init(config)
       local cmd = stat(6)  -- e.g., "tap_test:30"
       local timeout = parse_timeout(cmd)  -- 30
       timeout_frames = timeout * 60  -- 1800 frames
   end
   ```

3. **Automatic Termination**:
   ```lua
   function test_update_frame()
       if frame_count >= timeout_frames then
           test_complete()  -- Calls stop()
       end
   end
   ```

## Project Structure

```
picotestdriver/
├── README.md                       # This file
├── CHANGELOG.md                    # Project history  
├── LICENSE                         # MIT license
├── VERSION                         # Version number
├── ptd                             # Main command (test & generate)
├── lib/
│   ├── test_functions.sh           # Shared function library (for tests)
│   └── README.md                   # Library documentation
├── scripts/
│   └── README.md                   # Scripts documentation
├── test_framework.lua             # Core testing framework
├── test_utils.lua                 # Testing utilities
├── main.lua                       # Demo test implementation
├── test_cart.p8                  # Demo cartridge
├── .vscode/                       # VS Code settings
│   └── settings.json              # PICO-8 configuration
├── .github/                       # GitHub configuration
│   └── copilot-instructions.md    # AI assistant guidelines
├── docs/                          # Documentation
│   ├── integration_guide.md       # Integration tutorial
│   ├── development_notes.md       # Implementation details
│   ├── changelog_automation.md    # Changelog guide (see git-changelog-automation)
│   ├── ai_agent_workflow.md       # AI agent/CI guide
│   └── todo.md                    # Project roadmap
└── test/                          # Test suite (118 tests)
    ├── test_runner.sh             # Test executor
    ├── test_helper.sh             # Test utilities
    ├── test_functions.sh          # Function tests
    ├── test_integration.sh        # Integration tests
    ├── test_e2e.sh                # End-to-end tests
    ├── test_generator.sh          # Generator tests
    ├── test_timeout_param.sh      # Timeout tests
    ├── test_new_features.sh       # Feature tests
    └── README.md                  # Test suite docs
```

## Example Output

```
=== PicoTestDriver v2.0.2 ===
Cartridge: test_cart.p8
Subtest: movement
Timeout: 30s

Starting test execution...
Press Ctrl+C to abort

[INFO] === PICOTESTDRIVER DEMO ===
[INFO] Starting subtest: movement
[INFO] === MOVEMENT TEST ===
[INFO] ✓ MOVEMENT: Player moves right
[INFO] Advancing to subtest: collision
[INFO] === COLLISION TEST ===
[INFO] ✓ COLLISION: Detected when enemy is close
[INFO] All subtests complete!

Test execution completed successfully
```

## Integration Guide

### Adding to Existing Cartridge

1. **Include Framework Files**:
   ```lua
   #include test_framework.lua
   #include test_utils.lua
   ```

2. **Initialize in `_init()`**:
   ```lua
   function _init()
       init_game()
       
       -- Build subtest names list
       local subtest_names = {}
       for i = 1, #subtests do
           subtest_names[i] = subtests[i].name
       end
       
       test_init({
           subtests = subtest_names,
           timeout_frames = 1800,  -- 30 seconds
           debug_level = "info"
       })
   end
   ```

3. **Define Your Subtests**:
   ```lua
   local subtests = {
       { name = "player_test", duration = 120 },
       { name = "enemy_test", duration = 180 },
   }
   ```

4. **Update `_update60()`**:
   ```lua
   function _update60()
       test_update_frame()

       local subtest = subtests[current_subtest]
       if subtest then
           if subtest.name == "player_test" then
               test_player()
           elseif subtest.name == "enemy_test" then
               test_enemy()
           end
       end
   end
   ```

5. **Create Test Functions**:
   ```lua
   function test_player()
       test_assert_equal(player.health, 100, "Player starts with full health")
       -- Complete when duration reached
       if subtest_frame >= subtests[current_subtest].duration then
           next_subtest()
       end
   end
   ```

### Running Tests

```bash
# From your project directory
/path/to/ptd test -c my_test.p8

# Or copy ptd to your project
cp /path/to/ptd ./ptd
chmod +x ./ptd
./ptd test -c my_test.p8

# Run specific subtest
./ptd test -c my_test.p8 player_test
```

## Test Patterns

### Unit Testing Game Logic

```lua
function test_collision_detection()
    -- Setup
    local player = {x = 10, y = 10, size = 4}
    local enemy = {x = 12, y = 12, size = 4}

    -- Test
    local collision = check_collision(player, enemy)
    test_assert_true(collision, "Nearby objects collide")

    -- Edge case
    enemy.x = 50
    collision = check_collision(player, enemy)
    test_assert_false(collision, "Distant objects don't collide")
end
```

### Input Testing

```lua
-- Note: PICO-8's btn() reads hardware directly and can't be mocked.
-- Use a testable input wrapper in your game:

function my_btn(b)
    -- Check for test override first
    if test_get_button_state then
        local override = test_get_button_state(b)
        if override ~= nil then return override end
    end
    return btn(b)
end

function test_button_handling()
    -- Test button state override
    test_set_button_state(0, true)
    test_assert_true(my_btn(0), "Button override works")

    -- Test button release
    test_set_button_state(0, false)
    test_assert_false(my_btn(0), "Button release works")
    
    -- Clear overrides
    test_clear_button_states()
end
```

### Performance Testing

```lua
function test_render_performance()
    local result = test_measure_performance(function()
        draw_sprites()
        draw_ui()
    end, 100, "Full render")

    test_assert(result.avg_frames < 2, "Render should be fast")
end
```

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup

```bash
git clone https://github.com/adamico/picotestdriver.git
cd picotestdriver

# Run demo tests
./ptd test -d

# Run specific test
./ptd test -d movement --verbose

# Run test suite (118 tests)
bash test/test_runner.sh
```

### AI-Assisted Development

This project includes [Copilot Instructions](.github/copilot-instructions.md) to help AI coding assistants understand the framework's unique PICO-8 constraints and patterns. AI tools can be helpful for:

- **Code generation** within PICO-8's Lua limitations
- **Pattern recognition** for test structure and assertions
- **Documentation** drafting and examples
- **Debugging assistance** with frame-based execution

However, AI suggestions should always be validated against PICO-8's specific constraints (token limits, available APIs, global scope requirements). The framework's patterns are designed to work within these limitations, so human judgment remains essential for ensuring compatibility.

**Model Recommendations**: For PICO-8 development, Claude Sonnet 4.5 generally provides very accurate suggestions due to a gret understanding of technical constraints and code patterns.

### Commit Conventions

This project uses conventional commits. Please follow these commit types:

- `feat:` - New features
- `fix:` - Bug fixes  
- `refactor:` - Code restructuring
- `perf:` - Performance improvements
- `style:` - Code style changes
- `test:` - Testing changes
- `build:` - Build system changes
- `ops:` - Operational changes
- `docs:` - Documentation
- `chore:` - Miscellaneous tasks

Example: `git commit -m "feat: add performance testing utilities"`

### Changelog Management

> **Note**: As of v2.0.2, the changelog automation tools have been extracted to a standalone library: [git-changelog-automation](https://github.com/adamico/git-changelog-automation)

The project uses automated changelog generation from conventional commits:

```bash
# Option 1: Use standalone git-changelog-automation (recommended)
changelog                    # Generate from last tag
changelog --release 1.2.0    # Release version
changelog --install-hooks    # Install git hooks

# Option 2: Use bundled scripts (backward compatibility)
./scripts/generate_changelog.sh
./scripts/generate_changelog.sh v1.0.0
./scripts/generate_changelog.sh --auto-accept
```

See [docs/changelog-automation.md](docs/changelog-automation.md) for migration details and documentation.

### VS Code Configuration

The project includes optimized VS Code settings for PICO-8 development:
- Lua language server configured for PICO-8 Lua 5.2
- Custom diagnostics that understand PICO-8 limitations
- PICO-8 specific operator support (`+=`, `-=`, `*=`)

### Adding New Features

1. Fork the repository
2. Create a feature branch
3. Add tests for your feature
4. Ensure all tests pass
5. Submit a pull request

## Troubleshooting

### Common Issues

**"PICO-8 executable not found"**
- Ensure PICO-8 is installed and in your PATH
- On Windows, use WSL or add PICO-8 to PATH

**"Test cartridge not found"**
- Check that your `.p8` file exists
- Ensure correct path is specified with `-c` option
- Use absolute or relative path from current directory

**Tests not running**
- Verify framework files are included with `#include`
- Check that `test_init()` is called in `_init()`
- Ensure `test_update_frame()` is called in `_update60()`
- Verify subtest definitions match the requested subtest name

### Debug Tips

Enable verbose logging:
```bash
./ptd test -c my_test.p8 --verbose
```

List available subtests:
```bash
./ptd test -c my_test.p8 --list
```

Check PICO-8 console output for detailed logs and test_log() messages.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built for the PICO-8 community
- Inspired by testing frameworks in other languages
- Thanks to all contributors and testers

## Support

- **Issues**: [GitHub Issues](https://github.com/adamico/picotestdriver/issues)
- **Discussions**: [GitHub Discussions](https://github.com/adamico/picotestdriver/discussions)
- **PICO-8 BBS**: Post in the development tools thread

---

**Happy Testing!**