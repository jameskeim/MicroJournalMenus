#!/bin/bash
# journal-menu.sh - Compact Journal Menu for 98x12 display
# Save as ~/.microjournal/scripts/journal-menu.sh

MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"
JOURNAL_FILE="$HOME/Documents/journal/myjournal.md"

# Function to check journal structure and report issues
check_journal_structure() {
  clear
  echo
  echo -e "\033[92mJOURNAL STRUCTURE CHECK\033[0m"
  echo

  if [ ! -f "$JOURNAL_FILE" ]; then
    echo -e "\033[91m✗ No journal file found\033[0m"
    echo "  Location: $JOURNAL_FILE"
    echo "  Fix: Create first entry with 'New Entry'"
    return
  fi

  local issues=0
  local warnings=0

  # Check 1: Main title (H1)
  if ! grep -q "^# " "$JOURNAL_FILE"; then
    echo -e "\033[91m✗ Missing main journal title (H1)\033[0m"
    echo "  Expected: # My Personal Journal"
    issues=$((issues + 1))
  else
    echo -e "\033[92m✓ Main title found\033[0m"
  fi

  # Check 2: Day headers (H2) format
  local h2_count=$(grep -c "^## " "$JOURNAL_FILE")
  if [ $h2_count -eq 0 ]; then
    echo -e "\033[93m⚠ No day entries found\033[0m"
    warnings=$((warnings + 1))
  else
    echo -e "\033[92m✓ Found $h2_count day entries\033[0m"

    # Check H2 format (should be day names)
    local bad_h2=$(grep "^## " "$JOURNAL_FILE" | grep -v "^## [A-Za-z]")
    if [ -n "$bad_h2" ]; then
      echo -e "\033[91m✗ Malformed day headers found:\033[0m"
      echo "$bad_h2" | head -3 | sed 's/^/  /'
      issues=$((issues + 1))
    fi
  fi

  # Check 3: Time headers (H3) format
  local h3_count=$(grep -c "^### " "$JOURNAL_FILE")
  if [ $h3_count -eq 0 ] && [ $h2_count -gt 0 ]; then
    echo -e "\033[93m⚠ Day entries found but no time entries\033[0m"
    warnings=$((warnings + 1))
  elif [ $h3_count -gt 0 ]; then
    echo -e "\033[92m✓ Found $h3_count time entries\033[0m"

    # Check H3 format (should be HH:MM)
    local bad_h3=$(grep "^### " "$JOURNAL_FILE" | grep -v "^### [0-9][0-9]:[0-9][0-9]")
    if [ -n "$bad_h3" ]; then
      echo -e "\033[91m✗ Malformed time headers found:\033[0m"
      echo "$bad_h3" | head -3 | sed 's/^/  /'
      issues=$((issues + 1))
    fi
  fi

  # Check 4: Orphaned H3s (H3 without H2)
  local orphaned_h3=$(awk '
    /^### / { if (!in_day) orphans[++count] = $0; next }
    /^## / { in_day = 1; next }
    /^# / { in_day = 0; next }
    END { for (i in orphans) print orphans[i] }
  ' "$JOURNAL_FILE")

  if [ -n "$orphaned_h3" ]; then
    echo -e "\033[91m✗ Time entries without day headers:\033[0m"
    echo "$orphaned_h3" | head -3 | sed 's/^/  /'
    issues=$((issues + 1))
  fi

  # Check 5: User content headers (H4, H5) - informational only
  local h4_count=$(grep -c "^#### " "$JOURNAL_FILE")
  local h5_count=$(grep -c "^##### " "$JOURNAL_FILE")

  if [ $h4_count -gt 0 ] || [ $h5_count -gt 0 ]; then
    echo -e "\033[96mℹ User content headers found:\033[0m"
    [ $h4_count -gt 0 ] && echo "  H4 sections: $h4_count"
    [ $h5_count -gt 0 ] && echo "  H5 subsections: $h5_count"
    echo "  (These enhance content organization - no issues)"
  fi

  # Check 6: File size and entry distribution
  local file_size=$(wc -c <"$JOURNAL_FILE" 2>/dev/null || echo 0)
  local file_size_kb=$((file_size / 1024))

  if [ $file_size_kb -gt 500 ]; then
    echo -e "\033[93m⚠ Large journal file (${file_size_kb}KB)\033[0m"
    echo "  Consider archiving old entries for better performance"
    warnings=$((warnings + 1))
  fi

  # Summary
  echo
  if [ $issues -eq 0 ] && [ $warnings -eq 0 ]; then
    echo -e "\033[92m✓ Journal structure is perfect!\033[0m"
  elif [ $issues -eq 0 ]; then
    echo -e "\033[93m✓ Structure is valid with $warnings minor warnings\033[0m"
  else
    echo -e "\033[91m✗ Found $issues structural issues and $warnings warnings\033[0m"
    echo
    echo "Common fixes:"
    echo "• Ensure day headers use ## format: ## Monday, January 13, 2025"
    echo "• Ensure time headers use ### format: ### 14:30"
    echo "• Each time entry should be under a day header"
    echo "• H4/H5 headers (####, #####) are welcome for content organization"
  fi

  echo
  echo -n "Press any key..."
  read -n 1 -s
}

# Main menu loop optimized for 98x12
while true; do
  clear
  echo

  # Compact header (2 lines used)
  printf "%*s\n" $(((98 - 9) / 2)) ""
  echo -e "\033[1;38;5;81m📔 JOURNAL\033[0m"
  echo

  # Compact menu (6 lines used, leaves 4 for content/navigation)
  echo "N) New Entry    R) Read (Glow)    T) Recent Entries"
  echo "S) Search       O) Open Editor    C) Check Structure"
  echo "Q) Quit to Menu"
  echo
  printf "Selection: "
  read -n 1 -s choice
  choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
  echo "$choice"
  echo

  case "$choice" in
  'n' | '')
    "$MCRJRNL/scripts/journal.sh" new
    break
    ;;
  'r')
    "$MCRJRNL/scripts/journal.sh" read
    ;;
  't')
    "$MCRJRNL/scripts/journal.sh" recent
    ;;
  's')
    "$MCRJRNL/scripts/journal.sh" search
    ;;
  'o')
    "$MCRJRNL/scripts/journal.sh" open
    break
    ;;
  'c')
    check_journal_structure
    ;;
  'q')
    break
    ;;
  *)
    echo "Invalid choice. Try again..."
    sleep 1
    ;;
  esac
done
