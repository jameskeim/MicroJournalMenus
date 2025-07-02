#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# SIMPLE WRITING PROMPT GENERATOR - OPTIMIZED FOR 98x12 DISPLAY
# ═══════════════════════════════════════════════════════════════════════════════
# HARMONIZATION PASS 1: COMPLETED - Full compliance: ANSI→COLOR_, emoji removal, system integration
#
# Ultra-lightweight writing prompt system using simple text files
# Perfect for MICRO JOURNAL 2000 PAUSE menu - inspiring breaks between writing sessions

# Load standardized styling systems (preserving elegant look)
MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"
source "$MCRJRNL/scripts/colors.sh"
source "$MCRJRNL/scripts/gum-styles.sh"

# Handle Ctrl-C gracefully
trap 'echo; echo "Exiting..."; exit 0' SIGINT

PROMPTS_DIR="$HOME/.microjournal/prompts"
CUSTOM_PROMPTS="$PROMPTS_DIR/custom.txt"
COLORS="off" # Set to "on" for color output

# Colors handled by standardized COLOR_ system - removed legacy ANSI codes

# ═══════════════════════════════════════════════════════════════════════════════
# BUILT-IN PROMPT LIBRARY (No external files needed!)
# ═══════════════════════════════════════════════════════════════════════════════

# Pre-loaded prompts - feel free to modify this array
BUILTIN_PROMPTS=(
  "Write about a color that doesn't exist yet."
  "Describe your morning routine from your coffee mug's perspective."
  "A character finds a door in their house that wasn't there yesterday."
  "Write a conversation between two people who speak different languages."
  "Describe the last day on Earth, but focus only on small details."
  "A librarian discovers that one book changes its contents each night."
  "Write about someone who collects something unusual."
  "Describe a meal that tastes like a memory."
  "A person wakes up with a skill they've never learned."
  "Write about the smell of rain from a plant's perspective."
  "Someone finds a letter addressed to them from 10 years in the future."
  "Describe a city where it's always 3 PM on a Tuesday."
  "A character can only speak in questions for an entire day."
  "Write about a music box that plays a song no one has heard before."
  "Someone discovers their reflection is one second behind."
  "Describe a conversation between the sun and the moon."
  "A person inherits a house that's bigger on the inside."
  "Write about someone who remembers everyone's dreams but their own."
  "A character finds a key that opens something unexpected."
  "Describe the first day of spring from winter's perspective."
  "Someone can taste colors - what does blue taste like?"
  "Write about a clock that runs backwards for one hour each day."
  "A character wakes up speaking a language they don't recognize."
  "Describe a photograph that shows something different each time you look."
  "Someone discovers they can edit their past by crossing out diary entries."
  "Write about a tree that grows words instead of leaves."
  "A person finds their childhood imaginary friend waiting in their office."
  "Describe a rain that falls upward."
  "Someone receives mail for a person who doesn't exist."
  "Write about a library where books read themselves to visitors."
  "A character's shadow starts acting independently."
  "Describe a world where gravity works differently on Wednesdays."
  "Someone can hear the thoughts of inanimate objects."
  "Write about a painter whose paintings change when no one is looking."
  "A person discovers their dreams are someone else's memories."
  "Describe a telephone that only receives calls from the past."
  "Someone wakes up in a world where everyone has the same face."
  "Write about a garden where each plant grows a different emotion."
  "A character finds a map of places that don't exist."
  "Describe the last bookstore in a world without reading."
)

# ═══════════════════════════════════════════════════════════════════════════════
# CORE FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Initialize custom prompts file if it doesn't exist
init_custom_prompts() {
  mkdir -p "$PROMPTS_DIR"
  if [ ! -f "$CUSTOM_PROMPTS" ]; then
    cat >"$CUSTOM_PROMPTS" <<'EOF'
# Custom Writing Prompts
# One prompt per line. Lines starting with # are ignored.
# Add your own prompts below:

Write about your most vivid childhood memory, but change one impossible detail.
Describe the perfect day that you've never had.
EOF
  fi
}

# Get all available prompts (built-in + custom)
get_all_prompts() {
  # Start with built-in prompts
  printf '%s\n' "${BUILTIN_PROMPTS[@]}"

  # Add custom prompts if file exists
  if [ -f "$CUSTOM_PROMPTS" ]; then
    # Filter out comments and empty lines
    grep -v '^#' "$CUSTOM_PROMPTS" | grep -v '^[[:space:]]*$'
  fi
}

