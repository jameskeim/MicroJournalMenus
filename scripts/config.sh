#!/bin/bash
# config.sh - Raspberry Pi Configuration Tool
# HARMONIZATION PASS 1: COMPLETED - Simple wrapper, minimal styling added

MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"

# Load standardized styling systems
source "$MCRJRNL/scripts/colors.sh"

clear
echo -e "${COLOR_HEADER_PRIMARY}▐ PI CONFIG ▌${COLOR_RESET}"
echo

sudo systemctl start NetworkManager.service
sudo raspi-config
sudo systemctl stop NetworkManager.service
