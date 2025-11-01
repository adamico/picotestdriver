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

---

**About this project:** PICO-8 Automated Testing Framework - Developed as part of the [obsi](https://github.com/adamico/obsi) PICO-8 game project. See [docs/development_notes.md](docs/development_notes.md) for roadmap and design decisions.

**Format:** This changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**Automation:** Maintained using conventional commits. Run `./scripts/generate_changelog.sh --auto-accept` to auto-generate entries from commits.