# MICRO JOURNAL 2000 - Color Usage Analysis

## Executive Summary

Analysis of 18 shell scripts reveals inconsistent color usage patterns across the system. While most scripts use similar color meanings (green for success, red for errors), the implementation varies between raw ANSI codes, color variables, and gum styling.

## Current Color Inventory

### Most Frequently Used Colors (by occurrence)

| Color Code | Count | Hex/Name | Usage Pattern |
|------------|--------|----------|--------------|
| `\033[0m` | 238 | Reset | Universal reset code |
| `\033[92m` | 64 | Bright Green | Success messages, headers, today's data |
| `\033[93m` | 61 | Bright Yellow | Warnings, status messages, word counts |
| `\033[91m` | 40 | Bright Red | Errors, failures, "not found" messages |
| `\033[96m` | 35 | Bright Cyan | Timestamps, file info, cache indicators |
| `\033[1;38;5;81m` | 17 | Bold Cyan (256-color) | Section headers, titles |
| `\033[94m` | 6 | Bright Blue | Column headers, table headers |

### Specialized Colors (lower frequency)

| Color Code | Count | Purpose |
|------------|-------|---------|
| `\033[1;33m` | 5 | Bold Yellow - goal tracking |
| `\033[0;36m` | 5 | Dark Cyan - defined variables |
| `\033[0;32m` | 5 | Dark Green - defined variables |
| `\033[90m` | 4 | Dark Gray - secondary info |
| `\033[0;31m` | 4 | Dark Red - defined variables |
| `\033[1;38;5;46m` | 3 | Bold Bright Green (256-color) - statistics |
| `\033[1;38;5;220m` | 3 | Bold Yellow (256-color) - totals |

## Color Semantic Analysis

### Headers and Titles
- **Primary Headers**: `\033[1;38;5;81m` (Bold Cyan 256-color) - used for main section titles
- **Secondary Headers**: `\033[92m` (Bright Green) - used for subsection titles
- **Table Headers**: `\033[94m` (Bright Blue) - column headers in data tables

### Status and Feedback
- **Success**: `\033[92m` (Bright Green) - completions, goals achieved
- **Warning**: `\033[93m` (Bright Yellow) - cache misses, processing messages
- **Error**: `\033[91m` (Bright Red) - failures, not found, invalid input
- **Info**: `\033[96m` (Bright Cyan) - timestamps, metadata, performance info

### Data Display
- **Numbers/Counts**: `\033[93m` (Bright Yellow) - word counts, statistics
- **Timestamps**: `\033[96m` (Bright Cyan) - dates, times, file info
- **Filenames**: `\033[93m` (Bright Yellow) - file names in listings
- **Metadata**: `\033[90m` (Dark Gray) - secondary information

### Interactive Elements
- **Hotkeys**: `\033[92m` (Bright Green) - menu hotkeys like [T]oday, [Q]uit
- **Prompts**: `\033[93m` (Bright Yellow) - "Press any key to continue"

## Implementation Patterns

### 1. Inline ANSI Codes (Most Common)
```bash
echo -e "\033[92mToday ($TODAY):\033[0m"
printf "\033[96m%s\033[0m \033[93m%4d\033[0m  %s\n" "$time" "$word_count" "$title"
```
**Used in**: wordcount-enhanced.sh, wordcount.sh, network.sh, journal.sh

### 2. Color Variables (Inconsistent)
```bash
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
```
**Used in**: goals-enhanced.sh, backup.sh, prompts.sh (partially)

### 3. Gum Styling (Menu System)
```bash
gum style --foreground 81 --background 0 --bold --width 20 --align center "MICRO JOURNAL 2000"
gum style --foreground "$color" --bold "$key"
```
**Used in**: menu system exclusively

## Inconsistencies Identified

### 1. Variable Naming Conflicts
- `goals-enhanced.sh` uses `CYAN='\033[0;36m'` (dark cyan)
- `prompts.sh` uses `CYAN='\033[0;36m'` (same)
- But most scripts use `\033[96m` (bright cyan) inline

