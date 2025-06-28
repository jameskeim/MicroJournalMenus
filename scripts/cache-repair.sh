#!/bin/bash
# cache-repair.sh - Proper cache refresh that scans for missing files

MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"
source "$MCRJRNL/scripts/analytics-cache.sh"

# ═══════════════════════════════════════════════════════════════
# PROPER CACHE REFRESH FUNCTION
# ═══════════════════════════════════════════════════════════════

refresh_session_cache() {
    echo "Scanning for files missing from session cache..."
    local missing_count=0
    local processed_count=0
    
    # Find all missing files
    for file in "$HOME/Documents/writing"/*.md; do
        [ -f "$file" ] || continue
        
        local filename=$(basename "$file")
        
        # Check if it matches our naming convention
        if [[ "$filename" =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{2}-[0-9]{4}.*\.md$ ]]; then
            # Check if missing from cache
            if ! grep -q "^$filename|" "$SESSION_CACHE" 2>/dev/null; then
                echo "Processing missing file: $filename"
                missing_count=$((missing_count + 1))
                
                # Process the file
                if process_missing_file "$file" "$filename"; then
                    processed_count=$((processed_count + 1))
                    echo "  ✓ Added to cache"
                else
                    echo "  ✗ Failed to process"
                fi
            fi
        fi
    done
    
    if [ $missing_count -eq 0 ]; then
        echo "✓ No missing files found - cache is up to date"
    else
        echo
        echo "Cache refresh complete:"
        echo "  Files found missing: $missing_count"
        echo "  Files processed: $processed_count"
        
        if [ $processed_count -gt 0 ]; then
            echo "  Rebuilding daily aggregates..."
            rebuild_daily_cache
        fi
    fi
}

# Process a single missing file and add to cache
process_missing_file() {
    local file="$1"
    local filename="$2"
    
    # Get accurate word count
    local word_count=$(get_accurate_word_count "$file")
    [ "$word_count" -gt 0 ] || return 1
    
    # Get character count
    local char_count=$(wc -c < "$file" 2>/dev/null || echo 0)
    
    # Extract date and time from filename
    local date_part=$(echo "$filename" | cut -d- -f1 | tr '.' '-')
    local time_part=$(echo "$filename" | sed 's/.*-\([0-9]\{4\}\).*/\1/' | sed 's/\(..\)\(..\)/\1:\2/')
    
    # Estimate session duration (we can't recover the actual time)
    # Use a reasonable estimate based on word count
    local estimated_duration=$((word_count * 60 / 15))  # Assume 15 wpm baseline
    local estimated_wpm=15
    
    # Add timestamp
    local timestamp=$(date +%s)
    
    # Add to session cache
    echo "$filename|$date_part|$time_part|$word_count|$char_count|$estimated_duration|$estimated_wpm|$timestamp" >> "$SESSION_CACHE"
    
    return 0
}

# Accurate word count function (same as enhanced scripts)
get_accurate_word_count() {
    local file="$1"
    
    # Try pandoc with lua filter first (most accurate for markdown)
    if command -v pandoc >/dev/null 2>&1 && [ -f "$MCRJRNL/filters/wordcount.lua" ]; then
        local pandoc_count=$(pandoc "$file" --lua-filter="$MCRJRNL/filters/wordcount.lua" --to=plain 2>/dev/null | tail -1)
        
        # Validate that pandoc returned a number
        if [[ "$pandoc_count" =~ ^[0-9]+$ ]] && [ "$pandoc_count" -gt 0 ]; then
            echo "$pandoc_count"
            return
        fi
    fi
    
    # Fallback to basic word count
    wc -w < "$file" 2>/dev/null || echo 0
}

# ═══════════════════════════════════════════════════════════════
# MANUAL SESSION COMPLETION (for newMarkDown debug)
# ═══════════════════════════════════════════════════════════════

manual_session_completion() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "Error: File not found: $file"
        return 1
    fi
    
    local filename=$(basename "$file")
    echo "Manually processing session for: $filename"
    
    # Check if already in cache
    if grep -q "^$filename|" "$SESSION_CACHE" 2>/dev/null; then
        echo "File already in cache - skipping"
        return 0
    fi
    
    # Get file stats
    local word_count=$(get_accurate_word_count "$file")
    local char_count=$(wc -c < "$file")
    
    # For manual completion, we can't know the actual session duration
    # So we'll estimate based on word count
    local estimated_duration=$((word_count * 60 / 15))
    local estimated_wpm=15
    
    echo "Word count: $word_count"
    echo "Session time: $(format_duration "$estimated_duration") (estimated)"
    echo "Writing speed: $estimated_wpm wpm (estimated)"
    
    # Add to cache
    local date_part=$(echo "$filename" | cut -d- -f1 | tr '.' '-')
    local time_part=$(echo "$filename" | sed 's/.*-\([0-9]\{4\}\).*/\1/' | sed 's/\(..\)\(..\)/\1:\2/')
    local timestamp=$(date +%s)
    
    echo "$filename|$date_part|$time_part|$word_count|$char_count|$estimated_duration|$estimated_wpm|$timestamp" >> "$SESSION_CACHE"
    
    echo "✓ Added to session cache"
    
    # Update daily cache
    update_daily_cache "$date_part"
    echo "✓ Updated daily cache"
    
    return 0
}

# Format duration helper
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

case "${1:-refresh}" in
    "refresh"|"scan")
        refresh_session_cache
        ;;
    "manual")
        if [ -n "$2" ]; then
            manual_session_completion "$2"
        else
            echo "Usage: $0 manual /path/to/file.md"
        fi
        ;;
    "help")
        echo "Usage: $0 [refresh|manual file.md|help]"
        echo "  refresh: Scan for missing files and add to cache"
        echo "  manual:  Manually process a specific file"
        echo "  help:    Show this help"
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use '$0 help' for usage information"
        ;;
esac