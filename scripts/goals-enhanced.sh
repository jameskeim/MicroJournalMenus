#!/bin/bash
# goals-enhanced.sh - Cache-Enhanced Goal Tracking for MICRO JOURNAL 2000
# Performance-optimized version using analytics cache system
# HARMONIZATION PASS 2: COMPLETED - Fixed numbered menus to use letters with hotkey colors

# Configuration
MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"
DOCS_DIR="$HOME/Documents/writing"
CONFIG_FILE="$MCRJRNL/config"
TODAY=$(date +%Y.%m.%d)

# Load standardized styling systems
source "$MCRJRNL/scripts/colors.sh"
source "$MCRJRNL/scripts/gum-styles.sh"

# Import analytics cache system (needed for performance optimization)
source "$MCRJRNL/scripts/analytics-cache.sh"

# ═══════════════════════════════════════════════════════════════
# CACHE-OPTIMIZED WORD COUNT FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# get_today_count is now provided by analytics-cache.sh

# get_today_sessions is now provided by analytics-cache.sh

# get_week_count is now provided by analytics-cache.sh

# get_month_count is now provided by analytics-cache.sh

# ═══════════════════════════════════════════════════════════════
# ORIGINAL FUNCTIONS (UNCHANGED)
# ═══════════════════════════════════════════════════════════════

# Use centralized word counting function from analytics-cache.sh
get_word_count() {
    get_accurate_word_count "$1"
}

# load_config replaced with load_goals from analytics-cache.sh

# save_config replaced with save_goals from analytics-cache.sh

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
    echo -e "${COLOR_HEADER_PRIMARY}▐ SET GOALS ▌${COLOR_RESET}"
    echo
    
    load_goals
    
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
    
    save_goals
    
    echo
    echo -e "${GREEN}Goals updated successfully${NC}"
    echo
    read -p "Press Enter to continue..."
}

# ═══════════════════════════════════════════════════════════════
# PAGER UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Function to get single keypress (borrowed from wordcount-enhanced.sh)
get_single_key() {
    local old_tty_settings=$(stty -g)
    stty -icanon -echo min 1 time 0
    local key=$(dd bs=1 count=1 2>/dev/null)
    stty "$old_tty_settings"
    echo "$key"
}

