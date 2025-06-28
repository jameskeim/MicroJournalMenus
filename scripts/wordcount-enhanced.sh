#!/bin/bash
# wordcount-enhanced.sh - Cache-Enhanced Word Count Tool for MICRO JOURNAL 2000
# Performance-optimized version using analytics cache system

export FZF_DEFAULT_COMMAND="fd --type f"

# Configuration
DOCS_DIR="$HOME/Documents/writing"
MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"

# Import analytics cache system
source "$MCRJRNL/scripts/analytics-cache.sh"

# Ensure writing directory exists
mkdir -p "$DOCS_DIR"

# Get today's date in YYYY.MM.DD format (matching newMarkDown.sh)
TODAY=$(date +%Y.%m.%d)

# ═══════════════════════════════════════════════════════════════
# CACHE-OPTIMIZED CORE FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Get word count with cache-first approach
get_word_count_cached() {
    local file="$1"
    local filename=$(basename "$file")
    
    # Try cache first for timestamped files
    if [[ "$filename" =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{2}-[0-9]{4}.*\.md$ ]] && is_cache_valid; then
        local cache_entry=$(grep "^$filename|" "$SESSION_CACHE" 2>/dev/null)
        if [ -n "$cache_entry" ]; then
            # Extract word count from cache: filename|date|time|word_count|char_count|duration|wpm|timestamp
            echo "$cache_entry" | cut -d'|' -f4
            return
        fi
    fi
    
    # Fallback to original word counting method
    get_word_count_original "$file"
}

# Original word counting function (renamed for fallback)
get_word_count_original() {
    local file="$1"
    
    # Check if pandoc is available and file is markdown
    if command -v pandoc >/dev/null 2>&1 && [[ "$file" == *.md ]]; then
        # Use accurate pandoc word counting for markdown files
        local pandoc_words=$(pandoc --lua-filter="$HOME/.microjournal/filters/wordcount.lua" "$file" 2>/dev/null)
        if [ -n "$pandoc_words" ] && [ "$pandoc_words" -gt 0 ]; then
            echo "$pandoc_words"
            return
        fi
    fi
    
    # Fallback to wc -w for non-markdown files or if pandoc fails
    wc -w <"$file"
}