### 2. Color Code Variations
**For Yellow/Gold:**
- `\033[93m` (bright yellow) - most common
- `\033[1;33m` (bold yellow) - goals.sh
- `\033[1;38;5;220m` (256-color yellow) - prompts.sh

**For Green:**
- `\033[92m` (bright green) - most common
- `\033[0;32m` (dark green) - variable definitions
- `\033[1;38;5;46m` (256-color bright green) - prompts.sh

### 3. Mixed Paradigms
Some scripts mix inline ANSI codes with color variables:
```bash
# Define variables
CYAN='\033[0;36m'
GREEN='\033[0;32m'

# But then use inline codes
echo -e "\033[92mSuccess message\033[0m"  # Different green!
```

## Recommendations for Color System

### 1. Standardized Color Palette
```bash
# Primary colors (most used)
COLOR_RESET='\033[0m'
COLOR_SUCCESS='\033[92m'      # Bright Green - success, headers
COLOR_WARNING='\033[93m'      # Bright Yellow - warnings, numbers
COLOR_ERROR='\033[91m'        # Bright Red - errors, failures
COLOR_INFO='\033[96m'         # Bright Cyan - timestamps, metadata

# Headers and titles
COLOR_HEADER='\033[1;38;5;81m'  # Bold Cyan (256-color) - main headers
COLOR_SUBHEADER='\033[94m'      # Bright Blue - column headers

# Secondary colors
COLOR_SECONDARY='\033[90m'      # Dark Gray - less important info
COLOR_HIGHLIGHT='\033[1;38;5;46m' # Bold Bright Green - statistics
COLOR_TOTAL='\033[1;38;5;220m'  # Bold Yellow - totals, summaries
```

### 2. Semantic Color Mapping
```bash
# Functional aliases
COLOR_TODAY="$COLOR_SUCCESS"        # Today's data
COLOR_FILENAME="$COLOR_WARNING"     # File names
COLOR_TIMESTAMP="$COLOR_INFO"       # Dates and times
COLOR_WORDCOUNT="$COLOR_WARNING"    # Numbers and counts
COLOR_HOTKEY="$COLOR_SUCCESS"       # Menu hotkeys
COLOR_PROMPT="$COLOR_WARNING"       # User prompts
COLOR_CACHE="$COLOR_INFO"           # Cache indicators
COLOR_NOTFOUND="$COLOR_ERROR"       # Missing files/data
```

### 3. Gum Integration
For consistency with the menu system:
```bash
# Gum color numbers (for --foreground option)
GUM_SUCCESS=92      # Maps to \033[92m
GUM_WARNING=93      # Maps to \033[93m
GUM_ERROR=91        # Maps to \033[91m
GUM_INFO=96         # Maps to \033[96m
GUM_HEADER=81       # Maps to \033[1;38;5;81m
GUM_SUBHEADER=94    # Maps to \033[94m
```

## Migration Strategy

### Phase 1: Create Color Library
Create `/home/jkeim/.microjournal/scripts/colors.sh` with standardized definitions.

### Phase 2: Update High-Impact Scripts
Priority scripts for color standardization:
1. `wordcount-enhanced.sh` - most color usage
2. `goals-enhanced.sh` - mixed paradigms
3. `network.sh` - good semantic usage
4. `prompts.sh` - 256-color inconsistencies

### Phase 3: Systematic Replacement
Replace inline ANSI codes with standardized variables across all scripts.

## Display Constraints

All color choices must work within the 98×12 character display constraint:
- Colors must be visible on black background (fbterm default)
- Color combinations must maintain readability
- Bright colors (9x series) are preferred for visibility
- 256-color codes should be used sparingly (terminal compatibility)

## Current System Strength

The system already has good semantic color usage:
- Green consistently means success/positive
- Red consistently means error/negative  
- Yellow consistently means warning/attention
- Cyan consistently means metadata/info

The main issue is implementation inconsistency, not semantic meaning.