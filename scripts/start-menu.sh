#!/bin/sh
# MICRO JOURNAL 2000 Menu Launcher
# Activate venv but skip welcomemenu.py - go directly to simple-menu

# cd ~/.microjournal
cd ~/

# echo "Starting MICRO JOURNAL 3000..."

# Activate virtual environment if it exists (keep it active for other programs)
if [ -f ".microjournal/venv/bin/activate" ]; then
  # echo "Activating Python on virtual environment..."
  source .microjournal/venv/bin/activate
  # echo "Virtual environment active"
else
  echo "No virtual environment found (running with system Python)"
fi

# Run simple menu directly
# echo "Loading simple menu..."
~/.microjournal/scripts/menu
