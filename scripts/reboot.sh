#!/bin/sh
# reboot.sh - Reboot the system with confirmation
# Save as ~/.microjournal/scripts/reboot.sh

clear
echo
echo -e "\033[96m*** MICRO JOURNAL 3000 ***\033[0m"
echo -e "\033[93mReboot System\033[0m"
echo
echo -e "\033[91mWarning: This will restart the system.\033[0m"
echo
echo -n "Are you sure you want to reboot? (y/N): "
read -n 1 response
echo

if [[ "$response" =~ ^[Yy]$ ]]; then
  echo
  echo -e "\033[93mSyncing filesystems...\033[0m"
  sudo sync
  echo -e "\033[93mRebooting system...\033[0m"
  sleep 2
  sudo reboot
else
  echo
  echo -e "\033[92mReboot cancelled.\033[0m"
  sleep 1
fi
