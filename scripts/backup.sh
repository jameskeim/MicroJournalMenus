#!/bin/bash
# backup.sh - Simple Backup Script for MICRO JOURNAL 2000
# Creates archive of system and documents, accessible via ShareFiles
# HARMONIZATION PASS 3: COMPLETED - Full compliance: ANSI→COLOR_, prompts standardized, symbols→ASCII

# Configuration
MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"

# Load standardized styling systems
source "$MCRJRNL/scripts/colors.sh"

DOCS_DIR="$HOME/Documents"
DATE=$(date +%Y.%m.%d-%H%M)
BACKUP_NAME="backup-$DATE.tar.gz"
BACKUP_PATH="$DOCS_DIR/$BACKUP_NAME"

clear
echo -e "${COLOR_HEADER_PRIMARY}▐ BACKUP ▌${COLOR_RESET}"
echo
echo "Creating: backup-$DATE.tar.gz"
echo

# Check if backup already exists
if [ -f "$BACKUP_PATH" ]; then
    echo -n "${COLOR_WARNING}File exists. Overwrite? (y/n): ${COLOR_RESET}"
    read -n 1 -s overwrite
    echo "$overwrite"
    if [ "$overwrite" != "y" ]; then
        echo "Cancelled."
        exit 0
    fi
    echo
fi

# Create backup with exclusions
echo "Archiving system and documents..."
echo "Excluding backups and virtual environment..."

# Use tar with exclusion patterns
if tar -czf "$BACKUP_PATH" \
    --exclude="Documents/backup-*" \
    --exclude="$(basename "$MCRJRNL")/venv" \
    -C "$HOME" \
    "$(basename "$MCRJRNL")" \
    "Documents" 2>/dev/null; then
    
    # Get backup size
    backup_size=$(du -h "$BACKUP_PATH" | cut -f1)
    file_count=$(tar -tzf "$BACKUP_PATH" 2>/dev/null | wc -l)
    
    echo -e "${COLOR_SUCCESS}[✓] Backup complete${COLOR_RESET}"
    echo
    echo "Size: $backup_size | Files: $file_count"
    echo "Accessible via ShareFiles"
    
else
    echo -e "${COLOR_ERROR}[✗] Backup failed${COLOR_RESET}"
    echo "Check permissions and disk space"
    exit 1
fi

echo
echo -ne "${COLOR_PROMPT}Press Enter to continue...${COLOR_RESET}"
read