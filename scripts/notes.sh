#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# 98x12 DISPLAY OPTIMIZATION FOR MICROJOURNAL VELOCITY
# ═══════════════════════════════════════════════════════════════════════════════
#
# This configuration is specifically optimized for a 98-column by 12-line display
# Every vertical line is precious - we maximize information density while
# maintaining usability.

# Load standardized styling systems
MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"
source "$MCRJRNL/scripts/colors.sh"
source "$MCRJRNL/scripts/gum-styles.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# DISPLAY CONSTRAINTS ANALYSIS
# ═══════════════════════════════════════════════════════════════════════════════

# Total available space: 98 columns × 12 lines
DISPLAY_WIDTH=98
DISPLAY_HEIGHT=12

# Space allocation:
# Lines 1-12: Full fzf interface       (12 lines maximum)
# fzf handles its own layout with prompt, file list, and preview

USABLE_HEIGHT=12 # Maximum lines for fzf content (full screen)

# ═══════════════════════════════════════════════════════════════════════════════
# ULTRA-COMPACT MARKDOWN NOTES INTERFACE
# ═══════════════════════════════════════════════════════════════════════════════

NOTES_DIR="$HOME/Documents/notes"
EDITOR="${EDITOR:-nvim}"

# Optimized fzf settings for 98-character display
FZF_OPTS=(
  --height="$USABLE_HEIGHT"      # Use only available vertical space
  --layout=reverse               # Put prompt at top (more natural)
  --border=none                  # No borders (save 2 lines!)
  --info=hidden                  # Hide info line (save 1 line!)
  --prompt=">"                   # Minimal prompt (save columns)
  --preview-window="right:40%:wrap"  # Show preview (40% of 98 chars = ~39 chars)
  --bind="tab:toggle-preview"    # Toggle preview with Tab
  --no-mouse                     # Keyboard only for speed
  --color="fg:7,bg:0,hl:3,fg+:15,bg+:8,hl+:11,prompt:2,pointer:5"
)

