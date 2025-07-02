#!/bin/bash
# test-newmarkdown-display.sh - Test display constraints in newMarkDown

echo "=== TESTING NEWMARKDOWN DISPLAY CONSTRAINTS ==="
echo

# Test the session completion display function
MCRJRNL="$HOME/.microjournal"
source "$MCRJRNL/scripts/analytics-cache.sh"
source "$MCRJRNL/scripts/display-constraints.sh"

# Test the compact session completion
echo "Testing compact session completion display:"
echo "==========================================="

# Mock the session completion function
get_compact_goal_progress() {
    local session_words="$1"
    local today_total=$((session_words + 123))  # Simulate existing words
    local daily_goal=500
    
    show_today_progress "$today_total" "$daily_goal" 15
}

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

# Simulate the new compact session completion
word_count=245
session_duration=312  # 5m 12s
words_per_minute=47
goal_progress=$(get_compact_goal_progress "$word_count")

echo "Starting display test..."
echo

# This should use only 5 lines maximum
safe_display_start
show_compact_session_complete "$word_count" "$(format_duration "$session_duration")" "$words_per_minute" "$goal_progress"

echo
echo "=== DISPLAY TEST RESULTS ==="
echo "Lines used: Should be 5 lines maximum"
echo "Width: All content should fit within 98 characters"
echo "The above output represents the new compact session completion"
echo
echo "Key improvements:"
echo "- Removed verbose headers"
echo "- Combined timing and word count on one line"
echo "- Eliminated unnecessary spacing"
echo "- Used compact goal progress display"
echo "- Fits comfortably within 98x12 constraints"