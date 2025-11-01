# AI Agent Workflow Guide

This guide explains how AI agents should interact with the changelog automation system.

## Quick Reference

### Making a Release Commit

```bash
# 1. Make your changes
git add .

# 2. Commit with conventional format
git commit -m "feat: add amazing feature"

# 3. If it's a release commit, generate changelog automatically
git commit -m "build: release version 1.2.0"
./scripts/generate_changelog.sh --auto-accept

# 4. Stage and amend the commit to include changelog
git add CHANGELOG.md
git commit --amend --no-edit

# 5. Tag and push
git tag v1.2.0
git push origin main --tags
```

## Auto-Accept Flag Options

All of these work the same (choose your preference):

```bash
./scripts/generate_changelog.sh --auto-accept
./scripts/generate_changelog.sh --non-interactive  
./scripts/generate_changelog.sh -y
```

## Complete Example Workflow

### Scenario: AI Agent Making Multiple Features and a Release

```bash
# Feature 1
git add feature1.lua
git commit -m "feat: add player movement system"

# Feature 2
git add feature2.lua
git commit -m "feat: add collision detection"

# Bug fix
git add bugfix.lua
git commit -m "fix: correct boundary checking logic"

# Prepare for release
# Update version in code
echo "VERSION=1.2.0" > version.txt
git add version.txt

# Commit version bump
git commit -m "build: bump version to 1.2.0"

# Generate changelog (AI agent uses --auto-accept)
./scripts/generate_changelog.sh --auto-accept

# Verify changelog was updated
git diff HEAD CHANGELOG.md

# Stage and amend the release commit
git add CHANGELOG.md
git commit --amend --no-edit

# Tag the release
git tag v1.2.0

# Push everything
git push origin main
git push origin v1.2.0
```

## Environment Detection

For even better automation, you can detect if running in an AI/CI environment:

```bash
# In your script
if [ -n "$AI_AGENT" ] || [ -n "$CI" ] || [ "$TERM" = "dumb" ]; then
    AUTO_ACCEPT="--auto-accept"
else
    AUTO_ACCEPT=""
fi

./scripts/generate_changelog.sh $AUTO_ACCEPT
```

## Expected Output

When using `--auto-accept`, you'll see:

```
=== Changelog Generator ===

Checking git-conventional-commits...
Generating changelog...
Changelog range: v1.1.0...HEAD
Parsing commits for conventional format...
Created backup: CHANGELOG.md.backup
Updated CHANGELOG.md
Auto-accepting changes (non-interactive mode)
```

No interactive prompts - the changelog is automatically accepted and the backup is removed.

## Commit Message Format

AI agents should use these prefixes for changelog inclusion:

| Prefix | Appears in Changelog | Example |
|--------|---------------------|---------|
| `feat:` | ✓ Yes | `feat: add new game mode` |
| `fix:` | ✓ Yes | `fix: correct score calculation` |
| `perf:` | ✓ Yes | `perf: optimize rendering loop` |
| `refactor:` | ✗ No | `refactor: extract helper functions` |
| `docs:` | ✗ No | `docs: update API reference` |
| `test:` | ✗ No | `test: add unit tests for player` |
| `build:` | ✗ No | `build: bump version to 1.2.0` |
| `chore:` | ✗ No | `chore: update .gitignore` |

## Error Handling

The script returns appropriate exit codes:

- `0` - Success (changelog generated and accepted)
- `1` - No changes found (no conventional commits in range)

```bash
if ./scripts/generate_changelog.sh --auto-accept; then
    echo "✓ Changelog updated"
    git add CHANGELOG.md
else
    echo "⚠ No changelog updates needed"
fi
```

## Integration with Git Hooks

The `prepare-commit-msg` hook will still prompt humans but shows the auto-accept option:

```
⚠️  Detected a release/version commit
ℹ️  Consider updating CHANGELOG.md before committing

You can run:
  ./scripts/generate_changelog.sh
  ./scripts/generate_changelog.sh --auto-accept  # For AI agents/CI
```

AI agents can ignore this prompt and run the command directly with `--auto-accept`.

## Best Practices for AI Agents

1. **Always use `--auto-accept`** - Don't leave prompts hanging
2. **Check exit codes** - Handle cases where no changelog updates are needed
3. **Verify the update** - Use `git diff` to check what changed
4. **Stage the changelog** - Don't forget `git add CHANGELOG.md`
5. **Use conventional commits** - Only `feat`, `fix`, and `perf` appear in changelog
6. **Amend release commits** - Include changelog in the same commit as version bump

## Troubleshooting

### Changelog not updating

```bash
# Check if you have conventional commits
git log --oneline v1.0.0..HEAD | grep -E "^[a-f0-9]+ (feat|fix|perf):"

# If empty, no changelog entries will be generated
```

### Interactive prompt appears

```bash
# Make sure you're using the flag
./scripts/generate_changelog.sh --auto-accept  # ✓ Correct
./scripts/generate_changelog.sh                # ✗ Will prompt
```

### Backup file remains

```bash
# If script fails, cleanup the backup
rm -f CHANGELOG.md.backup
```

## See Also

- [CHANGELOG.md](../CHANGELOG.md) - View the changelog
- [changelog_automation.md](changelog_automation.md) - Detailed automation guide
- [../git-conventional-commits.yaml](../git-conventional-commits.yaml) - Commit conventions
