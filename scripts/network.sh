#!/bin/bash
# network.sh - Combined network management with gum menu interface
# Replaces network-enable.sh and network-disable.sh
# HARMONIZATION PASS 3: COMPLETED - Full compliance: ANSI→COLOR_, gum standardized, symbols→ASCII

MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"

# Load standardized styling systems
source "$MCRJRNL/scripts/colors.sh"
source "$MCRJRNL/scripts/gum-styles.sh"

clear

# Standard header
echo -e "${COLOR_HEADER_PRIMARY}▐ NETWORK MANAGEMENT ▌${COLOR_RESET}"
echo

# Check current network status
check_network_status() {
    local nm_status=$(systemctl is-active NetworkManager 2>/dev/null || echo "inactive")
    local ssh_status=$(systemctl is-active ssh 2>/dev/null || echo "inactive")
    
    if [[ "$nm_status" == "active" ]] && [[ "$ssh_status" == "active" ]]; then
        echo "online"
    elif [[ "$nm_status" == "inactive" ]] && [[ "$ssh_status" == "inactive" ]]; then
        echo "offline"
    else
        echo "partial"
    fi
}

# Get current status
CURRENT_STATUS=$(check_network_status)

# Display current status with color coding
case "$CURRENT_STATUS" in
    "online")
        echo -e "${COLOR_SUCCESS}Current Status: Online [✓]${COLOR_RESET}"
        echo -e "${COLOR_INFO}NetworkManager and SSH are running${COLOR_RESET}"
        ;;
    "offline")
        echo -e "${COLOR_ERROR}Current Status: Offline [✗]${COLOR_RESET}"
        echo -e "${COLOR_INFO}NetworkManager and SSH are stopped${COLOR_RESET}"
        ;;
    "partial")
        echo -e "${COLOR_WARNING}Current Status: Partial [!]${COLOR_RESET}"
        echo -e "${COLOR_INFO}Some services are running, some are not${COLOR_RESET}"
        ;;
esac

echo

# Create menu options based on current status
if [[ "$CURRENT_STATUS" == "offline" ]]; then
    CHOICE=$(gum_choose_contrast "Select network action:" "Enable Networking" "Check Status" "Exit")
elif [[ "$CURRENT_STATUS" == "online" ]]; then
    CHOICE=$(gum_choose_contrast "Select network action:" "Disable Networking" "Check Status" "Exit")
else
    CHOICE=$(gum_choose_contrast "Select network action:" "Enable Networking" "Disable Networking" "Check Status" "Exit")
fi

echo

case "$CHOICE" in
    "Enable Networking")
        echo -e "${COLOR_WARNING}Starting NetworkManager...${COLOR_RESET}"
        sudo systemctl start NetworkManager
        if [ $? -eq 0 ]; then
            echo -e "${COLOR_SUCCESS}[✓] NetworkManager started${COLOR_RESET}"
        else
            echo -e "${COLOR_ERROR}[✗] Failed to start NetworkManager${COLOR_RESET}"
        fi

        echo -e "${COLOR_WARNING}Starting SSH service...${COLOR_RESET}"
        sudo systemctl start ssh
        if [ $? -eq 0 ]; then
            echo -e "${COLOR_SUCCESS}[✓] SSH service started${COLOR_RESET}"
        else
            echo -e "${COLOR_ERROR}[✗] Failed to start SSH service${COLOR_RESET}"
        fi

        echo
        echo -e "${COLOR_SUCCESS}Networking enabled.${COLOR_RESET}"
        ;;
    
    "Disable Networking")
        # Show warning for SSH users
        if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
            echo -e "${COLOR_ERROR}[!] WARNING: You are connected via SSH!${COLOR_RESET}"
            echo -e "${COLOR_WARNING}Disabling networking will disconnect your session.${COLOR_RESET}"
            echo
            CONFIRM=$(gum_confirm_danger "Are you sure you want to continue?" "Yes, disable networking" "No, cancel")
            if [[ "$CONFIRM" != "Yes, disable networking" ]]; then
                echo -e "${COLOR_WARNING}Operation cancelled.${COLOR_RESET}"
                sleep 2
                exit 0
            fi
            echo
        fi

        echo -e "${COLOR_WARNING}Stopping SSH service...${COLOR_RESET}"
        sudo systemctl stop ssh
        if [ $? -eq 0 ]; then
            echo -e "${COLOR_SUCCESS}[✓] SSH service stopped${COLOR_RESET}"
        else
            echo -e "${COLOR_ERROR}[✗] Failed to stop SSH service${COLOR_RESET}"
        fi

        echo -e "${COLOR_WARNING}Stopping NetworkManager...${COLOR_RESET}"
        sudo systemctl stop NetworkManager
        if [ $? -eq 0 ]; then
            echo -e "${COLOR_SUCCESS}[✓] NetworkManager stopped${COLOR_RESET}"
        else
            echo -e "${COLOR_ERROR}[✗] Failed to stop NetworkManager${COLOR_RESET}"
        fi

        echo
        echo -e "${COLOR_SUCCESS}Networking disabled.${COLOR_RESET}"
        ;;
    
    "Check Status")
        echo -e "${COLOR_WARNING}Checking network services status...${COLOR_RESET}"
        echo
        
        # NetworkManager status
        NM_STATUS=$(systemctl is-active NetworkManager 2>/dev/null)
        if [[ "$NM_STATUS" == "active" ]]; then
            echo -e "${COLOR_SUCCESS}NetworkManager: Active [✓]${COLOR_RESET}"
        else
            echo -e "${COLOR_ERROR}NetworkManager: Inactive [✗]${COLOR_RESET}"
        fi
        
        # SSH status
        SSH_STATUS=$(systemctl is-active ssh 2>/dev/null)
        if [[ "$SSH_STATUS" == "active" ]]; then
            echo -e "${COLOR_SUCCESS}SSH Service: Active [✓]${COLOR_RESET}"
        else
            echo -e "${COLOR_ERROR}SSH Service: Inactive [✗]${COLOR_RESET}"
        fi
        
        # Network connectivity test (only if NetworkManager is active)
        if [[ "$NM_STATUS" == "active" ]]; then
            echo
            echo -e "${COLOR_WARNING}Testing connectivity...${COLOR_RESET}"
            if timeout 3 ping -c 1 8.8.8.8 >/dev/null 2>&1; then
                echo -e "${COLOR_SUCCESS}Internet connectivity: Available [✓]${COLOR_RESET}"
            else
                echo -e "${COLOR_WARNING}Internet connectivity: Limited or unavailable [!]${COLOR_RESET}"
            fi
        fi
        ;;
    
    "Exit"|"")
        echo -e "${COLOR_WARNING}Exiting network management.${COLOR_RESET}"
        exit 0
        ;;
esac

echo
echo -ne "${COLOR_PROMPT}Press any key to continue...${COLOR_RESET}"
read -n 1 -s