# Display a random prompt
show_random_prompt() {
  local prompts_array=()

  # Read all prompts into array
  while IFS= read -r prompt; do
    [ -n "$prompt" ] && prompts_array+=("$prompt")
  done < <(get_all_prompts)

  # Check if we have any prompts
  if [ ${#prompts_array[@]} -eq 0 ]; then
    echo "No prompts available. Something went wrong!"
    return 1
  fi

  # Select random prompt
  local random_index=$((RANDOM % ${#prompts_array[@]}))
  local selected_prompt="${prompts_array[$random_index]}"

  # Clean display optimized for 12-line constraint
  clear
  
  # Display centered prompt with elegant gum styling (keep the beautiful light purple!)
  echo "$selected_prompt" | gum style --foreground "$GUM_PROMPT" --align center --width 98 --margin "3 0"
  
  echo
  
  # Simple choice using high-contrast gum confirm
  if gum_confirm_normal "Another prompt?"; then
    return 0  # Get another prompt (continues the loop in main menu)
  else
    return 1  # Go back to main menu
  fi
}

# Add a custom prompt
add_prompt() {
  clear
  
  # Use gum input for clean prompt entry
  new_prompt=$(gum input --placeholder "Enter your writing prompt..." --width 98)

  if [ -n "$new_prompt" ]; then
    # Add prompt to custom file
    echo "$new_prompt" >>"$CUSTOM_PROMPTS"
    gum_success "Prompt added successfully!"
    sleep 1
  fi
}

# Show statistics
show_stats() {
  clear
  
  local builtin_count=${#BUILTIN_PROMPTS[@]}
  local custom_count=0

  if [ -f "$CUSTOM_PROMPTS" ]; then
    custom_count=$(grep -v '^#' "$CUSTOM_PROMPTS" | grep -v '^[[:space:]]*$' | wc -l)
  fi

  local total_count=$((builtin_count + custom_count))

  # Humorous writing quotes
  local writing_quotes=(
    "I love deadlines. I like the whooshing sound they make as they fly by. - Douglas Adams"
    "Writing is easy. All you do is stare at a blank sheet of paper until drops of blood form on your forehead. - Gene Fowler"
    "I write one page of masterpiece to ninety-one pages of shit. I try to put the shit in the wastebasket. - Ernest Hemingway"
    "The first draft of anything is shit. - Ernest Hemingway"
    "There's nothing to writing. All you do is sit down at a typewriter and open a vein. - Walter Wellesley Smith"
    "Writing is the only profession where no one considers you ridiculous if you earn no money. - Jules Renard"
    "I can fix a bad page. I can't fix a blank page. - Nora Roberts"
    "Either write something worth reading or do something worth writing. - Benjamin Franklin"
    "Writing without revising is the literary equivalent of waltzing gaily out of the house in your underwear. - Patricia Fuller"
    "The difference between the right word and the almost right word is the difference between lightning and a lightning bug. - Mark Twain"
    "I am not a writer. I am someone who writes. - Karl Ove Knausgård"
    "Writing is a socially acceptable form of schizophrenia. - E.L. Doctorow"
  )

  # Select random quote
  local random_quote="${writing_quotes[$((RANDOM % ${#writing_quotes[@]}))]}"

  # Display with standardized COLOR_ system
  printf "${COLOR_HEADER_PRIMARY}Prompt Library Statistics${COLOR_RESET}\n\n"
  printf "Built-in prompts: ${COLOR_SUCCESS}%d${COLOR_RESET}\n" "$builtin_count"
  printf "Custom prompts:   ${COLOR_SUCCESS}%d${COLOR_RESET}\n" "$custom_count"
  printf "Total prompts:    ${COLOR_WARNING}%d${COLOR_RESET}\n" "$total_count"
  echo
  echo "$random_quote" | fold -s -w 90
  echo
  read -p "Press Enter to continue..."
}

# Browse all prompts with pager (useful for inspiration)
browse_prompts() {
  local all_prompts=()
  local prompt_num=1
  
  # Collect all prompts into array
  for prompt in "${BUILTIN_PROMPTS[@]}"; do
    all_prompts+=("$prompt_num. $prompt")
    ((prompt_num++))
  done
  
  # Add custom prompts if any
  if [ -f "$CUSTOM_PROMPTS" ]; then
    while IFS= read -r prompt; do
      if [ -n "$prompt" ]; then
        all_prompts+=("$prompt_num. $prompt")
        ((prompt_num++))
      fi
    done < <(grep -v '^#' "$CUSTOM_PROMPTS" | grep -v '^[[:space:]]*$')
  fi
  
  # Simple pager variables
  local current_line=0
  local lines_per_page=9  # Leave room for header and footer
  local total_lines=${#all_prompts[@]}
  local max_start=$((total_lines - lines_per_page))
  
  while true; do
    clear
    printf "${COLOR_HEADER_PRIMARY}Browse Prompts (%d total)${COLOR_RESET}\n\n" "$total_lines"
    
    # Show current page of prompts
    local end_line=$((current_line + lines_per_page))
    [ $end_line -gt $total_lines ] && end_line=$total_lines
    
    for ((i=current_line; i<end_line; i++)); do
      echo "${all_prompts[$i]}"
    done
    
    # Show navigation help
    echo
    printf "${COLOR_DIM}↑/↓ Line • ←/→ Page • Q Quit • %d/%d${COLOR_RESET}" \
           "$end_line" "$total_lines"
    
    # Get user input
    read -n 1 -s key
    case "$key" in
      'q'|'Q') break ;;
      # QA-EXEMPT: ANSI escape for arrow key detection, not display styling
      $'\033') # Arrow key sequence
        read -n 2 -s -t 0.1 arrow
        case "$arrow" in
          '[A') # Up arrow (line up)
            [ $current_line -gt 0 ] && current_line=$((current_line - 1))
            ;;
          '[B') # Down arrow (line down)
            [ $current_line -lt $max_start ] && current_line=$((current_line + 1))
            ;;
          '[C') # Right arrow (page down)
            current_line=$((current_line + lines_per_page))
            [ $current_line -gt $max_start ] && current_line=$max_start
            ;;
          '[D') # Left arrow (page up)
            current_line=$((current_line - lines_per_page))
            [ $current_line -lt 0 ] && current_line=0
            ;;
        esac
        ;;
    esac
  done
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN MENU SYSTEM
# ═══════════════════════════════════════════════════════════════════════════════

# Simple menu interface
show_menu() {
  clear
  
  # Display title with ANSI (fast)
  printf "${COLOR_HEADER_PRIMARY}Writing Prompt Generator${COLOR_RESET}\n\n"
  
  echo "What would you like to do?"
  echo
  echo "  R) Random prompt"
  echo "  A) Add prompt" 
  echo "  B) Browse all"
  echo "  S) Statistics"
  echo "  Q) Quit"
  echo
  printf '%b' "${COLOR_PROMPT}Selection: ${COLOR_RESET}"
}

# Main program loop
main() {
  # Clear screen and initialize system
  clear
  init_custom_prompts

  # If arguments provided, handle them
  case "${1:-menu}" in
  "random" | "r")
    show_random_prompt
    echo
    read -p "Press Enter to continue..."
    ;;
  "add" | "a")
    add_prompt
    ;;
  "browse" | "b")
    browse_prompts
    ;;
  "stats" | "s")
    show_stats
    ;;
  *)
    # Interactive menu mode
    while true; do
      show_menu
      read -n 1 -s choice
      echo

      case "${choice,,}" in
      "r")
        # Keep showing prompts until user chooses to return to menu
        while show_random_prompt; do
          : # Continue loop if return code is 0
        done
        ;;
      "a")
        add_prompt
        ;;
      "b")
        browse_prompts
        ;;
      "s")
        show_stats
        ;;
      "q")
        printf "${COLOR_SUCCESS}Happy writing!${COLOR_RESET}\n"
        exit 0
        ;;
      *)
        echo "Invalid choice. Try again."
        sleep 1
        ;;
      esac
    done
    ;;
  esac
}

# ═══════════════════════════════════════════════════════════════════════════════
# USAGE EXAMPLES
# ═══════════════════════════════════════════════════════════════════════════════

# Quick usage for PAUSE menu:
#   prompts.sh random    # Show random prompt and exit
#   prompts.sh          # Interactive menu mode

# Integration with other scripts:
#   PROMPT=$(prompts.sh random 2>/dev/null | grep -A1 "Your prompt:" | tail -1)

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  main "$@"
fi
