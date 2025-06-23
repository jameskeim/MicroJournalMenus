#!/bin/bash
# wordcount-foundation.sh - Foundational Word Count Tool for MICRO JOURNAL 3000
#
# ═══════════════════════════════════════════════════════════════════════════════
# ARCHITECTURAL FOUNDATION - Building Block for Advanced Writing Analytics
# ═══════════════════════════════════════════════════════════════════════════════
#
# This script serves as the FOUNDATION for a comprehensive writing analytics system.
# Every function here is designed to be expanded into more sophisticated features
# while maintaining the lightweight, distraction-free philosophy of the system.
#
# GROWTH PATH OVERVIEW:
# ├── CURRENT: Basic word counting and file analysis
# ├── PHASE 2: Daily goals and progress tracking
# ├── PHASE 3: Writing streak analysis and motivation
# ├── PHASE 4: Smart analytics (best writing times, patterns)
# ├── PHASE 5: Historical analysis and trend visualization
# └── PHASE 6: Integrated dashboard with all metrics
#
# KEY INSIGHT: The date/time filename structure (YYYY-MM-DD_HH-MM-*.md) contains
# ALL the metadata we need for sophisticated analytics without requiring a database.
# This makes the system extremely lightweight while enabling powerful features.
#
# ═══════════════════════════════════════════════════════════════════════════════

clear
echo -e "\033[96m*** WORD COUNT TOOL - FOUNDATION SYSTEM ***\033[0m"
echo

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION & CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════════

# Documents directory - FOUNDATION for all file operations
DOCS_DIR="$HOME/Documents"

# Current date for today's analysis - FOUNDATION for daily tracking
TODAY=$(date +%Y-%m-%d)

# FUTURE EXPANSION POINTS:
# - CONFIG_FILE="$HOME/.microjournal/config" for user preferences
# - GOALS_FILE="$HOME/.microjournal/goals.txt" for daily/weekly targets
# - STATS_FILE="$HOME/.microjournal/stats.txt" for historical data
# - STREAK_FILE="$HOME/.microjournal/streak.txt" for consecutive writing days

# ═══════════════════════════════════════════════════════════════════════════════
# CORE FOUNDATION FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# FOUNDATION FUNCTION: Single file analysis
# PURPOSE: Provides detailed metrics for any individual file
# EXPANSION PATH: This becomes the engine for session analysis, content metrics,
#                 writing velocity calculations, and quality indicators
count_file() {
  local file="$1"

  # CURRENT: Basic word/character/line counting
  if [ -f "$file" ]; then
    words=$(wc -w <"$file")
    chars=$(wc -c <"$file")
    lines=$(wc -l <"$file")

    echo -e "File: \033[93m$(basename "$file")\033[0m"
    echo "Words: $words | Characters: $chars | Lines: $lines"
    echo

    # FUTURE EXPANSION IDEAS for this function:
    # 1. CONTENT ANALYSIS:
    #    - Count markdown headers, links, emphasis
    #    - Detect document type/structure
    #    - Calculate readability scores
    #
    # 2. WRITING VELOCITY:
    #    - Parse filename timestamp vs file modification time
    #    - Calculate words per minute for the session
    #    - Track editing vs. creation time
    #
    # 3. QUALITY METRICS:
    #    - Average sentence length
    #    - Vocabulary diversity
    #    - Paragraph structure analysis
    #
    # 4. SESSION TRACKING:
    #    - Estimate actual writing time (creation to last edit)
    #    - Track breaks/pauses in writing
    #    - Calculate focus score based on consistent writing

  else
    echo -e "\033[91mFile not found: $file\033[0m"
  fi
}

