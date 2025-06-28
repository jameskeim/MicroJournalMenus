#!/bin/bash
# goals-enhanced.sh - Cache-Enhanced Goal Tracking for MICRO JOURNAL 2000
# Performance-optimized version using analytics cache system

# Configuration
MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"
DOCS_DIR="$HOME/Documents/writing"
CONFIG_FILE="$MCRJRNL/config"
TODAY=$(date +%Y.%m.%d)

# Import analytics cache system
source "$MCRJRNL/scripts/analytics-cache.sh"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ═══════════════════════════════════════════════════════════════
# CACHE-OPTIMIZED WORD COUNT FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Get today's word count - OPTIMIZED with cache lookup
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
    
    # Fallback to file scanning (original method)
    echo "Cache miss - scanning files..." >&2
    local total=0
    for file in "$DOCS_DIR"/${TODAY}-*.md; do
        if [ -f "$file" ]; then
            total=$((total + $(get_word_count "$file")))
        fi
    done
    echo "$total"
}

# Get today's session count - OPTIMIZED
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
    for file in "$DOCS_DIR"/${TODAY}-*.md; do
        if [ -f "$file" ]; then
            count=$((count + 1))
        fi
    done
    echo "$count"
}

# Get this week's word count - OPTIMIZED
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
    
    # Fallback to original file scanning method
    echo "Cache unavailable - scanning files..." >&2
    for file in "$DOCS_DIR"/*.md; do
        if [ -f "$file" ]; then
            local file_date=$(basename "$file" | cut -d'-' -f1-3 | tr '.' '-')
            if [[ "$file_date" > "$week_start" || "$file_date" == "$week_start" ]] && [[ "$file_date" < "$week_end" || "$file_date" == "$week_end" ]]; then
                total=$((total + $(get_word_count "$file")))
            fi
        fi
    done
    echo "$total"
}

# Get this month's word count - OPTIMIZED  
get_month_count() {
    local total=0
    local month_prefix=$(date +%Y-%m)
    
    if is_cache_valid; then
        # Sum from daily cache - MUCH FASTER
        while IFS='|' read -r date total_words file_count total_time avg_wpm timestamp; do
            # Skip comments and empty lines
            [[ "$date" =~ ^#.*$ ]] && continue
            [ -z "$date" ] && continue
            
            # Check if date is in this month
            if [[ "$date" == ${month_prefix}-* ]]; then
                total=$((total + total_words))
            fi
        done < "$DAILY_CACHE"
        
        echo "$total"
        return
    fi
    
    # Fallback to original file scanning method
    echo "Cache unavailable - scanning files..." >&2
    local month_pattern=$(date +%Y.%m)
    for file in "$DOCS_DIR"/${month_pattern}.*.md; do
        if [ -f "$file" ]; then
            total=$((total + $(get_word_count "$file")))
        fi
    done
    echo "$total"
}

# ═══════════════════════════════════════════════════════════════
# ORIGINAL FUNCTIONS (UNCHANGED)
# ═══════════════════════════════════════════════════════════════

# Function to get accurate word count for markdown files (fallback only)
get_word_count() {
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

# Load goals from config file
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE" 2>/dev/null
    fi
    
    # Set defaults matching WordCountOverview.md
    daily_goal=${daily_goal:-500}
    weekly_goal=${weekly_goal:-3500}
    monthly_goal=${monthly_goal:-15000}
}

# Save goals to config file
save_config() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat > "$CONFIG_FILE" << EOF
# MICRO JOURNAL 2000 - Writing Goals Configuration
# Cache-Enhanced Goal Tracking System

daily_goal=$daily_goal
weekly_goal=$weekly_goal
monthly_goal=$monthly_goal
EOF
}

# Show ASCII progress bar
show_progress() {
    local current=$1
    local goal=$2
    local width=20
    
    if [ "$goal" -eq 0 ]; then
        echo "No goal set"
        return
    fi
    
    local percentage=$((current * 100 / goal))
    local filled=$((current * width / goal))
    
    if [ "$filled" -gt "$width" ]; then
        filled=$width
    fi
    
    local bar=""
    for i in $(seq 1 $filled); do
        bar="${bar}█"
    done
    for i in $(seq $((filled + 1)) $width); do
        bar="${bar}░"
    done
    
    if [ "$current" -ge "$goal" ]; then
        echo -e "${GREEN}$bar${NC} ${percentage}% (${current}/${goal})"
    elif [ "$percentage" -ge 80 ]; then
        echo -e "${YELLOW}$bar${NC} ${percentage}% (${current}/${goal})"
    else
        echo -e "$bar ${percentage}% (${current}/${goal})"
    fi
}

# Set goals interface (98x12 optimized)
set_goals() {
    clear
    echo
    printf "%*s\n" $(((98 - 10) / 2)) ""
    echo -e "\033[1;38;5;81m▐ SET GOALS ▌\033[0m"
    echo
    
    load_config
    
    echo "Current goals:"
    echo "Daily: $daily_goal words | Weekly: $weekly_goal words | Monthly: $monthly_goal words"
    echo
    
    read -p "New daily goal [$daily_goal]: " new_daily
    if [ -n "$new_daily" ] && [ "$new_daily" -gt 0 ] 2>/dev/null; then
        daily_goal=$new_daily
    fi
    
    read -p "New weekly goal [$weekly_goal]: " new_weekly
    if [ -n "$new_weekly" ] && [ "$new_weekly" -gt 0 ] 2>/dev/null; then
        weekly_goal=$new_weekly
    fi
    
    read -p "New monthly goal [$monthly_goal]: " new_monthly
    if [ -n "$new_monthly" ] && [ "$new_monthly" -gt 0 ] 2>/dev/null; then
        monthly_goal=$new_monthly
    fi
    
    save_config
    
    echo
    echo -e "${GREEN}Goals updated successfully${NC}"
    echo
    read -p "Press Enter to continue..."
}

# ═══════════════════════════════════════════════════════════════
# ENHANCED PROGRESS DASHBOARD
# ═══════════════════════════════════════════════════════════════

show_progress_dashboard() {
    clear
    echo
    printf "%*s\n" $(((98 - 17) / 2)) ""
    echo -e "\033[1;38;5;81m▐ WRITING PROGRESS ▌\033[0m"
    
    # Show cache status for debugging
    if is_cache_valid; then
        echo -e "${GREEN}[Cache Enabled]${NC}"
    else
        echo -e "${YELLOW}[Cache Unavailable - File Scanning]${NC}"
    fi
    echo
    
    load_config
    
    # PERFORMANCE TEST: Time the operations
    local start_time=$(date +%s%N)
    
    local today_count=$(get_today_count)
    local today_sessions=$(get_today_sessions)
    local week_count=$(get_week_count)
    local month_count=$(get_month_count)
    
    local end_time=$(date +%s%N)
    local duration=$(((end_time - start_time) / 1000000))  # Convert to milliseconds
    
    # Today's Progress
    echo "Goal Progress: $(show_progress "$today_count" "$daily_goal")"
    echo
    
    # Show today's sessions
    if [ "$today_count" -gt 0 ]; then
        echo "Sessions today: $today_sessions"
        
        # Show recent session details if cache available
        if is_cache_valid; then
            echo "Recent sessions:"
            get_recent_sessions 3 | while IFS='|' read filename date time words chars duration wpm timestamp; do
                [ -z "$filename" ] && continue
                local title=$(extract_title_from_filename "$filename")
                printf "  %s %s: %d words" "$date" "$time" "$words"
                [ -n "$title" ] && [ "$title" != "[untitled]" ] && printf " (%s)" "$title"
                echo
            done
        fi
        echo
    fi
    
    # Weekly and Monthly Progress
    echo "This Week: $week_count/$weekly_goal words"
    echo "This Month: $month_count/$monthly_goal words"
    echo
    
    # Goal achievement messaging
    if [ "$today_count" -ge "$daily_goal" ]; then
        echo -e "${GREEN}*** Daily goal achieved! Total: $today_count words ***${NC}"
    else
        local needed=$((daily_goal - today_count))
        echo "Need $needed more words to reach daily goal"
    fi
    
    # Performance indicator
    echo
    echo -e "${CYAN}Analytics loaded in ${duration}ms${NC}"
    
    echo
    read -p "Press Enter to continue..."
}

# Cache management menu
show_cache_menu() {
    clear
    echo
    printf "%*s\n" $(((98 - 15) / 2)) ""
    echo -e "\033[1;38;5;81m▐ CACHE MANAGEMENT ▌\033[0m"
    echo
    
    show_cache_stats
    echo
    
    echo "1) Rebuild daily cache   2) Show cache contents   3) Back to main menu"
    echo
    printf "Choice: "
    read -n 1 -s choice
    echo "$choice"
    echo
    
    case "$choice" in
    "1")
        rebuild_daily_cache
        echo
        read -p "Press Enter to continue..."
        ;;
    "2")
        echo "Session Cache (last 10 entries):"
        tail -10 "$SESSION_CACHE" | while IFS='|' read filename date time words chars duration wpm timestamp; do
            [[ "$filename" =~ ^#.*$ ]] && continue
            [ -z "$filename" ] && continue
            printf "%s %s: %d words (%ds)\n" "$date" "$time" "$words" "$duration"
        done
        echo
        echo "Daily Cache:"
        tail -5 "$DAILY_CACHE" | while IFS='|' read date words files time wpm timestamp; do
            [[ "$date" =~ ^#.*$ ]] && continue
            [ -z "$date" ] && continue
            printf "%s: %d words, %d files\n" "$date" "$words" "$files"
        done
        echo
        read -p "Press Enter to continue..."
        ;;
    "3")
        return
        ;;
    esac
}

# ═══════════════════════════════════════════════════════════════
# MAIN INTERFACE
# ═══════════════════════════════════════════════════════════════

case "${1:-menu}" in
"set")
    set_goals
    ;;
"progress" | "p")
    show_progress_dashboard
    ;;
"cache")
    show_cache_menu
    ;;
*)
    # Menu mode
    while true; do
        clear
        echo
        printf "%*s\n" $(((98 - 8) / 2)) ""
        echo -e "\033[1;38;5;81m▐ GOALS ▌\033[0m"
        echo
        echo "1) View Progress   2) Set Goals   3) Cache Management   Q) Quit"
        echo
        printf "Choice: "
        read -n 1 -s choice
        echo "$choice"
        echo
        
        case "$choice" in
        "1")
            show_progress_dashboard
            ;;
        "2")
            set_goals
            ;;
        "3")
            show_cache_menu
            ;;
        "q"|"Q")
            break
            ;;
        *)
            echo "Invalid choice."
            sleep 1
            ;;
        esac
    done
    ;;
esac