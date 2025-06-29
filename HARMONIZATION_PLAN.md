# MICRO JOURNAL 2000 Script Harmonization Plan

## Overview

This plan harmonizes all secondary scripts launched from the main menu to follow the standardized Style Guide, ensuring consistent visual experience, accessibility, and maintainability across the entire system.

## Current State Analysis

### ✅ **Already Harmonized (Following New Style)**
- `wordcount-enhanced.sh` - Uses colors.sh and gum-styles.sh
- `goals-enhanced.sh` - Uses colors.sh 
- `quit.sh` - Uses gum-styles.sh with high-contrast confirms
- `newMarkDown-enhanced.sh` - Modern styling implementation

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

## Implementation Template

### **Standard Script Header Pattern**
```bash
#!/bin/bash
# script-name.sh - Brief description

# Configuration
MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"

# Load standardized styling systems
source "$MCRJRNL/scripts/colors.sh"
source "$MCRJRNL/scripts/gum-styles.sh"  # Only if using gum

clear

# Header (consistent across all scripts)
echo -e "${COLOR_HEADER_PRIMARY}▐ SCRIPT TITLE ▌${COLOR_RESET}"

# Menu pattern for interactive scripts
echo -e "${COLOR_HOTKEY}[A]${COLOR_RESET}ction One    ${COLOR_HOTKEY}[B]${COLOR_RESET}ction Two"
echo -e "${COLOR_HOTKEY}[Q]${COLOR_RESET}uit"
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

## Success Metrics

- [ ] All menu-launched scripts use standardized styling systems
- [ ] Zero hardcoded ANSI escape codes in harmonized scripts
- [ ] Consistent [Q]uit navigation across all scripts
- [ ] High-contrast gum elements throughout system
- [ ] All scripts fit 98×12 display constraint
- [ ] Unified visual identity across MICRO JOURNAL 2000

This harmonization plan transforms the MICRO JOURNAL 2000 from a collection of individual scripts into a cohesive, professional writing system worthy of the premium hardware craftsmanship.