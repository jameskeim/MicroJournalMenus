# MICRO JOURNAL 2000 Script Harmonization Plan

## Overview

This plan harmonizes all secondary scripts launched from the main menu to follow the standardized Style Guide, ensuring consistent visual experience, accessibility, and maintainability across the entire system.

## Current State Analysis

### ✅ **Already Harmonized (Following New Style)**
- `wordcount-enhanced.sh` - Uses colors.sh and gum-styles.sh
- `goals-enhanced.sh` - Uses colors.sh 
- `quit.sh` - Uses gum-styles.sh with high-contrast confirms
- `newMarkDown-enhanced.sh` - Modern styling implementation

### ✅ **Harmonized with Functional Variations**
Scripts that follow core styling principles but require interface-specific adaptations:
- `notes.sh` - FZF interface with custom display logic, uses styling systems
- `prompts.sh` - Interactive prompt selection with custom gum usage patterns
- `inspirations.sh` - Fortune integration with specialized display formatting

### ⚠️ **Partially Harmonized (Mixed Style)**
- `notes.sh` - Extensive manual ANSI + some gum usage
- `network.sh` - Hardcoded ANSI + basic gum
- `prompts.sh` - Gum usage but not standardized functions

### ❌ **Not Harmonized (Old/Basic Style)**
- `share.sh` - Basic script, no styling system
- `sysinfo.sh` - Minimal script, just runs neofetch

### 🔍 **Need Analysis**
- `journal-menu.sh`
- `outliner.sh` 
- `notes-explorer.sh`
- `backup.sh`
- `inspirations.sh`
- `config.sh`

## Harmonization Strategy

### **Phase 1: Core Writing Tools (Priority: HIGH)**

#### **1.1 notes.sh - Major Overhaul**
**Issues:**
- Manual ANSI escape codes throughout (`\033[96m`, `\033[93m`, etc.)
- Inconsistent gum usage 
- No standardized header format
- Mixed color schemes

**Changes Required:**
```bash
# Add at top of script
source "${MCRJRNL:-$HOME/.microjournal}/scripts/colors.sh"
source "${MCRJRNL:-$HOME/.microjournal}/scripts/gum-styles.sh"

# Replace manual ANSI with semantic colors
echo -e "\033[96mNotes Manager\033[0m"
# → 
echo -e "${COLOR_HEADER_PRIMARY}▐ NOTES MANAGER ▌${COLOR_RESET}"

# Replace hardcoded gum with standardized functions
gum style --foreground 196 "Error message"
# →
gum_error "Error message"
```

**Effort:** HIGH (extensive manual changes required)

#### **1.2 prompts.sh - Style Alignment**
**Issues:**
- Uses gum but hardcoded color numbers
- Inconsistent with gum-styles.sh functions
- Header styling not standardized

**Changes Required:**
```bash
# Replace hardcoded gum colors
gum style --foreground 159 --align center --width 98 "$prompt"
# →
gum_content "$prompt"

# Standardize confirmations
gum confirm "Another prompt?"
# →
gum_confirm_normal "Another prompt?"
```

**Effort:** MEDIUM (systematic replacement of gum calls)

### **Phase 2: System Tools (Priority: MEDIUM)**

#### **2.1 network.sh - ANSI to Colors**
**Issues:**
- Hardcoded ANSI codes for status messages
- Basic gum usage without high-contrast
- No standardized error handling

**Changes Required:**
```bash
# Replace hardcoded ANSI
echo -e "\033[92mConnected\033[0m"
# →
echo -e "${COLOR_SUCCESS}Connected${COLOR_RESET}"

# Upgrade gum usage
gum choose "Enable" "Disable" "Status"
# →
gum_choose_contrast "Select action:" "Enable" "Disable" "Status"
```

**Effort:** MEDIUM (systematic ANSI replacement)

### **Phase 3: Utility Scripts (Priority: LOW)**

#### **3.1 share.sh - Add Basic Styling**
**Issues:**
- Basic script with no styling
- Raw echo statements
- No status feedback

**Changes Required:**
```bash
# Add styling system
source "${MCRJRNL:-$HOME/.microjournal}/scripts/colors.sh"

# Add header
echo -e "${COLOR_HEADER_PRIMARY}▐ SHARE FILES ▌${COLOR_RESET}"

# Add status messages
echo -e "${COLOR_SUCCESS}File server started${COLOR_RESET}"
echo -e "${COLOR_INFO}Access at http://$(hostname -I | awk '{print $1}'):8080${COLOR_RESET}"
```

**Effort:** LOW (simple additions)

#### **3.2 sysinfo.sh - Header Enhancement**
**Issues:**
- Just calls neofetch, no styling
- No consistent header

**Changes Required:**
```bash
# Add header before neofetch
source "${MCRJRNL:-$HOME/.microjournal}/scripts/colors.sh"
echo -e "${COLOR_HEADER_PRIMARY}▐ SYSTEM INFO ▌${COLOR_RESET}"
neofetch
```

