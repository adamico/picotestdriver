#!/bin/bash
#
# Install Git Hooks
#
# This script installs custom git hooks from .git-hooks/ to .git/hooks/
#

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
HOOKS_SOURCE="$PROJECT_DIR/.git-hooks"
HOOKS_TARGET="$PROJECT_DIR/.git/hooks"

print_color "$BLUE" "=== Installing Git Hooks ==="
echo ""

# Check if .git directory exists
if [ ! -d "$PROJECT_DIR/.git" ]; then
    print_color "$YELLOW" "Warning: Not a git repository. Skipping hook installation."
    exit 0
fi

# Create hooks directory if it doesn't exist
mkdir -p "$HOOKS_TARGET"

# Install each hook
installed_count=0
for hook_file in "$HOOKS_SOURCE"/*; do
    if [ -f "$hook_file" ]; then
        hook_name=$(basename "$hook_file")
        
        # Skip README and other non-hook files
        if [[ "$hook_name" =~ ^[A-Z] ]] || [[ "$hook_name" == *.md ]]; then
            continue
        fi
        
        target_file="$HOOKS_TARGET/$hook_name"
        
        # Backup existing hook if present
        if [ -f "$target_file" ]; then
            cp "$target_file" "$target_file.backup"
            print_color "$YELLOW" "Backed up existing $hook_name to $hook_name.backup"
        fi
        
        # Copy hook
        cp "$hook_file" "$target_file"
        chmod +x "$target_file"
        
        print_color "$GREEN" "✓ Installed $hook_name"
        ((installed_count++))
    fi
done

echo ""
if [ $installed_count -gt 0 ]; then
    print_color "$GREEN" "Successfully installed $installed_count hook(s)!"
else
    print_color "$YELLOW" "No hooks found to install."
fi

echo ""
print_color "$BLUE" "Installed hooks:"
echo "  • commit-msg       - Validates conventional commit format"
echo "  • prepare-commit-msg - Prompts for changelog updates on release commits"
echo ""
print_color "$BLUE" "ℹ️  Hooks are sourced from .git-hooks/ directory"