# Ultra-compact file listing format
format_files_compact() {
  # Format: [icon] filename_truncated size date
  while read -r filepath; do
    if [ -f "$filepath" ]; then
      local name="${filepath#$NOTES_DIR/}"
      local size=$(stat -c%s "$filepath" 2>/dev/null || echo "0")
      local date=$(stat -c%y "$filepath" 2>/dev/null | cut -d' ' -f1 | cut -d'-' -f2-3)

      # All files are markdown
      local icon="[MD]"

      # Truncate filename to fit: icon(4) + name(70) + size(6) + date(6) + spaces(12) = 98
      if [ ${#name} -gt 70 ]; then
        name="${name:0:67}..."
      fi

      # Size formatting (compact)
      local size_fmt
      if [ "$size" -gt 1048576 ]; then
        size_fmt="$(($size / 1048576))M"
      elif [ "$size" -gt 1024 ]; then
        size_fmt="$(($size / 1024))K"
      else
        size_fmt="${size}b"
      fi

      printf "%s %-70s %5s %s\n" "$icon" "$name" "$size_fmt" "$date"
    fi
  done
}

# ═══════════════════════════════════════════════════════════════════════════════
# OPTIMIZED SEARCH FUNCTIONS (using ripgrep + fd)
# ═══════════════════════════════════════════════════════════════════════════════

# Lightning-fast file discovery with fd (sorted by recent modification)
find_notes() {
  if command -v fd >/dev/null 2>&1; then
    # fd is 3-5x faster than find, sort by modification time
    fd -t f -e md . "$NOTES_DIR" --max-depth 5 -x ls -t {} + 2>/dev/null
  else
    # fallback: find and sort by modification time (recent first)
    find "$NOTES_DIR" -type f -name "*.md" -maxdepth 5 2>/dev/null | xargs ls -t 2>/dev/null
  fi
}

# Blazing-fast content search with ripgrep
search_content() {
  local term="$1"
  if [ -z "$term" ]; then
    find_notes
    return
  fi

  {
    # Filename search (fd with pattern)
    if command -v fd >/dev/null 2>&1; then
      fd -t f "$term" "$NOTES_DIR" --max-depth 5 -i
    fi

    # Content search (ripgrep is 5-10x faster than grep)
    if command -v rg >/dev/null 2>&1; then
      rg -l -i "$term" "$NOTES_DIR" --type md
    else
      grep -r -l -i "$term" "$NOTES_DIR" --include="*.md" 2>/dev/null
    fi
  } | sort -u | xargs ls -t 2>/dev/null
}

# ═══════════════════════════════════════════════════════════════════════════════
# INSTANT NOTE CREATION (Terminal Velocity Style)
# ═══════════════════════════════════════════════════════════════════════════════

instant_create_note() {
  local note_title="$1"

  # Clean up the note title for filename
  local clean_title=$(echo "$note_title" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
  local new_path="$NOTES_DIR/${clean_title}.md"

  # Create proper title from input (restore spaces, capitalize)
  local display_title=$(echo "$note_title" | sed 's/_/ /g' | sed 's/\b\w/\U&/g')

  # Check if templates exist and offer selection
  if [ -d "$TEMPLATES_DIR" ] && [ "$(ls -A "$TEMPLATES_DIR"/*.md 2>/dev/null)" ]; then
    echo
    echo "Creating new note: \"$display_title\""
    echo
    
    # Build template options with smart key assignment
    local template_options=""
    local used_keys=""
    local key_map=""
    
    for template in "$TEMPLATES_DIR"/*.md; do
      if [ -f "$template" ]; then
        local name=$(basename "$template" .md)
        local key=""
        
        # Try each letter in the template name
        for (( i=0; i<${#name}; i++ )); do
          local char=$(echo "${name:$i:1}" | tr '[:upper:]' '[:lower:]')
          if [[ "$char" =~ [a-z] ]] && [[ "$used_keys" != *"$char"* ]]; then
            key="$char"
            used_keys="$used_keys$char"
            break
          fi
        done
        
        # Fallback to numbers if no letters available
        if [ -z "$key" ]; then
          for num in {1..9}; do
            if [[ "$used_keys" != *"$num"* ]]; then
              key="$num"
              used_keys="$used_keys$num"
              break
            fi
          done
        fi
        
        # Build display string with highlighted key
        if [ -n "$key" ]; then
          # Find position of key in name for highlighting
          local display_name=""
          local key_found=false
          for (( i=0; i<${#name}; i++ )); do
            local char="${name:$i:1}"
            if [ "$key_found" = false ] && [ "$(echo "$char" | tr '[:upper:]' '[:lower:]')" = "$key" ]; then
              display_name="$display_name[$char]"
              key_found=true
            else
              display_name="$display_name$char"
            fi
          done
          
          # If key wasn't found in name (number fallback), show it differently
          if [ "$key_found" = false ]; then
            display_name="[$key]$name"
          fi
          
          template_options="$template_options $display_name"
          key_map="$key_map$key:$name "
        fi
      fi
    done
    
    echo "Templates:$template_options [Enter] none"
    echo
    printf "Template (or Enter for blank): "
    read -n 1 -s template_choice
    echo "$template_choice"
    
    # Process template choice
    if [ -n "$template_choice" ] && [ "$template_choice" != $'\n' ]; then
      # Find matching template
      local selected_template=""
      for mapping in $key_map; do
        local map_key=$(echo "$mapping" | cut -d: -f1)
        local map_name=$(echo "$mapping" | cut -d: -f2)
        if [ "$template_choice" = "$map_key" ]; then
          selected_template="$map_name"
          break
        fi
      done
      
      if [ -n "$selected_template" ] && [ -f "$TEMPLATES_DIR/${selected_template}.md" ]; then
        echo
        echo "Creating from template: $selected_template"
        
        # Smart append template name with CAPS
        local template_upper=$(echo "$selected_template" | tr '[:lower:]' '[:upper:]')
        local note_lower=$(echo "$note_title" | tr '[:upper:]' '[:lower:]')
        local template_lower=$(echo "$selected_template" | tr '[:upper:]' '[:lower:]')
        
        # Check if template name already exists in note title
        if [[ "$note_lower" != *"$template_lower"* ]]; then
          # Append template name in CAPS
          clean_title="${clean_title}_${template_upper}"
          new_path="$NOTES_DIR/${clean_title}.md"
        fi
        
        process_template "$TEMPLATES_DIR/${selected_template}.md" "$note_title" "$new_path"
        "$EDITOR" "$new_path"
        return
      fi
    fi
  fi

  # Create blank note (default behavior)
  {
    echo "# $display_title"
    echo ""
    echo "*Created: $(date '+%Y-%m-%d %H:%M')*"
    echo ""
  } >"$new_path"

  # Open in editor
  "$EDITOR" "$new_path"
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN INTERFACE - OPTIMIZED FOR 98x12
# ═══════════════════════════════════════════════════════════════════════════════

notes_compact() {
  local search_term="$*"
  mkdir -p "$NOTES_DIR"

  # Clear screen and launch fzf directly
  clear

  # Check if fzf is available and we're in a tty, fall back to simple interface
  if ! command -v fzf >/dev/null 2>&1 || ! [ -t 0 ]; then
    if ! command -v fzf >/dev/null 2>&1; then
      gum_error "fzf not found, using simple interface"
    else
      gum_info "Not in terminal mode, using simple interface"
    fi
    sleep 1
    notes_list "$search_term"
    return
  fi

  # Use compact fzf interface with new file creation option
  local fzf_result=$(search_content "$search_term" |
    format_files_compact |
    fzf "${FZF_OPTS[@]}" \
      --query="$search_term" \
      --print-query \
      --expect="ctrl-n" \
      --header="Enter: open • Ctrl+N: new file • TAB: toggle preview" \
      --preview="filename=\$(echo {} | awk '{print \$2}'); head -10 \"$NOTES_DIR/\$filename\" 2>/dev/null || echo \"Preview not available for: \$filename\"")
  
  local key=$(echo "$fzf_result" | sed -n '1p')
  local query=$(echo "$fzf_result" | sed -n '2p') 
  local selected=$(echo "$fzf_result" | sed -n '3p')

  # Handle fzf results based on key pressed and selection
  if [ "$key" = "ctrl-n" ]; then
    # User pressed Ctrl+N - force new file creation with query
    instant_create_note "$query"
  elif [ -n "$selected" ]; then
    # User pressed Enter on a selected file
    local filename=$(echo "$selected" | awk '{print $2}')
    local filepath="$NOTES_DIR/$filename"

    if [ -f "$filepath" ]; then
      # Open existing file
      "$EDITOR" "$filepath"
    else
      # Selected item doesn't exist - create new note instantly
      instant_create_note "$selected"
    fi
  elif [ -n "$query" ]; then
    # User pressed Enter with no selection - create new note with query
    instant_create_note "$query"
  fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# ALTERNATIVE: NO-FZF COMPACT INTERFACE
# ═══════════════════════════════════════════════════════════════════════════════

notes_list() {
  local search_term="$*"
  mkdir -p "$NOTES_DIR"

  clear
  printf "${COLOR_HEADER_PRIMARY}Notes Manager${COLOR_RESET}\n\n"

  if [ -n "$search_term" ]; then
    # Search mode - show matches in 7 lines max
    local matches=$(search_content "$search_term")
    if [ -n "$matches" ]; then
      echo "Search results for: '$search_term'"
      echo "$matches" | format_files_compact | head -7 | nl -w2 -s' '
      echo
      read -p "Select # or Enter for new note: " choice
    else
      gum style --foreground 196 "No matches found for '$search_term'"
      gum style --foreground 46 "Creating new note..."
      instant_create_note "$search_term"
      return
    fi
  else
    # Browse mode - show recent files in 7 lines max
    echo "Recent notes:"
    find_notes | format_files_compact | head -7 | nl -w2 -s' '
    echo
    read -p "Select # or type new note name: " choice
  fi

  # Handle selection
  if [ "$choice" -eq "$choice" ] 2>/dev/null; then
    # Number selected
    local files_array=()
    if [ -n "$search_term" ]; then
      while IFS= read -r line; do
        files_array+=("$line")
      done <<<"$matches"
    else
      while IFS= read -r line; do
        files_array+=("$line")
      done <<<"$(find_notes)"
    fi

    local selected_file="${files_array[$((choice - 1))]}"
    [ -f "$selected_file" ] && "$EDITOR" "$selected_file"
  elif [ -n "$choice" ]; then
    # Create new note instantly
    instant_create_note "$choice"
  fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# DISPLAY-AWARE MENU INTEGRATION
# ═══════════════════════════════════════════════════════════════════════════════

# Your main menu should account for the 98x12 constraint
# Column widths: 19 chars each × 5 columns = 95 chars (fits in 98)
# Height: 10 lines for menu + 2 for headers = 12 lines total

# Example optimized menu layout:
display_menu() {
  clear
  # Header (1 line)
  printf "%-98s\n" "$(tput bold)MicroJournal 2000 - Writer's Interface$(tput sgr0)"

  # Menu columns (10 lines)
  printf "%-19s %-19s %-19s %-19s %-19s\n" \
    "$(tput setaf 2)DRAFTING$(tput sgr0)" \
    "$(tput setaf 6)REVIEW$(tput sgr0)" \
    "$(tput setaf 3)SHARING$(tput sgr0)" \
    "$(tput setaf 5)SYSTEM$(tput sgr0)" \
    "$(tput setaf 1)EXTRAS$(tput sgr0)"

  printf "%-19s %-19s %-19s %-19s %-19s\n" \
    "M:Markdown" \
    "N:Notes" \
    "S:Share Files" \
    "U:Up Network" \
    "T:Time Clock"

  printf "%-19s %-19s %-19s %-19s %-19s\n" \
    "W:Wordgrinder" \
    "O:Outliner" \
    "E:Export" \
    "D:Down Network" \
    "X:Matrix"

  # ... continue for remaining menu items

  # Prompt (1 line)
  printf "\n%-42s" ""
  printf "$(tput setaf 3)Selection: $(tput sgr0)"
}

# ═══════════════════════════════════════════════════════════════════════════════
# PERFORMANCE OPTIMIZATIONS FOR PI ZERO 2W
# ═══════════════════════════════════════════════════════════════════════════════

# Cache frequently accessed data
cache_notes_list() {
  local cache_file="/tmp/notes_cache_$$"
  find_notes | format_files_compact >"$cache_file"
  echo "$cache_file"
}

# Background file indexing (optional)
index_notes_background() {
  if command -v rg >/dev/null 2>&1; then
    # Build search index in background
    nohup rg --files "$NOTES_DIR" >/tmp/notes_index 2>/dev/null &
  fi
}

# Memory-efficient processing (stream instead of loading all)
stream_search() {
  local term="$1"
  search_content "$term" | while read -r file; do
    format_files_compact <<<"$file"
  done | head -7 # Only show first 7 results to fit display
}

# ═══════════════════════════════════════════════════════════════════════════════
# USAGE EXAMPLES FOR 98x12 DISPLAY
# ═══════════════════════════════════════════════════════════════════════════════

# Quick note creation:
# notes_compact "story idea"
#
# Quick search:
# notes_compact "character"
#
# Browse recent:
# notes_compact
#
# The interface will show:
# > [search term]                                                          <- Line 1
# [MD] recent_note.md                                          2K 06-25    <- Line 2
# [MD] story_ideas.md                                          1K 06-24    <- Line 3
# [MD] character_notes.md                                      5K 06-23    <- Line 4
# [MD] plot_outline.md                                         3K 06-22    <- Line 5
# [MD] research.md                                             8K 06-21    <- Line 6
# [MD] daily_journal.md                                        1K 06-20    <- Line 7
# [MD] meeting_notes.md                                        2K 06-19    <- Line 8
# [MD] chapter_draft.md                                       15K 06-18    <- Line 9
# [2/47]                                                                    <- Line 10
# > [cursor here for input]                                                <- Line 11
#                                                                           <- Line 12

# Tips for 98x12 usage:
# - Use TAB to toggle preview when needed
# - Keep note names concise for better display
# - All notes are markdown - perfect for writers
# - Vertical space is precious - minimize prompts
# - Horizontal space is adequate - use full width

# ═══════════════════════════════════════════════════════════════════════════════
# TEMPLATE SYSTEM FOR WRITERS
# ═══════════════════════════════════════════════════════════════════════════════

# Get the microjournal installation directory for templates
MCRJRNL_DIR="${MCRJRNL:-$HOME/.microjournal}"
TEMPLATES_DIR="$MCRJRNL_DIR/templates"

# Ensure templates directory exists
mkdir -p "$TEMPLATES_DIR"

# List available templates
list_templates() {
  echo "Available templates:"
  echo
  if [ -d "$TEMPLATES_DIR" ] && [ "$(ls -A "$TEMPLATES_DIR" 2>/dev/null)" ]; then
    for template in "$TEMPLATES_DIR"/*.md; do
      if [ -f "$template" ]; then
        local name=$(basename "$template" .md)
        local description=$(grep -m 1 "^#" "$template" 2>/dev/null | sed 's/^# *//' | sed 's/{{[^}]*}}//g' | tr -d '\n')
        if [ -z "$description" ]; then
          description="Template for $name"
        fi
        printf "  %-15s %s\n" "$name" "$description"
      fi
    done
  else
    echo "  No templates found in $TEMPLATES_DIR"
    echo "  Templates can be created as .md files in that directory"
  fi
}

# Process template variables
process_template() {
  local template_file="$1"
  local note_name="$2"
  local output_file="$3"

  if [ ! -f "$template_file" ]; then
    echo "Error: Template file not found: $template_file"
    return 1
  fi

  # Copy template to output
  cp "$template_file" "$output_file"

  # Basic variable substitutions
  local current_date=$(date '+%Y-%m-%d %H:%M')
  local clean_name=$(echo "$note_name" | sed 's/_/ /g' | sed 's/\b\w/\U&/g')

  # Prompt for common template variables
  echo "Creating note from template..."
  echo "Press Enter to skip any variable, or provide a value:"
  echo

  # Common variables that might be in templates
  local vars_found=$(grep -oh '{{[^}]*}}' "$template_file" | sort -u)

  # Replace standard variables first
  sed -i "s/{{DATE}}/$current_date/g" "$output_file"

  # Create temp file to capture variables during the loop
  local temp_vars="/tmp/notes_vars_$$"
  echo "$vars_found" >"$temp_vars"

  # Process each variable (read from temp file, not stdin)
  while IFS= read -r var; do
    if [ -n "$var" ]; then
      local var_name=$(echo "$var" | sed 's/{{//g' | sed 's/}}//g')
      case "$var_name" in
      "DATE")
        # Already handled
        ;;
      "CHARACTER_NAME" | "TITLE" | "SCENE_NAME" | "WORLD_NAME" | "PROJECT_NAME" | "CURRENT_PROJECT")
        printf "Enter %s [%s]: " "$var_name" "$clean_name"
        read -r value
        if [ -z "$value" ]; then
          value="$clean_name"
        fi
        sed -i "s|$var|$value|g" "$output_file"
        ;;
      "PROJECT")
        printf "Enter project name [default]: "
        read -r project
        if [ -z "$project" ]; then
          project="default"
        fi
        sed -i "s/{{PROJECT}}/$project/g" "$output_file"
        ;;
      *)
        printf "Enter %s: " "$var_name"
        read -r value
        if [ -n "$value" ]; then
          sed -i "s|$var|$value|g" "$output_file"
        fi
        ;;
      esac
    fi
  done <"$temp_vars"

  rm -f "$temp_vars"

  # Clean up any remaining template variables with empty values
  sed -i 's/{{[^}]*}}//g' "$output_file"
}