# FOUNDATION FUNCTION: Daily writing analysis
# PURPOSE: Aggregates all writing activity for current day
# EXPANSION PATH: This becomes the core of daily goals, progress tracking,
#                 and the foundation for the writing dashboard
count_today() {
  echo -e "\033[92mToday's Writing ($TODAY):\033[0m"
  echo

  # CURRENT: Basic aggregation of today's files
  total_words=0
  file_count=0

  # KEY ARCHITECTURAL ELEMENT: Filename parsing
  # The filename structure YYYY-MM-DD_HH-MM-*.md contains:
  # - Date for daily aggregation
  # - Time for session analysis
  # - Pattern for future smart filtering
  for file in "$DOCS_DIR"/${TODAY}_*.md; do
    if [ -f "$file" ]; then
      words=$(wc -w <"$file")
      filename=$(basename "$file")

      # CRITICAL FOUNDATION: Time extraction from filename
      # This simple regex becomes the basis for ALL time-based analytics
      time_part=$(echo "$filename" | sed 's/.*_\([0-9][0-9]-[0-9][0-9]\).*/\1/' | tr '-' ':')

      echo -e "$time_part - \033[93m$filename\033[0m"
      echo "       Words: $words"

      total_words=$((total_words + words))
      file_count=$((file_count + 1))

      # FUTURE EXPANSION: Session data collection
      # Each loop iteration could populate arrays/files with:
      # - session_times=("$time_part" ...)
      # - session_words=("$words" ...)
      # - session_files=("$filename" ...)
      # This data feeds into ALL advanced analytics
    fi
  done

  # CURRENT: Basic daily summary
  if [ $file_count -eq 0 ]; then
    echo -e "\033[91mNo writing files found for today.\033[0m"

    # FUTURE EXPANSION: Goal reminder and encouragement
    # - Check if user has daily goal set
    # - Show motivational message
    # - Suggest starting a writing session
    # - Display writing streak status (if broken)

  else
    echo
    echo -e "\033[92m--- TODAY'S TOTAL ---\033[0m"
    echo "Files: $file_count"
    echo "Total Words: $total_words"

    # CURRENT: Simple reading time calculation
    if [ $total_words -gt 0 ]; then
      read_time=$((total_words / 200))
      if [ $read_time -eq 0 ]; then
        echo "Reading Time: Less than 1 minute"
      else
        echo "Reading Time: ~$read_time minutes"
      fi
    fi

    # FUTURE EXPANSION OPPORTUNITIES:
    # 1. GOAL TRACKING:
    #    - Compare $total_words to daily goal
    #    - Show progress bar: ████████░░ 80% (400/500)
    #    - Calculate words needed to reach goal
    #
    # 2. STREAK ANALYSIS:
    #    - Check yesterday's writing to maintain streak
    #    - Update streak counter file
    #    - Display current streak: "🔥 Day 7 of writing streak!"
    #
    # 3. PRODUCTIVITY INSIGHTS:
    #    - Best writing time today (highest word count session)
    #    - Compare to historical best times
    #    - Session efficiency rating
    #
    # 4. WEEKLY PROGRESS:
    #    - Show week-to-date progress: "2,847 / 3,500 words this week"
    #    - Days remaining to hit weekly goal
    #    - Pace recommendation: "Write 93 words/day to hit weekly goal"
  fi
  echo
}

