#!/bin/bash
# journal-menu.sh - Compact Journal Menu for 98x12 display
# HARMONIZATION PASS 1: COMPLETED - Converted all ANSI codes to styling system

MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"

# Load standardized styling systems
source "$MCRJRNL/scripts/colors.sh"
source "$MCRJRNL/scripts/gum-styles.sh"

JOURNAL_FILE="$HOME/Documents/journal/myjournal.md"

# Function to check journal structure and report issues
check_journal_structure() {
  clear
  echo -e "${COLOR_HEADER_PRIMARY}▐ JOURNAL STRUCTURE CHECK ▌${COLOR_RESET}"

  if [ ! -f "$JOURNAL_FILE" ]; then
    echo -e "${COLOR_ERROR}[✗] No journal file found${COLOR_RESET}"
    echo "  Location: $JOURNAL_FILE"
    echo "  Fix: Create first entry with 'New Entry'"
    return
  fi

  local issues=0
  local warnings=0

  # Check 1: Main title (H1)
  if ! grep -q "^# " "$JOURNAL_FILE"; then
    echo -e "${COLOR_ERROR}[✗] Missing main journal title (H1)${COLOR_RESET}"
    echo "  Expected: # My Personal Journal"
    issues=$((issues + 1))
  else
    echo -e "${COLOR_SUCCESS}[✓] Main title found${COLOR_RESET}"
  fi

  # Check 2: Day headers (H2) format
  local h2_count=$(grep -c "^## " "$JOURNAL_FILE")
  if [ $h2_count -eq 0 ]; then
    echo -e "${COLOR_WARNING}[!] No day entries found${COLOR_RESET}"
    warnings=$((warnings + 1))
  else
    echo -e "${COLOR_SUCCESS}[✓] Found $h2_count day entries${COLOR_RESET}"

    # Check H2 format (should be day names)
    local bad_h2=$(grep "^## " "$JOURNAL_FILE" | grep -v "^## [A-Za-z]")
    if [ -n "$bad_h2" ]; then
      echo -e "${COLOR_ERROR}[✗] Malformed day headers found:${COLOR_RESET}"
      echo "$bad_h2" | head -3 | sed 's/^/  /'
      issues=$((issues + 1))
    fi
  fi

  # Check 3: Time headers (H3) format
  local h3_count=$(grep -c "^### " "$JOURNAL_FILE")
  if [ $h3_count -eq 0 ] && [ $h2_count -gt 0 ]; then
    echo -e "${COLOR_WARNING}[!] Day entries found but no time entries${COLOR_RESET}"
    warnings=$((warnings + 1))
  elif [ $h3_count -gt 0 ]; then
    echo -e "${COLOR_SUCCESS}[✓] Found $h3_count time entries${COLOR_RESET}"

    # Check H3 format (should be HH:MM)
    local bad_h3=$(grep "^### " "$JOURNAL_FILE" | grep -v "^### [0-9][0-9]:[0-9][0-9]")
    if [ -n "$bad_h3" ]; then
      echo -e "${COLOR_ERROR}[✗] Malformed time headers found:${COLOR_RESET}"
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
    echo -e "${COLOR_ERROR}[✗] Time entries without day headers:${COLOR_RESET}"
    echo "$orphaned_h3" | head -3 | sed 's/^/  /'
    issues=$((issues + 1))
  fi

  # Check 5: User content headers (H4, H5) - informational only
  local h4_count=$(grep -c "^#### " "$JOURNAL_FILE")
  local h5_count=$(grep -c "^##### " "$JOURNAL_FILE")

  if [ $h4_count -gt 0 ] || [ $h5_count -gt 0 ]; then
    echo -e "${COLOR_INFO}[i] User content headers found:${COLOR_RESET}"
    [ $h4_count -gt 0 ] && echo "  H4 sections: $h4_count"
    [ $h5_count -gt 0 ] && echo "  H5 subsections: $h5_count"
    echo "  (These enhance content organization - no issues)"
  fi

  # Check 6: File size and entry distribution
  local file_size=$(wc -c <"$JOURNAL_FILE" 2>/dev/null || echo 0)
  local file_size_kb=$((file_size / 1024))

  if [ $file_size_kb -gt 500 ]; then
    echo -e "${COLOR_WARNING}[!] Large journal file (${file_size_kb}KB)${COLOR_RESET}"
    echo "  Consider archiving old entries for better performance"
    warnings=$((warnings + 1))
  fi

  # Summary
  echo
  if [ $issues -eq 0 ] && [ $warnings -eq 0 ]; then
    echo -e "${COLOR_SUCCESS}[✓] Journal structure is perfect!${COLOR_RESET}"
  elif [ $issues -eq 0 ]; then
    echo -e "${COLOR_WARNING}[✓] Structure is valid with $warnings minor warnings${COLOR_RESET}"
  else
    echo -e "${COLOR_ERROR}[✗] Found $issues structural issues and $warnings warnings${COLOR_RESET}"
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

  # Compact header
  echo -e "${COLOR_HEADER_PRIMARY}▐ JOURNAL ▌${COLOR_RESET}"

  # Compact menu with hotkey highlighting
  echo -e "${COLOR_HOTKEY}N${COLOR_RESET}ew Entry    ${COLOR_HOTKEY}R${COLOR_RESET}ead (Glow)    Recent En${COLOR_HOTKEY}T${COLOR_RESET}ries"
  echo -e "${COLOR_HOTKEY}S${COLOR_RESET}earch       ${COLOR_HOTKEY}O${COLOR_RESET}pen Editor    ${COLOR_HOTKEY}C${COLOR_RESET}heck Structure"
  echo -e "${COLOR_HOTKEY}Q${COLOR_RESET}uit to Menu"
  echo
  echo -ne "${COLOR_PROMPT}Selection: ${COLOR_RESET}"
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
