# PICO-8 Automated Testing Framework

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/your-repo/pico8-test-framework)
[![PICO-8](https://img.shields.io/badge/PICO--8-0.2.5+-red.svg)](https://www.lexaloffle.com/pico-8.php)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A comprehensive automated testing framework for PICO-8 cartridges, enabling developers to create, run, and debug tests with detailed output and command-line integration.

## ✨ Features

- **Automated Testing**: Run tests programmatically with detailed logging
- **Command-Line Integration**: Execute specific test phases via script parameters
- **Debug Output**: Comprehensive logging with multiple verbosity levels
- **Assertion Library**: Rich set of assertions for validating game behavior
- **Performance Testing**: Measure frame rates and performance metrics
- **Easy Integration**: Drop-in framework for existing PICO-8 projects
- **Cross-Platform**: Works on Linux, macOS, and Windows (via WSL)

## 🚀 Quick Start

### 1. Download the Framework

```bash
# Clone or download the framework files
git clone https://github.com/your-repo/pico8-test-framework.git
cd pico8-test-framework
```

### 2. Run the Example

```bash
# Run all tests
./run_test.sh

# Run specific test phase
./run_test.sh movement_test

# Run with custom timeout
./run_test.sh collision_test 60
```

### 3. Integrate into Your Project

Add these lines to your cartridge:

```lua
#include test_framework.lua
#include test_utils.lua

function _init()
    -- Initialize your game
    init_game()

    -- Initialize test framework
    test_init({
        phases = {"movement", "combat", "ui"},
        default_phase = "all"
    })
end

function _update60()
    test_update_frame()

    -- Run tests or normal game logic
    local phase = test_get_phase()
    if phase == "movement" then
        test_movement()
    elseif phase == "all" then
        -- Normal game update
        update_game()
    end
end
```

## 📖 Documentation

### Core API

#### Test Framework

```lua
-- Initialize the framework
test_init(options)

-- Get current test phase
local phase = test_get_phase()

-- Check if test is completed
if test_is_completed() then
    -- Test finished
end

-- Mark test as completed
test_complete()

-- Update frame counter (call in _update60)
test_update_frame()

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

```bash
# Basic usage
./run_test.sh

# Run specific phase
./run_test.sh movement_test

# Custom timeout
./run_test.sh combat_test 120

# Help and options
./run_test.sh --help
./run_test.sh --list
./run_test.sh --verbose
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

## 📁 Project Structure

```
pico8-test-framework/
├── README.md                    # This file
├── CHANGELOG.md                 # Project history and version notes
├── LICENSE                      # MIT license
├── run_test.sh                 # Test runner script
├── test_framework.lua          # Core framework
├── test_utils.lua              # Testing utilities
├── test_cart.p8               # Example cartridge
├── git-conventional-commits.yaml # Commit convention configuration
├── .git-hooks/                 # Custom git hooks directory
│   └── commit-msg              # Commit message validation hook
├── .vscode/                    # VS Code workspace settings
│   └── settings.json           # PICO-8 development configuration
├── .github/                    # GitHub configuration
│   └── copilot-instructions.md # AI assistant guidelines
├── docs/                       # Documentation
│   ├── integration_guide.md    # Integration tutorial
│   └── development_notes.md    # Implementation details
└── examples/                   # Additional examples (future)
```

## 🎮 Example Output

```
=== PICO-8 Test Framework Runner v1.0.0 ===
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