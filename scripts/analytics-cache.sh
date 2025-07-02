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

# Get accurate word count using pandoc + lua filter when available
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

# ═══════════════════════════════════════════════════════════════
# GOAL MANAGEMENT FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Load goals configuration
load_goals() {
    local config_file="${CONFIG_FILE:-$CACHE_DIR/config}"
    
    if [ -f "$config_file" ]; then
        source "$config_file" 2>/dev/null
    fi
    
    # Set defaults matching MICRO JOURNAL 2000 standards
    daily_goal=${daily_goal:-500}
    weekly_goal=${weekly_goal:-$((daily_goal * 7))}
    monthly_goal=${monthly_goal:-$((daily_goal * 30))}
}

# Save goals configuration
save_goals() {
    local config_file="${CONFIG_FILE:-$CACHE_DIR/config}"
    
    cat > "$config_file" <<EOF
# MICRO JOURNAL 2000 Goals Configuration
# Generated: $(date)
daily_goal=${daily_goal:-500}
weekly_goal=${weekly_goal:-3500}
monthly_goal=${monthly_goal:-15000}
EOF
}

# ═══════════════════════════════════════════════════════════════
# PROGRESS DISPLAY FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Show progress bar with percentage
show_progress() {
    local current=$1
    local goal=$2
    local width=${3:-20}
    
    if [ "$goal" -eq 0 ]; then
        echo "No goal set"
        return
    fi
    
    local percentage=$((current * 100 / goal))
    [ "$percentage" -gt 100 ] && percentage=100
    
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))
    
    printf "["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %3d%% (%d/%d words)\n" "$percentage" "$current" "$goal"
}

# Show today's progress (single line) - renamed to avoid conflict with display-constraints.sh
show_today_progress() {
    local current=$1
    local goal=$2
    local bar_width=${3:-15}
    
    if [ "$goal" -eq 0 ]; then
        return
    fi
    
    local percentage=$((current * 100 / goal))
    [ "$percentage" -gt 100 ] && percentage=100
    
    local filled=$((percentage * bar_width / 100))
    
    printf "Today: "
    printf "["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=filled; i<bar_width; i++)); do printf "░"; done
    printf "] %d%%" "$percentage"
}

# Get compact goal progress for session display
get_compact_goal_progress() {
    local session_words="$1"
    
    # Load goals
    load_goals
    
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
    show_today_progress "$today_total" "$daily_goal" 15
}

# ═══════════════════════════════════════════════════════════════
# TIME-BASED ANALYTICS FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Get today's word count - cache-optimized
get_today_count() {
    local today_date=$(date +%Y-%m-%d)
    
    # Try cache first (instant lookup)
    if is_cache_valid; then
        local cache_data=$(get_today_stats)
        if [ -n "$cache_data" ]; then
            # Extract total words from cache: date|total_words|file_count|total_time|avg_wpm|timestamp
            echo "$cache_data" | cut -d'|' -f2
            return
        fi
    fi
    
    # Fallback to file scanning
    local total=0
    local today_pattern=$(date +"%Y.%m.%d")
    for file in "$DOCS_DIR"/${today_pattern}-*.md; do
        if [ -f "$file" ]; then
            total=$((total + $(get_accurate_word_count "$file")))
        fi
    done
    echo "$total"
}

# Get today's session count - cache-optimized
get_today_sessions() {
    local today_date=$(date +%Y-%m-%d)
    
    if is_cache_valid; then
        local cache_data=$(get_today_stats)
        if [ -n "$cache_data" ]; then
            # Extract file count from cache
            echo "$cache_data" | cut -d'|' -f3
            return
        fi
    fi
    
    # Fallback to file counting
    local count=0
    local today_pattern=$(date +"%Y.%m.%d")
    for file in "$DOCS_DIR"/${today_pattern}-*.md; do
        if [ -f "$file" ]; then
            count=$((count + 1))
        fi
    done
    echo "$count"
}

# Get this week's word count - cache-optimized
get_week_count() {
    local total=0
    
    # Calculate week date range
    local days_since_monday=$((($(date +%u) - 1)))
    local week_start=$(date -d "-${days_since_monday} days" +%Y-%m-%d)
    local week_end=$(date -d "+$((6 - days_since_monday)) days" +%Y-%m-%d)
    
    if is_cache_valid; then
        # Sum from daily cache - MUCH FASTER
        while IFS='|' read -r date total_words file_count total_time avg_wpm timestamp; do
            # Skip comments and empty lines
            [[ "$date" =~ ^#.*$ ]] && continue
            [ -z "$date" ] && continue
            
            # Check if date is in this week
            if [[ "$date" > "$week_start" || "$date" == "$week_start" ]] && [[ "$date" < "$week_end" || "$date" == "$week_end" ]]; then
                total=$((total + total_words))
            fi
        done < "$DAILY_CACHE"
        
        echo "$total"
        return
    fi
    
    # Fallback to file scanning
    local monday_pattern=$(date -d "monday" +"%Y.%m.%d")
    for file in "$DOCS_DIR"/*.md; do
        if [ -f "$file" ]; then
            local filename=$(basename "$file")
            local file_date=$(echo "$filename" | cut -d- -f1)
            if [[ "$file_date" > "$monday_pattern" || "$file_date" == "$monday_pattern" ]]; then
                total=$((total + $(get_accurate_word_count "$file")))
            fi
        fi
    done
    echo "$total"
}

# Get this month's word count - cache-optimized
get_month_count() {
    local total=0
    local month_pattern=$(date +"%Y-%m")
    
    if is_cache_valid; then
        # Sum from daily cache
        while IFS='|' read -r date total_words file_count total_time avg_wpm timestamp; do
            # Skip comments and empty lines
            [[ "$date" =~ ^#.*$ ]] && continue
            [ -z "$date" ] && continue
            
            # Check if date is in this month
            if [[ "$date" == ${month_pattern}* ]]; then
                total=$((total + total_words))
            fi
        done < "$DAILY_CACHE"
        
        echo "$total"
        return
    fi
    
    # Fallback to file scanning
    local month_file_pattern=$(date +"%Y.%m")
    for file in "$DOCS_DIR"/${month_file_pattern}*.md; do
        if [ -f "$file" ]; then
            total=$((total + $(get_accurate_word_count "$file")))
        fi
    done
    echo "$total"
}

# Initialize cache on script load
init_analytics_cache