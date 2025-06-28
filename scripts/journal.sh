#!/bin/bash
# journal.sh - Dead Simple Journal System for MICRO JOURNAL 2000
# Save as ~/.microjournal/scripts/journal.sh

# Configuration
JOURNAL_DIR="$HOME/Documents/journal"
JOURNAL_FILE="$JOURNAL_DIR/myjournal.md"
EDITOR="${EDITOR:-nvim}"

# Ensure journal directory exists
mkdir -p "$JOURNAL_DIR"

# Function to create initial journal file if it doesn't exist
init_journal() {
  if [ ! -f "$JOURNAL_FILE" ]; then
    cat >"$JOURNAL_FILE" <<'EOF'
# My Personal Journal

*A space for thoughts, reflections, and daily experiences.*

Welcome to your journal! Each entry will appear below with date and time headers.

**Organization Tips:**
- Use #### for topics within entries (#### Work Thoughts, #### Morning Reflection)
- Use ##### for subtopics (##### Meeting Notes, ##### Ideas to Explore)
- The system automatically creates ## Day and ### Time headers for you

---

EOF
    echo "Created new journal file: $JOURNAL_FILE"
  fi
}

# Function to add new entry header with smart chronological placement
add_entry_header() {
  local current_time=$(date '+%H:%M')
  local current_day=$(date '+%A, %B %d, %Y')

  # If journal doesn't exist, create it first
  if [ ! -f "$JOURNAL_FILE" ]; then
    init_journal
  fi

  # Check if today already has a section
  if grep -q "^## $current_day" "$JOURNAL_FILE"; then
    # Today exists - find where to insert new time entry
    # Strategy: Insert after the day header but before any other day headers

    # Create temp file with new time entry inserted in correct location
    local temp_file=$(mktemp)
    local inserted=false

    while IFS= read -r line; do
      echo "$line" >>"$temp_file"

      # If this is today's header and we haven't inserted yet
      if [[ "$line" == "## $current_day" ]] && [ "$inserted" = false ]; then
        echo "" >>"$temp_file"
        echo "### $current_time" >>"$temp_file"
        echo "" >>"$temp_file"
        echo "" >>"$temp_file" # Space for writing
        echo "" >>"$temp_file"
        inserted=true
      fi
    done <"$JOURNAL_FILE"

    mv "$temp_file" "$JOURNAL_FILE"

  else
    # Today doesn't exist - add new day section at the top (after main header)
    local temp_file=$(mktemp)
    local header_passed=false

    while IFS= read -r line; do
      echo "$line" >>"$temp_file"

      # Insert after the main journal header and any intro text
      if [[ "$line" =~ ^---$ ]] && [ "$header_passed" = false ]; then
        echo "" >>"$temp_file"
        echo "## $current_day" >>"$temp_file"
        echo "" >>"$temp_file"
        echo "### $current_time" >>"$temp_file"
        echo "" >>"$temp_file"
        echo "" >>"$temp_file" # Space for writing
        echo "" >>"$temp_file"
        echo "---" >>"$temp_file" # Separator only between days
        echo "" >>"$temp_file"
        header_passed=true
      fi
    done <"$JOURNAL_FILE"

    # If no --- separator found, append to end
    if [ "$header_passed" = false ]; then
      echo "" >>"$temp_file"
      echo "## $current_day" >>"$temp_file"
      echo "" >>"$temp_file"
      echo "### $current_time" >>"$temp_file"
      echo "" >>"$temp_file"
      echo "" >>"$temp_file" # Space for writing
      echo "" >>"$temp_file"
      echo "---" >>"$temp_file" # Separator only between days
    fi

    mv "$temp_file" "$JOURNAL_FILE"
  fi

  echo "Added new journal entry for $current_day at $current_time"
}

# Function to show recent entries (optimized for 98x12)
show_recent() {
  if [ ! -f "$JOURNAL_FILE" ]; then
    echo "No journal file found. Create your first entry!"
    return
  fi

  echo -e "\033[92mRecent Journal Entries:\033[0m"
  echo

  # Show last 3 entry headers (fits in 98x12 with room for prompt)
  grep -n "^## " "$JOURNAL_FILE" | head -3 | while IFS=: read -r line_num header; do
    # Truncate long headers to fit 98 chars
    header_clean=$(echo "$header" | cut -c1-90)
    echo -e "\033[96m$header_clean\033[0m"
  done

  echo
  echo "Total: $(grep -c "^## " "$JOURNAL_FILE" 2>/dev/null || echo 0) entries"
}

# Function to search journal entries (optimized for 98x12)
search_journal() {
  local search_term="$1"

  if [ -z "$search_term" ]; then
    echo -n "Search: "
    read search_term
  fi

  if [ -n "$search_term" ] && [ -f "$JOURNAL_FILE" ]; then
    echo -e "\033[92mResults for '$search_term':\033[0m"
    echo

    # Limit results to fit screen (5 lines max for 98x12)
    grep -i -C 1 "$search_term" "$JOURNAL_FILE" | head -5
  else
    echo "No search term or journal file not found."
  fi
}

# Main script logic
case "${1:-new}" in
"new" | "n" | "")
  # Default behavior: add new entry and open editor
  init_journal
  add_entry_header

  # Open editor positioned at the new entry (line 3, after the header)
  if command -v nvim >/dev/null 2>&1; then
    nvim +3 "$JOURNAL_FILE"
  elif command -v vim >/dev/null 2>&1; then
    vim +3 "$JOURNAL_FILE"
  else
    "$EDITOR" "$JOURNAL_FILE"
  fi
  ;;

"open" | "o")
  # Just open the journal without adding new entry
  init_journal
  "$EDITOR" "$JOURNAL_FILE"
  ;;

"recent" | "r")
  # Show recent entries (98x12 optimized)
  clear
  show_recent
  echo -n "Press any key..."
  read -n 1 -s
  ;;

"search" | "s")
  # Search journal entries (98x12 optimized)
  clear
  shift
  search_journal "$*"
  echo
  echo -n "Press any key..."
  read -n 1 -s
  ;;

"read" | "view" | "glow")
  # Beautiful reading mode with glow (full screen takeover - perfect for 98x12)
  if [ ! -f "$JOURNAL_FILE" ]; then
    echo "No journal file found. Create your first entry!"
    exit 1
  fi

  if command -v glow >/dev/null 2>&1; then
    # Force pager mode with proper header styling
    # -p = pager mode (essential for long content)
    # -w 98 = width constraint for your display
    # -s dark = dark theme (better for terminals)
    glow -p -w 98 -s dark "$JOURNAL_FILE"
  else
    echo "glow not found. Install: sudo apt install glow"
    echo "Fallback view..."
    less "$JOURNAL_FILE"
  fi
  ;;

"help" | "h")
  # Compact help for 98x12
  clear
  echo "JOURNAL - Simple daily journaling"
  echo
  echo "Commands: new(default) open read recent search help"
  echo "Location: ~/Documents/journal/myjournal.md"
  echo
  echo -n "Press any key..."
  read -n 1 -s
  ;;

*)
  echo "Unknown command: $1"
  echo "Use 'journal.sh help' for usage information"
  exit 1
  ;;
esac