# ═══════════════════════════════════════════════════════════════════════════════
# WIKI-STYLE LINKING SYSTEM
# ═══════════════════════════════════════════════════════════════════════════════

# Extract all [[wiki links]] from a note
extract_wiki_links() {
  local note_file="$1"
  if [ ! -f "$note_file" ]; then
    return 1
  fi

  # Find all [[link]] patterns and extract just the link text
  grep -oh '\[\[[^]]\+\]\]' "$note_file" 2>/dev/null | sed 's/\[\[\(.*\)\]\]/\1/' | sort -u
}

# Find notes that contain links to a specific note
find_backlinks() {
  local target_note="$1"
  if [ -z "$target_note" ]; then
    return 1
  fi

  # Remove .md extension if present for cleaner matching
  local clean_target=$(basename "$target_note" .md)

  # Convert underscores to spaces for link matching (wiki links use spaces)
  local link_text=$(echo "$clean_target" | tr '_' ' ')

  # Search for [[target_note]] in all notes (try both formats)
  local results=""
  if command -v rg >/dev/null 2>&1; then
    results=$(rg -l "\[\[$link_text\]\]" "$NOTES_DIR" --type md 2>/dev/null)
    if [ -z "$results" ]; then
      results=$(rg -l "\[\[$clean_target\]\]" "$NOTES_DIR" --type md 2>/dev/null)
    fi
  else
    results=$(grep -rl "\[\[$link_text\]\]" "$NOTES_DIR" --include="*.md" 2>/dev/null)
    if [ -z "$results" ]; then
      results=$(grep -rl "\[\[$clean_target\]\]" "$NOTES_DIR" --include="*.md" 2>/dev/null)
    fi
  fi

  echo "$results"
}

