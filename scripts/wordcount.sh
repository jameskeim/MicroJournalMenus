#!/bin/bash
# wordcount.sh - Simple Word Count Tool for MICRO JOURNAL 2000
# Save as ~/.microjournal/scripts/wordcount.sh

export FZF_DEFAULT_COMMAND="fd --type f"

# Documents directory
DOCS_DIR="$HOME/Documents"

# Get today's date in YYYY.MM.DD format (matching newMarkDown.sh)
TODAY=$(date +%Y.%m.%d)

# Function to count words in a single file with readability analysis
count_file() {
  local file="$1"
  if [ -f "$file" ]; then
    words=$(wc -w <"$file")
    chars=$(wc -c <"$file")
    lines=$(wc -l <"$file")
    paragraphs=$(grep -c '^$' "$file" 2>/dev/null || echo 0)
    paragraphs=$((paragraphs + 1)) # Add 1 since empty lines separate paragraphs

    # Calculate reading time (200 words per minute)
    read_time=$((words / 200))
    if [ $read_time -eq 0 ]; then
      read_str="<1min"
    else
      read_str="~${read_time}min"
    fi

    echo -e "File: \033[93m$(basename "$file")\033[0m"
    echo "Words: $words | Characters: $chars | Lines: $lines | Paragraphs: $paragraphs | $read_str read"

    # Readability analysis using style command
    if command -v style >/dev/null 2>&1 && [ $words -gt 10 ]; then
      echo -e "\033[96mReadability Analysis:\033[0m"

      # Extract key metrics from style output
      style_output=$(style "$file" 2>/dev/null)

      # Parse the most useful metrics for compact display
      flesch=$(echo "$style_output" | grep "Flesch Index:" | sed 's/.*Flesch Index: \([0-9.]*\).*/\1/')
      grade=$(echo "$style_output" | grep "Kincaid:" | sed 's/.*Kincaid: \([0-9.]*\).*/\1/')
      avg_words=$(echo "$style_output" | grep "average length.*words" | sed 's/.*average length \([0-9.]*\) words.*/\1/')

      # Flesch reading ease interpretation
      if [ -n "$flesch" ]; then
        if (($(echo "$flesch >= 90" | bc -l))); then
          flesch_desc="very easy"
        elif (($(echo "$flesch >= 80" | bc -l))); then
          flesch_desc="easy"
        elif (($(echo "$flesch >= 70" | bc -l))); then
          flesch_desc="fairly easy"
        elif (($(echo "$flesch >= 60" | bc -l))); then
          flesch_desc="standard"
        elif (($(echo "$flesch >= 50" | bc -l))); then
          flesch_desc="fairly difficult"
        elif (($(echo "$flesch >= 30" | bc -l))); then
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

        # Find most common meaningful word (excluding common articles/prepositions)
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
    else
      if [ $words -le 10 ]; then
        echo -e "\033[93m(File too short for analysis)\033[0m"
      fi
    fi
  else
    echo -e "\033[91mFile not found: $file\033[0m"
  fi
}

# Function to count words for today (columnar format)
count_today() {
  echo -e "\033[92mToday ($TODAY):\033[0m"
  echo -e "\033[94mDATE       TIME   WC   TITLE\033[0m"

  total_words=0
  file_count=0

  # Find all markdown files from today
  for file in "$DOCS_DIR"/${TODAY}-*.md; do
    if [ -f "$file" ]; then
      words=$(wc -w <"$file")
      filename=$(basename "$file")

      # Format word count with 4 digits
      words_padded=$(printf "%04d" "$words")

      # Extract time if it's a timestamped file
      if [[ "$filename" =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{2}-[0-9]{4} ]]; then
        # Extract time portion (HHMM) right after the date
        time_part=$(echo "$filename" | sed 's/^[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}-\([0-9]\{4\}\).*/\1/' | sed 's/\(..\)\(..\)/\1:\2/')
        # Extract suffix (everything after YYYY.MM.DD-HHMM-)
        suffix=$(echo "$filename" | sed 's/^[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}-[0-9]\{4\}-*\(.*\)\.md$/\1/')
        if [ -z "$suffix" ]; then
          suffix="[untitled]"
        fi
        printf "\033[96m%s\033[0m \033[96m%s\033[0m \033[93m%s\033[0m %s\n" "$TODAY" "$time_part" "$words_padded" "$suffix"
      else
        printf "\033[96m%s %-5s\033[0m \033[93m%s\033[0m %s\n" "$TODAY" "" "$words_padded" "$filename"
      fi

      total_words=$((total_words + words))
      file_count=$((file_count + 1))
    fi
  done

  if [ $file_count -eq 0 ]; then
    echo -e "\033[91mNo writing files found for today.\033[0m"
  else
    echo
    echo -e "\033[92mTotal: $file_count files, $total_words words\033[0m"
  fi
  echo
}

