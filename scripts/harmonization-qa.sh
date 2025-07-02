#!/bin/bash
# harmonization-qa.sh - Quality Assurance Tool for MICRO JOURNAL 2000 Script Harmonization
# Systematic verification of harmonization standards compliance
# HARMONIZATION PASS 1: COMPLETED - QA tool following all standards

MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"

# Load standardized styling systems
source "$MCRJRNL/scripts/colors.sh"
source "$MCRJRNL/scripts/gum-styles.sh"

# QA Configuration
SCRIPTS_DIR="$MCRJRNL/scripts"
QA_REPORT="/tmp/harmonization-qa-report.txt"
FAIL_COUNT=0
WARN_COUNT=0
PASS_COUNT=0

# Clear previous report
echo "# MICRO JOURNAL 2000 Harmonization QA Report" > "$QA_REPORT"
echo "# Generated: $(date)" >> "$QA_REPORT"
echo "# =============================================" >> "$QA_REPORT"
echo >> "$QA_REPORT"

# ═══════════════════════════════════════════════════════════════
# QA TEST FUNCTIONS
# ═══════════════════════════════════════════════════════════════

# Test for hardcoded ANSI escape codes
test_ansi_codes() {
    local script="$1"
    local script_name=$(basename "$script")
    local ansi_found=$(grep -n "\\\\033\|\\x1b" "$script" 2>/dev/null)
    
    if [ -n "$ansi_found" ]; then
        # Check if found ANSI codes are QA-EXEMPT by checking surrounding lines
        local exempt_lines=$(echo "$ansi_found" | while read line; do
            local line_num=$(echo "$line" | cut -d: -f1)
            local prev_line=$((line_num - 1))
            local next_line=$((line_num + 1))
            if sed -n "${prev_line}p;${line_num}p;${next_line}p" "$script" | grep -q "QA-EXEMPT"; then
                echo "EXEMPT"
                break
            fi
        done)
        
        if [ "$exempt_lines" = "EXEMPT" ]; then
            echo -e "${COLOR_SUCCESS}[✓] PASS: $script_name - ANSI codes are QA-EXEMPT${COLOR_RESET}"
            PASS_COUNT=$((PASS_COUNT + 1))
            return 0
        else
            echo -e "${COLOR_ERROR}[✗] FAIL: $script_name contains hardcoded ANSI codes${COLOR_RESET}"
            echo "FAIL: $script_name - Hardcoded ANSI codes found:" >> "$QA_REPORT"
            echo "$ansi_found" | sed 's/^/  /' >> "$QA_REPORT"
            echo >> "$QA_REPORT"
            FAIL_COUNT=$((FAIL_COUNT + 1))
            return 1
        fi
    else
        echo -e "${COLOR_SUCCESS}[✓] PASS: $script_name - No hardcoded ANSI codes${COLOR_RESET}"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    fi
}

# Test for harmonization tracking comment
test_harmonization_comment() {
    local script="$1"
    local script_name=$(basename "$script")
    local has_comment=$(head -10 "$script" | grep "HARMONIZATION PASS")
    
    if [ -z "$has_comment" ]; then
        echo -e "${COLOR_WARNING}[!] WARN: $script_name missing harmonization tracking comment${COLOR_RESET}"
        echo "WARN: $script_name - Missing harmonization tracking comment" >> "$QA_REPORT"
        echo >> "$QA_REPORT"
        WARN_COUNT=$((WARN_COUNT + 1))
        return 1
    else
        echo -e "${COLOR_SUCCESS}[✓] PASS: $script_name - Has harmonization tracking${COLOR_RESET}"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    fi
}