# ═══════════════════════════════════════════════════════════════
# CACHE-ENHANCED VIEW FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Today's writing - OPTIMIZED with cache
count_today() {
    load_goals
    
    echo -e "\033[92mToday ($TODAY):\033[0m"
    
    local today_date=$(date +%Y-%m-%d)
    local total_words=0
    local file_count=0
    local cache_hits=0
    local file_scans=0
    
    # Try to get today's summary from daily cache first
    if is_cache_valid; then
        echo -e "\033[94mTIME   WORDS  TITLE\033[0m"
        
        # Get individual sessions from session cache - INSTANT!
        while IFS='|' read -r filename date time word_count char_count duration wpm timestamp; do
            # Skip comments and empty lines
            [[ "$filename" =~ ^#.*$ ]] && continue
            [ -z "$filename" ] && continue
            
            # Filter for today's entries
            if [ "$date" = "$today_date" ]; then
                # Extract title from filename
                local title=$(extract_title_from_filename "$filename")
                
                # Format display
                printf "\033[96m%s\033[0m \033[93m%4d\033[0m  %s\n" "$time" "$word_count" "$title"
                
                total_words=$((total_words + word_count))
                file_count=$((file_count + 1))
                cache_hits=$((cache_hits + 1))
            fi
        done < "$SESSION_CACHE"
        
        # If no cache entries found, fall back to file scanning
        if [ $file_count -eq 0 ]; then
            echo -e "\033[93m[Cache miss - scanning files...]\033[0m"
            count_today_fallback
            return
        fi
    else
        echo -e "\033[93m[Cache unavailable - scanning files...]\033[0m"
        count_today_fallback
        return
    fi
    
    # Display results
    if [ $file_count -eq 0 ]; then
        echo -e "\033[91mNo writing files found for today.\033[0m"
        if [ "$daily_goal" -gt 0 ]; then
            echo
            echo "Daily Goal: $(show_progress 0 "$daily_goal")"
        fi
    else
        echo
        echo -e "\033[92mTotal: $file_count sessions, $total_words words\033[0m"
        echo -e "\033[96mCache performance: $cache_hits hits, $file_scans file scans\033[0m"
        
        if [ "$daily_goal" -gt 0 ]; then
            echo "Goal Progress: $(show_progress "$total_words" "$daily_goal")"
            if [ "$total_words" -ge "$daily_goal" ]; then
                echo -e "\033[92m*** Daily goal achieved! ***\033[0m"
            fi
        fi
    fi
    echo
}

# Fallback for today's writing when cache unavailable
count_today_fallback() {
    load_goals
    
    local total_words=0
    local file_count=0
    
    echo -e "\033[94mTIME   WORDS  TITLE\033[0m"
    
    # Find all markdown files from today
    for file in "$DOCS_DIR"/${TODAY}-*.md; do
        if [ -f "$file" ]; then
            words=$(get_word_count_original "$file")
            filename=$(basename "$file")
            
            # Extract time and title
            if [[ "$filename" =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{2}-[0-9]{4} ]]; then
                time_part=$(echo "$filename" | sed 's/^[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}-\([0-9]\{4\}\).*/\1/' | sed 's/\(..\)\(..\)/\1:\2/')
                suffix=$(echo "$filename" | sed 's/^[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}-[0-9]\{4\}-*\(.*\)\.md$/\1/')
                if [ -z "$suffix" ]; then
                    suffix="[untitled]"
                fi
                printf "\033[96m%s\033[0m \033[93m%4d\033[0m  %s\n" "$time_part" "$words" "$suffix"
            else
                printf "\033[96m%-5s\033[0m \033[93m%4d\033[0m  %s\n" "" "$words" "$filename"
            fi
            
            total_words=$((total_words + words))
            file_count=$((file_count + 1))
        fi
    done
    
    if [ $file_count -eq 0 ]; then
        echo -e "\033[91mNo writing files found for today.\033[0m"
    else
        echo
        echo -e "\033[92mTotal: $file_count sessions, $total_words words\033[0m"
    fi
    
    if [ "$daily_goal" -gt 0 ]; then
        echo "Goal Progress: $(show_progress "$total_words" "$daily_goal")"
        if [ "$total_words" -ge "$daily_goal" ]; then
            echo -e "\033[92m*** Daily goal achieved! ***\033[0m"
        fi
    fi
    echo
}

# Recent files - OPTIMIZED with cache
count_recent() {
    echo -e "\033[92mRecent Writing Sessions (Last 5):\033[0m"
    echo -e "\033[94mDATE       TIME   WORDS  TITLE\033[0m"
    
    if is_cache_valid; then
        # Get recent sessions from cache - INSTANT!
        local recent_sessions=$(get_recent_sessions 5)
        local session_count=0
        
        if [ -n "$recent_sessions" ]; then
            echo "$recent_sessions" | while IFS='|' read -r filename date time word_count char_count duration wpm timestamp; do
                [ -z "$filename" ] && continue
                
                local title=$(extract_title_from_filename "$filename")
                printf "\033[96m%s %s\033[0m \033[93m%4d\033[0m  %s\n" "$date" "$time" "$word_count" "$title"
                session_count=$((session_count + 1))
            done
            
            if [ $session_count -eq 0 ]; then
                echo -e "\033[91mNo cached sessions found.\033[0m"
            else
                echo
                echo -e "\033[96mLoaded from cache instantly\033[0m"
            fi
        else
            echo -e "\033[91mNo recent sessions found in cache.\033[0m"
        fi
    else
        echo -e "\033[93m[Cache unavailable - using file scanning...]\033[0m"
        count_recent_fallback
    fi
    echo
}

# Fallback for recent files when cache unavailable
count_recent_fallback() {
    # Find last 5 markdown files, sorted by modification time
    recent_files=$(find "$DOCS_DIR" -name "*.md" -type f -printf '%T@ %p\n' | sort -nr | head -5 | cut -d' ' -f2-)
    
    if [ -z "$recent_files" ]; then
        echo -e "\033[91mNo markdown files found.\033[0m"
    else
        while IFS= read -r file; do
            if [ -n "$file" ]; then
                words=$(get_word_count_original "$file")
                filename=$(basename "$file")
                mod_date=$(stat -c %y "$file" | cut -d' ' -f1)
                
                # Extract time if it's a timestamped file
                if [[ "$filename" =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{2}-[0-9]{4} ]]; then
                    time_part=$(echo "$filename" | sed 's/^[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}-\([0-9]\{4\}\).*/\1/' | sed 's/\(..\)\(..\)/\1:\2/')
                    suffix=$(echo "$filename" | sed 's/^[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}-[0-9]\{4\}-*\(.*\)\.md$/\1/')
                    if [ -z "$suffix" ]; then
                        suffix="[untitled]"
                    fi
                    printf "\033[96m%s %s\033[0m \033[93m%4d\033[0m  %s\n" "$mod_date" "$time_part" "$words" "$suffix"
                else
                    printf "\033[96m%s %-5s\033[0m \033[93m%4d\033[0m  %s\n" "$mod_date" "" "$words" "$filename"
                fi
            fi
        done <<<"$recent_files"
    fi
}

# All files - DRAMATICALLY OPTIMIZED with cache
count_all() {
    echo -e "\033[92mAll Writing Files:\033[0m"
    
    local total_words=0
    local file_count=0
    local cache_hits=0
    local file_scans=0
    local files_per_page=8
    local current_page=1
    
    # Build file list from cache first
    declare -a all_files
    declare -a all_words
    declare -a all_dates
    declare -a all_times
    declare -a all_titles
    
    if is_cache_valid; then
        echo -e "\033[96mLoading from analytics cache...\033[0m"
        
        # Read all entries from session cache - MUCH FASTER than file processing
        while IFS='|' read -r filename date time word_count char_count duration wmp timestamp; do
            # Skip comments and empty lines
            [[ "$filename" =~ ^#.*$ ]] && continue
            [ -z "$filename" ] && continue
            
            # Add to arrays
            all_files+=("$filename")
            all_words+=("$word_count")
            all_dates+=("$date")
            all_times+=("$time")
            all_titles+=("$(extract_title_from_filename "$filename")")
            
            total_words=$((total_words + word_count))
            file_count=$((file_count + 1))
            cache_hits=$((cache_hits + 1))
        done < "$SESSION_CACHE"
        
        # Check for any files not in cache
        for file in "$DOCS_DIR"/*.md; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                # Check if this file is already in cache
                if ! grep -q "^$filename|" "$SESSION_CACHE" 2>/dev/null; then
                    echo -e "\033[93m[Processing uncached file: $filename]\033[0m"
                    words=$(get_word_count_original "$file")
                    
                    all_files+=("$filename")
                    all_words+=("$words")
                    all_dates+=("unknown")
                    all_times+=("")
                    all_titles+=("$filename")
                    
                    total_words=$((total_words + words))
                    file_count=$((file_count + 1))
                    file_scans=$((file_scans + 1))
                fi
            fi
        done
    else
        echo -e "\033[93m[Cache unavailable - scanning all files...]\033[0m"
        count_all_fallback
        return
    fi
    
    if [ $file_count -eq 0 ]; then
        echo -e "\033[91mNo markdown files found.\033[0m"
        return
    fi
    
    # Pagination display
    total_pages=$(((file_count + files_per_page - 1) / files_per_page))
    
    while true; do
        clear
        echo -e "\033[92mAll Writing Files:\033[0m Page $current_page of $total_pages"
        echo -e "\033[96mPerformance: $cache_hits cache hits, $file_scans file scans\033[0m"
        echo -e "\033[94mDATE       TIME   WORDS  TITLE\033[0m"
        
        # Calculate range for current page
        start_idx=$(((current_page - 1) * files_per_page))
        end_idx=$((start_idx + files_per_page - 1))
        if [ $end_idx -ge $file_count ]; then
            end_idx=$((file_count - 1))
        fi
        
        # Display files for current page
        for i in $(seq $start_idx $end_idx); do
            local filename="${all_files[$i]}"
            local words="${all_words[$i]}"
            local date="${all_dates[$i]}"
            local time="${all_times[$i]}"
            local title="${all_titles[$i]}"
            
            printf "\033[96m%s %s\033[0m \033[93m%4d\033[0m  %s\n" "$date" "$time" "$words" "$title"
        done
        
        echo
        echo -e "\033[92mTotal: $file_count files, $total_words words\033[0m"
        
        # Navigation prompt
        nav_options=""
        if [ $current_page -gt 1 ]; then
            nav_options="${nav_options}[p]revious "
        fi
        if [ $current_page -lt $total_pages ]; then
            nav_options="${nav_options}[n]ext "
        fi
        nav_options="${nav_options}[q]uit"
        
        echo -n "$nav_options: "
        key=$(get_single_key | tr '[:upper:]' '[:lower:]')
        
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

# Fallback for all files when cache unavailable
count_all_fallback() {
    local total_words=0
    local file_count=0
    
    echo -e "\033[93mScanning all files (this may take a moment)...\033[0m"
    
    # Original implementation for fallback
    for file in "$DOCS_DIR"/*.md; do
        if [ -f "$file" ]; then
            words=$(get_word_count_original "$file")
            total_words=$((total_words + words))
            file_count=$((file_count + 1))
        fi
    done
    
    echo -e "\033[92mTotal: $file_count files, $total_words words\033[0m"
    echo
    read -p "Press Enter to continue..."
}

# ═══════════════════════════════════════════════════════════════
# ENHANCED SINGLE FILE ANALYSIS
# ═══════════════════════════════════════════════════════════════

# Function to count words in a single file with readability analysis
count_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local filename=$(basename "$file")
        
        # Try to get enhanced data from cache first
        if [[ "$filename" =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{2}-[0-9]{4}.*\.md$ ]] && is_cache_valid; then
            local cache_entry=$(grep "^$filename|" "$SESSION_CACHE" 2>/dev/null)
            if [ -n "$cache_entry" ]; then
                display_cached_file_analysis "$cache_entry" "$file"
                return
            fi
        fi
        
        # Fallback to original analysis
        display_original_file_analysis "$file"
    else
        echo -e "\033[91mFile not found: $file\033[0m"
    fi
}

# Display file analysis using cached data
display_cached_file_analysis() {
    local cache_entry="$1"
    local file="$2"
    
    # Parse cache entry: filename|date|time|word_count|char_count|duration|wpm|timestamp
    IFS='|' read -r filename date time word_count char_count duration wmp timestamp <<< "$cache_entry"
    
    echo -e "File: \033[93m$(basename "$file")\033[0m"
    echo -e "\033[96m[From Analytics Cache]\033[0m"
    
    # Enhanced session information
    echo "Words: $word_count (cached) | Characters: $char_count"
    echo "Writing session: $(format_duration "$duration") | Speed: $wmp words/minute"
    echo "Created: $date at $time"
    
    # Calculate reading time
    local read_time=$((word_count / 200))
    local read_str
    if [ $read_time -eq 0 ]; then
        read_str="<1min"
    else
        read_str="~${read_time}min"
    fi
    echo "Estimated reading time: $read_str"
    
    # Still do readability analysis on actual file
    if command -v style >/dev/null 2>&1 && [ $word_count -gt 10 ]; then
        echo
        perform_readability_analysis "$file" "$word_count"
    fi
}

# Display original file analysis (fallback)
display_original_file_analysis() {
    local file="$1"
    
    words=$(get_word_count_original "$file")
    chars=$(wc -c <"$file")
    lines=$(wc -l <"$file")
    paragraphs=$(grep -c '^$' "$file" 2>/dev/null || echo 0)
    paragraphs=$((paragraphs + 1))
    
    # Calculate reading time (200 words per minute)
    read_time=$((words / 200))
    if [ $read_time -eq 0 ]; then
        read_str="<1min"
    else
        read_str="~${read_time}min"
    fi
    
    echo -e "File: \033[93m$(basename "$file")\033[0m"
    echo "Words: $words | Characters: $chars | Lines: $lines | Paragraphs: $paragraphs | $read_str read"
    
    # Readability analysis
    if command -v style >/dev/null 2>&1 && [ $words -gt 10 ]; then
        echo
        perform_readability_analysis "$file" "$words"
    elif [ $words -le 10 ]; then
        echo -e "\033[93m(File too short for analysis)\033[0m"
    fi
}

# Perform readability analysis (shared function)
perform_readability_analysis() {
    local file="$1"
    local words="$2"
    
    echo -e "\033[96mReadability Analysis:\033[0m"
    
    # Extract key metrics from style output
    style_output=$(style "$file" 2>/dev/null)
    
    # Parse the most useful metrics for compact display
    flesch=$(echo "$style_output" | grep "Flesch Index:" | sed 's/.*Flesch Index: \([0-9.]*\).*/\1/')
    grade=$(echo "$style_output" | grep "Kincaid:" | sed 's/.*Kincaid: \([0-9.]*\).*/\1/')
    avg_words=$(echo "$style_output" | grep "average length.*words" | sed 's/.*average length \([0-9.]*\) words.*/\1/')
    
    # Flesch reading ease interpretation
    if [ -n "$flesch" ]; then
        if (($(echo "$flesch >= 90" | bc -l 2>/dev/null))); then
            flesch_desc="very easy"
        elif (($(echo "$flesch >= 80" | bc -l 2>/dev/null))); then
            flesch_desc="easy"
        elif (($(echo "$flesch >= 70" | bc -l 2>/dev/null))); then
            flesch_desc="fairly easy"
        elif (($(echo "$flesch >= 60" | bc -l 2>/dev/null))); then
            flesch_desc="standard"
        elif (($(echo "$flesch >= 50" | bc -l 2>/dev/null))); then
            flesch_desc="fairly difficult"
        elif (($(echo "$flesch >= 30" | bc -l 2>/dev/null))); then
            flesch_desc="difficult"
        else
            flesch_desc="very difficult"
        fi
        
        echo "Flesch Score: $flesch ($flesch_desc) | Grade Level: $grade"
        if [ -n "$avg_words" ]; then
            echo "Average Sentence Length: $avg_words words"
        fi
    fi
    
    # Word frequency insights
    if [ $words -gt 20 ]; then
        echo -e "\033[96mWord Analysis:\033[0m"
        
        # Get unique word count and most common word (excluding common words)
        unique_words=$(tr '[:upper:]' '[:lower:]' <"$file" | tr -d '[:punct:]' | tr ' ' '\n' | grep -v '^$' | sort | uniq | wc -l)
        
        # Find most common meaningful word
        common_word=$(tr '[:upper:]' '[:lower:]' <"$file" | tr -d '[:punct:]' | tr ' ' '\n' |
            grep -v -E '^(the|and|or|but|in|on|at|to|for|of|with|by|a|an|is|are|was|were|be|been|have|has|had|do|does|did|will|would|could|should|may|might|can|shall|must)$' |
            grep -v '^$' | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')
        
        common_count=$(tr '[:upper:]' '[:lower:]' <"$file" | tr -d '[:punct:]' | tr ' ' '\n' |
            grep -v -E '^(the|and|or|but|in|on|at|to|for|of|with|by|a|an|is|are|was|were|be|been|have|has|had|do|does|did|will|would|could|should|may|might|can|shall|must)$' |
            grep -v '^$' | sort | uniq -c | sort -rn | head -1 | awk '{print $1}')
        
        # Calculate vocabulary diversity ratio
        if [ $words -gt 0 ]; then
            diversity_ratio=$((unique_words * 100 / words))
        else
            diversity_ratio=0
        fi
        
        echo "Most common word: \"$common_word\" ($common_count times) | Unique words: $unique_words"
        echo "Vocabulary diversity: $diversity_ratio% | Writing complexity: $([ $diversity_ratio -gt 70 ] && echo "high" || [ $diversity_ratio -gt 50 ] && echo "medium" || echo "simple")"
    fi
}

# ═══════════════════════════════════════════════════════════════
# ORIGINAL UTILITY FUNCTIONS (PRESERVED)
# ═══════════════════════════════════════════════════════════════

# Load goals if config exists
load_goals() {
    if [ -f "$HOME/.microjournal/config" ]; then
        source "$HOME/.microjournal/config" 2>/dev/null
    fi
    daily_goal=${daily_goal:-500}
}

# Show progress bar
show_progress() {
    local current=$1
    local goal=$2
    local width=20
    
    if [ "$goal" -eq 0 ]; then
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
        echo -e "\033[92m$bar\033[0m ${percentage}% (${current}/${goal})"
    elif [ "$percentage" -ge 80 ]; then
        echo -e "\033[93m$bar\033[0m ${percentage}% (${current}/${goal})"
    else
        echo -e "$bar ${percentage}% (${current}/${goal})"
    fi
}

# Function to get terminal width with fallbacks
get_terminal_width() {
    local width
    # Try tput first
    width=$(tput cols 2>/dev/null)
    if [ -n "$width" ] && [ "$width" -gt 0 ]; then
        echo "$width"
        return
    fi
    
    # Try stty as fallback
    width=$(stty size 2>/dev/null | cut -d' ' -f2)
    if [ -n "$width" ] && [ "$width" -gt 0 ]; then
        echo "$width"
        return
    fi
    
    # Default fallback
    echo "98"
}

# Function to center text, ignoring ANSI color codes
center_text() {
    local text="$1"
    local width=$(get_terminal_width)
    
    # Remove ANSI color codes to get actual visible length
    local visible_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local visible_length=${#visible_text}
    
    # If text is wider than terminal, return as-is
    if [ "$visible_length" -ge "$width" ]; then
        echo -e "$text"
        return
    fi
    
    # Calculate padding and center the text
    local padding=$(((width - visible_length) / 2))
    printf "%*s" "$padding" ""
    echo -e "$text"
}

# Function to get single keypress
get_single_key() {
    local old_tty_settings=$(stty -g)
    stty -icanon -echo min 1 time 0
    local key=$(dd bs=1 count=1 2>/dev/null)
    stty "$old_tty_settings"
    echo "$key"
}

# ═══════════════════════════════════════════════════════════════
# MAIN MENU LOOP
# ═══════════════════════════════════════════════════════════════

# Initialize analytics cache
init_analytics_cache

# Main menu loop
while true; do
    clear
    echo
    
    # Header with cache status indicator
    if is_cache_valid; then
        center_text "\033[91m▐▀▀▀▀▀▀▀▀▀\033[96m WORD COUNT \033[91m▀▀▀▀▀▀▀▀▀▌\033[0m \033[92m*\033[0m"
    else
        center_text "\033[91m▐▀▀▀▀▀▀▀▀▀\033[96m WORD COUNT \033[91m▀▀▀▀▀▀▀▀▀▌\033[0m \033[93m!\033[0m"
    fi
    center_text "\033[91m▐▄▄▄\033[0m \033[93mWriting Analytics Tools\033[0m \033[91m▄▄▄▌\033[0m"
    echo
    
    center_text "\033[92mT\033[0m - Today's Writing    \033[92mF\033[0m - Specific File"
    center_text "\033[92mR\033[0m - Recent Files       \033[92mA\033[0m - All Files    "
    echo
    center_text "\033[91mE\033[0m - Exit to Main Menu"
    echo
    printf "%*s" $((($(get_terminal_width) - 18) / 2)) ""
    echo -n -e "\033[96mMake a selection: \033[0m"
    
    choice=$(get_single_key | tr '[:upper:]' '[:lower:]')
    
    case $choice in
    't')
        clear
        count_today
        echo -n -e "\033[93mPress any key to continue...\033[0m"
        read -n 1 -s
        ;;
    'r')
        clear
        count_recent
        echo -n -e "\033[93mPress any key to continue...\033[0m"
        read -n 1 -s
        ;;
    'f')
        clear
        # Use fzf to select file from writing directory
        if command -v fzf >/dev/null 2>&1; then
            # Change to writing directory and use relative paths
            cd "$DOCS_DIR" || exit 1
            selected_file=$(find . -name "*.md" -type f 2>/dev/null | sed 's|^\./||' | fzf --height=12 --reverse --no-border --prompt="Select file (Esc to cancel): " --preview='wc -w {} && echo && head -5 {}')
            
            if [ -n "$selected_file" ]; then
                echo
                count_file "$DOCS_DIR/$selected_file"
            else
                echo -e "\033[91mNo file selected.\033[0m"
            fi
            # Return to original directory
            cd - >/dev/null
        else
            # Fallback to manual entry if fzf is not available
            echo -n "Enter filename (or full path): "
            read filename
            
            # If just filename given, check writing directory
            if [[ "$filename" != /* ]]; then
                filename="$DOCS_DIR/$filename"
            fi
            echo
            count_file "$filename"
        fi
        echo -n -e "\033[93mPress any key to continue...\033[0m"
        read -n 1 -s
        ;;
    'a')
        count_all
        ;;
    'e')
        break
        ;;
    *)
        echo -n -e "\033[91mInvalid choice. Press any key to try again...\033[0m"
        read -n 1 -s
        ;;
    esac
done