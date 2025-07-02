#!/bin/bash
# inspirations.sh - Display inspiring quotations using fortune and gum
# HARMONIZATION PASS 1: COMPLETED WITH FUNCTIONAL VARIATIONS - Spartan interface preserved, gum styling maintained

MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"

# Load standardized styling systems
source "$MCRJRNL/scripts/colors.sh"
source "$MCRJRNL/scripts/gum-styles.sh"

show_fortune() {
  clear
  
  # Hide cursor for clean display
  tput civis
  
  # Get art or literature quotation (under 400 characters) and center it
  fortune_text=$(fortune -n 400 art literature 2>/dev/null || fortune -s -n 300)
  
  # Display centered fortune with standardized styling - preserving spartan aesthetic
  echo "$fortune_text" | gum style --foreground 159 --align center --width 98 --padding "4 0 0 0"
}

# Main loop
while true; do
  show_fortune
  
  # Wait for single keypress
  read -n 1 -s key
  
  case "$key" in
    ' ') continue ;;  # Space bar - show another quote
    'q'|'Q') break ;; # Q - exit to menu
    $'\003') break ;; # Ctrl-C - exit to menu
    *) continue ;;    # Any other key - show another quote
  esac
done

# Restore cursor before exiting
tput cnorm
clear