# FOUNDATION FUNCTION: Recent file analysis
# PURPOSE: Shows latest writing activity across all time periods
# EXPANSION PATH: Becomes the foundation for trend analysis, writing patterns,
#                 and the "Recent Activity" section of the dashboard
count_recent() {
  echo -e "\033[92mRecent Files (Last 5):\033[0m"
  echo

  # CURRENT: Simple file listing by modification time
  # ARCHITECTURAL NOTE: Using file system metadata for chronological ordering
  recent_files=$(find "$DOCS_DIR" -name "*.md" -type f -printf '%T@ %p\n' | sort -nr | head -5 | cut -d' ' -f2-)

  if [ -z "$recent_files" ]; then
    echo -e "\033[91mNo markdown files found.\033[0m"
  else
    # CURRENT: Basic recent file display
    while IFS= read -r file; do
      if [ -n "$file" ]; then
        words=$(wc -w <"$file")
        filename=$(basename "$file")
        mod_date=$(stat -c %y "$file" | cut -d' ' -f1)
        echo -e "$mod_date - \033[93m$filename\033[0m"
        echo "             Words: $words"

        # FUTURE EXPANSION: Pattern recognition
        # This loop could analyze:
        # 1. WRITING PATTERNS:
        #    - Extract times from filenames to find peak productivity hours
        #    - Identify writing frequency patterns (daily, sporadic, binges)
        #    - Calculate average words per session over time
        #
        # 2. TREND ANALYSIS:
        #    - Track word count progression over recent sessions
        #    - Identify increasing/decreasing productivity trends
        #    - Detect changes in writing style or session length
        #
        # 3. SMART RECOMMENDATIONS:
        #    - "You write 34% more words in morning sessions"
        #    - "Your longest streaks happen when you write before 10am"
        #    - "You haven't written for 3 days - time to get back on track!"
      fi
    done <<<"$recent_files"
  fi
  echo
}

