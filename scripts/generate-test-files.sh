#!/bin/bash
# generate-test-files.sh - Generate test markdown files for wordcount.sh testing
# Uses lorem-ipsum-cli to create realistic test data with newMarkDown.sh naming convention

set -e

# Configuration
DOCS_DIR="$HOME/Documents/writing"
LOREM_CMD="lorem"

# Descriptive suffixes for some files
SUFFIXES=("journal-entry" "writing-practice" "morning-pages" "story-draft" "notes" "ideas" "reflection" "brainstorm")

# Check if lorem-ipsum-cli is available
if ! command -v "$LOREM_CMD" &> /dev/null; then
    echo "Error: lorem-ipsum-cli not found. Install with: npm install -g lorem-ipsum-cli"
    exit 1
fi

# Ensure writing directory exists
mkdir -p "$DOCS_DIR"

# Function to generate random number in range
random_range() {
    local min=$1
    local max=$2
    echo $((RANDOM % (max - min + 1) + min))
}

# Function to generate random time
random_time() {
    local hour=$(printf "%02d" $(random_range 6 23))
    local minute=$(printf "%02d" $(random_range 0 59))
    echo "${hour}${minute}"
}

# Function to create a test file
create_test_file() {
    local date_str=$1
    local time_str=$2
    local word_count=$3
    local use_suffix=$4
    local suffix=$5
    
    local filename
    if [ "$use_suffix" = "true" ]; then
        filename="${date_str}-${time_str}-${suffix}.md"
    else
        filename="${date_str}-${time_str}.md"
    fi
    
    local filepath="$DOCS_DIR/$filename"
    
    # Generate lorem ipsum content
    local paragraphs=$(random_range 1 5)
    
    # Create file with lorem ipsum content
    echo "# Writing Session - $(echo $date_str | sed 's/\./-/g') at $(echo $time_str | sed 's/\(..\)\(..\)/\1:\2/')" > "$filepath"
    echo "" >> "$filepath"
    
    # Generate content to reach approximately the target word count
    # Average paragraph has ~50-100 words, average sentence has ~10-20 words
    local paragraphs_needed=$((word_count / 75))  # Rough estimate
    if [ $paragraphs_needed -lt 1 ]; then
        paragraphs_needed=1
    fi
    
    # Generate paragraphs
    for p in $(seq 1 $paragraphs_needed); do
        "$LOREM_CMD" -p >> "$filepath"
        echo "" >> "$filepath"
    done
    
    # If we need more words, add some sentences
    local current_words=$(wc -w < "$filepath")
    if [ $current_words -lt $word_count ]; then
        local sentences_needed=$(((word_count - current_words) / 15))
        if [ $sentences_needed -gt 0 ]; then
            "$LOREM_CMD" -s -c $sentences_needed >> "$filepath"
            echo "" >> "$filepath"
        fi
    fi
    
    echo "Created: $filename (target: $word_count words)"
}

# Main generation logic
echo "Generating test files for wordcount.sh testing..."
echo "Using lorem-ipsum-cli to create realistic content"
echo

# Get dates for last 10 days
dates=()
for i in {0..9}; do
    date_str=$(date -d "$i days ago" +"%Y.%m.%d")
    dates+=("$date_str")
done

# Skip days 3 and 7 (random gaps for testing)
skip_indices=(2 6)

# Generate files
file_count=0
for i in "${!dates[@]}"; do
    date_str="${dates[$i]}"
    
    # Check if this day should be skipped
    skip_day=false
    for skip_idx in "${skip_indices[@]}"; do
        if [ $i -eq $skip_idx ]; then
            skip_day=true
            echo "Skipping $date_str (simulating no writing day)"
            break
        fi
    done
    
    if [ "$skip_day" = true ]; then
        continue
    fi
    
    # Determine number of files for this day (1-4 sessions)
    sessions=$(random_range 1 4)
    
    echo "Generating $sessions file(s) for $date_str:"
    
    for j in $(seq 1 $sessions); do
        time_str=$(random_time)
        word_count=$(random_range 50 700)
        
        # 30% chance of using a descriptive suffix
        if [ $((RANDOM % 10)) -lt 3 ]; then
            suffix_idx=$((RANDOM % ${#SUFFIXES[@]}))
            suffix="${SUFFIXES[$suffix_idx]}"
            create_test_file "$date_str" "$time_str" "$word_count" "true" "$suffix"
        else
            create_test_file "$date_str" "$time_str" "$word_count" "false" ""
        fi
        
        file_count=$((file_count + 1))
        
        # Small delay between files to ensure different timestamps if needed
        sleep 0.1
    done
    
    echo
done

echo "Generation complete!"
echo "Created $file_count test files in $DOCS_DIR"
echo
echo "Test your wordcount.sh script with these files:"
echo "- Some days have multiple writing sessions"
echo "- Word counts range from 50-700 words"
echo "- Mix of plain and descriptive filenames"
echo "- Days $(date -d "2 days ago" +"%Y.%m.%d") and $(date -d "6 days ago" +"%Y.%m.%d") skipped for testing gaps"
echo
echo "Run: ./scripts/wordcount.sh"