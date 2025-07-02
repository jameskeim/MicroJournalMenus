#!/usr/bin/env bash
# notes-explorer.sh - Compact Notes Knowledge Management
# Optimized for 98x12 display
# HARMONIZATION PASS 1: COMPLETED - Full compliance: styling systems, prompts, emoji removal

NOTES_DIR="$HOME/Documents/notes"
MCRJRNL_DIR="${MCRJRNL:-$HOME/.microjournal}"

# Load standardized styling systems
source "$MCRJRNL_DIR/scripts/colors.sh"
source "$MCRJRNL_DIR/scripts/gum-styles.sh"

# Ensure notes directory exists
mkdir -p "$NOTES_DIR"

# Function to show paginated output
show_paged() {
  local content="$1"
  local lines_count=$(echo "$content" | wc -l)

  if [ "$lines_count" -le 8 ]; then
    # Fits on screen, show directly
    echo "$content"
  else
    # Use simple pagination
    echo "$content" | head -8
    echo
    printf "Showing 8 of $lines_count lines. Press Enter to see more, q to quit: "
    read -r response
    if [ "$response" != "q" ]; then
      echo "$content" | tail -n +9
    fi
  fi
}

# Main menu loop
while true; do
  clear
  echo -e "${COLOR_HEADER_PRIMARY}▐ EXPLORE NOTES ▌${COLOR_RESET}"
  echo

  # Compact menu - fits in 12 lines
  echo "T) Browse Tags      L) Link Explorer    S) Search Content"
  echo "O) Orphan Notes     N) Note Stats       Q) Quit to Main Menu"
  echo

  printf '%b' "${COLOR_PROMPT}Selection: ${COLOR_RESET}"
  read -n 1 -s choice
  choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
  echo "$choice"
  echo

  case "$choice" in
  't')
    clear
    # Use FZF to browse and select tags
    if command -v fzf >/dev/null 2>&1; then
      # Get unique tags from all notes
      all_tags=$(grep -roh '#[a-zA-Z0-9_-]\+' "$NOTES_DIR" --include="*.md" 2>/dev/null |
        grep -v '^[^:]*:[[:space:]]*#+[[:space:]]' |
        sort | uniq)

      if [ -n "$all_tags" ]; then
        selected_tag=$(echo "$all_tags" |
          fzf --height=100% \
            --layout=reverse \
            --border=none \
            --info=inline \
            --prompt="Browse tags - Select to find notes > " \
            --preview="grep -r -l '{}' '$NOTES_DIR' --include='*.md' 2>/dev/null | head -10 | xargs -I {} sh -c 'echo \"=== {} ===\"; head -3 \"{}\"' 2>/dev/null" \
            --preview-window="right:60%:wrap" \
            --header="Browse Tags - Select a tag to see related notes" \
            --bind="tab:toggle-preview" \
            --color="fg:7,bg:0,hl:3,fg+:15,bg+:8,hl+:11,prompt:46,pointer:5,header:208")

        if [ -n "$selected_tag" ]; then
          clear
          gum style --foreground 46 --bold "Notes with tag: $selected_tag"
          echo
          # Find all notes containing this tag
          tagged_files=$(grep -r -l "$selected_tag" "$NOTES_DIR" --include="*.md" 2>/dev/null)
          if [ -n "$tagged_files" ]; then
            echo "$tagged_files" | while read -r file; do
              echo "  $(basename "$file" .md)"
            done
          else
            echo "No notes found with tag $selected_tag"
          fi
          echo
          printf "Press any key to continue..."
          read -n 1 -s
        fi
      else
        gum style --foreground 196 "No tags found in notes"
        echo
        printf "Press any key to continue..."
        read -n 1 -s
      fi
    else
      # Fallback without FZF
      gum style --foreground 46 --bold "Browse Tags"
      echo
      tags_output=$(~/.microjournal/scripts/notes.sh tags)
      show_paged "$tags_output"
      echo
      printf "Press any key to continue..."
      read -n 1 -s
    fi
    ;;

  'l')
    clear
    # Use FZF to select a note file for link exploration
    if command -v fzf >/dev/null 2>&1; then
      # Get list of markdown files with full paths
      selected_file=$(find "$NOTES_DIR" -name "*.md" -type f 2>/dev/null |
        sort -t/ -k9 |
        fzf --height=100% \
          --layout=reverse \
          --border=none \
          --info=inline \
          --prompt="Select note to explore links > " \
          --preview="head -20 {}" \
          --preview-window="right:50%:wrap" \
          --header="Link Explorer - Select a note to see its connections" \
          --bind="tab:toggle-preview" \
          --color="fg:7,bg:0,hl:3,fg+:15,bg+:8,hl+:11,prompt:33,pointer:5,header:208")

      if [ -n "$selected_file" ]; then
        note_name=$(basename "$selected_file" .md)
        clear
        gum style --foreground 33 --bold "Link Explorer: $note_name"
        echo
        links_output=$(~/.microjournal/scripts/notes.sh links "$note_name" 2>/dev/null)
        if [ -n "$links_output" ]; then
          show_paged "$links_output"
        else
          gum style --foreground 196 "No links found in '$note_name'"
        fi
        echo
        printf "Press any key to continue..."
        read -n 1 -s
      fi
    else
      # Fallback to original method if FZF not available
      gum style --foreground 33 --bold "Link Explorer"
      echo
      printf "Note name: "
      read -r note_name

      if [ -n "$note_name" ]; then
        echo
        links_output=$(~/.microjournal/scripts/notes.sh links "$note_name" 2>/dev/null)
        if [ -n "$links_output" ]; then
          show_paged "$links_output"
        else
          gum style --foreground 196 "Note '$note_name' not found"
        fi
      fi
      echo
      printf "Press any key to continue..."
      read -n 1 -s
    fi
    ;;

  's')
    clear
    gum style --foreground 46 --bold "Search Content"
    echo
    printf "Search term: "
    read -r search_term

    if [ -n "$search_term" ] && command -v fzf >/dev/null 2>&1; then
      # Use FZF to select from search results
      search_results=$(~/.microjournal/scripts/notes.sh grep "$search_term" 2>/dev/null)
      if [ -n "$search_results" ]; then
        selected_file=$(echo "$search_results" |
          fzf --height=100% \
            --layout=reverse \
            --border=none \
            --info=inline \
            --prompt="Search results for '$search_term' > " \
            --preview="grep -n -C 3 -i '$search_term' {} || echo 'Preview not available'" \
            --preview-window="right:60%:wrap" \
            --header="Search Content - Select file to view matches" \
            --bind="tab:toggle-preview" \
            --color="fg:7,bg:0,hl:3,fg+:15,bg+:8,hl+:11,prompt:46,pointer:5,header:208")

        if [ -n "$selected_file" ]; then
          clear
          gum style --foreground 46 --bold "Content matches in: $(basename "$selected_file")"
          echo
          # Show context around matches
          if command -v rg >/dev/null 2>&1; then
            rg -n -C 2 -i "$search_term" "$selected_file" || echo "No matches found"
          else
            grep -n -C 2 -i "$search_term" "$selected_file" || echo "No matches found"
          fi
          echo
          printf "Press any key to continue..."
          read -n 1 -s
        fi
      else
        gum style --foreground 196 "No matches found for '$search_term'"
        echo
        printf "Press any key to continue..."
        read -n 1 -s
      fi
    elif [ -n "$search_term" ]; then
      # Fallback without FZF
      echo
      search_output=$(~/.microjournal/scripts/notes.sh grep "$search_term" 2>/dev/null)
      if [ -n "$search_output" ]; then
        show_paged "$search_output"
      else
        gum style --foreground 196 "No matches found for '$search_term'"
      fi
      echo
      printf "Press any key to continue..."
      read -n 1 -s
    fi
    ;;

  'o')
    clear
    gum style --foreground 33 --bold "Orphan Notes"
    gum style --foreground 220 "Notes with no WikiLinks in/out"
    echo

    orphan_files=()
    for note_file in "$NOTES_DIR"/*.md; do
      if [ -f "$note_file" ]; then
        note_name=$(basename "$note_file" .md)

        # Check for outgoing links
        outgoing=$(grep -c '\[\[[^]]\+\]\]' "$note_file" 2>/dev/null || echo 0)

        # Check for incoming links
        link_text=$(echo "$note_name" | tr '_' ' ')
        if command -v rg >/dev/null 2>&1; then
          incoming=$(rg -c "\[\[$link_text\]\]" "$NOTES_DIR" --type md 2>/dev/null | grep -v "$note_file" | wc -l)
        else
          incoming=$(grep -c "\[\[$link_text\]\]" "$NOTES_DIR"/*.md 2>/dev/null | grep -v "$note_file" | wc -l)
        fi

        if [ "$outgoing" -eq 0 ] && [ "$incoming" -eq 0 ]; then
          orphan_files+=("$note_file")
        fi
      fi
    done

    if [ ${#orphan_files[@]} -gt 0 ] && command -v fzf >/dev/null 2>&1; then
      selected_file=$(printf '%s\n' "${orphan_files[@]}" |
        fzf --height=100% \
          --layout=reverse \
          --border=none \
          --info=inline \
          --prompt="Orphan notes - Select to view > " \
          --preview="head -15 {} 2>/dev/null || echo 'Preview not available'" \
          --preview-window="right:50%:wrap" \
          --header="Orphan Notes - Notes with no connections (${#orphan_files[@]} found)" \
          --bind="tab:toggle-preview" \
          --color="fg:7,bg:0,hl:3,fg+:15,bg+:8,hl+:11,prompt:33,pointer:5,header:196")

      if [ -n "$selected_file" ]; then
        clear
        gum style --foreground 33 --bold "Orphan Note: $(basename "$selected_file")"
        gum style --foreground 220 "This note has no incoming or outgoing links"
        echo
        head -20 "$selected_file"
        echo
        printf "Press any key to continue..."
        read -n 1 -s
      fi
    elif [ ${#orphan_files[@]} -gt 0 ]; then
      # Fallback without FZF
      orphan_output=$(printf '  %s\n' $(basename -s .md "${orphan_files[@]}"))
      show_paged "$orphan_output"
      echo
      gum style --foreground 196 "Found ${#orphan_files[@]} orphaned notes"
      echo
      printf "Press any key to continue..."
      read -n 1 -s
    else
      gum style --foreground 46 "All notes are connected!"
      echo
      printf "Press any key to continue..."
      read -n 1 -s
    fi
    ;;

  'n')
    clear
    gum style --foreground 208 --bold "Note Statistics"
    echo

    total_notes=$(find "$NOTES_DIR" -name "*.md" -type f 2>/dev/null | wc -l)

    # Count template types
    char_notes=$(find "$NOTES_DIR" -name "*_CHARACTER.md" -type f 2>/dev/null | wc -l)
    scene_notes=$(find "$NOTES_DIR" -name "*_SCENE.md" -type f 2>/dev/null | wc -l)
    plot_notes=$(find "$NOTES_DIR" -name "*_PLOT.md" -type f 2>/dev/null | wc -l)
    world_notes=$(find "$NOTES_DIR" -name "*_WORLDBUILDING.md" -type f 2>/dev/null | wc -l)

    template_total=$((char_notes + scene_notes + plot_notes + world_notes))
    free_form=$((total_notes - template_total))

    # Count tags
    total_tags=$(grep -roh '#[a-zA-Z0-9_-]\+' "$NOTES_DIR" --include="*.md" 2>/dev/null |
      grep -v '^[^:]*:[[:space:]]*#+[[:space:]]' |
      sort | uniq | wc -l)

    echo "Total Notes: $total_notes"
    echo "Tags: $total_tags unique"
    echo
    echo "Templates:"
    [ "$char_notes" -gt 0 ] && echo "  Characters: $char_notes"
    [ "$scene_notes" -gt 0 ] && echo "  Scenes: $scene_notes"
    [ "$plot_notes" -gt 0 ] && echo "  Plots: $plot_notes"
    [ "$world_notes" -gt 0 ] && echo "  Worldbuilding: $world_notes"
    echo "  Free-form: $free_form"

    echo
    printf "Press any key to continue..."
    read -n 1 -s
    ;;

  'q')
    break
    ;;

  *)
    gum style --foreground 196 "Invalid choice. Try again..."
    sleep 1
    ;;
  esac
done