**Effort:** LOW (minimal changes)

### **Phase 4: Analysis and Completion**

Analyze remaining scripts and apply harmonization:
- `journal-menu.sh`, `outliner.sh`, `notes-explorer.sh`
- `backup.sh`, `inspirations.sh`, `config.sh`

## Harmonization Tracking System

Each script should include a harmonization status comment in its header:

### **Tracking Comment Standards**
```bash
# HARMONIZATION PASS 1: COMPLETED - Standard implementation
# HARMONIZATION PASS 1: COMPLETED WITH FUNCTIONAL VARIATIONS - Custom interface adaptations
# HARMONIZATION PASS 1: PARTIALLY COMPLETED - Mixed old/new approaches  
# HARMONIZATION PASS 1: NOT STARTED - Requires full harmonization
# HARMONIZATION PASS 1: SKIPPED - Legacy/minimal script, no changes needed
```

### **Functional Variation Guidelines**
Scripts with specialized interfaces (FZF, fortune, interactive prompts) may:
- Use custom display logic while sourcing styling systems
- Adapt gum functions for their specific interface needs
- Maintain core principles: colors.sh usage, 98×12 constraints, no emojis
- Include explanatory comments about interface-specific choices

## Implementation Template

### **Standard Script Header Pattern**
```bash
#!/bin/bash
# script-name.sh - Brief description
# HARMONIZATION PASS 1: COMPLETED - Full compliance with style guide

# Configuration
MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"

# Load standardized styling systems
source "$MCRJRNL/scripts/colors.sh"
source "$MCRJRNL/scripts/gum-styles.sh"  # Only if using gum

clear

# Header (consistent across all scripts)
echo -e "${COLOR_HEADER_PRIMARY}▐ SCRIPT TITLE ▌${COLOR_RESET}"

# Menu pattern for interactive scripts
echo -e "${COLOR_HOTKEY}T${COLOR_RESET}oday's Writing    ${COLOR_HOTKEY}R${COLOR_RESET}ecent Files"
echo -e "${COLOR_HOTKEY}Q${COLOR_RESET}uit"
echo -n "${COLOR_PROMPT}Selection: ${COLOR_RESET}"
```

### **CRITICAL: Menu Item Standards**

**DO NOT use brackets around hotkeys in output:**
```bash
# WRONG - Shows brackets on screen
echo -e "${COLOR_HOTKEY}[T]${COLOR_RESET}oday's Writing"

# CORRECT - No brackets, just colored letter
echo -e "${COLOR_HOTKEY}T${COLOR_RESET}oday's Writing"
```

**Use letters from words, not numbers:**
```bash
# WRONG - Numbers are hard on 40% keyboards
echo "1) Today   2) Recent   3) Quit"

# CORRECT - Letters integrated into words
echo -e "${COLOR_HOTKEY}T${COLOR_RESET}oday    ${COLOR_HOTKEY}R${COLOR_RESET}ecent    ${COLOR_HOTKEY}Q${COLOR_RESET}uit"
```

**Ensure Selection prompt uses color variables:**
```bash
# WRONG - Shows ANSI codes on screen
echo -n "\033[93mSelection: \033[0m"

# CORRECT - Uses color variables  
echo -n "${COLOR_PROMPT}Selection: ${COLOR_RESET}"
```

### **Gum Replacement Patterns**

**Headers:**
```bash
# Old
gum style --foreground 81 --bold "Title"
# New  
gum_header_primary "Title"
```

**Choose/Confirm:**
```bash
# Old
gum choose "Option1" "Option2"
gum confirm "Are you sure?"
# New
gum_choose_contrast "Select:" "Option1" "Option2"
gum_confirm_normal "Are you sure?"  # or gum_confirm_danger
```

**Content Display:**
```bash
# Old
gum style --foreground 159 --align center --width 98 "$content"
# New (keep elegant!)
gum_content "$content"
```

**Character Safety:**
```bash
# AVOID: Emojis (display as unknown characters)
echo "Writing session complete! 🎉"
# USE: ASCII alternatives
echo "Writing session complete! [✓]"

# AVOID: Unicode progress blocks
echo "Progress: ▓▓▓▓▓░░░░░"
# USE: ASCII progress bars
echo "Progress: [████░░░░░░]"

# SAFE: Basic UTF-8 box drawing
echo -e "${COLOR_HEADER_PRIMARY}▐ TITLE ▌${COLOR_RESET}"
```

## Quality Assurance Checklist

For each harmonized script:

### **Visual Consistency**
- [ ] Uses `▐ TITLE ▌` header format
- [ ] Loads colors.sh for ANSI colors
- [ ] Loads gum-styles.sh if using gum
- [ ] No hardcoded ANSI codes or gum colors
- [ ] Semantic color usage (SUCCESS, ERROR, INFO, etc.)

### **Interaction Consistency**
- [ ] Letter-based navigation ([Q]uit, [A]ction, etc.)
- [ ] High-contrast gum choose/confirm functions
- [ ] Consistent hotkey highlighting
- [ ] No number-based menus (40% keyboard friendly)

