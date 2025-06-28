#!/bin/bash
# test-enhanced-session.sh - Test the enhanced session capture without interactive editing

# Import the enhanced newMarkDown functions
MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"
source "$MCRJRNL/scripts/analytics-cache.sh"

# ═══════════════════════════════════════════════════════════════
# SIMULATE ENHANCED SESSION
# ═══════════════════════════════════════════════════════════════

echo
echo -e "\033[92m▐ TESTING ENHANCED SESSION CAPTURE ▌\033[0m"
echo

# Simulate session timing
session_start_time=$(date +%s)
echo "Session started at: $(date +%H:%M)"

# Create test file with timestamp
datetime=$(date +"%Y.%m.%d-%H%M")
filename="${datetime}-test-session.md"
filepath="$HOME/Documents/writing/$filename"

echo "Creating test file: $filename"

# Copy our test content to the writing directory
cp "$MCRJRNL/test-session.md" "$filepath"

# Simulate some writing time (5 seconds for testing)
echo "Simulating writing session..."
sleep 5

# Calculate session duration
session_end_time=$(date +%s)
session_duration=$((session_end_time - session_start_time))

echo "Session ended at: $(date +%H:%M)"
echo

# ═══════════════════════════════════════════════════════════════
# PROCESS SESSION (SAME AS ENHANCED NEWMARKDOWN)
# ═══════════════════════════════════════════════════════════════

process_test_session() {
    local filepath="$1"
    local filename="$2"
    local session_duration="$3"
    
    echo -e "\033[92m=== PROCESSING WRITING SESSION ===\033[0m"
    
    # Get accurate word count
    local word_count=$(get_accurate_word_count "$filepath")
    local char_count=$(wc -c < "$filepath")
    
    # Calculate writing speed
    local words_per_minute=0
    if [ "$session_duration" -gt 0 ] && [ "$word_count" -gt 0 ]; then
        words_per_minute=$((word_count * 60 / session_duration))
    fi
    
    # Display session results
    echo
    echo -e "\033[93mSession Summary:\033[0m"
    echo "Words written: $word_count"
    echo "Characters: $char_count"
    echo "Session time: $(format_duration "$session_duration")"
    
    if [ "$words_per_minute" -gt 0 ]; then
        echo "Writing speed: $words_per_minute words/minute"
    fi
    
    echo "File: $filename"
    
    # Store session data in analytics cache
    echo
    echo "Saving session data to analytics cache..."
    cache_session_data "$filename" "$word_count" "$char_count" "$session_duration" "$words_per_minute"
    echo -e "\033[92m✓ Session data cached for instant analytics\033[0m"
    
    # Show goal progress
    show_goal_progress "$word_count"
    
    echo
    echo -e "\033[92mTest session complete!\033[0m"
}

# ═══════════════════════════════════════════════════════════════
# HELPER FUNCTIONS (COPIED FROM ENHANCED)
# ═══════════════════════════════════════════════════════════════

get_accurate_word_count() {
    local filepath="$1"
    
    # Try pandoc with lua filter first
    if command -v pandoc >/dev/null 2>&1 && [ -f "$MCRJRNL/filters/wordcount.lua" ]; then
        local pandoc_count=$(pandoc "$filepath" --lua-filter="$MCRJRNL/filters/wordcount.lua" --to=plain 2>/dev/null | tail -1)
        
        if [[ "$pandoc_count" =~ ^[0-9]+$ ]] && [ "$pandoc_count" -gt 0 ]; then
            echo "$pandoc_count"
            return
        fi
    fi
    
    # Fallback to basic word count
    wc -w < "$filepath" 2>/dev/null || echo 0
}

show_goal_progress() {
    local session_words="$1"
    
    # Load goals configuration
    local config_file="$MCRJRNL/config"
    local daily_goal=500  # Default
    
    if [ -f "$config_file" ]; then
        source "$config_file" 2>/dev/null
    fi
    
    # Get today's total from cache
    local today_total=0
    if is_cache_valid; then
        local today_stats=$(get_today_stats)
        if [ -n "$today_stats" ]; then
            today_total=$(echo "$today_stats" | cut -d'|' -f2)
        fi
    fi
    
    # Add current session words
    today_total=$((today_total + session_words))
    
    echo
    echo -e "\033[96m📊 Daily Goal Progress:\033[0m"
    
    # Calculate progress percentage
    local progress_pct=0
    if [ "$daily_goal" -gt 0 ]; then
        progress_pct=$((today_total * 100 / daily_goal))
        [ "$progress_pct" -gt 100 ] && progress_pct=100
    fi
    
    # Show simple progress bar
    printf "Progress: "
    display_simple_progress_bar "$progress_pct"
    echo " $progress_pct% ($today_total/$daily_goal words)"
    
    # Motivational messaging
    if [ "$today_total" -ge "$daily_goal" ]; then
        echo -e "\033[92m🎯 Daily goal achieved! Outstanding work!\033[0m"
    else
        local words_needed=$((daily_goal - today_total))
        echo "Need $words_needed more words to reach today's goal"
    fi
}

display_simple_progress_bar() {
    local percentage="$1"
    local bar_length=20
    local filled_length=$((percentage * bar_length / 100))
    
    printf "["
    for ((i=0; i<filled_length; i++)); do printf "█"; done
    for ((i=filled_length; i<bar_length; i++)); do printf "░"; done
    printf "]"
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

# ═══════════════════════════════════════════════════════════════
# RUN TEST
# ═══════════════════════════════════════════════════════════════

# Initialize analytics cache
init_analytics_cache

# Process the test session
process_test_session "$filepath" "$filename" "$session_duration"

echo
echo "═══════════════════════════════════════════════════════════════"
echo "Testing cache integration with goals.sh..."
echo

# Test that goals.sh can now see the new session data
echo "Running goals.sh to verify cache integration:"
echo "1" | timeout 10s ./scripts/goals-enhanced.sh

echo
echo "═══════════════════════════════════════════════════════════════"
echo "End-to-end test complete!"