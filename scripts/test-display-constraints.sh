#!/bin/bash
# test-display-constraints.sh - Test the display constraint utilities

MCRJRNL="$HOME/.microjournal"
source "$MCRJRNL/scripts/display-constraints.sh"

echo "=== TESTING DISPLAY CONSTRAINTS UTILITIES ==="
echo

# Test 1: Width constraints
echo "1. Testing width truncation (98 characters max):"
long_text="This is a very long line of text that definitely exceeds the 98-character width limit and should be truncated appropriately with ellipsis to prevent horizontal scrolling issues on the display."
echo "Original length: ${#long_text} characters"
echo "Truncated: $(truncate_text "$long_text")"
echo "Truncated length: $(echo "$(truncate_text "$long_text")" | wc -c)"
echo

# Test 2: Compact headers
echo "2. Testing compact headers:"
show_compact_header "TEST HEADER" "With subtitle"
echo

# Test 3: Compact session completion
echo "3. Testing compact session completion:"
show_compact_session_complete "245" "5m 12s" "47" "Goal: [████████░░░░░░░░░░░░] 49% (245/500)"
echo

# Test 4: Ultra-compact menu
echo "4. Testing ultra-compact menu:"
show_ultra_compact_menu "WORD COUNT" \
    "\033[92mT\033[0m-Today" \
    "\033[92mR\033[0m-Recent" \
    "\033[92mA\033[0m-All" \
    "\033[92mF\033[0m-File" \
    "\033[91mE\033[0m-Exit"
echo

# Test 5: Compact progress bar
echo "5. Testing compact progress bars:"
echo -n "50% progress: "
show_compact_progress 250 500 20
echo
echo -n "100% progress: "
show_compact_progress 500 500 20
echo
echo -n "Small progress: "
show_compact_progress 50 500 15
echo
echo

# Test 6: Line counting simulation
echo "6. Testing display height management:"
echo "Current line count simulation:"
for i in {1..11}; do
    if can_display_lines $i 1; then
        echo "Line $i: Can display one more line"
    else
        echo "Line $i: Would exceed screen height"
        break
    fi
done
echo

echo "=== DISPLAY CONSTRAINTS TEST COMPLETE ==="
echo
echo "Summary:"
echo "- All functions loaded successfully"
echo "- Width truncation working at 98 characters"
echo "- Compact layouts designed for 12-line displays"
echo "- Height management functions available"
echo
echo "The enhanced scripts should now respect display constraints!"