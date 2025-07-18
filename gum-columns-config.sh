#!/bin/bash
# Configurable Column Layout Menu
# Easy configuration for non-programmers - just edit the arrays below!

# ============================================================================
# EASY CONFIGURATION - Edit these arrays to customize your menu
# Format: "KEY:Display Name:Command"
# - KEY: Single letter to press (will be highlighted in color)
# - Display Name: Text shown in menu (keep under 15 characters)
# - Command: What to execute when selected
# Special: Use ":::" for empty padding lines to balance column heights
# ============================================================================

# Column Names (these appear as headers above each column)
COLUMN1_NAME="WRITING"
COLUMN2_NAME="FILING"
COLUMN3_NAME="UTILITIES"
COLUMN4_NAME="EXTRA"
COLUMN5_NAME="CONTROL"

# Column 1 Items
COL1_ITEMS=(
  "M:Markdown:./scripts/newMarkDown.sh"
  "W:Wordgrinder:./scripts/newwrdgrndr.sh"
  "N:Neovim:nvim"
  "C:Count Words:./scripts/wordcount.sh"
)

# Column 2 Items
COL2_ITEMS=(
  "F:File Manager:yazi"
  "S:Share Files:./scripts/share.sh"
  ":::" # Empty padding line
  ":::" # Empty padding line
)

# Column 3 Items
COL3_ITEMS=(
  "U:Up Network:./scripts/network-enable.sh"
  "D:Down Network:./scripts/network-disable.sh"
  "P:Pi Config:./scripts/config.sh"
  "I:System Info:./scripts/sysinfo.sh"
)

# Column 4 Items
COL4_ITEMS=(
  "T:Time Clock:tty-clock"
  "X:Matrix:neo"
  "Z:Z Shell:zsh"
  ":::" # Empty padding line
)

# Column 5 Items
COL5_ITEMS=(
  "L:Load Menu:reload"
  "R:Reboot:./scripts/reboot.sh"
  "Q:Quit:./scripts/shutdown.sh"
  ":::" # Empty padding line
)

# Column colors (you can change these numbers to different colors)
COL1_COLOR=46  # Green
COL2_COLOR=33  # Cyan
COL3_COLOR=208 # Orange
COL4_COLOR=201 # Magenta
COL5_COLOR=196 # Red

# ============================================================================
# SCRIPT LOGIC - You probably don't need to edit below this line
# ============================================================================

# Function to create a styled menu item with highlighted key
create_menu_item() {
  local item="$1"
  local color="$2"

  # Check for padding line indicator
  if [[ "$item" == ":::" ]]; then
    echo "" # Return empty line for padding
    return
  fi

  # Parse the item format "KEY:Display Name:Command"
  local key=$(echo "$item" | cut -d: -f1)
  local display=$(echo "$item" | cut -d: -f2)
  local command=$(echo "$item" | cut -d: -f3)

  # Handle empty padding entries
  if [[ -z "$key" || -z "$display" ]]; then
    echo ""
    return
  fi

  # Find where the key appears in the display name (case insensitive)
  local lower_display=$(echo "$display" | tr '[:upper:]' '[:lower:]')
  local lower_key=$(echo "$key" | tr '[:upper:]' '[:lower:]')

  # Check if key is at the beginning
  if [[ "$lower_display" == "$lower_key"* ]]; then
    # Key at start: "Markdown" -> "M" + "arkdown"
    local highlighted=$(gum style --foreground "$color" --bold "$key")
    local rest="${display:1}"
    gum join "$highlighted" "$rest"
  else
    # Key elsewhere: "System Info" -> "System " + "I" + "nfo"
    local pos=$(echo "$lower_display" | grep -b -o "$lower_key" | head -1 | cut -d: -f1)
    if [[ -n "$pos" ]]; then
      local before="${display:0:$pos}"
      local highlighted=$(gum style --foreground "$color" --bold "${display:$pos:1}")
      local after="${display:$((pos + 1))}"
      gum join "$before" "$highlighted" "$after"
    else
      # Key not found in display, just highlight the key at start
      local highlighted=$(gum style --foreground "$color" --bold "$key")
      gum join "$highlighted" "$display"
    fi
  fi
}

# Function to create a column from an array of items
create_column() {
  local -n items_ref=$1
  local color=$2
  local title="$3"
  local width=${4:-17}

  # Create styled title (centered within the column width)
  local title_styled=$(gum style --foreground "$color" --bold --align center --width $((width - 4)) "$title")

  # Build the multi-line string exactly like the working version
  local content="$title_styled"

  for item in "${items_ref[@]}"; do
    if [[ "$item" == ":::" ]]; then
      # Add literal empty line
      content="$content
"
    else
      local menu_item=$(create_menu_item "$item" "$color")
      # Add literal newline + content
      content="$content
$menu_item"
    fi
  done

  # Use the exact same approach as the working fast version
  gum style --border rounded --border-foreground "$color" --padding "0 1" --width "$width" \
    "$content"
}

