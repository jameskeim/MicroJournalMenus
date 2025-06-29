# MICRO JOURNAL 2000 Style Guide

## Overview

This style guide defines the visual and interaction standards for all scripts in the MICRO JOURNAL 2000 system, ensuring consistency across the 98×12 display constraint and 40% keyboard optimization.

## Two-Tier UI System

### Main Menu (Aesthetic Showcase)
- Complex gum styling with borders and sophisticated layouts
- Centered, visually impressive design with column arrangements
- Premium hardware aesthetic with decorative elements

### Secondary Scripts (Functional Efficiency)
- Left-aligned, space-efficient design
- Minimal blank lines for maximum information density
- Strategic color coding for hierarchy and function

## Color System

### Load Standardized Colors
```bash
# Always include at start of scripts
source "${MCRJRNL:-$HOME/.microjournal}/scripts/colors.sh"
```

### Semantic Color Usage
- `COLOR_SUCCESS` - Achievements, completion, positive status
- `COLOR_ERROR` - Errors, failures, missing items
- `COLOR_WARNING` - Warnings, prompts, attention needed
- `COLOR_INFO` - Metadata, timestamps, cache status
- `COLOR_HEADER_PRIMARY` - Main section headers (▐ TITLE ▌)
- `COLOR_HOTKEY` - Menu hotkeys [T], [Q], etc.
- `COLOR_WORDCOUNT` - Numerical data and counts
- `COLOR_TIME` - Timestamps and durations

### Example Usage
```bash
echo -e "${COLOR_HEADER_PRIMARY}▐ WORD COUNT ▌${COLOR_RESET} ${COLOR_CACHE_ENABLED}●${COLOR_RESET}"
echo -e "${COLOR_HOTKEY}[T]${COLOR_RESET}oday's Writing  ${COLOR_HOTKEY}[F]${COLOR_RESET}ile Analysis"
printf "${COLOR_TIME}%s${COLOR_RESET} ${COLOR_WORDCOUNT}%4d${COLOR_RESET}  %s\n" "$time" "$words" "$title"
```

## Gum Styling System

### Load Standardized Gum Styles
```bash
# Include in scripts using gum
source "${MCRJRNL:-$HOME/.microjournal}/scripts/gum-styles.sh"
```

### High-Contrast Interactive Elements

#### Problem Solved: gum choose/confirm Button Visibility
The default gum styling creates poor contrast between **selected and unselected buttons** - both the button background and text are light colors, making it hard to see which option is highlighted.

**Note**: The elegant light purple content text for prompts (159) and light gray for inspirational content (146) should be **kept as-is** - they look elegant and are for content display, not interactive buttons.

#### Solutions:

**High-Contrast Button Selection:**
```bash
# Instead of: gum choose "Option1" "Option2" "Option3"  
# Use: (dark text on bright background when selected)
gum_choose_contrast "Select option:" "Option1" "Option2" "Option3"
```

**High-Contrast Confirmation Buttons:**
```bash
# For dangerous operations (shutdown, delete, etc.)
# Selected button: black text on red background
if gum_confirm_danger "Are you sure you want to shutdown?"; then

# For normal confirmations  
# Selected button: black text on green background
if gum_confirm_normal "Continue with this action?"; then
```

### Content Styling Functions

**Headers:**
```bash
gum_header_primary "▐ MAIN TITLE ▌"     # Bright cyan, bold
gum_header_secondary "Subtitle"         # Yellow, bold
```

**Messages:**
```bash
gum_success "Operation completed"       # Green
gum_error "Failed to connect"          # Red  
gum_info "Cache status updated"        # Cyan
```

**Content Display:**
```bash
gum_content "Writing prompt text"      # Centered, purple
gum_elegant "Inspirational quote"      # Centered, light gray
```

**Layout:**
```bash
gum_center_98 "Text content"           # Centered in 98-char width
gum_column "46" "20" "Column content"  # Colored column with border
```

### Gum Color Constants
```bash
GUM_HEADER_PRIMARY="81"    # Bright cyan for main headers
GUM_SUCCESS="46"           # Bright green for success
GUM_ERROR="196"            # Red for errors/warnings
GUM_INFO="33"              # Cyan for information
GUM_PROMPT="159"           # Light purple for content
GUM_ELEGANT="146"          # Light gray for elegant content
```

## Secondary Script Layout Pattern

