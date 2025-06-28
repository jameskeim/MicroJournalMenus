#!/bin/bash
# goals.sh - Phase 2 Goal Tracking for MICRO JOURNAL 2000
# Based on WordCountOverview.md Phase 2 specification

# Configuration
MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"
DOCS_DIR="$HOME/Documents/writing"
CONFIG_FILE="$MCRJRNL/config"
TODAY=$(date +%Y.%m.%d)

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function to get accurate word count for markdown files
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
# Phase 2 Goal Tracking System

daily_goal=$daily_goal
weekly_goal=$weekly_goal
monthly_goal=$monthly_goal
EOF
}

# Get today's word count
get_today_count() {
  local total=0
  for file in "$DOCS_DIR"/${TODAY}-*.md; do
    if [ -f "$file" ]; then
      total=$((total + $(get_word_count "$file")))
    fi
  done
  echo "$total"
}

# Get this week's word count (Monday to Sunday)
get_week_count() {
  local total=0
  
  # Calculate the Monday of the current week
  local days_since_monday=$((($(date +%u) - 1)))
  local week_start=$(date -d "-${days_since_monday} days" +%Y.%m.%d)
  local week_end=$(date -d "+$((6 - days_since_monday)) days" +%Y.%m.%d)
  
  for file in "$DOCS_DIR"/*.md; do
    if [ -f "$file" ]; then
      local file_date=$(basename "$file" | cut -d'-' -f1-3)
      if [[ "$file_date" > "$week_start" || "$file_date" == "$week_start" ]] && [[ "$file_date" < "$week_end" || "$file_date" == "$week_end" ]]; then
        total=$((total + $(get_word_count "$file")))
      fi
    fi
  done
  echo "$total"
}

# Get this month's word count
get_month_count() {
  local total=0
  local month_prefix=$(date +%Y.%m)
  
  for file in "$DOCS_DIR"/${month_prefix}.*.md; do
    if [ -f "$file" ]; then
      total=$((total + $(get_word_count "$file")))
    fi
  done
  echo "$total"
}

# Show ASCII progress bar (from WordCountOverview.md spec)
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

# Enhanced progress dashboard (implementing WordCountOverview.md Phase 2 spec)
show_progress_dashboard() {
  clear
  echo
  printf "%*s\n" $(((98 - 17) / 2)) ""
  echo -e "\033[1;38;5;81m▐ WRITING PROGRESS ▌\033[0m"
  echo
  
  load_config
  
  local today_count=$(get_today_count)
  local week_count=$(get_week_count)
  local month_count=$(get_month_count)
  
  # Count today's files
  local file_count=0
  for file in "$DOCS_DIR"/${TODAY}-*.md; do
    if [ -f "$file" ]; then
      file_count=$((file_count + 1))
    fi
  done
  
  # Today's Progress (matching WordCountOverview.md example)
  echo "Goal Progress: $(show_progress "$today_count" "$daily_goal")"
  echo
  
  # Show today's sessions (compact for 98x12)
  if [ "$today_count" -gt 0 ]; then
    echo "Sessions today: $file_count"
    echo
  fi
  
  # Weekly and Monthly Progress
  echo "This Week: $week_count/$weekly_goal words"
  echo "This Month: $month_count/$monthly_goal words"
  echo
  
  # Goal achievement messaging (per WordCountOverview.md)
  if [ "$today_count" -ge "$daily_goal" ]; then
    echo -e "${GREEN}*** Daily goal achieved! Total: $today_count words ***${NC}"
  else
    local needed=$((daily_goal - today_count))
    echo "Need $needed more words to reach daily goal"
  fi
  
  echo
  read -p "Press Enter to continue..."
}

# Main interface (98x12 optimized)
case "${1:-menu}" in
"set")
  set_goals
  ;;
"progress" | "p")
  show_progress_dashboard
  ;;
*)
  # Menu mode
  while true; do
    clear
    echo
    printf "%*s\n" $(((98 - 8) / 2)) ""
    echo -e "\033[1;38;5;81m▐ GOALS ▌\033[0m"
    echo
    echo "1) View Progress   2) Set Goals   Q) Quit"
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