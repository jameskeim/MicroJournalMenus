#!/bin/bash
# test-newmarkdown-fix.sh - Test the fixed newMarkDown script logic

echo "=== TESTING FIXED NEWMARKDOWN-ENHANCED.SH ==="
echo

# Create a test file with a timestamped name
test_filename="2025.06.28-1400-test-session-completion.md"
test_filepath="$HOME/Documents/writing/$test_filename"

# Create test content
cat > "$test_filepath" << 'EOF'
# Test Session

This is a test writing session to verify that the session completion logic works correctly after fixing the function definition order bug.

The script should now properly:
1. Calculate word count
2. Calculate session duration 
3. Update the analytics cache
4. Show session completion message

This should be approximately 50 words for testing.
EOF

echo "Created test file: $test_filename"
echo "Content:"
cat "$test_filepath"
echo
echo "Word count: $(wc -w < "$test_filepath")"
echo

# Test if the session completion logic would work
echo "Testing function availability..."

# Source the script functions
MCRJRNL="$HOME/.microjournal"
source "$MCRJRNL/scripts/analytics-cache.sh"

# Define the functions from newMarkDown-enhanced.sh
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
    
    # Compact session results for 98x12 display
    echo
    echo -e "\\033[93m$word_count words, $(format_duration "$session_duration")"
    if [ "$words_per_minute" -gt 0 ]; then
        echo -n ", $words_per_minute wpm"
    fi
    echo -e "\\033[0m"
    
    # Store session data in analytics cache
    if command -v cache_session_data >/dev/null 2>&1; then
        cache_session_data "$filename" "$word_count" "$char_count" "$session_duration" "$words_per_minute"
        echo -e "\\033[92mCached for instant analytics\\033[0m"
        return 0
    else
        echo "✗ cache_session_data function not available"
        return 1
    fi
}

# Now test the session completion logic
echo "Testing session completion with test file..."
echo

# Simulate a 2-minute session
test_session_duration=120

if [ -f "$test_filepath" ] && [ -s "$test_filepath" ]; then
    echo "✓ File exists and has content"
    echo "Running process_completed_session..."
    echo
    
    if process_completed_session "$test_filepath" "$test_filename" "$test_session_duration"; then
        echo "✓ Session completion successful!"
    else
        echo "✗ Session completion failed!"
    fi
else
    echo "✗ File check failed"
fi

echo
echo "=== TEST COMPLETE ==="

# Clean up test file
read -p "Remove test file? (y/n): " -n 1 remove_test
echo
if [[ "$remove_test" =~ ^[Yy]$ ]]; then
    rm "$test_filepath"
    echo "Test file removed."
fi