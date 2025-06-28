#!/bin/bash
# NOTE: WordGrinder files (.wg) use a proprietary format incompatible 
# with wordcount.sh, which is designed for Markdown files only.
# For word count analysis, use newMarkDown.sh instead.

# Get the current date and time in the format YYYY.MM.DD-HHMM
datetime=$(date +"%Y.%m.%d-%H%M")

# Prompt for optional title
echo "Create new WordGrinder file:"
echo "Optional title (short phrase, e.g., 'morning-thoughts', 'meeting-notes'):"
echo -n "Title (or press Enter to skip): "
read -r title

# Clean up title: replace spaces with hyphens, remove special characters
if [ -n "$title" ]; then
    # Convert to lowercase, replace spaces with hyphens, remove non-alphanumeric/hyphen chars
    clean_title=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[[:space:]]\+/-/g' | sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
    
    if [ -n "$clean_title" ]; then
        filename="${datetime}-${clean_title}.wg"
    else
        filename="${datetime}.wg"
    fi
else
    filename="${datetime}.wg"
fi

echo "Creating: ~/Documents/writing/$filename"

# Ensure writing directory exists
mkdir -p ~/Documents/writing

# Run WordGrinder with the generated filename
wordgrinder "~/Documents/writing/$filename"
