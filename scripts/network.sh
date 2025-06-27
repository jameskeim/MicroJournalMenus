#!/bin/bash
# network.sh - Combined network management with gum menu interface
# Replaces network-enable.sh and network-disable.sh

clear

# Header
echo -e "\033[96m*** MICRO JOURNAL 3000 ***\033[0m"
echo -e "\033[93mNetwork Management\033[0m"
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
        echo -e "\033[92mCurrent Status: Online ✓\033[0m"
        echo -e "\033[90mNetworkManager and SSH are running\033[0m"
        ;;
    "offline")
        echo -e "\033[91mCurrent Status: Offline ✗\033[0m"
        echo -e "\033[90mNetworkManager and SSH are stopped\033[0m"
        ;;
    "partial")
        echo -e "\033[93mCurrent Status: Partial ⚠\033[0m"
        echo -e "\033[90mSome services are running, some are not\033[0m"
        ;;
esac

echo

# Create menu options based on current status
if [[ "$CURRENT_STATUS" == "offline" ]]; then
    CHOICE=$(gum choose --header "Select network action:" "Enable Networking" "Check Status" "Exit")
elif [[ "$CURRENT_STATUS" == "online" ]]; then
    CHOICE=$(gum choose --header "Select network action:" "Disable Networking" "Check Status" "Exit")
else
    CHOICE=$(gum choose --header "Select network action:" "Enable Networking" "Disable Networking" "Check Status" "Exit")
fi

echo

case "$CHOICE" in
    "Enable Networking")
        echo -e "\033[93mStarting NetworkManager...\033[0m"
        sudo systemctl start NetworkManager
        if [ $? -eq 0 ]; then
            echo -e "\033[92m✓ NetworkManager started\033[0m"
        else
            echo -e "\033[91m✗ Failed to start NetworkManager\033[0m"
        fi

        echo -e "\033[93mStarting SSH service...\033[0m"
        sudo systemctl start ssh
        if [ $? -eq 0 ]; then
            echo -e "\033[92m✓ SSH service started\033[0m"
        else
            echo -e "\033[91m✗ Failed to start SSH service\033[0m"
        fi

        echo
        echo -e "\033[92mNetworking enabled.\033[0m"
        ;;
    
    "Disable Networking")
        # Show warning for SSH users
        if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
            echo -e "\033[91m⚠ WARNING: You are connected via SSH!\033[0m"
            echo -e "\033[93mDisabling networking will disconnect your session.\033[0m"
            echo
            CONFIRM=$(gum choose --header "Are you sure you want to continue?" "Yes, disable networking" "No, cancel")
            if [[ "$CONFIRM" != "Yes, disable networking" ]]; then
                echo -e "\033[93mOperation cancelled.\033[0m"
                sleep 2
                exit 0
            fi
            echo
        fi

        echo -e "\033[93mStopping SSH service...\033[0m"
        sudo systemctl stop ssh
        if [ $? -eq 0 ]; then
            echo -e "\033[92m✓ SSH service stopped\033[0m"
        else
            echo -e "\033[91m✗ Failed to stop SSH service\033[0m"
        fi

        echo -e "\033[93mStopping NetworkManager...\033[0m"
        sudo systemctl stop NetworkManager
        if [ $? -eq 0 ]; then
            echo -e "\033[92m✓ NetworkManager stopped\033[0m"
        else
            echo -e "\033[91m✗ Failed to stop NetworkManager\033[0m"
        fi

        echo
        echo -e "\033[92mNetworking disabled.\033[0m"
        ;;
    
    "Check Status")
        echo -e "\033[93mChecking network services status...\033[0m"
        echo
        
        # NetworkManager status
        NM_STATUS=$(systemctl is-active NetworkManager 2>/dev/null)
        if [[ "$NM_STATUS" == "active" ]]; then
            echo -e "\033[92mNetworkManager: Active ✓\033[0m"
        else
            echo -e "\033[91mNetworkManager: Inactive ✗\033[0m"
        fi
        
        # SSH status
        SSH_STATUS=$(systemctl is-active ssh 2>/dev/null)
        if [[ "$SSH_STATUS" == "active" ]]; then
            echo -e "\033[92mSSH Service: Active ✓\033[0m"
        else
            echo -e "\033[91mSSH Service: Inactive ✗\033[0m"
        fi
        
        # Network connectivity test (only if NetworkManager is active)
        if [[ "$NM_STATUS" == "active" ]]; then
            echo
            echo -e "\033[93mTesting connectivity...\033[0m"
            if timeout 3 ping -c 1 8.8.8.8 >/dev/null 2>&1; then
                echo -e "\033[92mInternet connectivity: Available ✓\033[0m"
            else
                echo -e "\033[93mInternet connectivity: Limited or unavailable ⚠\033[0m"
            fi
        fi
        ;;
    
    "Exit"|"")
        echo -e "\033[93mExiting network management.\033[0m"
        exit 0
        ;;
esac

echo
echo -e "\033[90mPress any key to continue...\033[0m"
read -n 1 -s