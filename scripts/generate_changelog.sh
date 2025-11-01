#!/bin/bash
#
# Changelog Generator using git-conventional-commits
#
# This script generates changelog entries from conventional commit messages
# and updates the CHANGELOG.md file.
#
# Usage:
#   ./scripts/generate_changelog.sh [from_tag] [to_tag]
#
# Examples:
#   ./scripts/generate_changelog.sh              # All commits since last tag
#   ./scripts/generate_changelog.sh v1.0.0       # All commits since v1.0.0
#   ./scripts/generate_changelog.sh v1.0.0 HEAD  # Commits between v1.0.0 and HEAD
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CHANGELOG_FILE="$PROJECT_DIR/CHANGELOG.md"
CHANGELOG_BACKUP="$CHANGELOG_FILE.backup"
CONFIG_FILE="$PROJECT_DIR/git-conventional-commits.yaml"

# Print colored message
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Check if git-conventional-commits is available
check_dependencies() {
    if ! command -v npx &> /dev/null; then
        print_color "$RED" "Error: npx is not installed. Install Node.js and npm first."
        exit 1
    fi
    
    print_color "$BLUE" "Checking git-conventional-commits..."
    if ! npx git-conventional-commits version &> /dev/null; then
        print_color "$YELLOW" "Installing git-conventional-commits..."
        npm install --save-dev git-conventional-commits
    fi
}

# Get the latest tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Generate changelog
generate_changelog() {
    local from_ref=$1
    local to_ref=${2:-HEAD}
    
    print_color "$BLUE" "Generating changelog..." >&2
    
    if [ -z "$from_ref" ]; then
        from_ref=$(get_latest_tag)
        if [ -z "$from_ref" ]; then
            print_color "$YELLOW" "No tags found. Generating changelog from all commits..." >&2
            from_ref=""
        else
            print_color "$GREEN" "Using latest tag: $from_ref" >&2
        fi
    fi
    
    if [ -n "$from_ref" ]; then
        print_color "$BLUE" "Changelog range: $from_ref...$to_ref" >&2
    else
        print_color "$BLUE" "Generating changelog from all commits to $to_ref" >&2
    fi
    
    # Generate changelog using git log parsing
    local temp_file
    temp_file=$(mktemp)
    
    print_color "$BLUE" "Parsing commits for conventional format..." >&2
    
    local git_range
    if [ -n "$from_ref" ]; then
        git_range="$from_ref..$to_ref"
    else
        git_range="$to_ref"
    fi
    
    # Extract conventional commits
    local feat_commits=$(git log --pretty=format:"%s" "$git_range" | grep -E "^feat:" || true)
    local fix_commits=$(git log --pretty=format:"%s" "$git_range" | grep -E "^fix:" || true)
    local perf_commits=$(git log --pretty=format:"%s" "$git_range" | grep -E "^perf:" || true)
    
    if [ -z "$feat_commits" ] && [ -z "$fix_commits" ] && [ -z "$perf_commits" ]; then
        print_color "$YELLOW" "No conventional commits (feat, fix, perf) found in range"
        rm "$temp_file"
        return 1
    fi
    
    # Generate simple changelog
    {
        echo "## [Unreleased]"
        echo ""
        
        if [ -n "$feat_commits" ]; then
            echo "### Features"
            echo "$feat_commits" | while read -r line; do
                # Remove "feat: " prefix
                echo "- ${line#feat: }"
            done
            echo ""
        fi
        
        if [ -n "$fix_commits" ]; then
            echo "### Bug Fixes"
            echo "$fix_commits" | while read -r line; do
                echo "- ${line#fix: }"
            done
            echo ""
        fi
        
        if [ -n "$perf_commits" ]; then
            echo "### Performance Improvements"
            echo "$perf_commits" | while read -r line; do
                echo "- ${line#perf: }"
            done
            echo ""
        fi
    } > "$temp_file"
    
    echo "$temp_file"
    return 0
}

