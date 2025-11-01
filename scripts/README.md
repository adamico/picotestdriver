# Changelog Generator Scripts

This directory contains the changelog automation scripts and tests.

## Scripts

### `generate_changelog.sh`
Main changelog generation script that parses git commits and updates CHANGELOG.md.

**Usage:**
```bash
# Interactive mode
./scripts/generate_changelog.sh

# Auto-accept for AI agents/CI
./scripts/generate_changelog.sh --auto-accept

# From specific version
./scripts/generate_changelog.sh v1.0.0

# Between versions
./scripts/generate_changelog.sh v1.0.0 v1.1.0
```

**Options:**
- `--auto-accept`, `--non-interactive`, `-y` - Skip interactive prompts
- `--help`, `-h` - Show help message

### `install_hooks.sh`
Installs git hooks (commit-msg, prepare-commit-msg) to .git/hooks/.

**Usage:**
```bash
./scripts/install_hooks.sh
```

### `test_generate_changelog.sh`
Test suite for the changelog generation script.

**Usage:**
```bash
./scripts/test_generate_changelog.sh
```

**Tests:**
- Help display functionality
- Feature merging into [Unreleased]
- Deduplication of entries
- Version section preservation
- Placeholder handling ("None yet")
- Footer preservation
- Flag acceptance
- Empty section handling
- Multiple commits collection
- Sorted output verification

## Development

### Running Tests

Before making changes to `generate_changelog.sh`, run the test suite:

```bash
./scripts/test_generate_changelog.sh
```

Expected output:
```
=== Changelog Generation Script Tests ===
...
Tests run:    19
Tests passed: 19
All tests passed! ✓
```

### Adding New Tests

1. Edit `test_generate_changelog.sh`
2. Add a new test function following the pattern:
   ```bash
   test_my_feature() {
       print_color "$YELLOW" "Test: My feature description"
       
       # Setup
       local input="test input"
       
       # Execute
       local output=$(process_input "$input")
       
       # Assert
       assert_equals "expected" "$output" "Description"
   }
   ```
3. Call the test in `main()`
4. Run the test suite to verify

### Assertion Helpers

- `assert_equals expected actual message` - Test equality
- `assert_contains haystack needle message` - Test substring presence
- `assert_not_contains haystack needle message` - Test substring absence

## Continuous Integration

Add to your CI pipeline:

```yaml
# .github/workflows/test.yml
- name: Test changelog generation
  run: ./scripts/test_generate_changelog.sh
```

## See Also

- [../CHANGELOG.md](../CHANGELOG.md) - The actual changelog
- [../docs/changelog_automation.md](../docs/changelog_automation.md) - Automation guide
- [../docs/ai_agent_workflow.md](../docs/ai_agent_workflow.md) - AI agent usage