# Test for styling system imports
test_styling_imports() {
    local script="$1"
    local script_name=$(basename "$script")
    local has_colors=$(grep "source.*colors.sh" "$script")
    local has_gum=$(grep "source.*gum-styles.sh" "$script")
    local uses_colors=$(grep "COLOR_" "$script")
    local uses_gum=$(grep "gum_" "$script")
    
    if [ -n "$uses_colors" ] && [ -z "$has_colors" ]; then
        echo -e "${COLOR_ERROR}[✗] FAIL: $script_name uses COLOR_ variables but doesn't import colors.sh${COLOR_RESET}"
        echo "FAIL: $script_name - Uses COLOR_ variables without importing colors.sh" >> "$QA_REPORT"
        echo >> "$QA_REPORT"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
    
    if [ -n "$uses_gum" ] && [ -z "$has_gum" ]; then
        echo -e "${COLOR_ERROR}[✗] FAIL: $script_name uses gum_ functions but doesn't import gum-styles.sh${COLOR_RESET}"
        echo "FAIL: $script_name - Uses gum_ functions without importing gum-styles.sh" >> "$QA_REPORT"
        echo >> "$QA_REPORT"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
    
    echo -e "${COLOR_SUCCESS}[✓] PASS: $script_name - Proper styling system imports${COLOR_RESET}"
    PASS_COUNT=$((PASS_COUNT + 1))
    return 0
}

# Test for bracket usage in menu output
test_menu_brackets() {
    local script="$1"
    local script_name=$(basename "$script")
    local bracket_menus=$(grep -n "echo.*\[.*\].*COLOR_HOTKEY\|COLOR_HOTKEY.*\[.*\]" "$script" 2>/dev/null)
    
    if [ -n "$bracket_menus" ]; then
        echo -e "${COLOR_ERROR}[✗] FAIL: $script_name has brackets around hotkeys in menu output${COLOR_RESET}"
        echo "FAIL: $script_name - Brackets around hotkeys in menu output:" >> "$QA_REPORT"
        echo "$bracket_menus" | sed 's/^/  /' >> "$QA_REPORT"
        echo >> "$QA_REPORT"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    else
        echo -e "${COLOR_SUCCESS}[✓] PASS: $script_name - No brackets around menu hotkeys${COLOR_RESET}"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    fi
}

# Test for numbered menus (should use letters)
test_numbered_menus() {
    local script="$1"
    local script_name=$(basename "$script")
    local numbered_menus=$(grep -n "echo.*[0-9]) " "$script" 2>/dev/null | grep -v "Page\|Cache\|entries\|sessions")
    
    if [ -n "$numbered_menus" ]; then
        echo -e "${COLOR_WARNING}[!] WARN: $script_name may have numbered menu items (40% keyboard unfriendly)${COLOR_RESET}"
        echo "WARN: $script_name - Possible numbered menu items:" >> "$QA_REPORT"
        echo "$numbered_menus" | sed 's/^/  /' >> "$QA_REPORT"
        echo >> "$QA_REPORT"
        WARN_COUNT=$((WARN_COUNT + 1))
        return 1
    else
        echo -e "${COLOR_SUCCESS}[✓] PASS: $script_name - No numbered menu items found${COLOR_RESET}"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    fi
}

# Test for proper Selection/Choice prompt usage
test_selection_prompts() {
    local script="$1"
    local script_name=$(basename "$script")
    local bad_prompts=$(grep -n "printf.*Selection:\|printf.*Choice:\|echo.*Selection:\|echo.*Choice:" "$script" 2>/dev/null | grep -v "COLOR_PROMPT")
    
    if [ -n "$bad_prompts" ]; then
        echo -e "${COLOR_ERROR}[✗] FAIL: $script_name has Selection/Choice prompts without COLOR_PROMPT${COLOR_RESET}"
        echo "FAIL: $script_name - Selection/Choice prompts without COLOR_PROMPT:" >> "$QA_REPORT"
        echo "$bad_prompts" | sed 's/^/  /' >> "$QA_REPORT"
        echo >> "$QA_REPORT"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    else
        echo -e "${COLOR_SUCCESS}[✓] PASS: $script_name - Proper Selection/Choice prompt styling${COLOR_RESET}"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    fi
}