# Convert wiki link to actual file path
resolve_wiki_link() {
  local link_text="$1"

  # Clean the link text - convert to filename format
  local clean_link=$(echo "$link_text" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
  local link_file="$NOTES_DIR/${clean_link}.md"

  # Check if file exists
  if [ -f "$link_file" ]; then
    echo "$link_file"
    return 0
  fi

  # Try to find similar files (case-insensitive partial match)
  local matches=$(find_notes | grep -i "$clean_link" | head -3)
  if [ -n "$matches" ]; then
    echo "$matches" | head -1
    return 0
  fi

  # File doesn't exist - return the expected path for creation
  echo "$link_file"
  return 1
}

# ═══════════════════════════════════════════════════════════════════════════════
# UNIX-STYLE COMMANDS FOR POWER USERS
# ═══════════════════════════════════════════════════════════════════════════════

notes_grep() {
  local pattern="$*"
  if [ -z "$pattern" ]; then
    echo "Usage: notes.sh grep PATTERN"
    echo "       notes.sh grep #tag          # Search for hashtag"
    echo "       notes.sh grep 'word1 AND word2'  # Multiple words"
    echo "Search for PATTERN in note content"
    return 1
  fi

  mkdir -p "$NOTES_DIR"

  # Handle special search patterns
  if [[ "$pattern" == "#"* ]]; then
    # Tag search - exclude markdown headings
    echo "Searching for tag: '$pattern'"
    echo
    
    # Simple approach: search for the pattern but exclude markdown heading lines
    if command -v rg >/dev/null 2>&1; then
      # Use ripgrep but exclude heading lines
      rg -i --context 1 --color always "$pattern" "$NOTES_DIR" --type md | \
        grep -v '^[^:]*:[[:space:]]*#+[[:space:]]'
    else
      # Grep fallback - search for pattern but exclude markdown heading lines
      grep -r -i --context=1 --color=always "$pattern" "$NOTES_DIR" --include="*.md" 2>/dev/null | \
        grep -v '^[^:]*:[[:space:]]*#+[[:space:]]'
    fi
  elif [[ "$pattern" == *" AND "* ]]; then
    # Multi-word AND search
    echo "Searching for: '$pattern' (all words must be present)"
    echo
    local words=($(echo "$pattern" | sed 's/ AND / /g'))
    local temp_files=""

    # Find files containing first word
    if command -v rg >/dev/null 2>&1; then
      temp_files=$(rg -l -i "${words[0]}" "$NOTES_DIR" --type md 2>/dev/null)
    else
      temp_files=$(grep -rl -i "${words[0]}" "$NOTES_DIR" --include="*.md" 2>/dev/null)
    fi

    # Filter by subsequent words
    for word in "${words[@]:1}"; do
      if [ -n "$temp_files" ]; then
        temp_files=$(echo "$temp_files" | xargs grep -l -i "$word" 2>/dev/null)
      fi
    done

    # Show results with context
    if [ -n "$temp_files" ]; then
      echo "$temp_files" | while read -r file; do
        echo "=== $(basename "$file" .md) ==="
        grep -i --color=always -C 1 "${words[0]}" "$file" 2>/dev/null
        echo
      done
    else
      echo "No notes found containing all specified words."
    fi
  else
    # Regular search
    echo "Searching for: '$pattern'"
    echo
    if command -v rg >/dev/null 2>&1; then
      rg -i --context 2 --color always "$pattern" "$NOTES_DIR" --type md
    else
      grep -r -i --context=2 --color=always "$pattern" "$NOTES_DIR" --include="*.md" 2>/dev/null
    fi
  fi
}

notes_mv() {
  local old_name="$1"
  local new_name="$2"

  if [ -z "$old_name" ] || [ -z "$new_name" ]; then
    echo "Usage: notes.sh mv OLD_NAME NEW_NAME"
    echo "Rename a note from OLD_NAME to NEW_NAME"
    return 1
  fi

  mkdir -p "$NOTES_DIR"

  # Find the old file (handle with/without .md extension)
  local old_file=""
  if [ -f "$NOTES_DIR/${old_name}.md" ]; then
    old_file="$NOTES_DIR/${old_name}.md"
  elif [ -f "$NOTES_DIR/${old_name}" ]; then
    old_file="$NOTES_DIR/${old_name}"
  else
    echo "Error: Note '$old_name' not found"
    echo "Available notes:"
    find_notes | sed "s|$NOTES_DIR/||" | sed 's/\.md$//' | head -5
    return 1
  fi

  # Clean new name and ensure .md extension
  local clean_new=$(echo "$new_name" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
  local new_file="$NOTES_DIR/${clean_new}.md"

  if [ -f "$new_file" ]; then
    echo "Error: Note '$clean_new' already exists"
    return 1
  fi

  mv "$old_file" "$new_file"
  echo "Renamed: $(basename "$old_file" .md) → $clean_new"
}

notes_append() {
  local note_name="$1"

  if [ -z "$note_name" ]; then
    echo "Usage: notes.sh append NOTE_NAME"
    echo "Add content to an existing note"
    echo "Content can be provided via stdin or will be prompted"
    return 1
  fi

  mkdir -p "$NOTES_DIR"

  # Find the note file
  local note_file=""
  if [ -f "$NOTES_DIR/${note_name}.md" ]; then
    note_file="$NOTES_DIR/${note_name}.md"
  elif [ -f "$NOTES_DIR/${note_name}" ]; then
    note_file="$NOTES_DIR/${note_name}"
  else
    echo "Error: Note '$note_name' not found"
    echo "Available notes:"
    find_notes | sed "s|$NOTES_DIR/||" | sed 's/\.md$//' | head -5
    return 1
  fi

  echo "Appending to: $(basename "$note_file" .md)"
  echo

  # Check if content is coming from stdin
  if [ ! -t 0 ]; then
    # Read from stdin
    echo "" >>"$note_file"
    echo "*Added: $(date '+%Y-%m-%d %H:%M')*" >>"$note_file"
    echo "" >>"$note_file"
    cat >>"$note_file"
    echo "Content appended from stdin"
  else
    # Interactive mode
    echo "Enter content (Ctrl+D when finished):"
    echo "" >>"$note_file"
    echo "*Added: $(date '+%Y-%m-%d %H:%M')*" >>"$note_file"
    echo "" >>"$note_file"
    cat >>"$note_file"
    echo "Content appended to note"
  fi
}

notes_tags() {
  mkdir -p "$NOTES_DIR"
  echo "Tags found in notes:"
  echo

  # Extract hashtags while excluding markdown headings
  # Strategy: Find lines that are NOT markdown headings, then extract hashtags
  local tags=""
  
  # First, get all lines that don't start with markdown heading syntax
  local non_heading_lines=$(grep -r --include="*.md" -v '^[[:space:]]*#+[[:space:]]' "$NOTES_DIR" 2>/dev/null)
  
  if [ -n "$non_heading_lines" ]; then
    # Extract hashtags from non-heading lines
    tags=$(echo "$non_heading_lines" | grep -oh '#[a-zA-Z0-9_-]\+' | sort | uniq)
  fi

  if [ -n "$tags" ]; then
    # Count occurrences
    echo "$tags" | while read -r tag; do
      if [ -n "$tag" ]; then
        count=$(echo "$non_heading_lines" | grep -o "$tag" | wc -l)
        printf "%7d %s\n" "$count" "$tag"
      fi
    done | sort -nr
  else
    echo "No hashtags found in notes"
  fi
}

notes_links() {
  local note_name="$1"

  if [ -z "$note_name" ]; then
    echo "Usage: notes.sh links NOTE_NAME"
    echo "Show all [[wiki links]] in a note and notes that link to it"
    return 1
  fi

  mkdir -p "$NOTES_DIR"

  # Find the note file
  local note_file=""
  if [ -f "$NOTES_DIR/${note_name}.md" ]; then
    note_file="$NOTES_DIR/${note_name}.md"
  elif [ -f "$NOTES_DIR/${note_name}" ]; then
    note_file="$NOTES_DIR/${note_name}"
  else
    echo "Error: Note '$note_name' not found"
    return 1
  fi

  echo "=== Links in $(basename "$note_file" .md) ==="
  echo

  # Show outgoing links
  local outgoing_links=$(extract_wiki_links "$note_file")
  if [ -n "$outgoing_links" ]; then
    echo "Links to other notes:"
    echo "$outgoing_links" | while read -r link; do
      local target_file=$(resolve_wiki_link "$link")
      if [ -f "$target_file" ]; then
        echo "  → [[$link]] (exists)"
      else
        echo "  → [[$link]] (missing)"
      fi
    done
  else
    echo "No outgoing links found"
  fi

  echo

  # Show incoming links (backlinks)
  local backlinks=$(find_backlinks "$(basename "$note_file" .md)")
  if [ -n "$backlinks" ]; then
    echo "Referenced by:"
    echo "$backlinks" | while read -r referring_file; do
      echo "  ← $(basename "$referring_file" .md)"
    done
  else
    echo "No backlinks found"
  fi
}

notes_recent() {
  local tag_filter="$1"

  mkdir -p "$NOTES_DIR"

  if [ -n "$tag_filter" ]; then
    # Filter by tag
    echo "Recent notes tagged with '$tag_filter':"
    echo

    local tagged_files=""
    if command -v rg >/dev/null 2>&1; then
      tagged_files=$(rg -l "$tag_filter" "$NOTES_DIR" --type md 2>/dev/null)
    else
      tagged_files=$(grep -rl "$tag_filter" "$NOTES_DIR" --include="*.md" 2>/dev/null)
    fi

    if [ -n "$tagged_files" ]; then
      # Sort by modification time and format
      echo "$tagged_files" | xargs ls -t | head -10 | while read -r file; do
        local basename_clean=$(basename "$file" .md)
        local mod_date=$(stat -c %y "$file" 2>/dev/null | cut -d' ' -f1)
        echo "  $mod_date  $basename_clean"
      done
    else
      echo "No notes found with tag '$tag_filter'"
    fi
  else
    # Show recent notes
    echo "Recent notes (last 10):"
    echo
    find_notes | head -10 | while read -r file; do
      local basename_clean=$(basename "$file" .md)
      local mod_date=$(stat -c %y "$file" 2>/dev/null | cut -d' ' -f1)
      echo "  $mod_date  $basename_clean"
    done
  fi
}

notes_template() {
  local command="$1"
  shift

  case "$command" in
  "list" | "ls" | "")
    list_templates
    ;;
  *)
    echo "Usage: notes.sh template [list]"
    echo "       notes.sh new NOTE_NAME --template TEMPLATE_NAME"
    echo ""
    echo "Available commands:"
    echo "  list      Show available templates"
    echo ""
    echo "To create from template:"
    echo "  notes.sh new 'Character Name' --template character"
    ;;
  esac
}

