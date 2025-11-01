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
    
    print_color "$BLUE" "Generating changelog..."
    
    if [ -z "$from_ref" ]; then
        from_ref=$(get_latest_tag)
        if [ -z "$from_ref" ]; then
            print_color "$YELLOW" "No tags found. Generating changelog from first commit..."
            from_ref=$(git rev-list --max-parents=0 HEAD)
        else
            print_color "$GREEN" "Using latest tag: $from_ref"
        fi
    fi
    
    print_color "$BLUE" "Changelog range: $from_ref...$to_ref"
    
    # Generate changelog using git-conventional-commits
    local temp_file=$(mktemp)
    
    if npx git-conventional-commits changelog --from="$from_ref" --to="$to_ref" > "$temp_file" 2>&1; then
        if [ -s "$temp_file" ]; then
            echo "$temp_file"
            return 0
        else
            print_color "$YELLOW" "No conventional commits found in range $from_ref...$to_ref"
            rm "$temp_file"
            return 1
        fi
    else
        print_color "$RED" "Error generating changelog:"
        cat "$temp_file"
        rm "$temp_file"
        return 1
    fi
}

# Update CHANGELOG.md
update_changelog() {
    local generated_file=$1
    
    # Backup existing changelog
    if [ -f "$CHANGELOG_FILE" ]; then
        cp "$CHANGELOG_FILE" "$CHANGELOG_BACKUP"
        print_color "$GREEN" "Created backup: $CHANGELOG_BACKUP"
    fi
    
    # Read generated changelog
    local generated_content=$(cat "$generated_file")
    
    # Extract [Unreleased] section from current changelog
    local unreleased_section=""
    if [ -f "$CHANGELOG_FILE" ]; then
        unreleased_section=$(sed -n '/## \[Unreleased\]/,/## \[/p' "$CHANGELOG_FILE" | sed '$d')
    fi
    
    # Create new changelog with generated content
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),"
        echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
        echo ""
        
        if [ -n "$unreleased_section" ]; then
            echo "$unreleased_section"
            echo ""
        fi
        
        echo "$generated_content"
        
        # Append project context and footer from original
        if [ -f "$CHANGELOG_FILE" ]; then
            sed -n '/^## Project Context/,$p' "$CHANGELOG_FILE"
        fi
    } > "$CHANGELOG_FILE.new"
    
    mv "$CHANGELOG_FILE.new" "$CHANGELOG_FILE"
    print_color "$GREEN" "Updated $CHANGELOG_FILE"
}

# Interactive mode
interactive_update() {
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
    local from_ref=$1
    local to_ref=$2
    
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
            interactive_update
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
  $0 [from_tag] [to_tag]
  $0 --help

Examples:
  $0                    # Generate from last tag to HEAD
  $0 v1.0.0             # Generate from v1.0.0 to HEAD
  $0 v1.0.0 v1.1.0      # Generate from v1.0.0 to v1.1.0

Options:
  --help    Show this help message

This script uses git-conventional-commits to generate changelog entries
from conventional commit messages. It will automatically update the
CHANGELOG.md file while preserving manual entries in [Unreleased].

EOF
}

# Parse arguments
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
fi

main "$@"
