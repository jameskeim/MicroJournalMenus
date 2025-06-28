#!/bin/bash
# test-wordcount-performance.sh - Compare original vs enhanced wordcount performance

MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"
source "$MCRJRNL/scripts/analytics-cache.sh"

echo "═══════════════════════════════════════════════════════════════"
echo "WORDCOUNT.SH PERFORMANCE COMPARISON"
echo "═══════════════════════════════════════════════════════════════"
echo

# ═══════════════════════════════════════════════════════════════
# TEST ENHANCED VERSION FUNCTIONS
# ═══════════════════════════════════════════════════════════════

echo "Testing Enhanced Version (Cache-Optimized):"
echo "-------------------------------------------"

# Test today's view
echo -n "Today's Writing: "
start_time=$(date +%s%N)
source "$MCRJRNL/scripts/wordcount-enhanced.sh"
count_today >/dev/null 2>&1
end_time=$(date +%s%N)
duration=$(((end_time - start_time) / 1000000))  # Convert to milliseconds
echo "${duration}ms"

# Test recent files view  
echo -n "Recent Files: "
start_time=$(date +%s%N)
count_recent >/dev/null 2>&1
end_time=$(date +%s%N)
duration=$(((end_time - start_time) / 1000000))
echo "${duration}ms"

echo

# ═══════════════════════════════════════════════════════════════
# TEST ORIGINAL VERSION FUNCTIONS
# ═══════════════════════════════════════════════════════════════

echo "Testing Original Version (File Scanning):"
echo "------------------------------------------"

# Define original functions for comparison
get_word_count_original() {
    local file="$1"
    
    if command -v pandoc >/dev/null 2>&1 && [[ "$file" == *.md ]]; then
        local pandoc_words=$(pandoc --lua-filter="$HOME/.microjournal/filters/wordcount.lua" "$file" 2>/dev/null)
        if [ -n "$pandoc_words" ] && [ "$pandoc_words" -gt 0 ]; then
            echo "$pandoc_words"
            return
        fi
    fi
    
    wc -w <"$file"
}

count_today_original() {
    local TODAY=$(date +%Y.%m.%d)
    local DOCS_DIR="$HOME/Documents/writing"
    
    local total_words=0
    local file_count=0
    
    for file in "$DOCS_DIR"/${TODAY}-*.md; do
        if [ -f "$file" ]; then
            words=$(get_word_count_original "$file")
            total_words=$((total_words + words))
            file_count=$((file_count + 1))
        fi
    done
    
    echo "Total: $file_count files, $total_words words" >/dev/null
}

count_recent_original() {
    local DOCS_DIR="$HOME/Documents/writing"
    
    # Find last 5 markdown files, sorted by modification time
    recent_files=$(find "$DOCS_DIR" -name "*.md" -type f -printf '%T@ %p\n' | sort -nr | head -5 | cut -d' ' -f2-)
    
    if [ -n "$recent_files" ]; then
        while IFS= read -r file; do
            if [ -n "$file" ]; then
                words=$(get_word_count_original "$file") >/dev/null
            fi
        done <<<"$recent_files"
    fi
}

# Test today's view (original)
echo -n "Today's Writing: "
start_time=$(date +%s%N)
count_today_original >/dev/null 2>&1
end_time=$(date +%s%N)
duration=$(((end_time - start_time) / 1000000))
echo "${duration}ms"

# Test recent files view (original)
echo -n "Recent Files: "
start_time=$(date +%s%N)
count_recent_original >/dev/null 2>&1
end_time=$(date +%s%N)
duration=$(((end_time - start_time) / 1000000))
echo "${duration}ms"

echo

# ═══════════════════════════════════════════════════════════════
# DETAILED COMPARISON
# ═══════════════════════════════════════════════════════════════

echo "Detailed Performance Analysis:"
echo "------------------------------"

# Cache status
if is_cache_valid; then
    local session_count=$(grep -v '^#' "$SESSION_CACHE" | wc -l)
    echo "✓ Analytics cache: $session_count sessions cached"
    echo "✓ Cache file size: $(du -h "$SESSION_CACHE" | cut -f1)"
    echo "✓ Daily aggregates: $(grep -v '^#' "$DAILY_CACHE" | wc -l) days"
else
    echo "✗ Analytics cache: unavailable"
fi

# File count for comparison
local file_count=$(find "$HOME/Documents/writing" -name "*.md" -type f | wc -l)
echo "• Total files in corpus: $file_count"

echo

echo "Enhanced Features Available:"
echo "---------------------------"
echo "✓ Instant session breakdowns"
echo "✓ Writing speed data (words/minute)"
echo "✓ Session duration tracking"
echo "✓ Real-time performance indicators"
echo "✓ Cache hit/miss reporting"
echo "✓ Graceful fallback to file scanning"

echo
echo "═══════════════════════════════════════════════════════════════"