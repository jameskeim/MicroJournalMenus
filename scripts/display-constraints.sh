#!/bin/bash
# display-constraints.sh - 98x12 display management utilities
# Shared functions for managing output within screen constraints

# ═══════════════════════════════════════════════════════════════
# DISPLAY CONSTRAINTS
# ═══════════════════════════════════════════════════════════════

# Terminal dimensions for MICRO JOURNAL 2000
readonly MAX_WIDTH=98
readonly MAX_HEIGHT=12
readonly USABLE_HEIGHT=11  # Reserve 1 line for prompts

# ═══════════════════════════════════════════════════════════════
# HEIGHT MANAGEMENT FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Check if adding more lines would exceed screen height
can_display_lines() {
    local current_lines="$1"
    local additional_lines="$2"
    local total=$((current_lines + additional_lines))
    [ "$total" -le "$USABLE_HEIGHT" ]
}

# Show paginated content with "more" breaks
paginate_output() {
    local -a content=("$@")
    local current_line=1
    
    for line in "${content[@]}"; do
        echo "$line"
        current_line=$((current_line + 1))
        
        # Check if we're approaching the limit
        if [ "$current_line" -ge "$USABLE_HEIGHT" ]; then
            echo
            read -p "Press any key for more..." -n 1 -s
            clear
            current_line=1
        fi
    done
}

