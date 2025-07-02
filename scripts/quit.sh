#!/usr/bin/env bash
# quit.sh - Power management options for MICRO JOURNAL 2000
# Combines shutdown and reboot functionality
# HARMONIZATION PASS 1: COMPLETED - Full compliance: prompt styling fixed

# Use portable installation directory
MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"

# Load standardized styling systems
source "$MCRJRNL/scripts/colors.sh"
source "$MCRJRNL/scripts/gum-styles.sh"

clear
echo
gum_header_primary "*** MICRO JOURNAL 2000 ***"
gum_header_secondary "Quit Options"
echo

# Create the quit menu
echo "Select an option:"
echo
gum style --foreground 196 --bold "S) Shutdown System - Power off completely"
gum style --foreground 33 --bold "R) Reboot System - Restart system"
echo
printf '%b' "${COLOR_PROMPT}Selection: ${COLOR_RESET}"
read -n 1 -s CHOICE
echo "$CHOICE"
echo

case "${CHOICE,,}" in  # Convert to lowercase
  s)
    echo
    gum style --foreground 196 --bold "Shutdown System" 
    echo
    gum style --foreground 196 "Warning: This will turn off the system."
    echo
    
    if gum_confirm_danger "Are you sure you want to shutdown?"; then
      echo
      gum style --foreground 220 "Syncing filesystems..."
      sudo sync
      gum style --foreground 220 "Shutting down system..."
      sleep 2
      sudo shutdown -h now
    else
      echo
      gum style --foreground 46 "Shutdown cancelled."
      sleep 1
    fi
    ;;
    
  r)
    echo
    gum style --foreground 33 --bold "Reboot System"
    echo
    gum style --foreground 196 "Warning: This will restart the system."
    echo
    
    if gum_confirm_danger "Are you sure you want to reboot?"; then
      echo
      gum style --foreground 220 "Syncing filesystems..."
      sudo sync
      gum style --foreground 220 "Rebooting system..."
      sleep 2
      sudo reboot
    else
      echo
      gum style --foreground 46 "Reboot cancelled."
      sleep 1
    fi
    ;;
    
  *)
    echo
    gum style --foreground 196 "Invalid selection. Returning to menu..."
    sleep 1
    ;;
esac