#!/usr/bin/env bash
# Terminal Velocity style notes manager for MICRO JOURNAL 2000

NOTES_DIR="$HOME/Documents/notes"
EDITOR="${EDITOR:-nvim}"

# Ensure notes directory exists
mkdir -p "$NOTES_DIR"

clear

# Terminal Velocity: if fzf available, use it for instant search/create
if command -v fzf >/dev/null 2>&1; then
  cd "$NOTES_DIR" || exit 1
  
  # Find all .md files, maximize fzf screen usage
  selected=$(find . -name "*.md" -type f 2>/dev/null | \
    sed 's|^\./||' | \
    sed 's|\.md$||' | \
    fzf --height=100% \
        --reverse \
        --no-border \
        --prompt="Search or create note: " \
        --print-query \
        --preview='if [ -f "{}.md" ]; then head -10 "{}.md"; else echo "New note: {}"; fi' \
        --preview-window="right:50%:wrap" | \
    tail -1)
  
  # Return to original directory
  cd - >/dev/null
  
  if [ -n "$selected" ]; then
    note_file="$NOTES_DIR/${selected}.md"
    
    if [ -f "$note_file" ]; then
      # Open existing note
      "$EDITOR" "$note_file"
    else
      # Create new note (Terminal Velocity style)
      # Clean the selected text for title
      note_title=$(echo "$selected" | sed 's/_/ /g' | sed 's/\b\w/\U&/g')
      
      # Create note with clean header
      {
        echo "# $note_title"
        echo ""
        echo "*Created: $(date '+%Y-%m-%d %H:%M')*"
        echo ""
      } > "$note_file"
      
      echo "Created new note: $selected"
      sleep 1
      "$EDITOR" "$note_file"
    fi
  else
    echo "No selection made"
  fi
  
else
  # Fallback if fzf not available
  echo -e "\033[196mfzf not found - install for full Terminal Velocity experience\033[0m"
  echo
  echo "Available notes:"
  find "$NOTES_DIR" -name "*.md" -type f 2>/dev/null | \
    sed 's|.*/||' | \
    sed 's|\.md$||' | \
    sort | \
    nl -w2 -s') '
  
  echo
  printf "Enter note number or new note name: "
  read -r selection
  
  if [[ "$selection" =~ ^[0-9]+$ ]]; then
    # Number selection
    note_name=$(find "$NOTES_DIR" -name "*.md" -type f 2>/dev/null | \
      sed 's|.*/||' | \
      sed 's|\.md$||' | \
      sort | \
      sed -n "${selection}p")
    note_file="$NOTES_DIR/${note_name}.md"
  else
    # Name selection/creation
    clean_name=$(echo "$selection" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
    note_file="$NOTES_DIR/${clean_name}.md"
    
    if [ ! -f "$note_file" ]; then
      # Create new note
      note_title=$(echo "$selection" | sed 's/_/ /g' | sed 's/\b\w/\U&/g')
      {
        echo "# $note_title"
        echo ""
        echo "*Created: $(date '+%Y-%m-%d %H:%M')*"
        echo ""
      } > "$note_file"
      echo "Created new note: $clean_name"
    fi
  fi
  
  if [ -f "$note_file" ]; then
    "$EDITOR" "$note_file"
  else
    echo "Note not found: $selection"
    sleep 2
  fi
fi