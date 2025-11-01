# Changelog Automation

This document explains the automated changelog generation system for the PICO-8 Test Framework.

## Overview

The project uses **conventional commits** and **git-conventional-commits** to automatically generate changelog entries from commit messages.

## Setup

### 1. Install Git Hooks

```bash
./scripts/install_hooks.sh
```

This installs two hooks:
- **`commit-msg`**: Validates conventional commit format
- **`prepare-commit-msg`**: Prompts for changelog updates on release commits

### 2. Install Dependencies (if needed)

The changelog generator uses `npx` and `git-conventional-commits`:

```bash
npm install --save-dev git-conventional-commits
```

## Usage

### Manual Changelog Generation

```bash
# Generate from last tag to HEAD (interactive)
./scripts/generate_changelog.sh

# Generate from specific version
./scripts/generate_changelog.sh v1.0.0

# Generate between versions
./scripts/generate_changelog.sh v1.0.0 v1.1.0

# Auto-accept without prompts (for AI agents/CI)
./scripts/generate_changelog.sh --auto-accept
./scripts/generate_changelog.sh -y
./scripts/generate_changelog.sh --non-interactive v1.0.0
```

### Automatic Prompts

When you make a release commit, the `prepare-commit-msg` hook will:
1. Detect version/release-related commits
2. Prompt you to generate the changelog
3. Offer to stage CHANGELOG.md automatically

Example release commit that triggers the prompt:
```bash
git commit -m "build: bump version to 1.1.0"
git commit -m "release: version 1.1.0"
```

## Commit Types

Follow these conventional commit types:

| Type | Description | In Changelog |
|------|-------------|--------------|
| `feat:` | New features | ✓ Yes |
| `fix:` | Bug fixes | ✓ Yes |
| `perf:` | Performance improvements | ✓ Yes |
| `refactor:` | Code restructuring | No |
| `style:` | Code style changes | No |
| `test:` | Testing changes | No |
| `build:` | Build system changes | No |
| `ops:` | Operational changes | No |
| `docs:` | Documentation | No |
| `chore:` | Miscellaneous tasks | No |

### Examples

```bash
# Feature (appears in changelog)
git commit -m "feat: add timeout parameter support"

# Bug fix (appears in changelog)
git commit -m "fix: correct boundary detection logic"

# Performance improvement (appears in changelog)
git commit -m "perf: optimize frame update loop"

# Refactor (not in changelog)
git commit -m "refactor: extract shared functions to library"

# Documentation (not in changelog)
git commit -m "docs: update README with new examples"
```

## Workflow

### For Regular Development

1. Make changes
2. Commit with conventional format
3. Hook validates commit message automatically

```bash
git add .
git commit -m "feat: add new assertion function"
# Hook validates format automatically
```

### For Releases

1. Update version number in code/documentation
2. Commit with release-related message
3. Hook prompts for changelog generation
4. Review and accept changelog updates
5. Push with tags

```bash
# Make version changes
git add .
git commit -m "build: bump version to 1.1.0"
# Hook prompts: "Generate changelog now? (y/n)"
# Select 'y' to auto-generate
# Review diff and accept

git tag v1.1.0
git push origin main --tags
```

### For AI Agents and CI/CD

Use the `--auto-accept` flag to skip interactive prompts:

```bash
# AI agent making a release commit
git add .
git commit -m "build: release version 1.2.0"
./scripts/generate_changelog.sh --auto-accept
git add CHANGELOG.md
git commit --amend --no-edit
git tag v1.2.0
git push origin main --tags
```

This allows automated tools to update the changelog without requiring human interaction.

## CHANGELOG.md Format

The changelog follows [Keep a Changelog](https://keepachangelog.com/) format:

```markdown
# Changelog

## [Unreleased]
### Features
- Manual entries for unreleased work

## [1.1.0] - 2025-11-01
### Features
- Auto-generated from feat: commits

### Bug Fixes
- Auto-generated from fix: commits

### Performance Improvements
- Auto-generated from perf: commits
```

### Manual vs Auto-Generated

- **[Unreleased] section**: Manually edited, preserved during generation
- **Version sections**: Auto-generated from commits between tags
- **Project Context footer**: Manually maintained, preserved during generation

## Troubleshooting

### "npx: command not found"

Install Node.js and npm:
```bash
# Ubuntu/Debian
sudo apt install nodejs npm

# macOS
brew install node

# Arch Linux
sudo pacman -S nodejs npm
```

### Hook not running

Ensure hooks are installed and executable:
```bash
./scripts/install_hooks.sh
ls -la .git/hooks/
```

### Commits not appearing in changelog

Check commit format matches conventional commits:
```bash
# ❌ Bad (won't appear)
git commit -m "added new feature"

# ✓ Good (will appear)
git commit -m "feat: add new feature"
```

Only `feat`, `fix`, and `perf` commits appear in the changelog by default.

## Configuration

Edit `git-conventional-commits.yaml` to customize:

```yaml
changelog:
  commitTypes:
  - feat    # Include in changelog
  - fix     # Include in changelog
  - perf    # Include in changelog
  # Add more types if needed
```

## Benefits

1. **Consistency**: Standardized commit messages across team
2. **Automation**: Changelog generated from commits, no manual entry needed
3. **Accuracy**: Changelog matches actual code changes
4. **Speed**: Fast generation even from hundreds of commits
5. **Git Integration**: Works with existing git workflow

## Best Practices

1. **Write clear commit messages**: They become user-facing changelog entries
2. **Use imperative mood**: "add feature" not "added feature"
3. **Be specific**: "fix boundary detection bug" not "fix bug"
4. **Group related changes**: Use multiple commits with same type for related work
5. **Review generated changelog**: Always review before accepting

## Resources

- [Conventional Commits Specification](https://www.conventionalcommits.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [git-conventional-commits](https://github.com/qoomon/git-conventional-commits)
- [Semantic Versioning](https://semver.org/)