# Update CHANGELOG.md
update_changelog() {
    local generated_file=$1
    
    # Backup existing changelog
    if [ -f "$CHANGELOG_FILE" ]; then
        cp "$CHANGELOG_FILE" "$CHANGELOG_BACKUP"
        print_color "$GREEN" "Created backup: $CHANGELOG_BACKUP" >&2
    fi
    
    # Read generated content (should be a new [Unreleased] section)
    local new_features=$(sed -n '/### Features/,/^$/p' "$generated_file" | grep -v "^### Features" | grep -v "^$" || true)
    local new_fixes=$(sed -n '/### Bug Fixes/,/^$/p' "$generated_file" | grep -v "^### Bug Fixes" | grep -v "^$" || true)
    local new_perf=$(sed -n '/### Performance Improvements/,/^$/p' "$generated_file" | grep -v "^### Performance Improvements" | grep -v "^$" || true)
    
    # Extract existing [Unreleased] content from current changelog
    local existing_features=$(sed -n '/## \[Unreleased\]/,/^## \[/p' "$CHANGELOG_FILE" | sed -n '/### Features/,/^### /p' | grep "^- " || true)
    local existing_fixes=$(sed -n '/## \[Unreleased\]/,/^## \[/p' "$CHANGELOG_FILE" | sed -n '/### Bug Fixes/,/^### /p' | grep "^- " || true)
    local existing_perf=$(sed -n '/## \[Unreleased\]/,/^## \[/p' "$CHANGELOG_FILE" | sed -n '/### Performance Improvements/,/^### /p' | grep "^- " || true)
    
    # Merge: Keep existing non-placeholder entries, add new ones (deduplicate)
    local merged_features=""
    if [ -n "$existing_features" ] && ! echo "$existing_features" | grep -q "None yet"; then
        merged_features="$existing_features"
    fi
    if [ -n "$new_features" ]; then
        if [ -n "$merged_features" ]; then
            merged_features=$(echo -e "$merged_features\n$new_features" | sort -u)
        else
            merged_features="$new_features"
        fi
    fi
    
    local merged_fixes=""
    if [ -n "$existing_fixes" ] && ! echo "$existing_fixes" | grep -q "None yet"; then
        merged_fixes="$existing_fixes"
    fi
    if [ -n "$new_fixes" ]; then
        if [ -n "$merged_fixes" ]; then
            merged_fixes=$(echo -e "$merged_fixes\n$new_fixes" | sort -u)
        else
            merged_fixes="$new_fixes"
        fi
    fi
    
    local merged_perf=""
    if [ -n "$existing_perf" ] && ! echo "$existing_perf" | grep -q "None yet"; then
        merged_perf="$existing_perf"
    fi
    if [ -n "$new_perf" ]; then
        if [ -n "$merged_perf" ]; then
            merged_perf=$(echo -e "$merged_perf\n$new_perf" | sort -u)
        else
            merged_perf="$new_perf"
        fi
    fi
    
    # Create new changelog with merged [Unreleased]
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),"
        echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
        echo ""
        echo "## [Unreleased]"
        echo ""
        echo "### Features"
        if [ -n "$merged_features" ]; then
            echo "$merged_features"
        else
            echo "- None yet"
        fi
        echo ""
        echo "### Bug Fixes"
        if [ -n "$merged_fixes" ]; then
            echo "$merged_fixes"
        else
            echo "- None yet"
        fi
        echo ""
        echo "### Performance Improvements"
        if [ -n "$merged_perf" ]; then
            echo "$merged_perf"
        else
            echo "- None yet"
        fi
        echo ""
        
        # Append all version sections (everything between first [Unreleased] and Project Context)
        if [ -f "$CHANGELOG_FILE" ]; then
            # Find all content after the first [Unreleased] section ends, before Project Context
            sed -n '/^## \[[0-9]/,/^## Project Context/p' "$CHANGELOG_FILE" | sed '/^## Project Context/d'
        fi
        
        # Append project context and footer from original
        if [ -f "$CHANGELOG_FILE" ]; then
            sed -n '/^## Project Context/,$p' "$CHANGELOG_FILE"
        fi
    } > "$CHANGELOG_FILE.new"
    
    mv "$CHANGELOG_FILE.new" "$CHANGELOG_FILE"
    print_color "$GREEN" "Updated $CHANGELOG_FILE" >&2
}

# Interactive mode
interactive_update() {
    local auto_accept=$1
    
    if [ "$auto_accept" = "true" ]; then
        print_color "$GREEN" "Auto-accepting changes (non-interactive mode)"
        rm "$CHANGELOG_BACKUP"
        return 0
    fi
    
    print_color "$YELLOW" "Generated changelog entries. Review the changes:"
    echo ""
    git diff --no-index "$CHANGELOG_BACKUP" "$CHANGELOG_FILE" || true
    echo ""
    
    read -p "Accept these changes? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_color "$GREEN" "Changelog updated successfully!"
        rm "$CHANGELOG_BACKUP"
        return 0
    else
        print_color "$YELLOW" "Reverting changes..."
        mv "$CHANGELOG_BACKUP" "$CHANGELOG_FILE"
        return 1
    fi
}

# Main
main() {
    local from_ref=""
    local to_ref=""
    local auto_accept="false"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --non-interactive|--auto-accept|-y)
                auto_accept="true"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                if [ -z "$from_ref" ]; then
                    from_ref=$1
                elif [ -z "$to_ref" ]; then
                    to_ref=$1
                fi
                shift
                ;;
        esac
    done
    
    print_color "$BLUE" "=== Changelog Generator ==="
    echo ""
    
    # Check dependencies
    check_dependencies
    
    # Generate changelog
    local generated_file
    if generated_file=$(generate_changelog "$from_ref" "$to_ref"); then
        update_changelog "$generated_file"
        rm "$generated_file"
        
        # Interactive review
        if [ -f "$CHANGELOG_BACKUP" ]; then
            interactive_update "$auto_accept"
        else
            print_color "$GREEN" "Changelog created successfully!"
        fi
    else
        print_color "$YELLOW" "No changes to add to changelog."
        return 1
    fi
}

# Show help
show_help() {
    cat << EOF
Changelog Generator

Usage:
  $0 [OPTIONS] [from_tag] [to_tag]
  $0 --help

Examples:
  $0                           # Generate from last tag to HEAD
  $0 v1.0.0                    # Generate from v1.0.0 to HEAD
  $0 v1.0.0 v1.1.0             # Generate from v1.0.0 to v1.1.0
  $0 --auto-accept v1.0.0      # Generate and auto-accept (no prompt)
  $0 -y                        # Generate from last tag, auto-accept

Options:
  --non-interactive, --auto-accept, -y
                    Auto-accept changes without prompting (useful for AI agents/CI)
  --help, -h        Show this help message

This script parses git log to generate changelog entries from conventional
commit messages (feat, fix, perf). It updates CHANGELOG.md while preserving
manual entries in [Unreleased].

For AI agents and automated workflows, use --auto-accept to skip interactive prompts.

EOF
}

# Parse arguments
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
fi

main "$@"
