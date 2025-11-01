# Changelog

## [Unreleased] - 2025-11-01

### Fixed
- fix: clean up duplicate entries in CHANGELOG using changelog --clean tool

## [3.0.2] - 2025-11-01

### Added
- feat: add color formatting to all help text and command output
- feat: add comprehensive edge case tests to demo cartridge
- feat: add unified ptd command with subcommands
- feat: add test file generator script
- feat: add demo option and clean up demo cartridge
- feat: add VERSION file as single source of truth
- feat: auto-update README version badge during release
- feat: remove [Unreleased] section from user-facing CHANGELOG
- feat: add automatic CHANGELOG sync validation with git tags
- feat: add --release flag with version section ordering fix
- feat: add --release flag to automate version releases
- feat: improve changelog generation to properly merge [Unreleased] sections
- feat: add test file for changelog automation verification
- feat: add auto-accept flag for non-interactive changelog generation
- feat: implement working changelog automation with git log parsing
- feat: add shared functions library for code consistency
- feat: enhance --list option to check included .lua files and update docs
- feat: add -c/--cart option to specify test cartridge file
- feat: add comprehensive GitHub repository enhancements

### Fixed
- fix: improve input simulation utilities with test coverage
- fix: improve test utilities and documentation
- fix: subtest selection, completion messages, and timeout handling
- fix: correct unreleased content extraction in release function
- fix: add deduplication to changelog merge to prevent duplicate entries
- fix: improve error handling in test runner
- fix: cart metadata

### Documentation
- docs: clean up completed todo items
- docs: update changelog for v3.0.1
- docs: update documentation for new button state functions
- docs: document extraction of changelog automation to standalone library
- docs: update todo.md with completed improvements
- docs: rename PICO-8 TEST FRAMEWORK to PicoTestDriver throughout
- docs: update run_test.sh help to promote test generator
- docs: document test file generator and update todo
- docs: removed mention of obsi from changelog footer
- docs: add semver and release workflow to copilot instructions
- docs: simplify CHANGELOG header
- docs: add AI agent workflow guide to project structure
- docs: add comprehensive AI agent workflow guide
- docs: add GitHub About section reference for repository setup
- docs: add balanced guidance on AI-assisted development practices (Claude 4 > Grok)
- docs: update documentation for v1.0.1 with development environment setup

### Changed
- refactor: remove changelog automation files (extracted to standalone library)
- refactor: improve changelog format with categorized sections
- refactor: remove old scripts and migrate to ptd command only
- refactor: simplify --list output to show only subtest names
- refactor: rename phases to subtests for clarity
- refactor: clean up CHANGELOG and move roadmap to development_notes

### Tests
- test: add comprehensive tests for generate_test.sh
- test: add coverage for demo flag, no-args behavior, and exit codes
- test: add comprehensive test suite for new changelog format
- test: add comprehensive test suite for changelog generation script
- test: add comprehensive unit testing framework for run_test.sh

### Build
- build: release v3.0.0
- build: prepare release v1.1.1
- build: prepare release v1.1.0 with consolidated changelog

### Chores
- chore: release v3.0.2
- chore: bump version to 3.0.1
- chore: bump version to 2.0.2
- chore: bump version to 2.0.1
- chore: bump version to 2.0.0
- chore: release version 1.3.0
- chore: release version 1.1.3
- chore: add remaining project files and complete initial setup
- chore: add VS Code settings for PICO-8 development
- chore: add git hooks and conventional commit configuration

## [3.0.1] - 2025-11-01

### Documentation
- docs: clean up completed todo items

### Chores
- chore: release v3.0.2

## [3.0.0] - 2025-11-01

### Fixed
- fix: improve input simulation utilities with test coverage

### Documentation
- docs: update changelog for v3.0.1
- docs: update documentation for new button state functions

### Chores
- chore: bump version to 3.0.1

## [2.0.2] - 2025-11-01

### Documentation
- docs: document extraction of changelog automation to standalone library

### Changed
- refactor: remove changelog automation files (extracted to standalone library)
- refactor: improve changelog format with categorized sections

### Build
- build: release v3.0.0

## [2.0.1] - 2025-11-01

### Added
- feat: add color formatting to all help text and command output

### Chores
- chore: bump version to 2.0.2

## [1.3.0] - 2025-11-01

### Added
- feat: add comprehensive edge case tests to demo cartridge
- feat: add unified ptd command with subcommands
- feat: add test file generator script
- feat: add demo option and clean up demo cartridge

### Fixed
- fix: improve test utilities and documentation
- fix: subtest selection, completion messages, and timeout handling

### Documentation
- docs: update todo.md with completed improvements
- docs: rename PICO-8 TEST FRAMEWORK to PicoTestDriver throughout
- docs: update run_test.sh help to promote test generator
- docs: document test file generator and update todo
- docs: removed mention of obsi from changelog footer

### Changed
- refactor: remove old scripts and migrate to ptd command only
- refactor: simplify --list output to show only subtest names
- refactor: rename phases to subtests for clarity

### Tests
- test: add comprehensive tests for generate_test.sh
- test: add coverage for demo flag, no-args behavior, and exit codes

### Chores
- chore: bump version to 2.0.1
- chore: bump version to 2.0.0

## [1.2.0] - 2025-11-01

### Added
- feat: add VERSION file as single source of truth
- feat: auto-update README version badge during release

### Documentation
- docs: add semver and release workflow to copilot instructions

### Chores
- chore: release version 1.3.0

## [1.1.3] - 2025-11-01

### Added
- feat: remove [Unreleased] section from user-facing CHANGELOG

### Fixed
- fix: correct unreleased content extraction in release function

### Documentation
- docs: simplify CHANGELOG header

### Tests
- test: add comprehensive test suite for new changelog format

## [1.1.2] - 2025-11-01

### Added
- feat: add automatic CHANGELOG sync validation with git tags

### Chores
- chore: release version 1.1.3

## [1.1.1] - 2025-11-01

### Added
- feat: add --release flag with version section ordering fix
- feat: add --release flag to automate version releases

## [1.1.0] - 2025-11-01

### Added
- feat: improve changelog generation to properly merge [Unreleased] sections
- feat: add test file for changelog automation verification

### Fixed
- fix: add deduplication to changelog merge to prevent duplicate entries
- fix: improve error handling in test runner

### Changed
- refactor: clean up CHANGELOG and move roadmap to development_notes

### Tests
- test: add comprehensive test suite for changelog generation script

### Build
- build: prepare release v1.1.1

## [1.0.1] - 2025-10-31

### Added
- feat: add auto-accept flag for non-interactive changelog generation
- feat: implement working changelog automation with git log parsing
- feat: add shared functions library for code consistency
- feat: enhance --list option to check included .lua files and update docs
- feat: add -c/--cart option to specify test cartridge file
- feat: add comprehensive GitHub repository enhancements

### Fixed
- fix: cart metadata

### Documentation
- docs: add AI agent workflow guide to project structure
- docs: add comprehensive AI agent workflow guide
- docs: add GitHub About section reference for repository setup
- docs: add balanced guidance on AI-assisted development practices (Claude 4 > Grok)

### Tests
- test: add comprehensive unit testing framework for run_test.sh

### Build
- build: prepare release v1.1.0 with consolidated changelog

### Chores
- chore: add remaining project files and complete initial setup

