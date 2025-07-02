#!/bin/bash
# newMarkDown-enhanced.sh - Writing session with analytics capture
# Enhanced version that captures session timing and integrates with analytics cache
# HARMONIZATION PASS 1: COMPLETED - Full compliance: styling imports, harmonized display functions

# Configuration
EDITOR="${EDITOR:-nvim}"
MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"

# Minimal imports for fast startup - heavy analytics loaded after editor
source "$MCRJRNL/scripts/colors.sh"
source "$MCRJRNL/scripts/display-constraints.sh"  # Lightweight display utilities

# ═══════════════════════════════════════════════════════════════
# SESSION SETUP AND TIMING
# ═══════════════════════════════════════════════════════════════

# Capture session start time
session_start_time=$(date +%s)
session_start_display=$(date +"%H:%M")

# Get the current date and time in the format YYYY.MM.DD-HHMM
datetime=$(date +"%Y.%m.%d-%H%M")

clear
echo -e "${COLOR_HEADER_PRIMARY}▐ NEW SESSION ▌${COLOR_RESET}"
echo -e "${COLOR_INFO}Started: $session_start_display${COLOR_RESET}"
echo
echo -n "Title (optional): "
read -r title

# Clean up title: replace spaces with hyphens, remove special characters
if [ -n "$title" ]; then
    # Convert to lowercase, replace spaces with hyphens, remove non-alphanumeric/hyphen chars
    clean_title=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[[:space:]]\+/-/g' | sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
    
    if [ -n "$clean_title" ]; then
        filename="${datetime}-${clean_title}.md"
    else
        filename="${datetime}.md"
    fi
else
    filename="${datetime}.md"
fi

filepath="$HOME/Documents/writing/$filename"

echo "Creating: $(truncate_text "$filename" 80)"

# Ensure writing directory exists
mkdir -p ~/Documents/writing

# ═══════════════════════════════════════════════════════════════
# WRITING SESSION
# ═══════════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════════════════════
# SESSION PROCESSING FUNCTIONS (DEFINED BEFORE USE)
# ═══════════════════════════════════════════════════════════════

# process_completed_session moved to after editor

# handle_empty_session moved to after editor

# All analytics functions loaded after editor for optimal startup speed

# ═══════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════

# Launch editor for writing session - FAST STARTUP!
echo "Opening editor..."
"$EDITOR" "$filepath"

# ═══════════════════════════════════════════════════════════════
# POST-EDITOR: LOAD FULL SYSTEMS AND PROCESS SESSION
# ═══════════════════════════════════════════════════════════════

# Now load the heavy systems after user has finished writing
echo "Saving and analyzing your work..."
source "$MCRJRNL/scripts/gum-styles.sh"
source "$MCRJRNL/scripts/analytics-cache.sh"

# Verify analytics functions are available
if ! command -v get_accurate_word_count >/dev/null 2>&1; then
    echo "Error: Analytics system failed to load. Using basic word count."
    get_accurate_word_count() { wc -w < "$1" 2>/dev/null || echo 0; }
    cache_session_data() { :; }  # No-op
    get_compact_goal_progress() { :; }  # No-op  
    format_duration() { echo "${1}s"; }  # Basic fallback
fi

# ═══════════════════════════════════════════════════════════════
# SESSION PROCESSING FUNCTIONS (NOW WITH FULL ANALYTICS LOADED)
# ═══════════════════════════════════════════════════════════════

process_completed_session() {
    local filepath="$1"
    local filename="$2"
    local session_duration="$3"
    
    echo "Analyzing writing session..."
    
    # Get accurate word count using analytics system
    local word_count=$(get_accurate_word_count "$filepath")
    local char_count=$(wc -c < "$filepath")
    
    # Calculate writing speed
    local words_per_minute=0
    if [ "$session_duration" -gt 0 ] && [ "$word_count" -gt 0 ]; then
        words_per_minute=$((word_count * 60 / session_duration))
    fi
    
    # Store session data in analytics cache
    echo "Caching session data for instant analytics..."
    cache_session_data "$filename" "$word_count" "$char_count" "$session_duration" "$words_per_minute"
    
    # Get goal progress
    local goal_progress=$(get_compact_goal_progress "$word_count")
    
    # Session completion display with full styling
    echo -e "${COLOR_SUCCESS}=== SESSION COMPLETE ===${COLOR_RESET}"
    echo -e "${COLOR_INFO}$word_count words, $(format_duration "$session_duration"), $words_per_minute wpm${COLOR_RESET}"
    echo -e "${COLOR_SUCCESS}Securely cached for instant analytics${COLOR_RESET}"
    if [ -n "$goal_progress" ]; then
        echo "$goal_progress"
    fi
    echo
    read -p "Press any key to continue..." -n 1 -s
}

handle_empty_session() {
    local filepath="$1"
    local filename="$2" 
    local session_duration="$3"
    
    echo "Processing session..."
    echo "No content written."
    echo "Session time: $(format_duration "$session_duration")"
    
    # Remove empty file
    if [ -f "$filepath" ]; then
        rm "$filepath"
        echo "Empty file removed: $filename"
    fi
    
    echo
    echo "No worries - every writing session is practice, even the short ones!"
    echo
    read -p "Press any key to continue..."
}

# ═══════════════════════════════════════════════════════════════
# SESSION COMPLETION AND ANALYTICS CAPTURE
# ═══════════════════════════════════════════════════════════════

# Calculate session duration
session_end_time=$(date +%s)
session_duration=$((session_end_time - session_start_time))
session_end_display=$(date +"%H:%M")

clear

# Check if file was created and has content
if [ -f "$filepath" ] && [ -s "$filepath" ]; then
    process_completed_session "$filepath" "$filename" "$session_duration"
else
    handle_empty_session "$filepath" "$filename" "$session_duration"
fi