# Changelog Automation

As of PicoTestDriver v2.0.2, the changelog automation tools have been extracted into a standalone library for broader reuse.

## Git Changelog Automation

The changelog generation scripts (`generate_changelog.sh`, git hooks, and tests) are now available as a separate project:

**Repository**: https://github.com/adamico/git-changelog-automation

### Features

- 🎯 Automatic changelog generation from conventional commits
- 📝 Smart categorization (Added, Fixed, Changed, Performance, etc.)
- 🪝 Git hooks for commit validation
- 🤖 CI/CD ready with non-interactive mode
- 🔖 Version release automation
- 🧪 Comprehensive test suite

### Why Extract?

The changelog automation system is **project-agnostic** and works with any git repository that uses conventional commits. It's not specific to PICO-8 or testing frameworks, making it ideal as a standalone tool.

### Migration

**PicoTestDriver still includes changelog automation** in the current release for backward compatibility. However, we recommend using the standalone library going forward:

```bash
# Clone the standalone library
git clone https://github.com/adamico/git-changelog-automation.git

# Or add as submodule
git submodule add https://github.com/adamico/git-changelog-automation.git tools/changelog

# Use it
./tools/changelog/changelog
```

### Quick Start

```bash
# Install globally
curl -o changelog https://raw.githubusercontent.com/adamico/git-changelog-automation/main/changelog
chmod +x changelog
sudo mv changelog /usr/local/bin/

# Generate changelog
changelog

# Release version
changelog --release 1.2.0

# Install git hooks
changelog --install-hooks
```

### Documentation

See the [git-changelog-automation README](https://github.com/adamico/git-changelog-automation) for complete documentation.

## PicoTestDriver Usage

Within PicoTestDriver, you can still use the included scripts:

```bash
# Generate changelog (current approach)
./scripts/generate_changelog.sh

# Or use the standalone tool (recommended)
changelog
```

## Future Plans

- PicoTestDriver v3.0 may remove the bundled changelog scripts entirely
- Users will be encouraged to use git-changelog-automation independently
- This aligns with the Unix philosophy: tools that do one thing well

## Questions?

If you have questions or suggestions about the changelog automation:

- **PicoTestDriver-specific**: Open an issue in the obsi/PicoTestDriver repo
- **Changelog automation**: Open an issue in the git-changelog-automation repo
