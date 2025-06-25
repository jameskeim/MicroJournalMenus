#!/bin/sh
# Save as ~/.microjournal/scripts/fbterm-startup.sh
# Make executable with: chmod +x ~/.microjournal/scripts/fbterm-startup.sh

# Set up fbterm environment
export TERM=fbterm

# Start tmux with proper TERM setting and run welcome menu inside it
TERM=fbterm tmux new-session -s main ~/.microjournal/scripts/start-menu.sh
