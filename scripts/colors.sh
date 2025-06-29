#!/bin/bash
# colors.sh - MICRO JOURNAL 2000 Standardized Color System
# Source this file in scripts for consistent color usage

# ═══════════════════════════════════════════════════════════════
# CORE COLOR DEFINITIONS
# ═══════════════════════════════════════════════════════════════

# Standard ANSI Colors (compatible with all terminals)
export COLOR_RED='\033[0;31m'          # Standard red
export COLOR_GREEN='\033[0;32m'        # Standard green  
export COLOR_YELLOW='\033[0;33m'       # Standard yellow
export COLOR_BLUE='\033[0;34m'         # Standard blue
export COLOR_MAGENTA='\033[0;35m'      # Standard magenta
export COLOR_CYAN='\033[0;36m'         # Standard cyan
export COLOR_WHITE='\033[0;37m'        # Standard white

# Bright ANSI Colors (higher visibility)
export COLOR_BRIGHT_RED='\033[91m'     # Bright red
export COLOR_BRIGHT_GREEN='\033[92m'   # Bright green
export COLOR_BRIGHT_YELLOW='\033[93m'  # Bright yellow
export COLOR_BRIGHT_BLUE='\033[94m'    # Bright blue
export COLOR_BRIGHT_MAGENTA='\033[95m' # Bright magenta
export COLOR_BRIGHT_CYAN='\033[96m'    # Bright cyan
export COLOR_BRIGHT_WHITE='\033[97m'   # Bright white

# 256-Color Mode (enhanced colors for modern terminals)
export COLOR_HEADER='\033[1;38;5;81m'  # Bright cyan for headers
export COLOR_CACHE_OK='\033[38;5;46m'  # Bright green for cache OK
export COLOR_CACHE_WARN='\033[38;5;220m' # Yellow for cache warnings

# Control Codes
export COLOR_RESET='\033[0m'           # Reset to default
export COLOR_BOLD='\033[1m'            # Bold text
export COLOR_DIM='\033[2m'             # Dim text

# ═══════════════════════════════════════════════════════════════
# SEMANTIC COLOR ALIASES (Use these in scripts)
# ═══════════════════════════════════════════════════════════════

# Status Indicators
export COLOR_SUCCESS="$COLOR_BRIGHT_GREEN"   # Achievement, completion, positive status
export COLOR_ERROR="$COLOR_BRIGHT_RED"       # Errors, failures, missing items
export COLOR_WARNING="$COLOR_BRIGHT_YELLOW"  # Warnings, prompts, attention needed
export COLOR_INFO="$COLOR_BRIGHT_CYAN"       # Metadata, timestamps, cache status

# UI Elements
export COLOR_HEADER_PRIMARY="$COLOR_HEADER"  # Main section headers (▐ TITLE ▌)
export COLOR_HOTKEY="$COLOR_BRIGHT_GREEN"    # Menu hotkeys [T], [Q], etc.
export COLOR_PROMPT="$COLOR_BRIGHT_CYAN"     # Selection prompts
export COLOR_WORDCOUNT="$COLOR_BRIGHT_YELLOW" # Word count numbers
export COLOR_TIME="$COLOR_BRIGHT_CYAN"       # Time stamps and durations

# Content Highlighting
export COLOR_FILENAME="$COLOR_CYAN"          # File names and paths
export COLOR_TITLE="$COLOR_WHITE"            # Document titles
export COLOR_PROGRESS="$COLOR_BRIGHT_GREEN"  # Progress bars and percentages

# Cache Status (specific indicators)
export COLOR_CACHE_ENABLED="$COLOR_BRIGHT_GREEN"   # Cache working (●)
export COLOR_CACHE_DISABLED="$COLOR_BRIGHT_YELLOW" # Cache unavailable (●)

# ═══════════════════════════════════════════════════════════════
# BACKWARD COMPATIBILITY ALIASES
# ═══════════════════════════════════════════════════════════════

# Support existing variable names in current scripts
export CYAN="$COLOR_BRIGHT_CYAN"
export GREEN="$COLOR_BRIGHT_GREEN"
export YELLOW="$COLOR_BRIGHT_YELLOW"
export RED="$COLOR_BRIGHT_RED"
export NC="$COLOR_RESET"

# ═══════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Function to disable colors (for redirected output or low-capability terminals)
disable_colors() {
    export COLOR_RED=''
    export COLOR_GREEN=''
    export COLOR_YELLOW=''
    export COLOR_BLUE=''
    export COLOR_MAGENTA=''
    export COLOR_CYAN=''
    export COLOR_WHITE=''
    export COLOR_BRIGHT_RED=''
    export COLOR_BRIGHT_GREEN=''
    export COLOR_BRIGHT_YELLOW=''
    export COLOR_BRIGHT_BLUE=''
    export COLOR_BRIGHT_MAGENTA=''
    export COLOR_BRIGHT_CYAN=''
    export COLOR_BRIGHT_WHITE=''
    export COLOR_HEADER=''
    export COLOR_CACHE_OK=''
    export COLOR_CACHE_WARN=''
    export COLOR_RESET=''
    export COLOR_BOLD=''
    export COLOR_DIM=''
    
    # Semantic aliases
    export COLOR_SUCCESS=''
    export COLOR_ERROR=''
    export COLOR_WARNING=''
    export COLOR_INFO=''
    export COLOR_HEADER_PRIMARY=''
    export COLOR_HOTKEY=''
    export COLOR_PROMPT=''
    export COLOR_WORDCOUNT=''
    export COLOR_TIME=''
    export COLOR_FILENAME=''
    export COLOR_TITLE=''
    export COLOR_PROGRESS=''
    export COLOR_CACHE_ENABLED=''
    export COLOR_CACHE_DISABLED=''
    
    # Backward compatibility
    export CYAN=''
    export GREEN=''
    export YELLOW=''
    export RED=''
    export NC=''
}

# Auto-disable colors if output is not a terminal
if [ ! -t 1 ]; then
    disable_colors
fi

# Function to test color display
test_colors() {
    echo -e "${COLOR_HEADER_PRIMARY}▐ COLOR TEST ▌${COLOR_RESET}"
    echo -e "${COLOR_SUCCESS}Success${COLOR_RESET} | ${COLOR_ERROR}Error${COLOR_RESET} | ${COLOR_WARNING}Warning${COLOR_RESET} | ${COLOR_INFO}Info${COLOR_RESET}"
    echo -e "${COLOR_HOTKEY}[H]${COLOR_RESET}otkey | ${COLOR_WORDCOUNT}1234${COLOR_RESET} words | ${COLOR_TIME}12:34${COLOR_RESET}"
    echo -e "Cache: ${COLOR_CACHE_ENABLED}●${COLOR_RESET} Enabled | ${COLOR_CACHE_DISABLED}●${COLOR_RESET} Disabled"
}