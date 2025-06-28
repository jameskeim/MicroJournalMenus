#!/bin/bash
# analytics-cache.sh - Core cache management system for MICRO JOURNAL 2000
# Provides fast analytics by caching word counts and session data

# Configuration
CACHE_DIR="$HOME/.microjournal"
SESSION_CACHE="$CACHE_DIR/session_cache"
DAILY_CACHE="$CACHE_DIR/daily_cache"
DOCS_DIR="$HOME/Documents/writing"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# ═══════════════════════════════════════════════════════════════
# CORE CACHE OPERATIONS
# ═══════════════════════════════════════════════════════════════

# Initialize cache system
init_analytics_cache() {
    # Create cache files if they don't exist
    if [ ! -f "$SESSION_CACHE" ]; then
        echo "# MICRO JOURNAL 2000 Session Cache - $(date)" > "$SESSION_CACHE"
        echo "# Format: filename|date|time|word_count|char_count|session_duration|wpm|timestamp" >> "$SESSION_CACHE"
    fi
    
    if [ ! -f "$DAILY_CACHE" ]; then
        echo "# MICRO JOURNAL 2000 Daily Cache - $(date)" > "$DAILY_CACHE"
        echo "# Format: date|total_words|file_count|total_time|avg_wpm|last_updated" >> "$DAILY_CACHE"
    fi
}

# Add session data to cache
cache_session_data() {
    local filename="$1" 
    local word_count="$2" 
    local char_count="$3" 
    local session_duration="$4" 
    local wpm="$5"
    
    # Extract date and time from filename
    local date_part=$(echo "$filename" | cut -d- -f1 | tr '.' '-')
    local time_part=$(echo "$filename" | sed 's/.*-\([0-9]\{4\}\).*/\1/' | sed 's/\(..\)\(..\)/\1:\2/')
    local timestamp=$(date +%s)
    
    # Append to session cache
    echo "$filename|$date_part|$time_part|$word_count|$char_count|$session_duration|$wpm|$timestamp" >> "$SESSION_CACHE"
    
    # Update daily cache
    update_daily_cache "$date_part"
}

# Update daily aggregated statistics
update_daily_cache() {
    local date="$1"
    
    # Calculate daily totals from session cache
    local daily_stats=$(grep "|$date|" "$SESSION_CACHE" | grep -v '^#' | awk -F'|' -v date="$date" '
    {
        total_words += $4
        file_count++
        total_time += $6
        if ($6 > 0) {
            wpm_sum += ($4 * 60 / $6)
            wmp_sessions++
        }
    }
    END {
        avg_wpm = (wmp_sessions > 0) ? int(wmp_sum / wmp_sessions) : 0
        print total_words "|" file_count "|" total_time "|" avg_wpm
    }')
    
    if [ -n "$daily_stats" ]; then
        local timestamp=$(date +%s)
        
        # Remove existing entry for this date and add updated one
        grep -v "^$date|" "$DAILY_CACHE" > "$DAILY_CACHE.tmp" 2>/dev/null || true
        echo "$date|$daily_stats|$timestamp" >> "$DAILY_CACHE.tmp"
        mv "$DAILY_CACHE.tmp" "$DAILY_CACHE"
    fi
}

# ═══════════════════════════════════════════════════════════════
# FAST CACHE LOOKUPS
# ═══════════════════════════════════════════════════════════════

# Get today's writing statistics (instant lookup)
get_today_stats() {
    local today=$(date +%Y-%m-%d)
    grep "^$today|" "$DAILY_CACHE" 2>/dev/null | head -1
}

# Get recent writing sessions
get_recent_sessions() {
    local count=${1:-5}
    grep -v '^#' "$SESSION_CACHE" | grep -v '^$' | tail -n "$count" 2>/dev/null
}

# Get statistics for specific date
get_date_stats() {
    local date="$1"
    grep "^$date|" "$DAILY_CACHE" 2>/dev/null | head -1
}

# Get session count (total writing sessions)
get_total_sessions() {
    grep -v '^#' "$SESSION_CACHE" | grep -v '^$' | wc -l 2>/dev/null
}

# Get date range of cached data
get_cache_date_range() {
    local first_date=$(grep -v '^#' "$SESSION_CACHE" | grep -v '^$' | head -1 | cut -d'|' -f2 2>/dev/null)
    local last_date=$(grep -v '^#' "$SESSION_CACHE" | grep -v '^$' | tail -1 | cut -d'|' -f2 2>/dev/null)
    
    if [ -n "$first_date" ] && [ -n "$last_date" ]; then
        echo "$first_date to $last_date"
    else
        echo "No cached data"
    fi
}

# ═══════════════════════════════════════════════════════════════
# CACHE VALIDATION AND FALLBACK
# ═══════════════════════════════════════════════════════════════

# Check if cache is available and valid
is_cache_valid() {
    [ -f "$SESSION_CACHE" ] && [ -f "$DAILY_CACHE" ] && [ -r "$SESSION_CACHE" ] && [ -r "$DAILY_CACHE" ]
}

# Get statistics with fallback to file scanning
get_stats_with_fallback() {
    local mode="$1"  # "today", "recent", "date:YYYY-MM-DD"
    
    if is_cache_valid; then
        case "$mode" in
            "today")
                get_today_stats
                ;;
            "recent")
                get_recent_sessions 5
                ;;
            date:*)
                local date="${mode#date:}"
                get_date_stats "$date"
                ;;
        esac
    else
        echo "Cache unavailable, falling back to file scanning..."
        fallback_to_file_scan "$mode"
    fi
}

