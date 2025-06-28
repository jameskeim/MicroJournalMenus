# SQLite-Based Writing Analytics System Migration Guide

*Transitioning from File-Based to Database-Driven Writing Analytics*

---

## Table of Contents

1. [Conceptual Overview](#conceptual-overview)
2. [System Architecture](#system-architecture)
3. [Database Schema](#database-schema)
4. [Core Implementation](#core-implementation)
5. [Migration Scripts](#migration-scripts)
6. [Enhanced Scripts](#enhanced-scripts)
7. [Implementation Timeline](#implementation-timeline)
8. [Benefits & Performance](#benefits-performance)

---

## Conceptual Overview

### The Fundamental Shift

The current MICRO JOURNAL 2000 system calculates writing statistics **on-demand** by processing files each time analytics are requested. The new approach **captures data at the moment of creation** and stores it in a SQLite database for instant retrieval.

#### Current Approach: Reactive Analytics
```
Write File → Save → Request Analytics → Process All Files → Display Results
                                      ↑
                                  2-8 seconds
```

#### New Approach: Proactive Data Capture
```
Write File → Save → Auto-Capture Stats → Store in Database
                                       ↓
Later: Request Analytics → Query Database → Instant Results
                                         ↑
                                     0.1 seconds
```

### Key Philosophy Changes

1. **Data Capture Point**: Move from "when requested" to "when created"
2. **Processing Strategy**: Shift from "calculate everything" to "store once, query many"
3. **Accuracy Focus**: Use single, accurate word counting method (pandoc + lua filter)
4. **Time Tracking**: Leverage filename timestamps + editor exit time
5. **Performance Priority**: Optimize for instant analytics over storage space

---

## System Architecture

### Data Flow Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   newMarkDown   │    │   SQLite         │    │   Analytics     │
│      .sh        │────▶   Database      ◀────│    Scripts      │
│                 │    │                  │    │                 │
│ • Creates file  │    │ • document_stats │    │ • wordcount.sh  │
│ • Tracks time   │    │ • daily_stats    │    │ • goals.sh      │
│ • Counts words  │    │ • goals          │    │ • dashboard.sh  │
│ • Stores data   │    │ • achievements   │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Component Responsibilities

#### newMarkDown.sh (Data Producer)
- **File Creation**: Generate timestamped markdown files
- **Session Management**: Launch editor and track session duration
- **Word Counting**: Use pandoc + lua filter for accurate counts
- **Data Storage**: Insert session data into SQLite database
- **User Feedback**: Display immediate session results

#### SQLite Database (Data Store)
- **Persistent Storage**: Maintain writing statistics across sessions
- **Fast Queries**: Enable sub-second analytics retrieval
- **Data Integrity**: Ensure consistent, accurate historical data
- **Scalability**: Handle growing writing corpus efficiently

#### Analytics Scripts (Data Consumers)
- **wordcount.sh**: Display writing statistics and file analysis
- **goals.sh**: Track progress toward writing goals and streaks
- **dashboard.sh**: Provide unified overview of writing activity

---

## Database Schema

### Core Tables Structure

```sql
-- Individual document statistics
CREATE TABLE document_stats (
    filename TEXT PRIMARY KEY,
    date TEXT NOT NULL,                    -- YYYY-MM-DD from filename
    time TEXT NOT NULL,                    -- HH:MM from filename  
    word_count INTEGER NOT NULL,           -- Accurate pandoc count
    char_count INTEGER,                    -- Character count
    session_duration INTEGER,              -- Seconds spent writing
    words_per_minute INTEGER,              -- Calculated writing speed
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Daily aggregated statistics
CREATE TABLE daily_stats (
    date TEXT PRIMARY KEY,
    total_words INTEGER NOT NULL,
    file_count INTEGER NOT NULL,
    total_time INTEGER,                    -- Total writing time in seconds
    avg_words_per_minute INTEGER,          -- Daily average writing speed
    streak_day INTEGER DEFAULT 0,          -- For streak calculation
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Writing goals and targets
CREATE TABLE goals (
    goal_type TEXT PRIMARY KEY,            -- 'daily', 'weekly', 'monthly'
    target_value INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Achievement tracking
CREATE TABLE achievements (
    achievement_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    unlocked_date DATE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Performance indexes
CREATE INDEX idx_document_date ON document_stats(date);
CREATE INDEX idx_document_time ON document_stats(date, time);
CREATE INDEX idx_daily_date ON daily_stats(date);
```

### Sample Data Structure

```sql
-- Example document_stats entries
INSERT INTO document_stats VALUES 
('2025.01.15-0930.md', '2025-01-15', '09:30', 347, 1823, 1800, 12, datetime('now'), datetime('now')),
('2025.01.15-1430-story-ideas.md', '2025-01-15', '14:30', 156, 834, 900, 10, datetime('now'), datetime('now'));

-- Example daily_stats entry
INSERT INTO daily_stats VALUES 
('2025-01-15', 503, 2, 2700, 11, 0, datetime('now'));

-- Example goals
INSERT INTO goals VALUES 
('daily', 500, datetime('now'), datetime('now')),
('weekly', 3500, datetime('now'), datetime('now'));
```

---

## Core Implementation

### Enhanced newMarkDown.sh

```bash
#!/bin/bash
# newMarkDown.sh - Enhanced with SQLite session tracking

# Configuration
DB_FILE="$HOME/.microjournal/stats.db"
WORDCOUNT_LUA="$HOME/.microjournal/wordcount.lua"

# Generate timestamped filename
filename=$(date +"%Y.%m.%d-%H%M.md")
filepath="$HOME/Documents/$filename"

echo "Starting writing session: $filename"
echo "Session started at $(date '+%H:%M')"
echo

# Launch NeoVim for writing session
nvim "$filepath"

# Session complete - process results
if [ -f "$filepath" ] && [ -s "$filepath" ]; then
    process_writing_session "$filepath" "$filename"
else
    handle_empty_session "$filepath"
fi

# Process completed writing session
process_writing_session() {
    local filepath="$1"
    local filename="$2"
    
    echo
    echo -e "\033[92m=== WRITING SESSION COMPLETE ===\033[0m"
    
    # Calculate session duration from filename
    local session_duration=$(calculate_session_duration "$filename")
    
    # Get accurate word count using pandoc + lua filter
    local word_count=$(get_accurate_word_count "$filepath")
    
    if [ "$word_count" -gt 0 ]; then
        # Calculate additional metrics
        local char_count=$(wc -c < "$filepath")
        local words_per_minute=0
        
        if [ "$session_duration" -gt 0 ]; then
            words_per_minute=$((word_count * 60 / session_duration))
        fi
        
        # Display session results
        display_session_results "$word_count" "$session_duration" "$words_per_minute"
        
        # Store data in SQLite database
        store_session_data "$filename" "$word_count" "$char_count" "$session_duration" "$words_per_minute"
        
        # Update daily aggregates
        update_daily_stats "$(get_date_from_filename "$filename")"
        
        echo -e "\033[93mGreat work! Press any key to continue...\033[0m"
        read -n 1 -s
    else
        echo "Word count calculation failed."
        read -n 1 -s
    fi
}

# Calculate session duration from filename timestamp
calculate_session_duration() {
    local filename="$1"
    
    # Extract timestamp from filename: YYYY.MM.DD-HHMM
    local timestamp_str=$(echo "$filename" | sed 's/\([0-9]\{4\}\)\.\([0-9]\{2\}\)\.\([0-9]\{2\}\)-\([0-9]\{2\}\)\([0-9]\{2\}\).*/\1-\2-\3 \4:\5/')
    
    # Convert to epoch time
    local start_time=$(date -d "$timestamp_str" +%s 2>/dev/null)
    local end_time=$(date +%s)
    
    if [ -n "$start_time" ] && [ "$start_time" -gt 0 ]; then
        echo $((end_time - start_time))
    else
        echo 0
    fi
}

# Get accurate word count using pandoc + lua filter
get_accurate_word_count() {
    local filepath="$1"
    
    if [ -f "$WORDCOUNT_LUA" ]; then
        # Use pandoc with lua filter for most accurate count
        local count=$(pandoc "$filepath" --lua-filter="$WORDCOUNT_LUA" --to=plain 2>/dev/null | tail -1)
        
        # Validate count is numeric
        if [[ "$count" =~ ^[0-9]+$ ]]; then
            echo "$count"
        else
            # Fallback to basic wc if pandoc fails
            wc -w < "$filepath"
        fi
    else
        # Fallback if lua filter not available
        wc -w < "$filepath"
    fi
}

# Display formatted session results
display_session_results() {
    local word_count="$1"
    local session_duration="$2"
    local words_per_minute="$3"
    
    echo "Words written: $word_count"
    echo "Session time: $(format_duration "$session_duration")"
    echo "Writing speed: $words_per_minute words/minute"
}

# Store session data in SQLite database
store_session_data() {
    local filename="$1"
    local word_count="$2"
    local char_count="$3"
    local session_duration="$4"
    local words_per_minute="$5"
    
    # Extract date and time from filename
    local date_part=$(get_date_from_filename "$filename")
    local time_part=$(get_time_from_filename "$filename")
    
    # Insert or replace document stats
    sqlite3 "$DB_FILE" "
    INSERT OR REPLACE INTO document_stats 
    (filename, date, time, word_count, char_count, session_duration, words_per_minute, updated_at)
    VALUES 
    ('$filename', '$date_part', '$time_part', $word_count, $char_count, 
     $session_duration, $words_per_minute, datetime('now'));"
}

# Update daily aggregated statistics
update_daily_stats() {
    local date="$1"
    
    sqlite3 "$DB_FILE" "
    INSERT OR REPLACE INTO daily_stats 
    (date, total_words, file_count, total_time, avg_words_per_minute, updated_at)
    SELECT 
        date,
        SUM(word_count) as total_words,
        COUNT(*) as file_count,
        SUM(session_duration) as total_time,
        CASE 
            WHEN SUM(session_duration) > 0 
            THEN (SUM(word_count) * 60 / SUM(session_duration))
            ELSE 0 
        END as avg_words_per_minute,
        datetime('now') as updated_at
    FROM document_stats 
    WHERE date = '$date'
    GROUP BY date;"
}

# Helper functions
get_date_from_filename() {
    echo "$1" | cut -d- -f1
}

get_time_from_filename() {
    echo "$1" | sed 's/.*-\([0-9]\{4\}\).*/\1/' | sed 's/\(..\)\(..\)/\1:\2/'
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

handle_empty_session() {
    local filepath="$1"
    echo "No content written - session cancelled."
    [ -f "$filepath" ] && rm "$filepath"
}

# Initialize database if needed
init_database() {
    if [ ! -f "$DB_FILE" ]; then
        ~/.microjournal/scripts/init-database.sh
    fi
}

# Initialize database on first run
init_database
```

### Enhanced wordcount.sh (Data Consumer)

```bash
#!/bin/bash
# wordcount.sh - Enhanced database-driven analytics

DB_FILE="$HOME/.microjournal/stats.db"

# Display today's writing with session breakdown
count_today() {
    local today=$(date +%Y-%m-%d)
    
    echo -e "\033[92mToday ($today):\033[0m"
    echo -e "\033[94mTIME   DURATION  WORDS  WPM  TITLE\033[0m"
    
    # Query database instead of processing files
    sqlite3 "$DB_FILE" "
    SELECT time, session_duration, word_count, words_per_minute, filename
    FROM document_stats 
    WHERE date = '$today'
    ORDER BY time;" | while IFS='|' read time duration words wpm filename; do
        
        # Format display
        local duration_formatted=$(format_duration "$duration")
        local title=$(extract_title_from_filename "$filename")
        
        printf "\033[96m%s\033[0m %8s \033[93m%4d\033[0m %3d  %s\n" \
               "$time" "$duration_formatted" "$words" "$wpm" "$title"
    done
    
    # Display daily totals from aggregated stats
    local daily_totals=$(sqlite3 "$DB_FILE" "
    SELECT total_words, file_count, total_time, avg_words_per_minute
    FROM daily_stats WHERE date = '$today';")
    
    if [ -n "$daily_totals" ]; then
        echo
        IFS='|' read total_words file_count total_time avg_wpm <<< "$daily_totals"
        echo -e "\033[92mTotal: $file_count sessions, $total_words words, $(format_duration "$total_time"), ${avg_wpm} wpm avg\033[0m"
    else
        echo -e "\033[91mNo writing sessions recorded for today.\033[0m"
    fi
}

# Display recent writing activity
count_recent() {
    echo -e "\033[92mRecent Writing Sessions (Last 5):\033[0m"
    echo -e "\033[94mDATE       TIME   WORDS  TITLE\033[0m"
    
    sqlite3 "$DB_FILE" "
    SELECT date, time, word_count, filename
    FROM document_stats 
    ORDER BY date DESC, time DESC
    LIMIT 5;" | while IFS='|' read date time words filename; do
        
        local title=$(extract_title_from_filename "$filename")
        printf "\033[96m%s %s\033[0m \033[93m%4d\033[0m  %s\n" \
               "$date" "$time" "$words" "$title"
    done
}

# Display comprehensive statistics
count_all() {
    echo -e "\033[92mWriting Statistics Overview:\033[0m"
    echo
    
    # Grand totals from database
    local totals=$(sqlite3 "$DB_FILE" "
    SELECT 
        COUNT(*) as total_files,
        SUM(word_count) as total_words,
        SUM(session_duration) as total_time,
        COUNT(DISTINCT date) as writing_days
    FROM document_stats;")
    
    IFS='|' read total_files total_words total_time writing_days <<< "$totals"
    
    echo "Total documents: $total_files"
    echo "Total words: $total_words"
    echo "Total writing time: $(format_duration "$total_time")"
    echo "Days with writing: $writing_days"
    
    if [ "$writing_days" -gt 0 ]; then
        local avg_daily_words=$((total_words / writing_days))
        echo "Average per writing day: $avg_daily_words words"
    fi
    
    echo
    echo -e "\033[92mRecent Daily Activity:\033[0m"
    
    sqlite3 "$DB_FILE" "
    SELECT date, total_words, file_count, total_time
    FROM daily_stats 
    ORDER BY date DESC
    LIMIT 7;" | while IFS='|' read date words files time; do
        printf "%s: \033[93m%4d\033[0m words (%d sessions, %s)\n" \
               "$date" "$words" "$files" "$(format_duration "$time")"
    done
}

# Analyze specific file (if exists in database)
count_file() {
    local file="$1"
    local filename=$(basename "$file")
    
    local file_data=$(sqlite3 "$DB_FILE" "
    SELECT date, time, word_count, session_duration, words_per_minute
    FROM document_stats 
    WHERE filename = '$filename';")
    
    if [ -n "$file_data" ]; then
        IFS='|' read date time words duration wpm <<< "$file_data"
        
        echo -e "File: \033[93m$filename\033[0m"
        echo "Date: $date at $time"
        echo "Words: $words"
        echo "Session time: $(format_duration "$duration")"
        echo "Writing speed: $wpm words/minute"
    else
        echo "File not found in database: $filename"
        echo "Use newMarkDown.sh to create tracked writing sessions."
    fi
}

# Helper functions
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

extract_title_from_filename() {
    local filename="$1"
    local title=$(echo "$filename" | sed 's/^[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}-[0-9]\{4\}-*\(.*\)\.md$/\1/')
    [ -z "$title" ] && title="[untitled]"
    echo "$title"
}

# Main menu (unchanged structure, enhanced performance)
main_menu() {
    while true; do
        clear
        echo
        center_text "\033[91m▐▀▀▀▀▀▀▀▀▀\033[96m WORD COUNT \033[91m▀▀▀▀▀▀▀▀▀▌\033[0m"
        center_text "\033[91m▐▄▄▄\033[0m \033[93mWriting Analytics Dashboard\033[0m \033[91m▄▄▄▌\033[0m"
        echo
        center_text "\033[92mT\033[0m - Today's Writing    \033[92mF\033[0m - Specific File"
        center_text "\033[92mR\033[0m - Recent Sessions    \033[92mA\033[0m - All Statistics"
        echo
        center_text "\033[91mE\033[0m - Exit to Main Menu"
        echo
        printf "%*s" $(((98 - 18) / 2)) ""
        echo -n -e "\033[96mMake a selection: \033[0m"

        choice=$(get_single_key | tr '[:upper:]' '[:lower:]')

        case $choice in
            't') clear; count_today; echo; read -p "Press Enter to continue..." ;;
            'r') clear; count_recent; echo; read -p "Press Enter to continue..." ;;  
            'f') clear; select_and_analyze_file ;;
            'a') clear; count_all; echo; read -p "Press Enter to continue..." ;;
            'e') break ;;
            *) echo "Invalid choice. Try again..."; sleep 1 ;;
        esac
    done
}

# Run main menu
main_menu
```

---

## Migration Scripts

### Database Initialization Script

```bash
#!/bin/bash
# init-database.sh - Initialize SQLite database for writing analytics

DB_FILE="$HOME/.microjournal/stats.db"

echo "Initializing MICRO JOURNAL 2000 SQLite database..."

# Create database with schema
sqlite3 "$DB_FILE" << 'EOF'
-- Document-level statistics
CREATE TABLE IF NOT EXISTS document_stats (
    filename TEXT PRIMARY KEY,
    date TEXT NOT NULL,
    time TEXT NOT NULL,
    word_count INTEGER NOT NULL,
    char_count INTEGER,
    session_duration INTEGER,
    words_per_minute INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Daily aggregated statistics  
CREATE TABLE IF NOT EXISTS daily_stats (
    date TEXT PRIMARY KEY,
    total_words INTEGER NOT NULL,
    file_count INTEGER NOT NULL,
    total_time INTEGER,
    avg_words_per_minute INTEGER,
    streak_day INTEGER DEFAULT 0,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Writing goals and targets
CREATE TABLE IF NOT EXISTS goals (
    goal_type TEXT PRIMARY KEY,
    target_value INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Achievement tracking
CREATE TABLE IF NOT EXISTS achievements (
    achievement_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    unlocked_date DATE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Performance indexes
CREATE INDEX IF NOT EXISTS idx_document_date ON document_stats(date);
CREATE INDEX IF NOT EXISTS idx_document_time ON document_stats(date, time);
CREATE INDEX IF NOT EXISTS idx_daily_date ON daily_stats(date);

-- Default goals
INSERT OR IGNORE INTO goals (goal_type, target_value) VALUES 
    ('daily', 500),
    ('weekly', 3500),
    ('monthly', 15000);

EOF

echo "Database initialized at: $DB_FILE"
echo "Default goals set: 500 words daily, 3500 weekly, 15000 monthly"
```

### Historical Data Migration Script

```bash
#!/bin/bash
# migrate-existing-files.sh - Import existing writing files into SQLite

DB_FILE="$HOME/.microjournal/stats.db"
DOCS_DIR="$HOME/Documents"
WORDCOUNT_LUA="$HOME/.microjournal/wordcount.lua"

echo "Migrating existing writing files to SQLite database..."
echo "This may take a few minutes for large document collections."
echo

# Function to get accurate word count
get_word_count() {
    local file="$1"
    
    if [ -f "$WORDCOUNT_LUA" ]; then
        pandoc "$file" --lua-filter="$WORDCOUNT_LUA" --to=plain 2>/dev/null | tail -1
    else
        wc -w < "$file"
    fi
}

# Function to extract date from filename
extract_date() {
    local filename="$1"
    echo "$filename" | sed 's/\([0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}\).*/\1/' | tr '.' '-'
}

# Function to extract time from filename  
extract_time() {
    local filename="$1"
    echo "$filename" | sed 's/.*-\([0-9]\{2\}\)\([0-9]\{2\}\).*/\1:\2/'
}

# Initialize counters
total_files=0
processed_files=0
skipped_files=0

# Process all markdown files
find "$DOCS_DIR" -name "*.md" -type f | while read filepath; do
    filename=$(basename "$filepath")
    
    # Only process files that match our naming convention
    if [[ "$filename" =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{2}-[0-9]{4}.*\.md$ ]]; then
        total_files=$((total_files + 1))
        
        # Check if already in database
        existing=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM document_stats WHERE filename = '$filename';")
        
        if [ "$existing" -eq 0 ]; then
            echo "Processing: $filename"
            
            # Extract metadata from filename
            date_part=$(extract_date "$filename")
            time_part=$(extract_time "$filename")
            
            # Get file statistics
            word_count=$(get_word_count "$filepath")
            char_count=$(wc -c < "$filepath")
            
            # Estimate session duration (placeholder - cannot recover actual time)
            estimated_duration=$((word_count / 10))  # Assume ~10 words per minute for estimation
            words_per_minute=10
            
            # Insert into database
            sqlite3 "$DB_FILE" "
            INSERT INTO document_stats 
            (filename, date, time, word_count, char_count, session_duration, words_per_minute, created_at, updated_at)
            VALUES 
            ('$filename', '$date_part', '$time_part', $word_count, $char_count, 
             $estimated_duration, $words_per_minute, datetime('now'), datetime('now'));"
            
            processed_files=$((processed_files + 1))
        else
            skipped_files=$((skipped_files + 1))
        fi
    fi
done

echo
echo "Migration complete!"
echo "Files processed: $processed_files"
echo "Files skipped (already in database): $skipped_files"
echo

# Rebuild daily aggregates
echo "Rebuilding daily statistics..."
sqlite3 "$DB_FILE" "
DELETE FROM daily_stats;

INSERT INTO daily_stats (date, total_words, file_count, total_time, avg_words_per_minute)
SELECT 
    date,
    SUM(word_count) as total_words,
    COUNT(*) as file_count,
    SUM(session_duration) as total_time,
    CASE 
        WHEN SUM(session_duration) > 0 
        THEN (SUM(word_count) * 60 / SUM(session_duration))
        ELSE 0 
    END as avg_words_per_minute
FROM document_stats 
GROUP BY date
ORDER BY date;"

echo "Daily statistics rebuilt."
echo "Database migration complete!"
```

### Database Maintenance Script

```bash
#!/bin/bash
# maintain-database.sh - Regular database maintenance and optimization

DB_FILE="$HOME/.microjournal/stats.db"

echo "Performing database maintenance..."

# Vacuum database to reclaim space
echo "Optimizing database storage..."
sqlite3 "$DB_FILE" "VACUUM;"

# Update query planner statistics
echo "Updating query optimization statistics..."
sqlite3 "$DB_FILE" "ANALYZE;"

# Verify data integrity
echo "Checking data integrity..."
sqlite3 "$DB_FILE" "PRAGMA integrity_check;" | head -5

# Display database statistics
echo
echo "Database Statistics:"
echo "==================="

# Table sizes
sqlite3 "$DB_FILE" "
SELECT 
    'Documents: ' || COUNT(*) as stat
FROM document_stats
UNION ALL
SELECT 
    'Daily records: ' || COUNT(*) as stat  
FROM daily_stats
UNION ALL
SELECT
    'Goals configured: ' || COUNT(*) as stat
FROM goals
UNION ALL
SELECT
    'Achievements: ' || COUNT(*) as stat
FROM achievements;"

# Database file size
db_size=$(du -h "$DB_FILE" | cut -f1)
echo "Database file size: $db_size"

# Date range of data
date_range=$(sqlite3 "$DB_FILE" "
SELECT 
    'Date range: ' || MIN(date) || ' to ' || MAX(date)
FROM document_stats;")
echo "$date_range"

echo
echo "Maintenance complete!"
```

---

## Enhanced Scripts

### Enhanced goals.sh

```bash
#!/bin/bash
# goals.sh - Enhanced database-driven goal tracking

DB_FILE="$HOME/.microjournal/stats.db"

# Display daily goal progress
show_daily_progress() {
    local today=$(date +%Y-%m-%d)
    
    echo -e "\033[92mDaily Writing Progress ($today):\033[0m"
    echo
    
    # Get today's stats and daily goal
    local today_stats=$(sqlite3 "$DB_FILE" "
    SELECT COALESCE(total_words, 0), COALESCE(total_time, 0), COALESCE(avg_words_per_minute, 0)
    FROM daily_stats WHERE date = '$today';")
    
    local daily_goal=$(sqlite3 "$DB_FILE" "
    SELECT target_value FROM goals WHERE goal_type = 'daily';")
    
    if [ -n "$today_stats" ]; then
        IFS='|' read today_words today_time today_wpm <<< "$today_stats"
    else
        today_words=0
        today_time=0  
        today_wpm=0
    fi
    
    # Calculate progress percentage
    local progress=0
    if [ "$daily_goal" -gt 0 ]; then
        progress=$((today_words * 100 / daily_goal))
        [ "$progress" -gt 100 ] && progress=100
    fi
    
    # Display progress bar
    echo -n "Daily Goal: "
    display_progress_bar "$progress"
    echo " $progress% ($today_words/$daily_goal words)"
    
    # Show time and speed info
    if [ "$today_time" -gt 0 ]; then
        echo "Writing time: $(format_duration "$today_time")"
        echo "Average speed: $today_wpm words/minute"
    fi
    
    # Motivational messages and recommendations
    if [ "$today_words" -ge "$daily_goal" ]; then
        echo -e "\033[92m🎯 Daily goal achieved! Excellent work!\033[0m"
    else
        local words_needed=$((daily_goal - today_words))
        if [ "$today_wpm" -gt 0 ]; then
            local minutes_needed=$((words_needed / today_wpm))
            echo -e "\033[93m💡 Write for $minutes_needed more minutes to reach your goal\033[0m"
        else
            echo -e "\033[93m💡 $words_needed more words to reach your daily goal\033[0m"
        fi
    fi
    
    # Show current writing streak
    show_writing_streak
}

# Display weekly goal progress
show_weekly_progress() {
    local week_start=$(date -d "monday" +%Y-%m-%d)
    
    echo -e "\033[92mWeekly Writing Progress:\033[0m"
    echo
    
    # Get week's stats and weekly goal
    local week_stats=$(sqlite3 "$DB_FILE" "
    SELECT 
        COALESCE(SUM(total_words), 0) as week_words,
        COUNT(*) as writing_days,
        COALESCE(SUM(total_time), 0) as week_time
    FROM daily_stats 
    WHERE date >= '$week_start' AND total_words > 0;")
    
    local weekly_goal=$(sqlite3 "$DB_FILE" "
    SELECT target_value FROM goals WHERE goal_type = 'weekly';")
    
    if [ -n "$week_stats" ]; then
        IFS='|' read week_words writing_days week_time <<< "$week_stats"
    else
        week_words=0
        writing_days=0
        week_time=0
    fi
    
    # Calculate weekly progress
    local week_progress=0
    if [ "$weekly_goal" -gt 0 ]; then
        week_progress=$((week_words * 100 / weekly_goal))
        [ "$week_progress" -gt 100 ] && week_progress=100
    fi
    
    # Display weekly progress
    echo -n "Weekly Goal: "
    display_progress_bar "$week_progress"
    echo " $week_progress% ($week_words/$weekly_goal words)"
    
    echo "Writing days this week: $writing_days"
    echo "Total writing time: $(format_duration "$week_time")"
    
    # Weekly pacing recommendations
    local days_left=$((7 - $(date +%u)))  # Days until Sunday
    if [ "$days_left" -gt 0 ] && [ "$week_words" -lt "$weekly_goal" ]; then
        local words_needed=$((weekly_goal - week_words))
        local daily_pace=$((words_needed / days_left))
        echo -e "\033[93m📈 Pace: Write $daily_pace words per day to reach weekly goal\033[0m"
    fi
}

# Show writing streak information
show_writing_streak() {
    echo
    echo -e "\033[96mWriting Streak:\033[0m"
    
    # Calculate current streak using SQL
    local streak=$(sqlite3 "$DB_FILE" "
    WITH RECURSIVE date_series AS (
        SELECT date('now') as check_date, 0 as streak_count
        UNION ALL
        SELECT date(check_date, '-1 day'), streak_count + 1
        FROM date_series
        WHERE check_date IN (SELECT date FROM daily_stats WHERE total_words > 0)
        AND streak_count < 365
    )
    SELECT MAX(streak_count) FROM date_series;")
    
    if [ "$streak" -gt 0 ]; then
        echo -e "🔥 Current streak: \033[93m$streak days\033[0m"
        
        # Streak milestones
        if [ "$streak" -ge 30 ]; then
            echo "🏆 Amazing! You've maintained a month-long writing habit!"
        elif [ "$streak" -ge 14 ]; then
            echo "📚 Great momentum! Two weeks of consistent writing!"
        elif [ "$streak" -ge 7 ]; then
            echo "✨ Excellent! One week of daily writing!"
        elif [ "$streak" -ge 3 ]; then
            echo "💪 Building momentum! Keep it up!"
        fi
    else
        echo "❄️  No current streak - start today!"
    fi
    
    # Best streak
    local best_streak=$(sqlite3 "$DB_FILE" "
    SELECT MAX(consecutive_days) FROM (
        WITH RECURSIVE streak_calc AS (
            SELECT date, 1 as consecutive_days,
                   date as streak_start
            FROM daily_stats 
            WHERE total_words > 0
            UNION ALL
            SELECT d.date, 
                   CASE WHEN date(s.date, '+1 day') = d.date 
                        THEN s.consecutive_days + 1 
                        ELSE 1 END,
                   CASE WHEN date(s.date, '+1 day') = d.date 
                        THEN s.streak_start 
                        ELSE d.date END
            FROM daily_stats d, streak_calc s
            WHERE d.total_words > 0 
            AND d.date > s.date
            ORDER BY d.date
        )
        SELECT consecutive_days FROM streak_calc
    );")
    
    if [ -n "$best_streak" ] && [ "$best_streak" -gt 0 ]; then
        echo "🎯 Personal record: $best_streak days"
    fi
}

# Set or modify writing goals
set_goals() {
    echo -e "\033[92mWriting Goals Configuration:\033[0m"
    echo
    
    # Display current goals
    echo "Current goals:"
    sqlite3 "$DB_FILE" "
    SELECT goal_type, target_value 
    FROM goals 
    ORDER BY 
        CASE goal_type 
            WHEN 'daily' THEN 1 
            WHEN 'weekly' THEN 2 
            WHEN 'monthly' THEN 3 
        END;" | while IFS='|' read type value; do
        echo "  ${type^}: $value words"
    done
    
    echo
    echo "Which goal would you like to modify?"
    echo "D) Daily goal"
    echo "W) Weekly goal" 
    echo "M) Monthly goal"
    echo "Q) Return to menu"
    
    read -n 1 -s choice
    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
    echo "$choice"
    
    case "$choice" in
        'd') modify_goal "daily" "Daily" ;;
        'w') modify_goal "weekly" "Weekly" ;;
        'm') modify_goal "monthly" "Monthly" ;;
        'q') return ;;
        *) echo "Invalid choice"; sleep 1 ;;
    esac
}

# Modify specific goal
modify_goal() {
    local goal_type="$1"
    local goal_name="$2"
    
    local current_value=$(sqlite3 "$DB_FILE" "
    SELECT target_value FROM goals WHERE goal_type = '$goal_type';")
    
    echo
    echo "$goal_name goal is currently: $current_value words"
    echo -n "Enter new $goal_name goal (or press Enter to keep current): "
    read new_value
    
    if [ -n "$new_value" ] && [[ "$new_value" =~ ^[0-9]+$ ]]; then
        sqlite3 "$DB_FILE" "
        UPDATE goals 
        SET target_value = $new_value, updated_at = datetime('now')
        WHERE goal_type = '$goal_type';"
        
        echo "$goal_name goal updated to $new_value words"
    else
        echo "$goal_name goal unchanged"
    fi
    
    sleep 2
}

# Display progress bar
display_progress_bar() {
    local progress="$1"
    local bar_length=20
    local filled_length=$((progress * bar_length / 100))
    
    printf "["
    for ((i=0; i<filled_length; i++)); do printf "█"; done
    for ((i=filled_length; i<bar_length; i++)); do printf "░"; done
    printf "]"
}

# Format duration helper
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

# Main goals menu
main_menu() {
    while true; do
        clear
        echo
        echo -e "\033[1;38;5;81m📊 WRITING GOALS & PROGRESS\033[0m"
        echo
        
        echo "D) Daily Progress     W) Weekly Progress"
        echo "S) Set Goals          A) Analytics"
        echo "Q) Return to Main Menu"
        echo
        printf "Selection: "
        read -n 1 -s choice
        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
        echo "$choice"
        echo

        case "$choice" in
            'd') show_daily_progress; echo; read -p "Press Enter to continue..." ;;
            'w') show_weekly_progress; echo; read -p "Press Enter to continue..." ;;
            's') set_goals ;;
            'a') show_analytics ;;
            'q') break ;;
            *) echo "Invalid choice. Try again..."; sleep 1 ;;
        esac
    done
}

# Show advanced analytics
show_analytics() {
    echo -e "\033[92mWriting Analytics:\033[0m"
    echo
    
    # Best writing time analysis
    echo -e "\033[96m⏰ Optimal Writing Times:\033[0m"
    sqlite3 "$DB_FILE" "
    SELECT 
        CASE 
            WHEN CAST(substr(time, 1, 2) AS INTEGER) < 6 THEN 'Early Morning (before 6am)'
            WHEN CAST(substr(time, 1, 2) AS INTEGER) < 12 THEN 'Morning (6am-12pm)'
            WHEN CAST(substr(time, 1, 2) AS INTEGER) < 18 THEN 'Afternoon (12pm-6pm)'
            ELSE 'Evening (after 6pm)'
        END as time_period,
        COUNT(*) as sessions,
        ROUND(AVG(words_per_minute), 1) as avg_wpm,
        SUM(word_count) as total_words
    FROM document_stats 
    WHERE words_per_minute > 0
    GROUP BY 1
    ORDER BY avg_wpm DESC;" | while IFS='|' read period sessions wpm words; do
        printf "  %-25s: %d sessions, %.1f wpm avg, %d words\n" "$period" "$sessions" "$wpm" "$words"
    done
    
    echo
    
    # Session length analysis
    echo -e "\033[96m📊 Session Length Efficiency:\033[0m"
    sqlite3 "$DB_FILE" "
    SELECT 
        CASE 
            WHEN session_duration < 600 THEN 'Quick (< 10 min)'
            WHEN session_duration < 1800 THEN 'Short (10-30 min)'
            WHEN session_duration < 3600 THEN 'Medium (30-60 min)'
            ELSE 'Long (> 60 min)'
        END as session_type,
        COUNT(*) as sessions,
        ROUND(AVG(words_per_minute), 1) as avg_wpm,
        ROUND(AVG(word_count), 0) as avg_words
    FROM document_stats 
    WHERE session_duration > 0 AND words_per_minute > 0
    GROUP BY 1
    ORDER BY avg_wpm DESC;" | while IFS='|' read type sessions wpm words; do
        printf "  %-20s: %d sessions, %.1f wpm, %.0f words avg\n" "$type" "$sessions" "$wpm" "$words"
    done
    
    echo
    read -p "Press Enter to continue..."
}

# Run main menu
main_menu
