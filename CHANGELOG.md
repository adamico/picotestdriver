# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Features
- Shared functions library (`lib/test_functions.sh`) for code consistency
- Timeout parameter passing from shell to PICO-8 via `-p phase:timeout`
- Automatic test termination when timeout is reached
- Architecture section in README documenting shared library design

### Bug Fixes
- Fixed code desync between `run_test.sh`, `run_test_testable.sh`, and `test_helper.sh`
- Corrected `build_command()` function signature consistency across test suite

### Performance Improvements
- None

## [1.0.1] - 2025-10-31

### Features
- Git conventional commits configuration with validation hook
- VS Code settings optimized for PICO-8 development
- Copilot instructions for AI-assisted development
- Comprehensive development workflow documentation

### Documentation
- Added `.git-hooks/commit-msg` for commit message validation
- Created `git-conventional-commits.yaml` with commit type definitions
- Added `.vscode/settings.json` for PICO-8 IDE integration
- Created `.github/copilot-instructions.md` for AI assistant guidance

## [1.0.0] - 2025-10-31

### Features
- Core test framework with parameter parsing, phase management, and logging
- Rich assertion library (`test_assert`, `test_assert_equal`, `test_assert_in_range`, etc.)
- Input simulation utilities (`test_press_button`, `test_release_button`)
- Performance measurement tools (`test_measure_performance`)
- Command-line test runner (`run_test.sh`) with timeout support
- Phase-based test organization for isolated testing
- Function override system for runtime debugging
- Frame-accurate test timing (60 FPS)
- Cross-platform Bash script integration
- Example cartridge demonstrating framework features

### Documentation
- Comprehensive README with quick start guide
- Integration guide for adding framework to existing projects
- Development notes capturing design decisions and patterns
- API reference for all framework functions
- Test suite documentation

### Technical Implementation
- PICO-8 compatible Lua (works within platform limitations)
- Command-line parameter passing via `stat(6)`
- Structured logging with configurable verbosity levels
- Modular architecture to manage token limits
- Robust error reporting without exception handling

---

## Project Context

This framework was developed as part of the **obsi** PICO-8 game project, where complex boundary mechanics and physics required sophisticated testing capabilities. The framework evolved from manual testing to automated command-line execution, then was extracted into a reusable community tool.

### Original Use Case
- **Game**: One-button Space Invaders with risk/reward mechanics
- **Challenge**: Complex boundary reversal physics with acceleration/deceleration
- **Solution**: Automated testing with detailed debug output and frame-accurate simulation

### Known Limitations
- Function override system requires manual restoration
- No exception handling (PICO-8 Lua limitation)
- Single command-line parameter string
- Manual test data cleanup required

### Future Roadmap
- Visual test results overlay in PICO-8
- Screenshot comparison testing
- Test result export functionality (JSON format)
- CI/CD integration examples
- Enhanced function override system with automatic restoration
- Performance regression detection
- Test coverage analysis

---

*This changelog is maintained using [git-conventional-commits](https://github.com/qoomon/git-conventional-commits). 
Run `scripts/generate_changelog.sh` to auto-generate entries from commits.*