# Fallback to traditional file scanning when cache unavailable
fallback_to_file_scan() {
    local mode="$1"
    
    case "$mode" in
        "today")
            # Scan today's files
            local today_pattern=$(date +"%Y.%m.%d")
            local total_words=0
            local file_count=0
            
            for file in "$DOCS_DIR"/${today_pattern}-*.md; do
                [ -f "$file" ] || continue
                local words=$(wc -w < "$file" 2>/dev/null || echo 0)
                total_words=$((total_words + words))
                file_count=$((file_count + 1))
            done
            
            if [ "$file_count" -gt 0 ]; then
                echo "$(date +%Y-%m-%d)|$total_words|$file_count|0|0|$(date +%s)"
            fi
            ;;
        "recent")
            # Show recent files by modification time
            find "$DOCS_DIR" -name "*.md" -type f | head -5 | while read file; do
                local filename=$(basename "$file")
                local words=$(wc -w < "$file" 2>/dev/null || echo 0)
                echo "$filename|unknown|unknown|$words|0|0|0|0"
            done
            ;;
    esac
}

# ═══════════════════════════════════════════════════════════════
# CACHE MAINTENANCE
# ═══════════════════════════════════════════════════════════════

# Rebuild daily cache from session cache
rebuild_daily_cache() {
    echo "Rebuilding daily cache from session data..."
    
    # Create new daily cache header
    echo "# MICRO JOURNAL 2000 Daily Cache - Rebuilt $(date)" > "$DAILY_CACHE.new"
    echo "# Format: date|total_words|file_count|total_time|avg_wpm|last_updated" >> "$DAILY_CACHE.new"
    
    # Aggregate all session data by date
    grep -v '^#' "$SESSION_CACHE" | grep -v '^$' | awk -F'|' '
    {
        date = $2
        daily_words[date] += $4
        daily_files[date] += 1
        daily_time[date] += $6
        if ($6 > 0) {
            wmp_sum[date] += ($4 * 60 / $6)
            wmp_count[date] += 1
        }
    }
    END {
        for (date in daily_words) {
            avg_wpm = (wmp_count[date] > 0) ? int(wmp_sum[date] / wmp_count[date]) : 0
            timestamp = systime()
            print date "|" daily_words[date] "|" daily_files[date] "|" daily_time[date] "|" avg_wpm "|" timestamp
        }
    }' | sort >> "$DAILY_CACHE.new"
    
    # Replace old cache with new one
    mv "$DAILY_CACHE.new" "$DAILY_CACHE"
    echo "Daily cache rebuilt successfully"
}

# Show cache statistics
show_cache_stats() {
    echo "Analytics Cache Statistics:"
    echo "=========================="
    
    if is_cache_valid; then
        local session_count=$(get_total_sessions)
        local date_range=$(get_cache_date_range)
        local cache_size=$(du -h "$SESSION_CACHE" "$DAILY_CACHE" 2>/dev/null | awk '{total+=$1} END {print total"K"}')
        
        echo "Session records: $session_count"
        echo "Date range: $date_range"
        echo "Cache size: $cache_size"
        echo "Last updated: $(date -r "$SESSION_CACHE" 2>/dev/null || echo 'Unknown')"
    else
        echo "Cache not available or invalid"
    fi
}

# ═══════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Format duration in seconds to human readable
format_duration() {
    local seconds="$1"
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local remaining_seconds=$((seconds % 60))
    
    if [ "$hours" -gt 0 ]; then
        echo "${hours}h ${minutes}m"
    elif [ "$minutes" -gt 0 ]; then
        echo "${minutes}m ${remaining_seconds}s"
    else
        echo "${seconds}s"
    fi
}

# Extract title from filename
extract_title_from_filename() {
    local filename="$1"
    local title=$(echo "$filename" | sed 's/^[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}-[0-9]\{4\}-*\(.*\)\.md$/\1/')
    [ -z "$title" ] && title="[untitled]"
    echo "$title"
}

# Initialize cache on script load
init_analytics_cache