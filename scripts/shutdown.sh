#!/bin/bash
# shutdown.sh - Shutdown the system with confirmation
# Save as ~/.microjournal/scripts/shutdown.sh

clear
echo
echo -e "\033[96m*** MICRO JOURNAL 3000 ***\033[0m"
echo -e "\033[93mShutdown System\033[0m"
echo
echo -e "\033[91mWarning: This will turn off the system.\033[0m"
echo
echo -n "Are you sure you want to shutdown? (y/N): "
read -n 1 response
echo

if [[ "$response" =~ ^[Yy]$ ]]; then
  echo
  echo -e "\033[93mSyncing filesystems...\033[0m"
  sudo sync
  echo -e "\033[93mShutting down system...\033[0m"
  sleep 2
  sudo shutdown -h now
else
  echo
  echo -e "\033[92mShutdown cancelled.\033[0m"
  sleep 1
fi
