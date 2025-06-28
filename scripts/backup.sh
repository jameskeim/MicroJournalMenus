#!/bin/bash
# backup.sh - Simple Backup Script for MICRO JOURNAL 2000
# Creates archive of system and documents, accessible via ShareFiles

# Configuration
MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"
DOCS_DIR="$HOME/Documents"
DATE=$(date +%Y.%m.%d-%H%M)
BACKUP_NAME="backup-$DATE.tar.gz"
BACKUP_PATH="$DOCS_DIR/$BACKUP_NAME"

# Colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo
printf "%*s\n" $(((98 - 8) / 2)) ""
echo -e "\033[1;38;5;81m▐ BACKUP ▌\033[0m"
echo
echo "Creating: backup-$DATE.tar.gz"
echo

# Check if backup already exists
if [ -f "$BACKUP_PATH" ]; then
    echo -e "${YELLOW}File exists. Overwrite? (y/n):${NC}"
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
    
    echo -e "${GREEN}✅ Backup complete${NC}"
    echo
    echo "Size: $backup_size | Files: $file_count"
    echo "Accessible via ShareFiles"
    
else
    echo -e "${RED}❌ Backup failed${NC}"
    echo "Check permissions and disk space"
    exit 1
fi

echo
read -p "Press Enter to continue..."