# FOUNDATION FUNCTION: Complete document analysis
# PURPOSE: Provides comprehensive overview of all writing
# EXPANSION PATH: Becomes the "Portfolio Overview" and foundation for
#                 historical analysis, achievement tracking, and corpus statistics
count_all() {
  echo -e "\033[92mAll Files in Documents:\033[0m"
  echo

  # CURRENT: Simple aggregation across all files
  total_words=0
  file_count=0

  # ARCHITECTURAL FOUNDATION: Complete corpus analysis
  for file in "$DOCS_DIR"/*.md; do
    if [ -f "$file" ]; then
      words=$(wc -w <"$file")
      filename=$(basename "$file")
      echo -e "\033[93m$filename\033[0m - $words words"

      total_words=$((total_words + words))
      file_count=$((file_count + 1))

      # FUTURE EXPANSION: Historical data collection
      # Each file could contribute to:
      # 1. TEMPORAL ANALYSIS:
      #    - Parse filename dates to create writing timeline
      #    - Build monthly/yearly word count totals
      #    - Identify productive periods and dry spells
      #
      # 2. ACHIEVEMENT TRACKING:
      #    - Detect personal records (highest daily word count, longest streak)
      #    - Track milestones (first 1000-word day, 10th consecutive day)
      #    - Calculate writing "levels" or achievements unlocked
      #
      # 3. PORTFOLIO METRICS:
      #    - Average document length
      #    - Writing style evolution over time
      #    - Vocabulary growth and complexity trends
    fi
  done

  # CURRENT: Grand total display
  if [ $file_count -eq 0 ]; then
    echo -e "\033[91mNo markdown files found.\033[0m"
  else
    echo
    echo -e "\033[92m--- GRAND TOTAL ---\033[0m"
    echo "Files: $file_count"
    echo "Total Words: $total_words"

    # FUTURE EXPANSION: Portfolio insights
    # This section could become a rich dashboard:
    # 1. LIFETIME STATISTICS:
    #    - Total writing time (estimated)
    #    - Words per day average since starting
    #    - Most productive month/week/day
    #
    # 2. ACHIEVEMENT DISPLAY:
    #    - "🏆 Personal Record: 847 words in one day!"
    #    - "📚 Milestone: 50,000 total words written!"
    #    - "🔥 Best Streak: 12 consecutive days"
    #
    # 3. WRITING PERSONALITY:
    #    - "You're a consistent daily writer" vs "You prefer writing binges"
    #    - "Your average session: 247 words"
    #    - "You write best in the early morning"
  fi
  echo
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN INTERFACE - FOUNDATION FOR DASHBOARD SYSTEM
# ═══════════════════════════════════════════════════════════════════════════════

# CURRENT: Simple menu-driven interface
# EXPANSION PATH: This becomes a sophisticated dashboard with multiple views
echo "What would you like to count?"
echo
echo "1) Today's writing"        # → Becomes "Daily Dashboard" with goals/progress
echo "2) Recent files (last 5)"  # → Becomes "Recent Activity" with trends
echo "3) Specific file"          # → Becomes "Deep Analysis" with session metrics
echo "4) All files in Documents" # → Becomes "Portfolio Overview" with achievements
echo
# FUTURE MENU OPTIONS:
# echo "5) Weekly progress"      # → Shows week's goal progress, daily breakdown
# echo "6) Writing goals"        # → Set/modify daily/weekly/monthly targets
# echo "7) Analytics dashboard"  # → Comprehensive view with charts and insights
# echo "8) Achievement gallery"  # → Display unlocked achievements and milestones
# echo "9) Writing insights"     # → Smart analytics about patterns and habits

echo -n "Choice (1-4): "
read choice

echo

# CURRENT: Basic menu handling
# EXPANSION PATH: Each case becomes a sophisticated view with multiple features
case $choice in
1)
  count_today
  # FUTURE: Add goal checking, streak status, daily encouragement
  ;;
2)
  count_recent
  # FUTURE: Add trend arrows, pattern recognition, smart recommendations
  ;;
3)
  echo -n "Enter filename (or full path): "
  read filename

  # Auto-complete to Documents directory if relative path
  if [[ "$filename" != /* ]]; then
    filename="$DOCS_DIR/$filename"
  fi

  count_file "$filename"
  # FUTURE: Add session analysis, writing velocity, content metrics
  ;;
4)
  count_all
  # FUTURE: Add achievement gallery, lifetime statistics, writing personality
  ;;
*)
  echo -e "\033[91mInvalid choice.\033[0m"
  ;;
esac

# ═══════════════════════════════════════════════════════════════════════════════
# ARCHITECTURAL NOTES FOR FUTURE DEVELOPMENT
# ═══════════════════════════════════════════════════════════════════════════════

# DATA PERSISTENCE STRATEGY:
# To maintain the lightweight philosophy while adding features, use simple text files:
#
# ~/.microjournal/config          # User preferences and daily goals
# ~/.microjournal/streak.txt      # Current writing streak counter
# ~/.microjournal/achievements.txt # Unlocked achievements and milestones
# ~/.microjournal/stats.txt       # Daily aggregated statistics
# ~/.microjournal/insights.txt    # Cached analytical insights
#
# This approach keeps the system dependency-free while enabling persistence.

# FILENAME PARSING ARCHITECTURE:
# The YYYY-MM-DD_HH-MM-*.md format is the key to everything:
# - Date extraction: ${filename:0:10} gives YYYY-MM-DD
# - Time extraction: sed pattern gives HH:MM
# - Pattern matching: find by date/time ranges
# - Sorting: natural chronological order
# - No database needed: filesystem provides all metadata

# PERFORMANCE CONSIDERATIONS:
# For large document collections, consider:
# - Caching daily/weekly aggregates in stats.txt
# - Using find with date ranges instead of processing all files
# - Implementing incremental updates for new files only
# - Background processing for analytics (cron job)

# SCALABILITY PATH:
# Phase 1: Current foundation ✓
# Phase 2: Add simple goal tracking (daily target in config file)
# Phase 3: Add streak tracking (maintain counter, show encouragement)
# Phase 4: Add smart analytics (parse patterns, cache insights)
# Phase 5: Add dashboard mode (comprehensive view)
# Phase 6: Add achievement system (milestones, gamification)

echo -e "\033[93mPress any key to return to menu...\033[0m"
read -n 1 -s

# ═══════════════════════════════════════════════════════════════════════════════
# END OF FOUNDATION SCRIPT
#
# This script establishes the architectural foundation for a comprehensive
# writing analytics system while maintaining the lightweight, distraction-free
# philosophy of the MICRO JOURNAL 3000. Every function is designed to scale
# gracefully into more sophisticated features without breaking the simple
# interface or requiring heavy dependencies.
# ═══════════════════════════════════════════════════════════════════════════════
