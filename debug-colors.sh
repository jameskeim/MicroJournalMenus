#!/bin/bash
# Debug script to test gum color handling

echo "=== Testing individual gum style commands ==="

# Test 1: Simple colored text
echo "Test 1: Basic gum style"
gum style --foreground 46 --bold "GREEN TEXT"

echo ""
echo "Test 2: Gum join with colored parts"
GREEN_M=$(gum style --foreground 46 --bold "M")
echo "GREEN_M variable contains: '$GREEN_M'"
RESULT=$(gum join "$GREEN_M" "arkdown")
echo "Join result: '$RESULT'"

echo ""
echo "Test 3: Complex column test"
TITLE=$(gum style --foreground 46 --bold "WRITING")
ITEM1=$(gum join "$(gum style --foreground 46 --bold "M")" "arkdown")
ITEM2="Test item 2"
ITEM3=""

echo "Individual parts:"
echo "TITLE: $TITLE"
echo "ITEM1: $ITEM1" 
echo "ITEM2: $ITEM2"
echo "ITEM3: '$ITEM3'"

echo ""
echo "Building content with printf:"
CONTENT=$(printf "%s\n%s\n%s\n%s" "$TITLE" "$ITEM1" "$ITEM2" "$ITEM3")
echo "Combined content:"
echo "$CONTENT"

echo ""
echo "Final styled box:"
echo "$CONTENT" | gum style --border rounded --border-foreground 46 --padding "0 1" --width 17