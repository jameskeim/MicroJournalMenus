#!/bin/bash
# sysinfo.sh - Display system information and wait for keypress
# Save as ~/.microjournal/scripts/sysinfo.sh

clear
echo "Loading system information..."
echo

# Run neofetch
neofetch

read -n 1 -s
clear
