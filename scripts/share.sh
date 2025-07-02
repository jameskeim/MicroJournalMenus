#!/bin/bash
# share.sh - File sharing web server for MICRO JOURNAL 2000
# HARMONIZATION PASS 3: COMPLETED - Full compliance: Added styling, status messages, improved UX

MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"

# Load standardized styling systems
source "$MCRJRNL/scripts/colors.sh"

clear
echo -e "${COLOR_HEADER_PRIMARY}▐ SHARE FILES ▌${COLOR_RESET}"
echo

# Function to run when Ctrl + C (SIGINT) is detected
cleanup() {
    echo
    echo -e "${COLOR_WARNING}Stopping file server...${COLOR_RESET}"
    echo -e "${COLOR_INFO}Disabling NetworkManager.service...${COLOR_RESET}"
    sudo systemctl stop NetworkManager.service
    echo -e "${COLOR_SUCCESS}[✓] NetworkManager.service disabled.${COLOR_RESET}"
    exit 0
}

# Trap Ctrl + C (SIGINT) and call the cleanup function
trap cleanup SIGINT

echo -e "${COLOR_INFO}Starting NetworkManager.service...${COLOR_RESET}"
sudo systemctl start NetworkManager.service
echo -e "${COLOR_SUCCESS}[✓] Network enabled${COLOR_RESET}"
echo
echo -e "${COLOR_SUCCESS}File server starting on port 8080${COLOR_RESET}"
echo -e "${COLOR_INFO}Access files at: http://$(hostname -I | awk '{print $1}'):8080${COLOR_RESET}"
echo -e "${COLOR_WARNING}Press Ctrl+C to stop server and disable networking${COLOR_RESET}"
echo

# Start the file browser, suppressing output
filebrowser -r ~/Documents -a 0.0.0.0 --noauth -d ~/file.db > /dev/null 2>&1

# Wait indefinitely until Ctrl + C is pressed
while true; do
    sleep 1
done