# Limit session display to prevent scrolling
limit_session_display() {
    local max_sessions="${1:-3}"  # Default to 3 sessions
    local session_count=0
    
    while IFS='|' read -r filename date time word_count char_count duration wpm timestamp; do
        # Skip comment lines
        [[ "$filename" =~ ^# ]] && continue
        
        session_count=$((session_count + 1))
        if [ "$session_count" -gt "$max_sessions" ]; then
            echo "... and $(($(wc -l < "${SESSION_CACHE:-/dev/null}") - max_sessions - 2)) more sessions"
            echo "(Use 'All Files' view for complete list)"
            break
        fi
        
        # Process and display session
        local title=$(echo "$filename" | sed 's/.*-\([^.]*\)\.md$/\1/' | sed 's/-/ /g')
        printf "\033[96m%s\033[0m \033[93m%4d\033[0m  %s\n" "$time" "$word_count" "$title"
    done
}

# ═══════════════════════════════════════════════════════════════
# WIDTH MANAGEMENT FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Truncate text to fit within width constraints
truncate_text() {
    local text="$1"
    local max_width="${2:-$MAX_WIDTH}"
    
    if [ "${#text}" -gt "$max_width" ]; then
        echo "${text:0:$((max_width - 3))}..."
    else
        echo "$text"
    fi
}

# Center text within width constraints
center_text_constrained() {
    local text="$1"
    local width="${2:-$MAX_WIDTH}"
    
    # Strip ANSI codes for length calculation
    local clean_text=$(echo "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local text_length=${#clean_text}
    
    if [ "$text_length" -ge "$width" ]; then
        truncate_text "$text" "$width"
    else
        local padding=$(( (width - text_length) / 2 ))
        printf "%*s%s\n" "$padding" "" "$text"
    fi
}

# ═══════════════════════════════════════════════════════════════
# COMPACT DISPLAY TEMPLATES
# ═══════════════════════════════════════════════════════════════

# Minimal menu header (3 lines total)
show_compact_header() {
    local title="$1"
    local subtitle="$2"
    
    center_text_constrained "\033[96m▐ $title ▌\033[0m"
    if [ -n "$subtitle" ]; then
        center_text_constrained "\033[93m$subtitle\033[0m"
    fi
    echo
}

# Compact session completion (max 5 lines)
show_compact_session_complete() {
    local word_count="$1"
    local duration="$2"
    local wpm="$3"
    local goal_progress="$4"
    
    echo -e "\033[92m=== SESSION COMPLETE ===\033[0m"
    echo -e "\033[93m$word_count words, $duration, $wpm wpm\033[0m"
    echo -e "\033[92mCached for instant analytics\033[0m"
    if [ -n "$goal_progress" ]; then
        echo "$goal_progress"
    fi
    echo
}

# Ultra-compact progress bar (single line)
show_compact_progress() {
    local current="$1"
    local goal="$2"
    local width="${3:-20}"
    
    local percentage=0
    if [ "$goal" -gt 0 ]; then
        percentage=$((current * 100 / goal))
        [ "$percentage" -gt 100 ] && percentage=100
    fi
    
    local filled_length=$((percentage * width / 100))
    
    printf "Goal: ["
    for ((i=0; i<filled_length; i++)); do printf "█"; done
    for ((i=filled_length; i<width; i++)); do printf "░"; done
    printf "] %d%% (%d/%d)" "$percentage" "$current" "$goal"
}

# Compact analytics summary (max 4 lines)
show_compact_analytics() {
    local today_count="$1"
    local today_sessions="$2"
    local goal="$3"
    local cache_enabled="$4"
    
    echo "Today: $today_sessions sessions, $today_count words"
    show_compact_progress "$today_count" "$goal"
    echo
    if [ "$cache_enabled" = "true" ]; then
        echo -e "\033[92m[Instant Analytics Enabled]\033[0m"
    else
        echo -e "\033[93m[File Scanning Mode]\033[0m"
    fi
}

# ═══════════════════════════════════════════════════════════════
# MENU OPTIMIZATION FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Ultra-compact menu (max 6 lines)
show_ultra_compact_menu() {
    local title="$1"
    shift
    local -a options=("$@")
    
    center_text_constrained "\033[96m▐ $title ▌\033[0m"
    echo
    
    # Display options in compact format
    local line=""
    for option in "${options[@]}"; do
        if [ ${#line} -eq 0 ]; then
            line="$option"
        elif [ $((${#line} + ${#option} + 3)) -le "$MAX_WIDTH" ]; then
            line="$line   $option"
        else
            center_text_constrained "$line"
            line="$option"
        fi
    done
    
    if [ -n "$line" ]; then
        center_text_constrained "$line"
    fi
    
    echo
}

# ═══════════════════════════════════════════════════════════════
# SCROLLING PREVENTION
# ═══════════════════════════════════════════════════════════════

# Clear screen and start fresh to prevent scrolling
safe_display_start() {
    clear
    return 0
}

# Check remaining screen space before displaying content
get_remaining_lines() {
    # Count lines since last clear (approximation)
    # In practice, scripts should track their own line usage
    echo "$USABLE_HEIGHT"  # Conservative estimate
}

# Safe echo that checks for space
safe_echo() {
    local remaining=$(get_remaining_lines)
    if [ "$remaining" -le 2 ]; then
        echo
        read -p "Press any key to continue..." -n 1 -s
        clear
    fi
    echo "$@"
}

# ═══════════════════════════════════════════════════════════════
# TESTING FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Test display constraints
test_display_constraints() {
    echo "Testing 98x12 Display Constraints"
    echo "================================="
    
    # Test width
    local test_line=""
    for ((i=1; i<=MAX_WIDTH; i++)); do
        test_line="${test_line}x"
    done
    echo "Width test (98 chars): $test_line"
    
    # Test height
    echo "Height test (should fit in 12 lines total):"
    for ((i=1; i<=USABLE_HEIGHT; i++)); do
        echo "Line $i of $USABLE_HEIGHT usable lines"
    done
    
    echo "This should be the last visible line before prompt."
}

# Export functions for use in other scripts
export -f can_display_lines paginate_output limit_session_display
export -f truncate_text center_text_constrained
export -f show_compact_header show_compact_session_complete show_compact_progress
export -f show_compact_analytics show_ultra_compact_menu
export -f safe_display_start get_remaining_lines safe_echo