# Function to generate the complete menu layout
generate_menu() {
  # Header with dark yellow side bars and cyan text on black background
  local TITLE_TEXT=$(gum style --foreground 81 --background 0 --bold --width 20 --align center "MICRO JOURNAL 2000")
  local LEFT_BAR=$(gum style --background 136 --width 39 " ")
  local RIGHT_BAR=$(gum style --background 136 --width 39 " ")
  local HEADER=$(gum join "$LEFT_BAR" "$TITLE_TEXT" "$RIGHT_BAR")

  # Create all columns
  local COL1=$(create_column COL1_ITEMS "$COL1_COLOR" "$COLUMN1_NAME")
  local COL2=$(create_column COL2_ITEMS "$COL2_COLOR" "$COLUMN2_NAME")
  local COL3=$(create_column COL3_ITEMS "$COL3_COLOR" "$COLUMN3_NAME")
  local COL4=$(create_column COL4_ITEMS "$COL4_COLOR" "$COLUMN4_NAME")
  local COL5=$(create_column COL5_ITEMS "$COL5_COLOR" "$COLUMN5_NAME")

  # Join all columns horizontally
  local COLUMNS=$(gum join "$COL1" "$COL2" "$COL3" "$COL4" "$COL5")

  # Add left margin for centering
  local COLUMNS_CENTERED=$(gum style --margin "0 0 0 1" "$COLUMNS")

  # Output the complete menu without prompt (we'll add it separately)
  gum join --vertical --align center "$HEADER" "$COLUMNS_CENTERED"
}

# Function to execute command based on key selection
execute_selection() {
  local choice="$1"
  local choice_lower=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

  # Search all item arrays for matching key
  local all_items=("${COL1_ITEMS[@]}" "${COL2_ITEMS[@]}" "${COL3_ITEMS[@]}" "${COL4_ITEMS[@]}" "${COL5_ITEMS[@]}")

  for item in "${all_items[@]}"; do
    # Skip padding entries
    if [[ "$item" == ":::" ]]; then
      continue
    fi

    local key=$(echo "$item" | cut -d: -f1)
    local key_lower=$(echo "$key" | tr '[:upper:]' '[:lower:]')
    local display=$(echo "$item" | cut -d: -f2)
    local command=$(echo "$item" | cut -d: -f3)

    # Skip empty entries
    if [[ -z "$key" ]]; then
      continue
    fi

    if [[ "$choice_lower" == "$key_lower" ]]; then
      if [[ "$command" == "reload" ]]; then
        echo -e "\nReloading menu..."
        rm -f "$CACHE_FILE"
        exec "$0"
      elif [[ "$command" == "./scripts/shutdown.sh" ]]; then
        echo -e "\nShutting down..."
        eval "$command"
        exit 0
      elif [[ "$command" == "./scripts/reboot.sh" ]]; then
        echo -e "\nRebooting..."
        eval "$command"
        exit 0
      else
        eval "$command"
      fi
      return
    fi
  done

  echo -e "\nInvalid selection: $choice"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

# Cache file for pre-computed menu (persistent across reboots)
CACHE_DIR="$HOME/.microjournal"
CACHE_FILE="$CACHE_DIR/menu_cache"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# Check if we need to regenerate cache
REGENERATE=false

# Force regeneration with -f flag
if [[ "$1" == "-f" ]]; then
  REGENERATE=true
fi

# Regenerate if cache doesn't exist
if [[ ! -f "$CACHE_FILE" ]]; then
  REGENERATE=true
fi

# Regenerate if script is newer than cache
if [[ -f "$CACHE_FILE" ]] && [[ "$0" -nt "$CACHE_FILE" ]]; then
  REGENERATE=true
fi

if [[ "$REGENERATE" == "true" ]]; then
  clear
  generate_menu >"$CACHE_FILE"
fi

# Remove force regeneration - caching should work normally now

# Main menu loop
while true; do
  # Display the cached menu instantly
  clear
  cat "$CACHE_FILE"

  # Add prompt with cursor positioning and yellow color
  echo ""
  # ANSI escape codes: \033[1;38;5;220m = bold yellow, \033[0m = reset
  # Centering: (98 - 11) / 2 = 43.5, so 44 spaces for proper centering
  printf "%*s\033[1;38;5;220mSelection: \033[0m" 44 ""
  read -n 1 -s CHOICE

  # Handle the selection
  execute_selection "$CHOICE"
done