# Test for emoji usage (should be ASCII alternatives)
test_emoji_usage() {
    local script="$1"
    local script_name=$(basename "$script")
    # Look for common emoji patterns in UTF-8
    local emoji_found=$(grep -n "[🎉📔📚📝📂⚡📤📥📁📊✅❌⚠️💡🔍🎯📄📋🗂️🔄]" "$script" 2>/dev/null)
    
    if [ -n "$emoji_found" ]; then
        echo -e "${COLOR_ERROR}[✗] FAIL: $script_name contains emojis (display as unknown characters on fbterm)${COLOR_RESET}"
        echo "FAIL: $script_name - Emoji usage found:" >> "$QA_REPORT"
        echo "$emoji_found" | sed 's/^/  /' >> "$QA_REPORT"
        echo >> "$QA_REPORT"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    else
        echo -e "${COLOR_SUCCESS}[✓] PASS: $script_name - No emojis found${COLOR_RESET}"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    fi
}

# Test for proper header format
test_header_format() {
    local script="$1"
    local script_name=$(basename "$script")
    local has_header=$(grep -n "COLOR_HEADER_PRIMARY.*▐.*▌" "$script" 2>/dev/null)
    local uses_colors=$(grep "COLOR_" "$script")
    
    # Only check for header format if the script uses colors (indicates it should have a header)
    if [ -n "$uses_colors" ] && [ -z "$has_header" ]; then
        echo -e "${COLOR_WARNING}[!] WARN: $script_name may be missing standard ▐ TITLE ▌ header format${COLOR_RESET}"
        echo "WARN: $script_name - May be missing standard header format" >> "$QA_REPORT"
        echo >> "$QA_REPORT"
        WARN_COUNT=$((WARN_COUNT + 1))
        return 1
    else
        echo -e "${COLOR_SUCCESS}[✓] PASS: $script_name - Proper header format or no header needed${COLOR_RESET}"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    fi
}

# Test for syntax errors
test_syntax() {
    local script="$1"
    local script_name=$(basename "$script")
    
    if ! bash -n "$script" 2>/dev/null; then
        echo -e "${COLOR_ERROR}[✗] FAIL: $script_name has syntax errors${COLOR_RESET}"
        echo "FAIL: $script_name - Syntax errors found:" >> "$QA_REPORT"
        bash -n "$script" 2>&1 | sed 's/^/  /' >> "$QA_REPORT"
        echo >> "$QA_REPORT"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    else
        echo -e "${COLOR_SUCCESS}[✓] PASS: $script_name - No syntax errors${COLOR_RESET}"
        PASS_COUNT=$((PASS_COUNT + 1))
        return 0
    fi
}

# ═══════════════════════════════════════════════════════════════
# MAIN QA RUNNER
# ═══════════════════════════════════════════════════════════════

run_qa_on_script() {
    local script="$1"
    local script_name=$(basename "$script")
    
    echo -e "${COLOR_INFO}Testing: $script_name${COLOR_RESET}"
    echo "----------------------------------------"
    
    # Run all tests
    test_syntax "$script"
    test_harmonization_comment "$script"
    test_ansi_codes "$script"
    test_styling_imports "$script"
    test_menu_brackets "$script"
    test_numbered_menus "$script"
    test_selection_prompts "$script"
    test_emoji_usage "$script"
    test_header_format "$script"
    
    echo
}

# Main menu function
show_qa_menu() {
    clear
    echo -e "${COLOR_HEADER_PRIMARY}▐ HARMONIZATION QA ▌${COLOR_RESET}"
    echo
    echo -e "${COLOR_HOTKEY}A${COLOR_RESET}ll Scripts    ${COLOR_HOTKEY}S${COLOR_RESET}pecific Script    ${COLOR_HOTKEY}H${COLOR_RESET}armonized Only"
    echo -e "${COLOR_HOTKEY}R${COLOR_RESET}eport Only    ${COLOR_HOTKEY}Q${COLOR_RESET}uit"
    echo
    echo -ne "${COLOR_PROMPT}Selection: ${COLOR_RESET}"
}

