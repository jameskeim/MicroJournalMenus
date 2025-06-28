#!/bin/bash
# debug-session-completion.sh - Test session completion logic

MCRJRNL="$HOME/.microjournal"
source "$MCRJRNL/scripts/analytics-cache.sh"

echo "=== DEBUGGING SESSION COMPLETION LOGIC ==="
echo

# Test file details
test_file="$HOME/Documents/writing/2025.06.28-1307-quick-work-count-test.md"
filename=$(basename "$test_file")

echo "Test file: $test_file"
echo "Filename: $filename"
echo

# Check file existence and content
echo "File checks:"
if [ -f "$test_file" ]; then
    echo "✓ File exists"
else
    echo "✗ File does not exist"
    exit 1
fi

if [ -s "$test_file" ]; then
    echo "✓ File has content"
    file_size=$(stat -c%s "$test_file")
    echo "  File size: $file_size bytes"
else
    echo "✗ File is empty"
    exit 1
fi

echo
echo "File content:"
cat "$test_file"
echo
echo "--- End of file content ---"
echo

# Test word counting function
echo "Testing word count function:"
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

word_count=$(get_accurate_word_count "$test_file")
echo "Word count: $word_count"

char_count=$(wc -c < "$test_file")
echo "Character count: $char_count"

echo

# Test cache function availability
echo "Testing cache function availability:"
if command -v cache_session_data >/dev/null 2>&1; then
    echo "✓ cache_session_data function is available"
else
    echo "✗ cache_session_data function is not available"
    echo "Available functions:"
    declare -F | grep cache
fi

echo

# Test if session is already in cache
echo "Checking if already in cache:"
if grep -q "^$filename|" "$SESSION_CACHE" 2>/dev/null; then
    echo "✓ File found in session cache"
    grep "^$filename|" "$SESSION_CACHE"
else
    echo "✗ File not found in session cache"
fi

echo

# Simulate process_completed_session logic
echo "=== SIMULATING PROCESS_COMPLETED_SESSION ==="
session_duration=180  # 3 minutes for testing

echo "Processing writing session..."
echo "Word count: $word_count"
echo "Character count: $char_count"
echo "Session duration: $session_duration seconds"

# Calculate writing speed
words_per_minute=0
if [ "$session_duration" -gt 0 ] && [ "$word_count" -gt 0 ]; then
    words_per_minute=$((word_count * 60 / session_duration))
fi
echo "Words per minute: $words_per_minute"

echo

# Test cache_session_data function
echo "Testing cache_session_data function:"
if command -v cache_session_data >/dev/null 2>&1; then
    echo "Calling cache_session_data..."
    cache_session_data "$filename" "$word_count" "$char_count" "$session_duration" "$words_per_minute"
    echo "✓ cache_session_data completed"
else
    echo "✗ cache_session_data function not available"
fi

echo
echo "=== DEBUG COMPLETE ==="