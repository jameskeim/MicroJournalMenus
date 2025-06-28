#!/bin/bash
# newMarkDown-enhanced.sh - Writing session with analytics capture
# Enhanced version that captures session timing and integrates with analytics cache

# Configuration
EDITOR="${EDITOR:-nvim}"
MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"

# Import analytics cache system and display constraints
source "$MCRJRNL/scripts/analytics-cache.sh"
source "$MCRJRNL/scripts/display-constraints.sh"

# ═══════════════════════════════════════════════════════════════
# SESSION SETUP AND TIMING
# ═══════════════════════════════════════════════════════════════

# Capture session start time
session_start_time=$(date +%s)
session_start_display=$(date +"%H:%M")

# Get the current date and time in the format YYYY.MM.DD-HHMM
datetime=$(date +"%Y.%m.%d-%H%M")

safe_display_start
show_compact_header "NEW SESSION" "Started: $session_start_display"
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

process_completed_session() {
    local filepath="$1"
    local filename="$2"
    local session_duration="$3"
    
    echo "Processing writing session..."
    
    # Get accurate word count using existing wordcount system
    local word_count=$(get_accurate_word_count "$filepath")
    local char_count=$(wc -c < "$filepath")
    
    # Calculate writing speed
    local words_per_minute=0
    if [ "$session_duration" -gt 0 ] && [ "$word_count" -gt 0 ]; then
        words_per_minute=$((word_count * 60 / session_duration))
    fi
    
    # Store session data in analytics cache first
    if command -v cache_session_data >/dev/null 2>&1; then
        cache_session_data "$filename" "$word_count" "$char_count" "$session_duration" "$words_per_minute"
    fi
    
    # Get compact goal progress
    local goal_progress=$(get_compact_goal_progress "$word_count")
    
    # Ultra-compact session completion display (max 5 lines)
    show_compact_session_complete "$word_count" "$(format_duration "$session_duration")" "$words_per_minute" "$goal_progress"
    read -p "Press any key to continue..." -n 1 -s
}

handle_empty_session() {
    local filepath="$1"
    local filename="$2" 
    local session_duration="$3"
    
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

# Get accurate word count using pandoc + lua filter
get_accurate_word_count() {
    local filepath="$1"
    
    # Try pandoc with lua filter first (most accurate for markdown)
    if command -v pandoc >/dev/null 2>&1 && [ -f "$MCRJRNL/filters/wordcount.lua" ]; then
        local pandoc_count=$(pandoc "$filepath" --lua-filter="$MCRJRNL/filters/wordcount.lua" --to=plain 2>/dev/null | tail -1)
        
        # Validate that pandoc returned a number
        if [[ "$pandoc_count" =~ ^[0-9]+$ ]] && [ "$pandoc_count" -gt 0 ]; then
            echo "$pandoc_count"
            return
        fi
    fi
    
    # Fallback to basic word count
    wc -w < "$filepath" 2>/dev/null || echo 0
}

# Get compact goal progress (single line)
get_compact_goal_progress() {
    local session_words="$1"
    
    # Load goals configuration
    local config_file="$MCRJRNL/config"
    local daily_goal=500  # Default
    
    if [ -f "$config_file" ]; then
        source "$config_file" 2>/dev/null
    fi
    
    # Get today's total from cache or calculate
    local today_total=0
    if is_cache_valid; then
        local today_stats=$(get_today_stats)
        if [ -n "$today_stats" ]; then
            today_total=$(echo "$today_stats" | cut -d'|' -f2)
        fi
    fi
    
    # Add current session words
    today_total=$((today_total + session_words))
    
    # Return compact progress line
    show_compact_progress "$today_total" "$daily_goal" 15
}

# Legacy function - now handled by display-constraints.sh
# Kept for compatibility
display_simple_progress_bar() {
    local percentage="$1"
    local bar_length="${2:-20}"
    local filled_length=$((percentage * bar_length / 100))
    
    printf "["
    for ((i=0; i<filled_length; i++)); do printf "█"; done
    for ((i=filled_length; i<bar_length; i++)); do printf "░"; done
    printf "]"
}

# Format duration in seconds to human readable
format_duration() {
    local seconds="$1"
    local minutes=$((seconds / 60))
    local remaining_seconds=$((seconds % 60))
    
    if [ "$minutes" -gt 0 ]; then
        echo "${minutes}m ${remaining_seconds}s"
    else
        echo "${seconds}s"
    fi
}

# ═══════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════

# Initialize analytics cache
init_analytics_cache

# Launch editor for writing session
echo "Opening editor... (save and quit when finished)"
"$EDITOR" "$filepath"

# ═══════════════════════════════════════════════════════════════
# SESSION COMPLETION AND ANALYTICS CAPTURE
# ═══════════════════════════════════════════════════════════════

# Calculate session duration
session_end_time=$(date +%s)
session_duration=$((session_end_time - session_start_time))
session_end_display=$(date +"%H:%M")

safe_display_start

# Check if file was created and has content
if [ -f "$filepath" ] && [ -s "$filepath" ]; then
    process_completed_session "$filepath" "$filename" "$session_duration"
else
    handle_empty_session "$filepath" "$filename" "$session_duration"
fi