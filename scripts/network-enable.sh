#!/bin/sh
# network-enable.sh - Enable networking and SSH services
# Save as ~/.microjournal/scripts/network-enable.sh

clear
echo
echo -e "\033[96m*** MICRO JOURNAL 3000 ***\033[0m"
echo -e "\033[93mEnable Networking\033[0m"
echo

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
sleep 2