# Function to show recent files (columnar format)
count_recent() {
  echo -e "\033[92mRecent Files (Last 5):\033[0m"
  echo -e "\033[94mDATE       TIME   WC   TITLE\033[0m"

  # Find last 5 markdown files, sorted by modification time
  recent_files=$(find "$DOCS_DIR" -name "*.md" -type f -printf '%T@ %p\n' | sort -nr | head -5 | cut -d' ' -f2-)

  if [ -z "$recent_files" ]; then
    echo -e "\033[91mNo markdown files found.\033[0m"
  else
    while IFS= read -r file; do
      if [ -n "$file" ]; then
        words=$(wc -w <"$file")
        filename=$(basename "$file")
        mod_date=$(stat -c %y "$file" | cut -d' ' -f1)

        # Format word count with 4 digits
        words_padded=$(printf "%04d" "$words")

        # Extract time if it's a timestamped file
        if [[ "$filename" =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{2}-[0-9]{4} ]]; then
          # Extract time portion (HHMM) right after the date
          time_part=$(echo "$filename" | sed 's/^[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}-\([0-9]\{4\}\).*/\1/' | sed 's/\(..\)\(..\)/\1:\2/')
          # Extract suffix (everything after YYYY.MM.DD-HHMM-)
          suffix=$(echo "$filename" | sed 's/^[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}-[0-9]\{4\}-*\(.*\)\.md$/\1/')
          if [ -z "$suffix" ]; then
            suffix="[untitled]"
          fi
          printf "\033[96m%s\033[0m \033[96m%s\033[0m \033[93m%s\033[0m %s\n" "$mod_date" "$time_part" "$words_padded" "$suffix"
        else
          printf "\033[96m%s %-5s\033[0m \033[93m%s\033[0m %s\n" "$mod_date" "" "$words_padded" "$filename"
        fi
      fi
    done <<<"$recent_files"
  fi
  echo
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

# Main menu loop
while true; do
  clear
  echo

  # CENTERING REQUIREMENT: Header and subheader must have identical visible character lengths
  # Current visible length: "▐▀▀▀▀▀▀▀▀▀ WORD COUNT ▀▀▀▀▀▀▀▀▀▌" = "▐▄▄▄ Writing Analysis Tools ▄▄▄▌"
  center_text "\033[91m▐▀▀▀▀▀▀▀▀▀\033[96m WORD COUNT \033[91m▀▀▀▀▀▀▀▀▀▌\033[0m"
  center_text "\033[91m▐▄▄▄\033[0m \033[93mWriting Analysis Tools\033[0m \033[91m▄▄▄▌\033[0m"
  echo

  # CENTERING REQUIREMENT: Each menu line must have identical visible character lengths for column alignment
  # Current visible length: "T - Today's Writing    F - Specific File" = "R - Recent Files       A - All Files    "
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
    # Use fzf to select file from Documents directory
    if command -v fzf >/dev/null 2>&1; then
      # Change to Documents directory and use relative paths
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

      # If just filename given, check Documents directory
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
    # Paginated compact view for all files (Note: this option handles its own screen clearing)
    echo -e "\033[92mAll Files in Documents:\033[0m"

    total_words=0
    file_count=0
    files_per_page=7
    current_page=1

    # Build array of all files with word counts
    declare -a all_files
    declare -a all_words

    for file in "$DOCS_DIR"/*.md; do
      if [ -f "$file" ]; then
        words=$(wc -w <"$file")
        filename=$(basename "$file")
        all_files+=("$filename")
        all_words+=("$words")
        total_words=$((total_words + words))
        file_count=$((file_count + 1))
      fi
    done

    if [ $file_count -eq 0 ]; then
      echo -e "\033[91mNo markdown files found.\033[0m"
    else
      total_pages=$(((file_count + files_per_page - 1) / files_per_page))

      while true; do
        clear
        echo -e "\033[92mAll Files in Documents:\033[0m Page $current_page of $total_pages"
        echo -e "\033[94mDATE       TIME   WC   TITLE\033[0m"

        # Calculate range for current page
        start_idx=$(((current_page - 1) * files_per_page))
        end_idx=$((start_idx + files_per_page - 1))
        if [ $end_idx -ge $file_count ]; then
          end_idx=$((file_count - 1))
        fi

        # Display files for current page
        for i in $(seq $start_idx $end_idx); do
          filename="${all_files[$i]}"
          words="${all_words[$i]}"

          # Format word count with 4 digits
          words_padded=$(printf "%04d" "$words")

          # Extract date and time for compact display
          if [[ "$filename" =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{2}-[0-9]{4} ]]; then
            date_part=$(echo "$filename" | cut -d'-' -f1)
            # Extract time portion (HHMM) right after the date
            time_part=$(echo "$filename" | sed 's/^[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}-\([0-9]\{4\}\).*/\1/' | sed 's/\(..\)\(..\)/\1:\2/')
            # Extract suffix (everything after YYYY.MM.DD-HHMM-)
            suffix=$(echo "$filename" | sed 's/^[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}-[0-9]\{4\}-*\(.*\)\.md$/\1/')
            if [ -z "$suffix" ]; then
              suffix="[untitled]"
            fi
            printf "\033[96m%s\033[0m \033[96m%s\033[0m \033[93m%s\033[0m %s\n" "$date_part" "$time_part" "$words_padded" "$suffix"
          else
            printf "\033[96m%-10s %-5s\033[0m \033[93m%s\033[0m %s\n" "" "" "$words_padded" "$filename"
          fi
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
    fi
    echo
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
