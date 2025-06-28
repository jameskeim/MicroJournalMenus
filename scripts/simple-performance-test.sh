#!/bin/bash
# simple-performance-test.sh - Direct performance comparison

MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"
source "$MCRJRNL/scripts/analytics-cache.sh"

echo "═══════════════════════════════════════════════════════════════"
echo "WORDCOUNT PERFORMANCE COMPARISON"
echo "═══════════════════════════════════════════════════════════════"
echo

# ═══════════════════════════════════════════════════════════════
# CACHE-ENHANCED FUNCTIONS (FROM ENHANCED VERSION)
# ═══════════════════════════════════════════════════════════════

count_today_cached() {
    local today_date=$(date +%Y-%m-%d)
    local total_words=0
    local file_count=0
    
    if is_cache_valid; then
        while IFS='|' read -r filename date time word_count char_count duration wmp timestamp; do
            [[ "$filename" =~ ^#.*$ ]] && continue
            [ -z "$filename" ] && continue
            
            if [ "$date" = "$today_date" ]; then
                total_words=$((total_words + word_count))
                file_count=$((file_count + 1))
            fi
        done < "$SESSION_CACHE"
        
        echo "Today (cached): $file_count files, $total_words words"
    else
        echo "Cache unavailable"
    fi
}

count_recent_cached() {
    if is_cache_valid; then
        local recent_sessions=$(get_recent_sessions 5)
        local count=0
        
        if [ -n "$recent_sessions" ]; then
            count=$(echo "$recent_sessions" | wc -l)
        fi
        
        echo "Recent (cached): $count sessions"
    else
        echo "Cache unavailable"
    fi
}

# ═══════════════════════════════════════════════════════════════
# ORIGINAL FILE-SCANNING FUNCTIONS
# ═══════════════════════════════════════════════════════════════

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
    
    echo "Today (file scan): $file_count files, $total_words words"
}

count_recent_original() {
    local DOCS_DIR="$HOME/Documents/writing"
    local count=0
    
    recent_files=$(find "$DOCS_DIR" -name "*.md" -type f -printf '%T@ %p\n' | sort -nr | head -5 | cut -d' ' -f2-)
    
    if [ -n "$recent_files" ]; then
        while IFS= read -r file; do
            if [ -n "$file" ]; then
                words=$(get_word_count_original "$file") >/dev/null
                count=$((count + 1))
            fi
        done <<<"$recent_files"
    fi
    
    echo "Recent (file scan): $count files processed"
}

# ═══════════════════════════════════════════════════════════════
# PERFORMANCE TESTS
# ═══════════════════════════════════════════════════════════════

echo "Testing Cache-Enhanced Functions:"
echo "---------------------------------"

echo -n "Today's writing (cached): "
start_time=$(date +%s%N)
count_today_cached >/dev/null
end_time=$(date +%s%N)
duration=$(((end_time - start_time) / 1000000))
echo "${duration}ms"

echo -n "Recent files (cached): "
start_time=$(date +%s%N)
count_recent_cached >/dev/null
end_time=$(date +%s%N)
duration=$(((end_time - start_time) / 1000000))
echo "${duration}ms"

echo

echo "Testing Original File-Scanning Functions:"
echo "-----------------------------------------"

echo -n "Today's writing (file scan): "
start_time=$(date +%s%N)
count_today_original >/dev/null
end_time=$(date +%s%N)
duration=$(((end_time - start_time) / 1000000))
echo "${duration}ms"

echo -n "Recent files (file scan): "
start_time=$(date +%s%N)
count_recent_original >/dev/null
end_time=$(date +%s%N)
duration=$(((end_time - start_time) / 1000000))
echo "${duration}ms"

echo

echo "Cache Status:"
echo "-------------"
if is_cache_valid; then
    session_count=$(grep -v '^#' "$SESSION_CACHE" | wc -l)
    echo "✓ Session cache: $session_count entries"
    echo "✓ Daily cache: $(grep -v '^#' "$DAILY_CACHE" | wc -l) days"
else
    echo "✗ Cache unavailable"
fi

total_files=$(find "$HOME/Documents/writing" -name "*.md" -type f | wc -l)
echo "• Total files: $total_files"

echo
echo "Enhanced Features in Cache Version:"
echo "-----------------------------------"
echo "✓ Session timing data"
echo "✓ Writing speed metrics"
echo "✓ Instant lookups"
echo "✓ Performance indicators"
echo "✓ Graceful fallbacks"

echo
echo "═══════════════════════════════════════════════════════════════"