notes_new() {
  local note_name=""
  local template_name=""
  local use_template=false

  # Parse arguments
  while [ $# -gt 0 ]; do
    case "$1" in
    --template | -t)
      use_template=true
      template_name="$2"
      shift 2
      ;;
    *)
      if [ -z "$note_name" ]; then
        note_name="$1"
      fi
      shift
      ;;
    esac
  done

  if [ -z "$note_name" ]; then
    echo "Usage: notes.sh new NOTE_NAME [--template TEMPLATE_NAME]"
    echo ""
    echo "Examples:"
    echo "  notes.sh new 'Story Ideas'              # Create blank note"
    echo "  notes.sh new 'Hero' --template character # Create from template"
    echo ""
    echo "Available templates:"
    list_templates | grep "^  " || echo "  No templates available"
    return 1
  fi

  mkdir -p "$NOTES_DIR"

  # Clean note name for filename
  local clean_name=$(echo "$note_name" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
  local note_file="$NOTES_DIR/${clean_name}.md"

  if [ -f "$note_file" ]; then
    echo "Error: Note '$clean_name' already exists"
    return 1
  fi

  if [ "$use_template" = true ]; then
    if [ -z "$template_name" ]; then
      echo "Error: Template name required when using --template flag"
      return 1
    fi

    local template_file="$TEMPLATES_DIR/${template_name}.md"
    if [ ! -f "$template_file" ]; then
      echo "Error: Template '$template_name' not found"
      echo ""
      echo "Available templates:"
      list_templates
      return 1
    fi

    # Create note from template
    process_template "$template_file" "$note_name" "$note_file"
    echo ""
    echo "Created note '$clean_name' from template '$template_name'"

  else
    # Create basic note using instant_create_note function
    instant_create_note "$note_name"
    return
  fi

  # Open the new note in editor
  "$EDITOR" "$note_file"
}

