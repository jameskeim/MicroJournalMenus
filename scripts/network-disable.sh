#!/bin/sh
# network-disable.sh - Disable networking and SSH services
# Save as ~/.microjournal/scripts/network-disable.sh

clear
echo
echo -e "\033[96m*** MICRO JOURNAL 3000 ***\033[0m"
echo -e "\033[93mDisable Networking\033[0m"
echo

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
sleep 2