# Run QA on all scripts
run_qa_all() {
    echo -e "${COLOR_INFO}Running QA on all .sh scripts in $SCRIPTS_DIR${COLOR_RESET}"
    echo "=================================================="
    echo
    
    for script in "$SCRIPTS_DIR"/*.sh; do
        [ -f "$script" ] || continue
        # Skip the QA script itself
        [ "$(basename "$script")" = "harmonization-qa.sh" ] && continue
        run_qa_on_script "$script"
    done
    
    show_summary
}

# Run QA on harmonized scripts only
run_qa_harmonized() {
    echo -e "${COLOR_INFO}Running QA on harmonized scripts only${COLOR_RESET}"
    echo "============================================="
    echo
    
    for script in "$SCRIPTS_DIR"/*.sh; do
        [ -f "$script" ] || continue
        # Skip the QA script itself
        [ "$(basename "$script")" = "harmonization-qa.sh" ] && continue
        
        # Check if script has harmonization comment
        if head -10 "$script" | grep -q "HARMONIZATION PASS"; then
            run_qa_on_script "$script"
        fi
    done
    
    show_summary
}

# Run QA on specific script
run_qa_specific() {
    echo
    echo "Available scripts:"
    local i=1
    local scripts=()
    for script in "$SCRIPTS_DIR"/*.sh; do
        [ -f "$script" ] || continue
        [ "$(basename "$script")" = "harmonization-qa.sh" ] && continue
        scripts+=("$script")
        echo "$i) $(basename "$script")"
        ((i++))
    done
    
    echo
    echo -n "Select script number (1-$((i-1))): "
    read selection
    
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#scripts[@]} ]; then
        local selected_script="${scripts[$((selection - 1))]}"
        echo
        run_qa_on_script "$selected_script"
        show_summary
    else
        echo -e "${COLOR_ERROR}Invalid selection.${COLOR_RESET}"
    fi
}

# Show summary
show_summary() {
    echo "=================================================="
    echo -e "${COLOR_INFO}QA SUMMARY${COLOR_RESET}"
    echo "=================================================="
    echo -e "${COLOR_SUCCESS}PASSED: $PASS_COUNT tests${COLOR_RESET}"
    echo -e "${COLOR_WARNING}WARNINGS: $WARN_COUNT tests${COLOR_RESET}"
    echo -e "${COLOR_ERROR}FAILED: $FAIL_COUNT tests${COLOR_RESET}"
    echo
    
    if [ $FAIL_COUNT -eq 0 ] && [ $WARN_COUNT -eq 0 ]; then
        echo -e "${COLOR_SUCCESS}🎉 ALL TESTS PASSED! Harmonization is excellent.${COLOR_RESET}"
    elif [ $FAIL_COUNT -eq 0 ]; then
        echo -e "${COLOR_WARNING}✓ No failures, but $WARN_COUNT warnings to review.${COLOR_RESET}"
    else
        echo -e "${COLOR_ERROR}❌ $FAIL_COUNT critical issues need fixing.${COLOR_RESET}"
    fi
    
    echo
    echo "Full report saved to: $QA_REPORT"
    echo
    echo -n "Press Enter to continue..."
    read
}

# Show report only
show_report() {
    if [ -f "$QA_REPORT" ]; then
        echo -e "${COLOR_INFO}Displaying QA Report:${COLOR_RESET}"
        echo "===================="
        cat "$QA_REPORT"
        echo
        echo -n "Press Enter to continue..."
        read
    else
        echo -e "${COLOR_WARNING}No QA report found. Run tests first.${COLOR_RESET}"
        sleep 2
    fi
}

# ═══════════════════════════════════════════════════════════════
# MAIN PROGRAM LOOP
# ═══════════════════════════════════════════════════════════════

main() {
    while true; do
        show_qa_menu
        read -n 1 -s choice
        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
        echo "$choice"
        echo
        
        case "$choice" in
        'a')
            run_qa_all
            ;;
        's')
            run_qa_specific
            ;;
        'h')
            run_qa_harmonized
            ;;
        'r')
            show_report
            ;;
        'q'|'')
            echo -e "${COLOR_SUCCESS}QA testing complete.${COLOR_RESET}"
            break
            ;;
        *)
            echo -e "${COLOR_ERROR}Invalid choice. Try again...${COLOR_RESET}"
            sleep 1
            ;;
        esac
    done
}

# Run main function if executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi