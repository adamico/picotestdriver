# PicoTestDriver

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/adamico/picotestdriver)
[![PICO-8](https://img.shields.io/badge/PICO--8-0.2.5+-red.svg)](https://www.lexaloffle.com/pico-8.php)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A comprehensive automated testing framework for PICO-8 cartridges, enabling developers to create, run, and debug tests with detailed output and command-line integration.

## ✨ Features

- **Automated Testing**: Run tests programmatically with detailed logging
- **Command-Line Integration**: Execute specific test subtests via script parameters
- **Test Generation**: Generate test files with boilerplate code in seconds
- **Debug Output**: Comprehensive logging with multiple verbosity levels
- **Assertion Library**: Rich set of assertions for validating game behavior
- **Performance Testing**: Measure frame rates and performance metrics
- **Easy Integration**: Drop-in framework for existing PICO-8 projects
- **Cross-Platform**: Works on Linux, macOS, and Windows (via WSL)

## � Table of Contents

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

## �🚀 Quick Start

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

## 📖 Documentation

### Core API

#### Test Framework

```lua
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
```

-- Logging
test_log("Message", "info")  -- "info", "debug", "warn", "error"
```

#### Test Utilities

```lua
-- Assertions
test_assert(condition, "Should be true")
test_assert_equal(actual, expected, "Values should match")
test_assert_in_range(value, 0, 100, "Value out of range")

-- Input simulation
test_press_button(0)    -- Left button
test_release_button(0)  -- Release left button
test_hold_button(0, 30) -- Hold for 30 frames

-- Timing
test_start_timer()
-- ... run test code ...
local duration = test_end_timer()

-- Performance testing
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

The `--list` (or `-l`) option inspects your test cartridge and displays all available test phases. It searches for `test_init()` calls in:

1. The cartridge file itself (`.p8`)
2. All included `.lua` files (excluding `test_framework.lua` and `test_utils.lua`)

This helps you discover what test phases are available in your cartridge without having to examine the code manually.

**Examples:**

```bash
# List phases in default cartridge
./run_test.sh --list

# List phases in specific cartridge
./run_test.sh -l -c my_game_tests.p8

# Output example:
Available test phases in 'test_cart.p8':
  movement - Test phase
  collision - Test phase
  input - Test phase
  boundary - Test phase
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

    -- Simulate input and update
    test_press_button(1)  -- Right button
    update_player()

    -- Verify movement
    test_assert(player.x > 64, "Player moves right")
    test_assert_in_range(player.x, 60, 70, "Movement is reasonable")

    test_complete()
end
```

## 🏗️ Architecture

### Shared Library Design

The framework uses a **shared function library** to prevent code duplication and maintain consistency across components. This design ensures a single source of truth for common functionality.

#### Component Overview

```
lib/picotestdriver/
├── lib/
│   └── test_functions.sh           # Shared library (single source of truth)
├── run_test.sh                     # Production test runner
├── run_test_testable.sh            # Testable version for unit tests
├── test/
│   ├── test_helper.sh              # Test utilities
│   ├── test_integration.sh         # Integration tests
│   └── test_runner.sh              # Test suite runner
├── test_framework.lua              # PicoTestDriver framework core
└── test_utils.lua                  # PicoTestDriver utilities
```

#### Shared Functions Library (`lib/test_functions.sh`)

All shell components source this library to access common functionality:

- **`build_command(cart_file, phase, timeout, verbose)`**: Constructs PICO-8 command with proper timeout format (`-p phase:timeout`)
- **`parse_arguments(...)`**: Command-line argument parsing
- **`validate_timeout(timeout)`**: Input validation
- **Color functions**: Terminal output formatting
- **Help/configuration display**: User-facing documentation

**Sourcing Pattern:**
```bash
source "$LIB_DIR/test_functions.sh"
```

#### Timeout Parameter Flow

The framework passes timeout values from the shell to PICO-8 using stat(6):

1. **Shell Layer** (`run_test.sh`):
   ```bash
   build_command "test.p8" "tap_test" "30" "false"
   # Generates: pico8 -run test.p8 -p tap_test:30
   ```

2. **PICO-8 Layer** (`test_framework.lua`):
   ```lua
   function test_init(phase)
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

#### Benefits of Shared Library Architecture

- **Single Source of Truth**: Function signatures defined once, used everywhere
- **Consistency**: All components use identical parameter passing and validation
- **Maintainability**: Changes propagate automatically to all consumers
- **Testability**: Unit tests use same functions as production code
- **Type Safety**: Centralized validation prevents parameter mismatches

## 📁 Project Structure

```
pico8-test-framework/
├── README.md                    # This file
├── CHANGELOG.md                 # Project history (auto-generated from commits)
├── LICENSE                      # MIT license
├── run_test.sh                 # Test runner script
├── run_test_testable.sh        # Testable version for unit tests
├── lib/
│   ├── test_functions.sh        # Shared function library
│   └── README.md                # Library documentation
├── scripts/
│   ├── generate_changelog.sh   # Automated changelog generator
│   └── install_hooks.sh         # Git hooks installer
├── test_framework.lua          # Core framework
├── test_utils.lua              # Testing utilities
├── test_cart.p8               # Example cartridge
├── git-conventional-commits.yaml # Commit convention configuration
├── .git-hooks/                 # Custom git hooks directory
│   ├── commit-msg              # Commit message validation hook
│   └── prepare-commit-msg      # Changelog update prompt
├── .vscode/                    # VS Code workspace settings
│   └── settings.json           # PICO-8 development configuration
├── .github/                    # GitHub configuration
│   └── copilot-instructions.md # AI assistant guidelines
├── docs/                       # Documentation
│   ├── integration_guide.md    # Integration tutorial
│   ├── development_notes.md    # Implementation details
│   ├── changelog_automation.md # Changelog generation guide
│   └── ai_agent_workflow.md    # AI agent/CI workflow guide
├── test/                       # Test suite
│   ├── test_runner.sh          # Test suite executor
│   ├── test_helper.sh          # Test utilities
│   ├── test_integration.sh     # Integration tests
│   └── README.md               # Test suite documentation
└── examples/                   # Additional examples (future)
```

## 🎮 Example Output

```
=== PicoTestDriver v1.0.0 ===
Cartridge: test_cart.p8
Phase: movement_test
Timeout: 30s

Starting test execution...
Press Ctrl+C to abort

[INFO] Test framework initialized - Phase: movement_test
[INFO] Running test phase: movement_test
[INFO] Testing player movement
[DEBUG] Assertion passed: 64 == 64
[DEBUG] Assertion passed: 65 > 64
[DEBUG] Assertion passed: 65 in range [60, 70]
[INFO] Test completed successfully

Test execution completed successfully
```

## 🔧 Integration Guide

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
       test_init({
           phases = {"my_test", "another_test"},
           debug_level = "info"
       })
   end
   ```

3. **Update `_update60()`**:
   ```lua
   function _update60()
       test_update_frame()

       local phase = test_get_phase()
       if phase == "my_test" then
           run_my_test()
       else
           update_game()
       end
   end
   ```

4. **Create Test Functions**:
   ```lua
   function run_my_test()
       test_assert_equal(player.health, 100, "Player starts with full health")
       test_complete()
   end
   ```

### Running Tests

```bash
# From your project directory
/path/to/run_test.sh my_test

# Or copy run_test.sh to your project
cp /path/to/run_test.sh ./run_test.sh
./run_test.sh my_test
```

## 🧪 Test Patterns

### For Contributors
- **[Copilot Instructions](.github/copilot-instructions.md)** - AI assistant context for framework development

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
function test_button_handling()
    -- Test button press
    test_press_button(0)
    test_assert_true(btn(0), "Button press detected")

    -- Test button release
    test_release_button(0)
    test_assert_false(btn(0), "Button release detected")
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

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup

```bash
git clone https://github.com/your-repo/pico8-test-framework.git
cd pico8-test-framework

# Run tests
./run_test.sh

# Run specific tests
./run_test.sh movement_test --verbose
```

### AI-Assisted Development

This project includes [Copilot Instructions](.github/copilot-instructions.md) to help AI coding assistants understand the framework's unique PICO-8 constraints and patterns. AI tools can be helpful for:

- **Code generation** within PICO-8's Lua limitations
- **Pattern recognition** for test structure and assertions
- **Documentation** drafting and examples
- **Debugging assistance** with frame-based execution

However, AI suggestions should always be validated against PICO-8's specific constraints (token limits, available APIs, global scope requirements). The framework's patterns are designed to work within these limitations, so human judgment remains essential for ensuring compatibility.

**Model Recommendations**: For PICO-8 development, Claude 4 generally provides more accurate suggestions than Grok due to better understanding of technical constraints and code patterns.

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

The project uses automated changelog generation from conventional commits:

```bash
# Install git hooks (includes commit-msg validation and changelog prompt)
./scripts/install_hooks.sh

# Generate changelog from commits (interactive)
./scripts/generate_changelog.sh

# Generate from specific version
./scripts/generate_changelog.sh v1.0.0

# Generate between versions
./scripts/generate_changelog.sh v1.0.0 v1.1.0

# Auto-accept for AI agents/CI (non-interactive)
./scripts/generate_changelog.sh --auto-accept
./scripts/generate_changelog.sh -y v1.0.0
```

The `prepare-commit-msg` hook will automatically prompt you to update the changelog when making release-related commits. Use `--auto-accept` for automated workflows and AI agents.

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

## 📋 Roadmap

### Version 1.1.0
- [ ] Visual test results in PICO-8
- [ ] Screenshot comparison for UI tests
- [ ] Test result export (JSON/CSV)

### Version 1.2.0
- [ ] Integration with external test runners
- [ ] Performance regression detection
- [ ] Test coverage reporting

### Future Versions
- [ ] CI/CD pipeline integration
- [ ] Collaborative testing features
- [ ] Advanced mocking/stubbing

## 🐛 Troubleshooting

### Common Issues

**"PICO-8 executable not found"**
- Ensure PICO-8 is installed and in your PATH
- On Windows, use WSL or add PICO-8 to PATH

**"Test cartridge not found"**
- Check that your `.p8` file exists
- Ensure correct path in `run_test.sh`

**Tests not running**
- Verify framework files are included with `#include`
- Check that `test_init()` is called in `_init()`
- Ensure `test_update_frame()` is called in `_update60()`

### Debug Tips

Enable verbose logging:
```bash
./run_test.sh my_test --verbose
```

Check PICO-8 console output for detailed logs.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built for the PICO-8 community
- Inspired by testing frameworks in other languages
- Thanks to all contributors and testers

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/your-repo/pico8-test-framework/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-repo/pico8-test-framework/discussions)
- **PICO-8 BBS**: Post in the development tools thread

---

**Happy Testing!** 🎮✨