# ═══════════════════════════════════════════════════════════════════════════════
# COMMAND-LINE INTERFACE (Unix-style commands)
# ═══════════════════════════════════════════════════════════════════════════════

notes_help() {
  cat <<'HELP'
NOTES - Terminal Velocity style note-taking with wiki links & templates

USAGE:
  notes.sh [COMMAND] [ARGS...]

COMMANDS:
  [no command]      Launch interactive note browser/search
  new NOTE_NAME     Create new note (optionally from template)
  grep PATTERN      Search note content (supports #tags and 'word1 AND word2')
  mv OLD NEW        Rename note from OLD to NEW  
  append NOTE       Add content to existing note (from stdin or prompt)
  tags              List all hashtags found in notes
  links NOTE        Show [[wiki links]] in note and backlinks to it
  recent [TAG]      Show recent notes, optionally filtered by tag
  template [list]   List available templates or show template help
  help              Show this help message

TEMPLATES:
  Create structured notes for common writing tasks
  Available: character, plot, scene, worldbuilding, project, journal

WIKI LINKS:
  Use [[note name]] to link between notes
  Links automatically resolve to existing notes or create new ones

EXAMPLES:
  notes.sh                                    # Interactive mode
  notes.sh character ideas                    # Search for "character ideas"
  notes.sh new "Hero" --template character    # Create character from template
  notes.sh new "Chapter 1" --template scene   # Create scene from template
  notes.sh template list                      # List available templates
  notes.sh grep "protagonist"                 # Find notes containing "protagonist"
  notes.sh grep "#character"                  # Find notes with #character tag
  notes.sh grep "magic AND system"            # Find notes with both words
  notes.sh mv "old name" "new name"           # Rename a note
  echo "New content" | notes.sh append "story outline"
  notes.sh tags                               # List all #tags
  notes.sh links "character notes"            # Show all connections for a note
  notes.sh recent "#writing"                  # Recent notes tagged #writing

NOTES are stored in: $NOTES_DIR
TEMPLATES are stored in: $TEMPLATES_DIR
HELP
}

# Parse command line arguments
  case "$1" in
  "help" | "-h" | "--help")
    notes_help
    ;;
  "grep")
    shift
    notes_grep "$@"
    ;;
  "mv")
    shift
    notes_mv "$@"
    ;;
  "append")
    shift
    notes_append "$@"
    ;;
  "tags")
    notes_tags
    ;;
  "links")
    shift
    notes_links "$@"
    ;;
  "recent")
    shift
    notes_recent "$@"
    ;;
  "template")
    shift
    notes_template "$@"
    ;;
  "new")
    shift
    notes_new "$@"
    ;;
  *)
    # Default: interactive mode with search term
    notes_compact "$@"
    ;;
  esac