# Show today's sessions with pagination (98x12 optimized)
show_today_sessions_paged() {
    local today_date=$(date +%Y-%m-%d)
    local sessions_per_page=8  # Maximum sessions that fit in 12-line display
    local current_page=1
    
    # Build session arrays from cache
    declare -a session_files
    declare -a session_dates
    declare -a session_times
    declare -a session_words
    declare -a session_titles
    
    local session_count=0
    local total_words=0
    
    if is_cache_valid; then
        # Get today's sessions from session cache
        while IFS='|' read -r filename date time word_count char_count duration wmp timestamp; do
            # Skip comments and empty lines
            [[ "$filename" =~ ^#.*$ ]] && continue
            [ -z "$filename" ] && continue
            
            # Filter for today's entries
            if [ "$date" = "$today_date" ]; then
                session_files+=("$filename")
                session_dates+=("$date")
                session_times+=("$time")
                session_words+=("$word_count")
                session_titles+=("$(extract_title_from_filename "$filename")")
                
                total_words=$((total_words + word_count))
                session_count=$((session_count + 1))
            fi
        done < "$SESSION_CACHE"
    fi
    
    if [ $session_count -eq 0 ]; then
        clear
        echo -e "${COLOR_ERROR}No writing sessions found for today.${COLOR_RESET}"
        echo -n "Press any key to continue..."
        read -n 1 -s
        return
    fi
    
    # Use pagination for all session views (consistent UX)
    local total_pages=$(((session_count + sessions_per_page - 1) / sessions_per_page))
    
    while true; do
        clear
        
        # Compact header (Line 1)
        echo -e "${COLOR_HEADER_PRIMARY}▐ TODAY'S SESSIONS ▌${COLOR_RESET} Page $current_page/$total_pages"
        
        # Session list (Lines 2-9, up to 8 sessions)
        local start_idx=$(((current_page - 1) * sessions_per_page))
        local end_idx=$((start_idx + sessions_per_page - 1))
        if [ $end_idx -ge $session_count ]; then
            end_idx=$((session_count - 1))
        fi
        
        for i in $(seq $start_idx $end_idx); do
            local title="${session_titles[$i]}"
            # Truncate title to fit in remaining space (98 - time(5) - words(5) - spaces(2) = 86)
            local max_title_length=86
            if [ ${#title} -gt $max_title_length ]; then
                title="${title:0:$((max_title_length-3))}..."
            fi
            printf "${CYAN}%s${NC} ${GREEN}%4d${NC} %s\n" "${session_times[$i]}" "${session_words[$i]}" "$title"
        done
        
        # Fill remaining lines if needed (to maintain consistent layout)
        local displayed_sessions=$((end_idx - start_idx + 1))
        for i in $(seq $((displayed_sessions + 1)) $sessions_per_page); do
            echo
        done
        
        # Summary line (Line 10)
        echo -e "${GREEN}Total: $session_count sessions, $total_words words${NC}"
        
        # Navigation prompt (Line 11-12)
        local nav_options=""
        if [ $current_page -gt 1 ]; then
            nav_options="${nav_options}[p]rev "
        fi
        if [ $current_page -lt $total_pages ]; then
            nav_options="${nav_options}[n]ext "
        fi
        nav_options="${nav_options}[q]uit"
        
        echo -n "$nav_options: "
        local key=$(get_single_key | tr '[:upper:]' '[:lower:]')
        
        case $key in
        'p')
            if [ $current_page -gt 1 ]; then
                current_page=$((current_page - 1))
            fi
            ;;
        'n')
            if [ $current_page -lt $total_pages ]; then
                current_page=$((current_page + 1))
            fi
            ;;
        'q')
            break
            ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
# ENHANCED PROGRESS DASHBOARD
# ═══════════════════════════════════════════════════════════════

show_progress_dashboard() {
    clear
    load_goals
    
    # PERFORMANCE TEST: Time the operations
    local start_time=$(date +%s%N)
    
    local today_count=$(get_today_count)
    local today_sessions=$(get_today_sessions)
    local week_count=$(get_week_count)
    local month_count=$(get_month_count)
    
    local end_time=$(date +%s%N)
    local duration=$(((end_time - start_time) / 1000000))  # Convert to milliseconds
    
    # Compact header with cache status (Line 1)
    local cache_indicator=""
    if is_cache_valid; then
        cache_indicator="${GREEN}●${NC}"
    else
        cache_indicator="${YELLOW}●${NC}"
    fi
    echo -e "${COLOR_HEADER_PRIMARY}▐ WRITING PROGRESS ▌${COLOR_RESET} ${cache_indicator} ${COLOR_INFO}${duration}ms${COLOR_RESET}"
    
    # Today's goal progress (Line 2)
    echo "Today: $(show_progress "$today_count" "$daily_goal")"
    
    # Period summaries on one line (Line 3)
    echo "Week: $week_count/$weekly_goal | Month: $month_count/$monthly_goal | Sessions: $today_sessions"
    
    # Goal achievement or motivation (Line 4)
    if [ "$today_count" -ge "$daily_goal" ]; then
        echo -e "${GREEN}*** Daily goal achieved! ***${NC}"
    else
        local needed=$((daily_goal - today_count))
        echo "Need $needed more words to reach daily goal"
    fi
    
    # Recent sessions preview (Lines 5-8, max 4 sessions)
    if [ "$today_count" -gt 0 ] && is_cache_valid; then
        echo -e "${YELLOW}Recent Sessions:${NC}"
        get_recent_sessions 4 | head -4 | while IFS='|' read filename date time words chars duration wpm timestamp; do
            [ -z "$filename" ] && continue
            
            local title=$(extract_title_from_filename "$filename")
            # Truncate title to fit in 98 characters with other info
            local max_title_length=$((98 - 15))  # Account for time and word count
            if [ ${#title} -gt $max_title_length ]; then
                title="${title:0:$((max_title_length-3))}..."
            fi
            printf "${CYAN}%s${NC} ${GREEN}%4d${NC} %s\n" "$time" "$words" "$title"
        done
    fi
    
    # Navigation prompt (Line 9-12 depending on content)
    echo
    if [ "$today_sessions" -gt 4 ]; then
        echo -n "Press [S] for all sessions, [Enter] to continue: "
    else
        echo -n "Press [Enter] to continue: "
    fi
    
    local key=$(get_single_key | tr '[:upper:]' '[:lower:]')
    
    if [ "$key" = "s" ] && [ "$today_sessions" -gt 4 ]; then
        show_today_sessions_paged
        echo
        read -p "Press Enter to continue..."
    fi
}

# Cache management menu
show_cache_menu() {
    clear
    echo -e "${COLOR_HEADER_PRIMARY}▐ CACHE MANAGEMENT ▌${COLOR_RESET}"
    echo
    
    show_cache_stats
    echo
    
    echo -e "${COLOR_HOTKEY}R${COLOR_RESET}ebuild daily cache   ${COLOR_HOTKEY}S${COLOR_RESET}how cache contents   ${COLOR_HOTKEY}B${COLOR_RESET}ack to main menu"
    echo
    echo -ne "${COLOR_PROMPT}Selection: ${COLOR_RESET}"
    read -n 1 -s choice
    echo "$choice"
    echo
    
    case "$choice" in
    "r"|"R"|"1")
        rebuild_daily_cache
        echo
        read -p "Press Enter to continue..."
        ;;
    "s"|"S"|"2")
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
    "b"|"B"|"3")
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
        echo -e "${COLOR_HEADER_PRIMARY}▐ GOALS ▌${COLOR_RESET}"
        echo
        echo -e "${COLOR_HOTKEY}V${COLOR_RESET}iew Progress   ${COLOR_HOTKEY}S${COLOR_RESET}et Goals   ${COLOR_HOTKEY}C${COLOR_RESET}ache Management   ${COLOR_HOTKEY}Q${COLOR_RESET}uit"
        echo
        echo -ne "${COLOR_PROMPT}Selection: ${COLOR_RESET}"
        read -n 1 -s choice
        echo "$choice"
        echo
        
        case "$choice" in
        "v"|"V"|"1")
            show_progress_dashboard
            ;;
        "s"|"S"|"2")
            set_goals
            ;;
        "c"|"C"|"3")
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