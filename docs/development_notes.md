# Development Notes & Implementation Details

This document captures key insights, design decisions, and implementation details from the development of the PICO-8 Automated Testing Framework.

## PICO-8 Specific Challenges & Solutions

### Command-Line Parameter Passing
- **Challenge**: PICO-8 has limited command-line integration
- **Solution**: Used `stat(6)` to read parameters passed via `-p` flag
- **Limitation**: Only one parameter string available, requiring custom parsing

### Lua Environment Constraints
- **Missing Functions**: No `pcall`, `table.concat`, `table.unpack` in PICO-8 Lua
- **Global Scope**: All functions are global by default
- **Solution**: Adapted APIs to work within these constraints

### Token & Character Limits
- **Challenge**: PICO-8 cartridges have token limits (8192) and compressed size limits
- **Solution**: Modular design allowing selective inclusion of components

## Testing Patterns Developed

### Function Override System
```lua
-- Original approach (doesn't work in PICO-8)
local original = some_function
some_function = function(...) debug_log(...) return original(...) end

-- PICO-8 compatible approach
-- Manual override with documentation for restoration
test_override_function("update_position", debug_version)
-- User responsible for restoring: update_position = original_update_position
```

### Frame-Based Test Execution
- **Problem**: PICO-8 runs at 60 FPS, tests need to be frame-aware
- **Solution**: `test_update_frame()` called in `_update60()`, frame counting for timing
- **Benefit**: Accurate simulation of game timing and physics

### Phase-Based Organization
- **Problem**: Running all tests simultaneously causes conflicts
- **Solution**: Command-line phase selection allows isolated testing
- **Benefit**: Faster iteration, clearer test organization

## Integration Patterns

### Minimal Integration
```lua
-- Add to existing cartridge
#include test_framework.lua
#include test_utils.lua

function _init()
    init_game()
    test_init({phases = {"my_test"}})
end

function _update60()
    test_update_frame()
    if test_get_phase() == "my_test" then
        run_my_test()
    else
        update_game()
    end
end
```

### Test Data Management
- **Pattern**: Separate setup functions for test scenarios
- **Benefit**: Clean test isolation, reusable test data
- **Example**: `setup_combat_scenario()`, `setup_movement_test()`

## Debug Output Evolution

### Early Debug Output
```
check_boundary_crossing() called
  Parameters: old_x=83.5005, new_x=82.5005, dir=-1, s=4
  Boundaries: left=4, right=123
  Result: false
```

### Structured Debug Output
```
[INFO] Test framework initialized - Phase: boundary_test
[DEBUG] Assertion passed: 64 == 64
[ERROR] ASSERTION FAILED: Expected 5, got 3
```

## Boundary Crossing Test Development

### Initial Implementation
- Simple boundary detection: `x = mid(left, x, right)`
- Basic reversal: `dir = -dir`

### Advanced Implementation
- Smooth deceleration using configurable acceleration system
- Frame-based reversal timing
- Position clamping with direction change
- Visual feedback integration

### Debug Challenges
- **Issue**: Test not triggering boundary crossing
- **Root Cause**: Player positioned outside boundary crossing zone
- **Solution**: Position player near boundary with appropriate velocity

## Command-Line Script Evolution

### Basic Version
```bash
#!/bin/bash
timeout 30 pico8 -run test.p8 -p "$1"
```

### Advanced Version
```bash
#!/bin/bash
# Parameter validation, help system, colored output
# Cross-platform compatibility, error handling
```

## Design Decisions

### API Design Philosophy
- **Simple**: Easy for beginners to adopt
- **Flexible**: Powerful for complex testing scenarios
- **PICO-8 Native**: Works within platform constraints
- **Extensible**: Room for future enhancements

### Error Handling
- **PICO-8 Limitation**: No exception handling
- **Solution**: Return values and logging for error indication
- **Pattern**: `test_assert()` returns success/failure boolean

### Performance Considerations
- **Overhead**: Testing adds frame time
- **Solution**: Conditional compilation flags, selective test execution
- **Measurement**: Built-in performance testing utilities

## Future Enhancement Possibilities

### Short Term
- Visual test results overlay in PICO-8
- Screenshot comparison for UI testing
- Test result export (JSON format)
- Integration with external test runners

### Long Term
- CI/CD pipeline integration
- Collaborative testing features
- Test coverage analysis
- Performance regression detection

## Lessons Learned

### Development Process
1. **Start Simple**: Basic assertion framework first
2. **Iterate on Real Problems**: Boundary testing revealed physics bugs
3. **Extract Gradually**: Move from integrated to standalone framework
4. **Document Thoroughly**: Capture design decisions for future contributors

### Testing Philosophy
- **Test the Game**: Framework tests actual game behavior, not isolated units
- **Debug-Friendly**: Rich logging helps identify issues quickly
- **Performance-Aware**: Tests shouldn't break game performance
- **Integration-First**: Easy to add to existing projects

### Community Considerations
- **Accessibility**: Framework should help newcomers learn testing
- **Compatibility**: Work with existing PICO-8 development workflows
- **Documentation**: Comprehensive guides for adoption
- **Examples**: Real working examples, not just API docs

## Technical Debt & Known Limitations

### Current Limitations
- Function override system requires manual restoration
- No exception handling (PICO-8 limitation)
- Limited string manipulation functions
- Single parameter string from command line

### Workarounds Implemented
- Manual function restoration documentation
- Return value error indication
- Custom string formatting functions
- Phase-based parameter passing

### Future Improvements
- Enhanced function override system
- Better error handling patterns
- Additional utility functions
- Extended command-line options

## Contributing Guidelines

### Code Style
- PICO-8 Lua conventions
- Clear function naming
- Comprehensive comments
- Error handling patterns

### Commit Conventions
This project uses conventional commits defined in `git-conventional-commits.yaml`:

**Commit Types:**
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

**Examples:**
```bash
git commit -m "feat: add performance testing utilities"
git commit -m "fix: resolve collision detection bug"
git commit -m "docs: update integration guide"
```

### Development Environment
- **VS Code Settings**: `.vscode/settings.json` provides optimized configuration for PICO-8 development
- **Git Hooks**: Custom hooks in `.git-hooks/` enforce commit conventions
- **Copilot Instructions**: `.github/copilot-instructions.md` guides AI assistants

### Testing
- Test framework changes with framework itself
- Include example usage
- Update documentation
- Cross-platform verification

### Documentation
- Update relevant docs for changes
- Include code examples
- Explain design decisions
- Note limitations and workarounds

---

*This document should be updated as the framework evolves to capture new insights and decisions.*