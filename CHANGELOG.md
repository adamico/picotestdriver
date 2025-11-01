# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Features
- None yet

### Bug Fixes
- None yet

### Performance Improvements
- None yet

## [1.1.0] - 2025-11-01

### Features
- Shared functions library (`lib/test_functions.sh`) for code consistency and preventing code desync
- Timeout parameter passing from shell to PICO-8 via `-p phase:timeout` format
- Automatic test termination when timeout is reached
- Changelog automation with `generate_changelog.sh` script
- Auto-accept flag (`--auto-accept`, `-y`, `--non-interactive`) for AI agents and CI/CD
- Architecture section in README documenting shared library design
- AI agent workflow guide with complete automation examples
- Enhanced `--list` option to check included .lua files
- `-c`/`--cart` option to specify test cartridge file
- Comprehensive GitHub repository enhancements

### Bug Fixes
- Fixed code desync between `run_test.sh`, `run_test_testable.sh`, and `test_helper.sh`
- Corrected `build_command()` function signature consistency across test suite
- Fixed cart metadata

### Documentation
- Created `docs/changelog_automation.md` - Complete changelog automation guide
- Created `docs/ai_agent_workflow.md` - AI agent/CI workflow guide
- Created `lib/README.md` - Shared library documentation
- Updated README with architecture section and changelog management
- Added prepare-commit-msg hook for changelog prompts
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