### Template Structure
```bash
#!/bin/bash
# script-name.sh - Brief description

# Load standardized systems
source "${MCRJRNL:-$HOME/.microjournal}/scripts/colors.sh"
source "${MCRJRNL:-$HOME/.microjournal}/scripts/gum-styles.sh"  # If using gum

clear

# Header (Line 1): Simple colored title
if is_cache_valid; then
    echo -e "${COLOR_HEADER_PRIMARY}▐ TITLE ▌${COLOR_RESET} ${COLOR_CACHE_ENABLED}●${COLOR_RESET}"
else
    echo -e "${COLOR_HEADER_PRIMARY}▐ TITLE ▌${COLOR_RESET} ${COLOR_CACHE_DISABLED}●${COLOR_RESET}"
fi

# Menu options (Lines 2-4): Left-aligned, minimal spacing
echo -e "${COLOR_HOTKEY}[O]${COLOR_RESET}ption One    ${COLOR_HOTKEY}[T]${COLOR_RESET}wo Options"
echo -e "${COLOR_HOTKEY}[A]${COLOR_RESET}nother       ${COLOR_HOTKEY}[F]${COLOR_RESET}inal Option"
echo -e "${COLOR_HOTKEY}[Q]${COLOR_RESET}uit"

# Prompt (Line 5): Direct, functional
echo -n "${COLOR_PROMPT}Selection: ${COLOR_RESET}"
```

### Key Principles

**40% Keyboard Optimization:**
- Use letter-based navigation (no numbers requiring key-chords)
- Highlight hotkeys with `COLOR_HOTKEY` 
- Consistent [Q]uit across all scripts

**98×12 Display Optimization:**
- Maximum 12 lines total
- 98 characters maximum width
- Eliminate unnecessary blank lines
- Use horizontal space efficiently

**Space Efficiency Techniques:**
- Two-column menu layouts where possible
- Inline status indicators (● green/yellow)
- Strategic color coding instead of spacing for hierarchy
- Functional headers only (no decorative elements)

## Menu Option Formatting

### Standard Pattern
```bash
echo -e "${COLOR_HOTKEY}[T]${COLOR_RESET}oday's Writing  ${COLOR_HOTKEY}[F]${COLOR_RESET}ile Analysis"
echo -e "${COLOR_HOTKEY}[R]${COLOR_RESET}ecent Files     ${COLOR_HOTKEY}[A]${COLOR_RESET}ll Files"
echo -e "${COLOR_HOTKEY}[Q]${COLOR_RESET}uit"
```

### Hotkey Selection Pattern
- Use first letter of primary word: **[T]**oday, **[F]**ile, **[Q]**uit
- Avoid conflicts within same menu
- Use semantic letters: **[S]**et, **[V]**iew, **[E]**dit

### Input Handling
```bash
choice=$(get_single_key | tr '[:upper:]' '[:lower:]')

case $choice in
't') # Today's action ;;
'f') # File action ;;
'q') break ;;
*) echo -e "${COLOR_ERROR}Invalid choice.${COLOR_RESET}" ;;
esac
```

## Pagination and Data Display

### Pagination Pattern (for large datasets)
```bash
# Use arrays for data management
declare -a all_files all_words all_dates

# Fixed items per page for consistent layout
local items_per_page=8  # Fit within 12-line constraint

# Navigation with consistent keys
echo -n "[p]rev [n]ext [q]uit: "
key=$(get_single_key | tr '[:upper:]' '[:lower:]')
```

### Data Formatting
```bash
# Consistent column alignment
printf "${COLOR_TIME}%s${COLOR_RESET} ${COLOR_WORDCOUNT}%4d${COLOR_RESET}  %s\n" "$time" "$words" "$title"

# Truncate long content to fit width
if [ ${#title} -gt 83 ]; then
    title="${title:0:80}..."
fi
```

## Testing and Validation

### Color System Test
```bash
source scripts/colors.sh && test_colors
```

### Gum Styling Test  
```bash
source scripts/gum-styles.sh && gum_test_contrast
```

### Display Constraint Validation
- Test all interfaces at exactly 98×12 characters
- Verify no horizontal scrolling required
- Ensure all content fits within 12 lines

## Implementation Checklist

For each new or updated script:

- [ ] Loads standardized color system
- [ ] Uses semantic color variables (not raw ANSI codes)
- [ ] Loads gum styling system if using gum
- [ ] Uses high-contrast gum functions
- [ ] Headers use standard `▐ TITLE ▌` format
- [ ] Menu options use letter-based navigation
- [ ] Hotkeys highlighted with `COLOR_HOTKEY`
- [ ] Fits within 98×12 display constraint
- [ ] Uses [Q]uit consistently
- [ ] No unnecessary blank lines
- [ ] Left-aligned functional layout (secondary scripts)

This guide ensures visual consistency, accessibility, and optimal use of the hardware constraints across the entire MICRO JOURNAL 2000 ecosystem.