### **Display Optimization**
- [ ] Fits within 98×12 constraint
- [ ] Left-aligned functional layout
- [ ] Minimal blank lines
- [ ] Proper text truncation for long content

### **UTF-8 Character Restrictions**
- [ ] No emojis used (display as unknown characters on fbterm)
- [ ] Safe UTF-8 box drawing only: `▐`, `▌`, `─`, `│`, `┌`, `┐`, `└`, `┘`
- [ ] ASCII progress bars: `[████░░░░]` not Unicode block characters
- [ ] Status indicators: `[✓]`, `[✗]`, `[!]` instead of emoji symbols
- [ ] Safe arrows: `→`, `←`, `↑`, `↓` (basic directional arrows only)

### **Accessibility**
- [ ] High contrast interactive elements
- [ ] Fallback handling when gum unavailable
- [ ] Clear visual hierarchy
- [ ] Consistent navigation patterns

## Implementation Order

### **Week 1: Foundation**
1. Complete analysis of remaining scripts
2. Update notes.sh (highest impact)

### **Week 2: Core Tools**  
3. Update prompts.sh
4. Update network.sh

### **Week 3: Utilities**
5. Update share.sh, sysinfo.sh
6. Update remaining analyzed scripts

### **Week 4: Testing & Polish**
7. System-wide testing
8. Performance optimization
9. Documentation updates

## Expected Benefits

### **User Experience**
- Consistent visual language across all tools
- Improved accessibility with high-contrast elements
- Predictable navigation patterns
- Professional, cohesive interface

### **Developer Experience**
- Centralized color/style management
- Easier maintenance and updates
- Consistent code patterns
- Better error handling and status feedback

### **System Performance**
- Optimized for 98×12 display constraint
- Reduced memory usage vs old Python-based systems
- Faster load times with cached styling
- Better resource utilization on Pi Zero 2W

## Refined Harmonization Process (Updated)

### **Step 1: Initial Harmonization**
1. Add harmonization tracking comment to header
2. Import styling systems (colors.sh, gum-styles.sh)
3. Convert hardcoded ANSI codes to COLOR_ variables
4. Fix menu items: remove brackets, use integrated letters
5. Update Selection/Choice prompts to use COLOR_PROMPT
6. Replace emojis with ASCII alternatives
7. Ensure standard ▐ TITLE ▌ header format

### **Step 2: Quality Assurance**
1. **MANDATORY**: Run `harmonization-qa.sh` on every script
2. Fix ALL failures before marking script as complete
3. Address warnings where possible
4. Update harmonization comment to reflect completion level

### **Step 3: Multi-Pass Approach**
- **PASS 1**: Basic conversion (ANSI → COLOR_, styling imports)
- **PASS 2**: Menu and UX fixes (brackets, prompts, letters vs numbers)
- **PASS 3**: QA-driven refinements (emoji removal, edge cases)

### **QA Tool Integration**
The `harmonization-qa.sh` tool is now **mandatory** for verification:
- Tests 9 critical harmonization standards
- Provides pass/warn/fail counts with detailed reports
- Must show 0 failures before marking script complete
- Reveals issues invisible to manual review

### **Lessons Learned**
1. **Manual review misses critical issues** - QA tool found 6 failures in "completed" scripts
2. **Bracket removal is easily missed** - `[T]oday` vs `Today` with colored `T`
3. **ANSI codes hide throughout scripts** - Requires systematic replacement
4. **Functional scripts need special handling** - FZF, outliner menus, etc.
5. **Multiple menu systems per script** - Each needs individual attention

## Success Metrics

- [ ] All menu-launched scripts use standardized styling systems
- [ ] Zero hardcoded ANSI escape codes in harmonized scripts (except utility functions)
- [ ] Zero brackets around menu hotkeys in output
- [ ] All menus use letters integrated into words, not standalone numbers
- [ ] All Selection/Choice prompts use COLOR_PROMPT variables
- [ ] Zero emojis (replaced with ASCII: [✓], [✗], [!])
- [ ] Consistent ▐ TITLE ▌ header format where applicable
- [ ] **QA tool shows 0 failures** for all harmonized scripts
- [ ] High-contrast gum elements throughout system
- [ ] All scripts fit 98×12 display constraint
- [ ] Unified visual identity across MICRO JOURNAL 2000

## QA Tool Commands
```bash
# Test all scripts
./scripts/harmonization-qa.sh -> A

# Test harmonized scripts only (recommended during development)
./scripts/harmonization-qa.sh -> H

# Test specific script
./scripts/harmonization-qa.sh -> S

# View last report
./scripts/harmonization-qa.sh -> R
```

This harmonization plan transforms the MICRO JOURNAL 2000 from a collection of individual scripts into a cohesive, professional writing system worthy of the premium hardware craftsmanship. The QA tool ensures consistency and catches issues that manual review misses.