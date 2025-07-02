#!/bin/bash
# ui-utils.sh - Common UI utility functions for MICRO JOURNAL 2000
# Consolidates scattered UI functions used across multiple scripts

# ═══════════════════════════════════════════════════════════════
# TERMINAL INTERACTION UTILITIES
# ═══════════════════════════════════════════════════════════════

# Get single keypress without waiting for Enter
get_single_key() {
    local old_tty_settings=$(stty -g)
    stty -icanon -echo min 1 time 0
    local key=$(dd bs=1 count=1 2>/dev/null)
    stty "$old_tty_settings"
    echo "$key"
}

# ═══════════════════════════════════════════════════════════════
# TERMINAL DIMENSION UTILITIES
# ═══════════════════════════════════════════════════════════════

# Get terminal width with multiple fallback methods
get_terminal_width() {
    local width
    
    # Try tput first (most reliable)
    width=$(tput cols 2>/dev/null)
    if [ -n "$width" ] && [ "$width" -gt 0 ]; then
        echo "$width"
        return
    fi
    
    # Try stty as fallback
    width=$(stty size 2>/dev/null | cut -d' ' -f2)
    if [ -n "$width" ] && [ "$width" -gt 0 ]; then
        echo "$width"
        return
    fi
    
    # Default to MICRO JOURNAL 2000 standard width
    echo "98"
}

# ═══════════════════════════════════════════════════════════════
# TEXT FORMATTING UTILITIES
# ═══════════════════════════════════════════════════════════════

# Center text in terminal, accounting for ANSI color codes
center_text() {
    local text="$1"
    local width=$(get_terminal_width)
    
    # Remove ANSI color codes to get actual visible length
    local visible_text=$(echo -e "$text" | sed 's/\033\[[0-9;]*m//g')
    local visible_length=${#visible_text}
    
    # If text is wider than terminal, return as-is
    if [ "$visible_length" -ge "$width" ]; then
        echo -e "$text"
        return
    fi
    
    # Calculate padding and center the text
    local padding=$(((width - visible_length) / 2))
    printf "%*s" "$padding" ""
    echo -e "$text"
}

# ═══════════════════════════════════════════════════════════════
# FILE SYSTEM UTILITIES
# ═══════════════════════════════════════════════════════════════

# Fast file discovery with fd/find fallback - generalized from notes.sh
find_files_fast() {
    local directory="${1:-.}"
    local pattern="${2:-*}"
    local extension="${3:-md}"
    local max_depth="${4:-5}"
    
    if command -v fd >/dev/null 2>&1; then
        # fd is 3-5x faster than find, sort by modification time
        fd -t f -e "$extension" "$pattern" "$directory" --max-depth "$max_depth" -x ls -t {} + 2>/dev/null
    else
        # fallback: find and sort by modification time (recent first)
        find "$directory" -type f -name "*.$extension" -maxdepth "$max_depth" 2>/dev/null | xargs ls -t 2>/dev/null
    fi
}

# Fast content search with ripgrep/grep fallback - generalized from notes.sh
search_content_fast() {
    local term="$1"
    local directory="${2:-.}"
    local extension="${3:-md}"
    local max_depth="${4:-5}"
    
    if [ -z "$term" ]; then
        find_files_fast "$directory" "*" "$extension" "$max_depth"
        return
    fi

    {
        # Filename search (fd with pattern)
        if command -v fd >/dev/null 2>&1; then
            fd -t f "$term" "$directory" --max-depth "$max_depth" -i
        fi

        # Content search (ripgrep is 5-10x faster than grep)
        if command -v rg >/dev/null 2>&1; then
            rg -l -i "$term" "$directory" --type "$extension"
        else
            grep -r -l -i "$term" "$directory" --include="*.$extension" 2>/dev/null
        fi
    } | sort -u | xargs ls -t 2>/dev/null
}

# ═══════════════════════════════════════════════════════════════
# UI HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Clear screen and reset cursor position
clear_screen() {
    clear
    printf '\033[H'
}

# Wait for any key with optional prompt
wait_for_key() {
    local prompt="${1:-Press any key to continue...}"
    echo -n "$prompt"
    read -n 1 -s
    echo
}

# Convert key to lowercase for case-insensitive menus
normalize_key() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# ═══════════════════════════════════════════════════════════════
# EXPORT FUNCTIONS FOR USE IN OTHER SCRIPTS
# ═══════════════════════════════════════════════════════════════

export -f get_single_key
export -f get_terminal_width
export -f center_text
export -f find_files_fast
export -f search_content_fast
export -f clear_screen
export -f wait_for_key
export -f normalize_key