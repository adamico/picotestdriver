# Changelog

## [2.0.2] - 2025-11-01

### Features
- feat: add color formatting to all help text and command output

## [2.0.1] - 2025-11-01

### Features
- feat: add comprehensive edge case tests to demo cartridge

### Bug Fixes
- fix: improve test utilities and documentation

### Documentation
- docs: update todo.md with completed improvements

## [2.0.0] - 2025-11-01


### BREAKING CHANGES
- remove run_test.sh and generate_test.sh scripts (replaced by ptd command)
- all functionality now accessible via unified `ptd` command

### Features
- complete migration to single `ptd` command interface
- simplified codebase with single entry point
- updated all tests to use ptd command (118/118 passing)

### Migration Guide
- `run_test.sh -c file.p8` → `ptd test -c file.p8`
- `generate_test.sh -d tests -n x` → `ptd generate -d tests -n x`


## [1.4.0] - 2025-11-01


### Features
- add unified `ptd` command with subcommand architecture (ptd test, ptd generate)
- improve command-line interface with clearer help text and examples
- add exit codes for better automation and CI/CD integration
- maintain backward compatibility with run_test.sh and generate_test.sh


## [1.3.0] - 2025-11-01


### Features
- add VERSION file as single source of truth
- auto-update README version badge during release


## [1.2.0] - 2025-11-01


### Features
- remove [Unreleased] section from user-facing CHANGELOG


## [1.1.3] - 2025-11-01


### Features
- add automatic CHANGELOG sync validation with git tags

### Bug Fixes
- None yet

### Performance Improvements
- None yet


## [1.1.2] - 2025-11-01


### Features
- add --release flag to automate version releases

### Bug Fixes
- None yet

### Performance Improvements
- None yet


## [1.1.1] - 2025-11-01

### Features
- Improved changelog generation to properly merge [Unreleased] sections
- Comprehensive test suite for changelog generation script (19 tests)

### Bug Fixes
- Added deduplication to changelog merge to prevent duplicate entries

### Refactoring
- Cleaned up CHANGELOG and moved roadmap to development_notes.md
- Simplified CHANGELOG footer with concise references

### Documentation
- Created `scripts/README.md` documenting all scripts and testing workflow
- Updated roadmap in `docs/development_notes.md`

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

## [1.0.1] - 2025-11-01

### Features
- Development environment setup with git hooks for conventional commits
- Automated commit message validation
- Git hooks installation script

### Documentation
- Enhanced documentation with development workflow guide
- Added contribution guidelines

## [1.0.0] - 2025-11-01

### Features
- Initial release of PICO-8 Automated Testing Framework
- Core test execution with `run_test.sh` script
- Testable architecture with `run_test_testable.sh`
- Test helper utilities for PICO-8
- Support for custom timeout values
- Phase-based test execution
- Exit code propagation from PICO-8 to shell
- Comprehensive README documentation

### Documentation
- Complete usage guide and examples
- Architecture documentation
- Development setup instructions

---

**About this project:** PICO-8 Automated Testing Framework. See [docs/development_notes.md](docs/development_notes.md) for roadmap and design decisions.

**Format:** This changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**Automation:** Maintained using conventional commits. Run `./scripts/generate_changelog.sh --auto-accept` to auto-generate entries from commits.