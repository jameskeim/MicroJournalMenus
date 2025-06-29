#!/bin/bash
# gum-styles.sh - MICRO JOURNAL 2000 Standardized Gum Styling System
# Source this file in scripts for consistent gum styling

# ═══════════════════════════════════════════════════════════════
# GUM STYLE DEFINITIONS
# ═══════════════════════════════════════════════════════════════

# Color constants for gum (256-color palette)
export GUM_HEADER_PRIMARY="81"        # Bright cyan for main headers
export GUM_HEADER_SECONDARY="220"     # Yellow for subheaders
export GUM_SUCCESS="46"               # Bright green for success
export GUM_ERROR="196"                # Red for errors/warnings
export GUM_INFO="33"                  # Cyan for information
export GUM_PROMPT="159"               # Light purple for prompts/content
export GUM_ELEGANT="146"              # Light gray for elegant content

# Column colors for main menu system
export GUM_CREATE="46"                # Green for CREATE column
export GUM_PROCESS="33"               # Cyan for PROCESS column
export GUM_SHARE="208"                # Orange for SHARE column
export GUM_PAUSE="201"                # Magenta for PAUSE column
export GUM_CONTROL="196"              # Red for CONTROL column

# ═══════════════════════════════════════════════════════════════
# HIGH-CONTRAST GUM STYLING FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# High-contrast gum choose (fixes button selection visibility)
gum_choose_contrast() {
    local header="$1"
    shift
    gum choose \
        --cursor.foreground="0" \
        --cursor.background="15" \
        --selected.foreground="0" \
        --selected.background="15" \
        --unselected.foreground="15" \
        --unselected.background="0" \
        --header.foreground="81" \
        --header "$header" \
        "$@"
}

# High-contrast gum confirm for critical operations (dark text on bright background when selected)
gum_confirm_danger() {
    local message="$1"
    gum confirm \
        --selected.foreground="0" \
        --selected.background="196" \
        --unselected.foreground="15" \
        --unselected.background="0" \
        --prompt.foreground="196" \
        "$message"
}

# High-contrast gum confirm for normal operations (dark text on bright background when selected)
gum_confirm_normal() {
    local message="$1"
    gum confirm \
        --selected.foreground="0" \
        --selected.background="46" \
        --unselected.foreground="15" \
        --unselected.background="0" \
        --prompt.foreground="81" \
        "$message"
}

# Styled input with consistent appearance
gum_input_styled() {
    local placeholder="$1"
    local width="${2:-50}"
    gum input \
        --placeholder="$placeholder" \
        --width="$width" \
        --cursor.foreground="15" \
        --prompt.foreground="81"
}

# ═══════════════════════════════════════════════════════════════
# CONTENT STYLING FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Primary header styling (main section titles)
gum_header_primary() {
    local text="$1"
    gum style --foreground "$GUM_HEADER_PRIMARY" --bold "$text"
}

# Secondary header styling (subsection titles)
gum_header_secondary() {
    local text="$1"
    gum style --foreground "$GUM_HEADER_SECONDARY" --bold "$text"
}

# Success message styling
gum_success() {
    local text="$1"
    gum style --foreground "$GUM_SUCCESS" "$text"
}

# Error/warning message styling
gum_error() {
    local text="$1"
    gum style --foreground "$GUM_ERROR" "$text"
}

# Information message styling
gum_info() {
    local text="$1" 
    gum style --foreground "$GUM_INFO" "$text"
}

# Content display styling (for prompts, quotes, etc.) - Keep this elegant light purple!
gum_content() {
    local text="$1"
    local width="${2:-98}"
    local padding="${3:-3 0}"
    gum style --foreground "$GUM_PROMPT" --align center --width "$width" --padding "$padding" "$text"
}

# Elegant content styling (for inspirational content) - Keep this elegant light gray!
gum_elegant() {
    local text="$1"
    local width="${2:-98}"
    local padding="${3:-4 0 0 0}"
    gum style --foreground "$GUM_ELEGANT" --align center --width "$width" --padding "$padding" "$text"
}

# ═══════════════════════════════════════════════════════════════
# LAYOUT STYLING FUNCTIONS  
# ═══════════════════════════════════════════════════════════════

# Column styling for menu system
gum_column() {
    local color="$1"
    local width="$2"
    local content="$3"
    gum style --border rounded --border-foreground "$color" --padding "0 1" --width "$width" "$content"
}

# Centered layout for 98-character constraint
gum_center_98() {
    local text="$1"
    local padding="${2:-0 0}"
    gum style --align center --width 98 --padding "$padding" "$text"
}

# ═══════════════════════════════════════════════════════════════
# ACCESSIBILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Test contrast and visibility
gum_test_contrast() {
    echo "=== GUM CONTRAST TEST ==="
    echo
    gum_header_primary "▐ PRIMARY HEADER ▌"
    gum_header_secondary "Secondary Header"
    echo
    
    echo "Choose test (should have high contrast):"
    gum_choose_contrast "Select an option:" "Option 1" "Option 2" "Option 3"
    echo
    
    echo "Confirm tests:"
    echo -n "Normal confirm: "
    gum_confirm_normal "Continue with normal action?"
    echo -n "Danger confirm: "
    gum_confirm_danger "Continue with dangerous action?"
    echo
    
    gum_success "Success message"
    gum_error "Error message"
    gum_info "Information message"
    echo
    
    gum_content "This is content display text with proper contrast"
    gum_elegant "This is elegant inspirational text"
}

# Check if gum is available and working
check_gum() {
    if ! command -v gum >/dev/null 2>&1; then
        echo "Warning: gum not found. Install with: sudo apt install gum"
        return 1
    fi
    
    # Test gum functionality
    if ! echo "test" | gum style --foreground 46 >/dev/null 2>&1; then
        echo "Warning: gum not functioning properly"
        return 1
    fi
    
    return 0
}

# ═══════════════════════════════════════════════════════════════
# SCRIPT INITIALIZATION
# ═══════════════════════════════════════════════════════════════

# Auto-check gum availability when sourced
if ! check_gum; then
    echo "Gum styling functions loaded but gum not available"
fi