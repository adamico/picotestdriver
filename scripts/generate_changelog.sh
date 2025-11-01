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
CHANGELOG_FILE="${CHANGELOG_FILE:-$PROJECT_DIR/CHANGELOG.md}"
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

# Validate CHANGELOG is in sync with git tags
validate_changelog_sync() {
    if [ ! -f "$CHANGELOG_FILE" ]; then
        return 0  # No changelog yet, nothing to validate
    fi
    
    # Get all version tags (v1.0.0 format or 1.0.0 format)
    local git_tags=$(git tag -l | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' | sed 's/^v//' | sort -V)
    
    if [ -z "$git_tags" ]; then
        return 0  # No tags yet
    fi
    
    # Get versions from CHANGELOG (extract [X.Y.Z] format)
    local changelog_versions=$(grep -oP '(?<=## \[)[0-9]+\.[0-9]+\.[0-9]+(?=\])' "$CHANGELOG_FILE" | sort -V)
    
    # Find missing versions (in git tags but not in changelog)
    local missing_versions=""
    while IFS= read -r tag_version; do
        if ! echo "$changelog_versions" | grep -q "^${tag_version}$"; then
            missing_versions="${missing_versions}${tag_version}"$'\n'
        fi
    done <<< "$git_tags"
    
    if [ -n "$missing_versions" ]; then
        print_color "$YELLOW" "Warning: CHANGELOG is out of sync with git tags!" >&2
        print_color "$YELLOW" "Missing versions in CHANGELOG:" >&2
        echo "$missing_versions" | grep -v '^$' | while read -r version; do
            local tag_date=$(git log -1 --format=%ad --date=short "v${version}" 2>/dev/null || git log -1 --format=%ad --date=short "${version}" 2>/dev/null)
            echo "  - $version (tagged on ${tag_date:-unknown})" >&2
        done
        echo "" >&2
        
        if [ "$auto_accept" = "true" ]; then
            print_color "$GREEN" "Auto-adding missing versions to CHANGELOG..." >&2
            add_missing_versions "$missing_versions"
            return 0
        fi
        
        read -p "Add missing versions to CHANGELOG? (y/n): " -n 1 -r >&2
        echo "" >&2
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            add_missing_versions "$missing_versions"
        else
            print_color "$YELLOW" "Skipping sync. CHANGELOG may be incomplete." >&2
        fi
    fi
}

# Add missing versions to CHANGELOG
add_missing_versions() {
    local missing_versions=$1
    
    # Backup current changelog
    cp "$CHANGELOG_FILE" "$CHANGELOG_BACKUP"
    
    # Sort missing versions in descending order
    local sorted_missing=$(echo "$missing_versions" | grep -v '^$' | sort -V -r)
    
    # Create entries for each missing version
    local entries_file=$(mktemp)
    echo "$sorted_missing" | while read -r version; do
        local tag_date=$(git log -1 --format=%ad --date=short "v${version}" 2>/dev/null || git log -1 --format=%ad --date=short "${version}" 2>/dev/null)
        [ -z "$tag_date" ] && tag_date=$(date +%Y-%m-%d)
        
        print_color "$GREEN" "Adding version $version to CHANGELOG..." >&2
        
        echo "## [$version] - $tag_date"
        echo ""
        echo "### Features"
        echo "- See git history for details: \`git log v${version}\`"
        echo ""
    done > "$entries_file"
    
    # Rebuild changelog: everything before footer + new entries + footer
    local temp_file=$(mktemp)
    sed -n '1,/^---/p' "$CHANGELOG_FILE" | sed '$d' > "$temp_file"
    cat "$entries_file" >> "$temp_file"
    sed -n '/^---/,$p' "$CHANGELOG_FILE" >> "$temp_file"
    
    mv "$temp_file" "$CHANGELOG_FILE"
    rm -f "$entries_file" "$CHANGELOG_BACKUP"
    
    print_color "$YELLOW" "Note: Added versions before footer. You may want to manually reorder for chronological sorting." >&2
    print_color "$GREEN" "CHANGELOG synchronized with git tags!" >&2
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

# Release [Unreleased] to a version
release_version() {
    local version=$1
    local release_date=${2:-$(date +%Y-%m-%d)}
    
    if [ -z "$version" ]; then
        print_color "$RED" "Error: Version number required for release" >&2
        echo "Usage: $0 --release VERSION [DATE]" >&2
        return 1
    fi
    
    # Validate version format (basic semver check)
    if ! echo "$version" | grep -qE '^v?[0-9]+\.[0-9]+\.[0-9]+$'; then
        print_color "$RED" "Error: Invalid version format. Use semver (e.g., 1.2.3 or v1.2.3)" >&2
        return 1
    fi
    
    # Remove 'v' prefix if present
    version="${version#v}"
    
    print_color "$BLUE" "Releasing [Unreleased] as version $version ($release_date)..." >&2
    
    # Check if [Unreleased] has content
    local unreleased_content=$(sed -n '/## \[Unreleased\]/,/^## \[/p' "$CHANGELOG_FILE" | grep "^- " | grep -v "None yet" || true)
    
    if [ -z "$unreleased_content" ]; then
        print_color "$YELLOW" "Warning: [Unreleased] section has no content to release" >&2
        if [ "$auto_accept" != "true" ]; then
            read -p "Continue anyway? (y/n): " -n 1 -r >&2
            echo "" >&2
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                return 1
            fi
        else
            print_color "$GREEN" "Auto-accepting empty [Unreleased] (non-interactive mode)" >&2
        fi
    fi
    
    # Backup
    cp "$CHANGELOG_FILE" "$CHANGELOG_BACKUP"
    print_color "$GREEN" "Created backup: $CHANGELOG_BACKUP" >&2
    
    # Create temp file with new structure
    {
        # Header
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),"
        echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
        echo ""
        
        # New empty [Unreleased]
        echo "## [Unreleased]"
        echo ""
        echo "### Features"
        echo "- None yet"
        echo ""
        echo "### Bug Fixes"
        echo "- None yet"
        echo ""
        echo "### Performance Improvements"
        echo "- None yet"
        echo ""
        
        # Convert old [Unreleased] to new version
        echo "## [$version] - $release_date"
        echo ""
        sed -n '/## \[Unreleased\]/,/^## \[/p' "$CHANGELOG_FILE" | \
            sed '1d;$d' | \
            sed '/^## \[Unreleased\]/d'
        echo ""
        
        # Append all existing version sections
        # Extract everything from the first version section to the footer
        awk '/^## \[[0-9]/ {found=1} found && /^---/ {exit} found {print}' "$CHANGELOG_FILE"
        
        # Append footer
        sed -n '/^---/,$p' "$CHANGELOG_FILE"
    } > "$CHANGELOG_FILE.new"
    
    mv "$CHANGELOG_FILE.new" "$CHANGELOG_FILE"
    print_color "$GREEN" "Released [Unreleased] as [$version]" >&2
    
    return 0
}

# Main
main() {
    local from_ref=""
    local to_ref=""
    local auto_accept="false"
    local release_mode="false"
    local release_version=""
    local release_date=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --non-interactive|--auto-accept|-y)
                auto_accept="true"
                shift
                ;;
            --release|-r)
                release_mode="true"
                shift
                if [[ $# -gt 0 ]] && [[ ! "$1" =~ ^- ]]; then
                    release_version=$1
                    shift
                    # Optional date parameter
                    if [[ $# -gt 0 ]] && [[ ! "$1" =~ ^- ]]; then
                        release_date=$1
                        shift
                    fi
                fi
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
    
    # Validate CHANGELOG is in sync with git tags (skip in release mode)
    if [ "$release_mode" != "true" ]; then
        validate_changelog_sync
        echo ""
    fi
    
    # Handle release mode
    if [ "$release_mode" = "true" ]; then
        if [ -z "$release_version" ]; then
            print_color "$RED" "Error: --release requires a version number"
            echo ""
            echo "Usage: $0 --release VERSION [DATE]"
            echo "Example: $0 --release 1.2.0"
            echo "Example: $0 --release v1.2.0 2025-11-01"
            return 1
        fi
        
        if release_version "$release_version" "$release_date"; then
            if [ "$auto_accept" = "true" ]; then
                print_color "$GREEN" "Release completed (auto-accepted)"
                rm -f "$CHANGELOG_BACKUP"
            else
                interactive_update "$auto_accept"
            fi
        else
            return 1
        fi
        return 0
    fi
    
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
  $0 --release VERSION [DATE]
  $0 --help

Examples:
  $0                           # Generate from last tag to HEAD
  $0 v1.0.0                    # Generate from v1.0.0 to HEAD
  $0 v1.0.0 v1.1.0             # Generate from v1.0.0 to v1.1.0
  $0 --auto-accept v1.0.0      # Generate and auto-accept (no prompt)
  $0 -y                        # Generate from last tag, auto-accept
  
  $0 --release 1.2.0           # Convert [Unreleased] to [1.2.0] with today's date
  $0 --release v1.2.0 2025-11-01  # Convert with specific date
  $0 -r 1.2.0 -y               # Release and auto-accept

Options:
  --non-interactive, --auto-accept, -y
                    Auto-accept changes without prompting (useful for AI agents/CI)
  --release VERSION [DATE], -r VERSION [DATE]
                    Convert [Unreleased] section to a version release
                    DATE defaults to today if not specified
  --help, -h        Show this help message

This script parses git log to generate changelog entries from conventional
commit messages (feat, fix, perf). It updates CHANGELOG.md while preserving
manual entries in [Unreleased].

For AI agents and automated workflows, use --auto-accept to skip interactive prompts.

Release Mode:
  Use --release to prepare a new version release. This converts the [Unreleased]
  section to a versioned section and creates a new empty [Unreleased] at the top.

EOF
}

# Parse arguments
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
fi

main "$@"
