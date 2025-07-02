#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# HNB OUTLINER LAUNCHER & CONVERSION SYSTEM
# ═══════════════════════════════════════════════════════════════════════════════
#
# Comprehensive script for Hierarchical Notebook (hnb) with conversion tools
# Optimized for Pi Zero 2W and writer workflows
# HARMONIZATION PASS 1: COMPLETED - Converted custom color system to standardized styling

MCRJRNL="${MCRJRNL:-$HOME/.microjournal}"

# Load standardized styling systems
source "$MCRJRNL/scripts/colors.sh"
source "$MCRJRNL/scripts/gum-styles.sh"

OUTLINES_DIR="$HOME/Documents/outlines"

# ═══════════════════════════════════════════════════════════════════════════════
# INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════════

# Ensure outlines directory exists
init_outlines() {
  mkdir -p "$OUTLINES_DIR"

  # Create sample outline if none exist
  if [ ! -f "$OUTLINES_DIR/example.hnb" ] && [ -z "$(ls -A "$OUTLINES_DIR" 2>/dev/null)" ]; then
    cat >"$OUTLINES_DIR/example.hnb" <<'EOF'
+ Welcome to HNB Outlining
	+ This is a sample outline structure
		+ Sub-items are indented with tabs
		+ You can expand/collapse sections
	+ HNB Features
		+ Fast hierarchical editing
		+ Export to multiple formats
		+ Lightweight and efficient
	+ Writing Applications
		+ Story structure planning
		+ Article organization
		+ Research notes
		+ Project planning
	+ Tips for Writers
		+ Use + for main topics
		+ Use - for sub-points
		+ Keep it simple and focused
		+ Regular saves (Ctrl+S)
EOF
    echo -e "${COLOR_SUCCESS}[✓] Created example outline in $OUTLINES_DIR${COLOR_RESET}"
  fi
}

# Check if hnb is installed
check_hnb() {
  if ! command -v hnb >/dev/null 2>&1; then
    echo -e "${COLOR_ERROR}[✗] HNB not found!${COLOR_RESET}"
    echo
    echo "Install with:"
    echo "  sudo apt update"
    echo "  sudo apt install hnb"
    echo
    echo "Or compile from source for latest features:"
    echo "  git clone https://github.com/larshp/hnb"
    return 1
  fi
  return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# HNB LAUNCHER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Show HNB tutorial/help
launch_tutorial() {
  echo -e "${COLOR_INFO}Launching HNB Tutorial${COLOR_RESET}"
  echo "Navigate with arrow keys. Press 'q' then Enter to quit."
  sleep 2

  # Launch hnb tutorial mode
  if ! hnb --tutorial; then
    clear
    echo
    echo -e "${COLOR_WARNING}HNB Quick Reference${COLOR_RESET}"
    echo
    echo "NAV: ↑↓ j/k move  →/Tab expand  ←/h collapse"
    echo "EDIT: Enter edit  i insert  a child  d delete"
    echo "FILE: Ctrl+S save  Ctrl+L load  Ctrl+X export"
    echo "TIPS: Use + for topics, - for points. Save often!"
    echo
    echo "Press Enter to continue..."
    read
  fi
}

# Create new outline
new_outline() {
  echo -e "${COLOR_INFO}Create New Outline${COLOR_RESET}"
  echo
  read -p "Enter outline name (without extension): " outline_name

  if [ -z "$outline_name" ]; then
    echo "Cancelled."
    return
  fi

  # Clean filename
  outline_name=$(echo "$outline_name" | tr ' ' '_' | tr -cd '[:alnum:]_-')
  local outline_path="$OUTLINES_DIR/${outline_name}.hnb"

  if [ -f "$outline_path" ]; then
    echo
    read -p "Outline '$outline_name' exists. Overwrite? (y/n): " overwrite
    [ "$overwrite" != "y" ] && return
  fi

  # Create basic outline structure
  cat >"$outline_path" <<EOF
+ ${outline_name//_/ }
	+ Main Point 1
		+ Supporting detail
		+ Another detail
	+ Main Point 2
		+ Supporting detail
	+ Main Point 3
		+ Supporting detail
	+ Conclusion
		+ Summary
		+ Next steps
EOF

  echo -e "${COLOR_SUCCESS}[✓] Created: $outline_path${COLOR_RESET}"
  echo "Launching HNB..."
  sleep 1

  if ! hnb --ascii "$outline_path"; then
    echo -e "${COLOR_ERROR}Failed to launch HNB. You can edit the file manually:${COLOR_RESET}"
    echo "$outline_path"
  fi
}

# Open existing outline
open_outline() {
  local outlines=($(find "$OUTLINES_DIR" -name "*.hnb" -type f 2>/dev/null | sort))

  if [ ${#outlines[@]} -eq 0 ]; then
    echo -e "${COLOR_WARNING}No outlines found in $OUTLINES_DIR${COLOR_RESET}"
    echo "Create a new outline first."
    return
  fi

  echo -e "${COLOR_INFO}Open Existing Outline${COLOR_RESET}"
  echo

  # List available outlines
  local i=1
  for outline in "${outlines[@]}"; do
    local basename=$(basename "$outline" .hnb)
    local size=$(wc -l <"$outline" 2>/dev/null || echo "?")
    local modified=$(stat -c %y "$outline" 2>/dev/null | cut -d' ' -f1 || echo "?")
    printf "%2d) %-20s %3s lines %s\n" "$i" "$basename" "$size" "$modified"
    ((i++))
  done

  echo
  read -p "Select outline (number) or press Enter to cancel: " selection

  if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#outlines[@]} ]; then
    local selected_outline="${outlines[$((selection - 1))]}"
    echo -e "${COLOR_SUCCESS}Opening: $(basename "$selected_outline")${COLOR_RESET}"
    sleep 1
    if ! hnb --ascii "$selected_outline"; then
      echo -e "${COLOR_ERROR}Failed to launch HNB. You can edit the file manually:${COLOR_RESET}"
      echo "$selected_outline"
    fi
  else
    echo "Cancelled."
  fi
}

# Quick outline (temporary)
quick_outline() {
  echo -e "${COLOR_INFO}Quick Outline (Temporary)${COLOR_RESET}"
  echo "This creates a temporary outline for brainstorming"
  echo "Save it manually if you want to keep it"
  sleep 2

  # Create temporary outline
  local temp_outline="/tmp/quick_outline_$(date +%s).hnb"
  cat >"$temp_outline" <<'EOF'
+ Quick Brainstorm Session
	+ Idea 1
		+ Details
	+ Idea 2  
		+ Details
	+ Idea 3
		+ Details
	+ Next Steps
		+ Action items
EOF

  if ! hnb --ascii "$temp_outline"; then
    echo -e "${COLOR_ERROR}Failed to launch HNB. Temp outline saved at:${COLOR_RESET}"
    echo "$temp_outline"
    return
  fi

  # Offer to save after editing
  echo
  read -p "Save this outline? (y/n): " save_choice
  if [ "$save_choice" = "y" ]; then
    read -p "Enter name for outline: " save_name
    if [ -n "$save_name" ]; then
      save_name=$(echo "$save_name" | tr ' ' '_' | tr -cd '[:alnum:]_-')
      cp "$temp_outline" "$OUTLINES_DIR/${save_name}.hnb"
      echo -e "${COLOR_SUCCESS}[✓] Saved as: ${save_name}.hnb${COLOR_RESET}"
    fi
  fi

  rm -f "$temp_outline"
}

# ═══════════════════════════════════════════════════════════════════════════════
# CONVERSION FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Convert HNB to other formats
export_outline() {
  local outlines=($(find "$OUTLINES_DIR" -name "*.hnb" -type f 2>/dev/null | sort))

  if [ ${#outlines[@]} -eq 0 ]; then
    echo -e "${COLOR_WARNING}No HNB outlines found to export${COLOR_RESET}"
    return
  fi

  echo -e "${COLOR_INFO}Export HNB Outline${COLOR_RESET}"
  echo

  # Select outline to export
  echo "Available outlines:"
  local i=1
  for outline in "${outlines[@]}"; do
    printf "%2d) %s\n" "$i" "$(basename "$outline" .hnb)"
    ((i++))
  done

  echo
  read -p "Select outline to export (number): " selection

  if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#outlines[@]} ]; then
    echo "Invalid selection."
    return
  fi

  local source_file="${outlines[$((selection - 1))]}"
  local basename=$(basename "$source_file" .hnb)

  echo
  echo "Export formats:"
  echo -e "${COLOR_HOTKEY}T${COLOR_RESET}ext  ${COLOR_HOTKEY}M${COLOR_RESET}arkdown  ${COLOR_HOTKEY}H${COLOR_RESET}TML  ${COLOR_HOTKEY}X${COLOR_RESET}ML  ${COLOR_HOTKEY}C${COLOR_RESET}SV"
  echo
  echo -ne "${COLOR_PROMPT}Selection: ${COLOR_RESET}"
  read format

  case "$format" in
  1)
    export_to_text "$source_file" "$basename"
    ;;
  2)
    export_to_markdown "$source_file" "$basename"
    ;;
  3)
    export_to_html "$source_file" "$basename"
    ;;
  4)
    export_to_xml "$source_file" "$basename"
    ;;
  5)
    export_to_csv "$source_file" "$basename"
    ;;
  *)
    echo "Invalid format selection."
    ;;
  esac
}

# Export to plain text (indented)
export_to_text() {
  local source="$1"
  local basename="$2"
  local output="$OUTLINES_DIR/${basename}.txt"

  # Simple conversion: replace + with - and preserve indentation
  sed 's/^+/-/g' "$source" >"$output"

  echo -e "${COLOR_SUCCESS}[✓] Exported to: $output${COLOR_RESET}"
}

# Export to Markdown
export_to_markdown() {
  local source="$1"
  local basename="$2"
  local output="$OUTLINES_DIR/${basename}.md"

  {
    echo "# $basename"
    echo
    # Convert HNB format to Markdown
    awk '
        /^\+/ { 
            level = 0; 
            line = $0; 
            while(match(line, /^\t/)) { 
                level++; 
                line = substr(line, 2); 
            }
            gsub(/^\+ */, "", line);
            for(i=0; i<level+1; i++) printf "#";
            printf " %s\n", line;
        }
        /^-/ {
            level = 0;
            line = $0;
            while(match(line, /^\t/)) {
                level++;
                line = substr(line, 2);
            }
            gsub(/^- */, "", line);
            for(i=0; i<level; i++) printf "  ";
            printf "- %s\n", line;
        }
        ' "$source"
  } >"$output"

  echo -e "${COLOR_SUCCESS}[✓] Exported to: $output${COLOR_RESET}"
}

# Export to HTML
export_to_html() {
  local source="$1"
  local basename="$2"
  local output="$OUTLINES_DIR/${basename}.html"

  {
    cat <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>$basename</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        ul { margin: 10px 0; }
        li { margin: 5px 0; }
    </style>
</head>
<body>
    <h1>$basename</h1>
EOF

    # Convert to nested HTML lists
    awk '
        BEGIN { level = 0; }
        /^\+/ {
            new_level = 0;
            line = $0;
            while(match(line, /^\t/)) {
                new_level++;
                line = substr(line, 2);
            }
            gsub(/^\+ */, "", line);
            
            if(new_level > level) {
                for(i=level; i<new_level; i++) print "    <ul>";
            } else if(new_level < level) {
                for(i=new_level; i<level; i++) print "    </ul>";
            }
            level = new_level;
            printf "        <li>%s</li>\n", line;
        }
        END {
            for(i=0; i<level; i++) print "    </ul>";
        }
        ' "$source"

    echo "</body>"
    echo "</html>"
  } >"$output"

  echo -e "${COLOR_SUCCESS}[✓] Exported to: $output${COLOR_RESET}"
}

# Export to XML
export_to_xml() {
  local source="$1"
  local basename="$2"
  local output="$OUTLINES_DIR/${basename}.xml"

  {
    echo '<?xml version="1.0" encoding="UTF-8"?>'
    echo "<outline title=\"$basename\">"

    awk '
        /^\+/ {
            level = 0;
            line = $0;
            while(match(line, /^\t/)) {
                level++;
                line = substr(line, 2);
            }
            gsub(/^\+ */, "", line);
            gsub(/&/, "\\&amp;", line);
            gsub(/</, "\\&lt;", line);
            gsub(/>/, "\\&gt;", line);
            gsub(/"/, "\\&quot;", line);
            
            for(i=0; i<level; i++) printf "  ";
            printf "  <item level=\"%d\" text=\"%s\" />\n", level, line;
        }
        ' "$source"

    echo "</outline>"
  } >"$output"

  echo -e "${COLOR_SUCCESS}[✓] Exported to: $output${COLOR_RESET}"
}

# Export to CSV
export_to_csv() {
  local source="$1"
  local basename="$2"
  local output="$OUTLINES_DIR/${basename}.csv"

  {
    echo "Level,Text,Parent"
    awk -F'\t' '
        /^\+/ {
            level = 0;
            line = $0;
            while(match(line, /^\t/)) {
                level++;
                line = substr(line, 2);
            }
            gsub(/^\+ */, "", line);
            gsub(/"/, "\"\"", line);  # Escape quotes
            printf "%d,\"%s\",\"%s\"\n", level, line, (level > 0 ? "Parent" level-1 : "");
        }
        ' "$source"
  } >"$output"

  echo -e "${COLOR_SUCCESS}[✓] Exported to: $output${COLOR_RESET}"
}

# Import from other formats
import_outline() {
  echo -e "${COLOR_INFO}Import Outline${COLOR_RESET}"
  echo
  echo "Import formats:"
  echo -e "${COLOR_HOTKEY}P${COLOR_RESET}lain text  ${COLOR_HOTKEY}M${COLOR_RESET}arkdown  ${COLOR_HOTKEY}S${COLOR_RESET}imple list"
  echo
  echo -ne "${COLOR_PROMPT}Selection: ${COLOR_RESET}"
  read format

  case "$format" in
  1)
    import_from_text
    ;;
  2)
    import_from_markdown
    ;;
  3)
    import_from_list
    ;;
  *)
    echo "Invalid format selection."
    ;;
  esac
}

# Import from plain text
import_from_text() {
  echo
  read -p "Enter path to text file: " text_file

  if [ ! -f "$text_file" ]; then
    echo "File not found: $text_file"
    return
  fi

  read -p "Enter name for new HNB outline: " outline_name
  outline_name=$(echo "$outline_name" | tr ' ' '_' | tr -cd '[:alnum:]_-')

  if [ -z "$outline_name" ]; then
    echo "Invalid outline name."
    return
  fi

  local output="$OUTLINES_DIR/${outline_name}.hnb"

  # Convert indented text to HNB format
  awk '
    {
        # Count leading whitespace
        level = 0;
        line = $0;
        while(match(line, /^[ \t]/)) {
            level++;
            line = substr(line, 2);
        }
        
        # Remove leading markers
        gsub(/^[-*+] */, "", line);
        
        # Output with proper HNB format
        if(level == 0) {
            printf "+ %s\n", line;
        } else {
            for(i=1; i<level; i++) printf "\t";
            printf "\t+ %s\n", line;
        }
    }
    ' "$text_file" >"$output"

  echo -e "${COLOR_SUCCESS}[✓] Imported to: $output${COLOR_RESET}"

  read -p "Open in HNB now? (y/n): " open_now
  [ "$open_now" = "y" ] && hnb --ascii "$output"
}

# Import from Markdown
import_from_markdown() {
  echo
  read -p "Enter path to Markdown file: " md_file

  if [ ! -f "$md_file" ]; then
    echo "File not found: $md_file"
    return
  fi

  read -p "Enter name for new HNB outline: " outline_name
  outline_name=$(echo "$outline_name" | tr ' ' '_' | tr -cd '[:alnum:]_-')

  if [ -z "$outline_name" ]; then
    echo "Invalid outline name."
    return
  fi

  local output="$OUTLINES_DIR/${outline_name}.hnb"

  # Convert Markdown to HNB format
  awk '
    /^#{1,6} / {
        level = 0;
        while(match($0, /^#/)) {
            level++;
            $0 = substr($0, 2);
        }
        gsub(/^ */, "");
        
        if(level == 1) {
            printf "+ %s\n", $0;
        } else {
            for(i=1; i<level; i++) printf "\t";
            printf "+ %s\n", $0;
        }
    }
    /^[-*+] / {
        gsub(/^[-*+] */, "");
        printf "\t+ %s\n", $0;
    }
    ' "$md_file" >"$output"

  echo -e "${COLOR_SUCCESS}[✓] Imported to: $output${COLOR_RESET}"

  read -p "Open in HNB now? (y/n): " open_now
  [ "$open_now" = "y" ] && hnb --ascii "$output"
}

# Import from simple list
import_from_list() {
  echo
  read -p "Enter path to list file (one item per line): " list_file

  if [ ! -f "$list_file" ]; then
    echo "File not found: $list_file"
    return
  fi

  read -p "Enter name for new HNB outline: " outline_name
  outline_name=$(echo "$outline_name" | tr ' ' '_' | tr -cd '[:alnum:]_-')

  if [ -z "$outline_name" ]; then
    echo "Invalid outline name."
    return
  fi

  local output="$OUTLINES_DIR/${outline_name}.hnb"

  {
    echo "+ $outline_name"
    while IFS= read -r line; do
      [ -n "$line" ] && echo -e "\t+ $line"
    done <"$list_file"
  } >"$output"

  echo -e "${COLOR_SUCCESS}[✓] Imported to: $output${COLOR_RESET}"

  read -p "Open in HNB now? (y/n): " open_now
  [ "$open_now" = "y" ] && hnb --ascii "$output"
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN MENU SYSTEM
# ═══════════════════════════════════════════════════════════════════════════════

show_main_menu() {
  clear
  echo
  printf "%*s\n" $(((98 - 11) / 2)) ""
  echo -e "${COLOR_HEADER_PRIMARY}▐ OUTLINER ▌${COLOR_RESET}"
  echo
  echo -e "${COLOR_HOTKEY}T${COLOR_RESET}utorial   ${COLOR_HOTKEY}N${COLOR_RESET}ew       ${COLOR_HOTKEY}O${COLOR_RESET}pen      ${COLOR_HOTKEY}Q${COLOR_RESET}uick"
  echo -e "${COLOR_HOTKEY}E${COLOR_RESET}xport     ${COLOR_HOTKEY}I${COLOR_RESET}mport    ${COLOR_HOTKEY}B${COLOR_RESET}rowse    ${COLOR_HOTKEY}S${COLOR_RESET}tats"
  echo -e "${COLOR_HOTKEY}X${COLOR_RESET} Quit"
  echo
  echo -ne "${COLOR_PROMPT}Selection: ${COLOR_RESET}"
}

# Browse outlines folder
browse_folder() {
  echo -e "${COLOR_INFO}Outlines Folder${COLOR_RESET}"

  if command -v yazi >/dev/null 2>&1; then
    echo "Opening in Yazi file manager..."
    sleep 1
    yazi "$OUTLINES_DIR"
  elif command -v ranger >/dev/null 2>&1; then
    echo "Opening in Ranger file manager..."
    sleep 1
    ranger "$OUTLINES_DIR"
  else
    echo
    ls -la "$OUTLINES_DIR"
    echo
    read -p "Press Enter to continue..."
  fi
}

# Show outline statistics
show_stats() {
  echo -e "${COLOR_INFO}Outline Statistics${COLOR_RESET}"
  echo

  local total_outlines=$(find "$OUTLINES_DIR" -name "*.hnb" -type f 2>/dev/null | wc -l)
  local total_lines=0
  local newest_file=""
  local newest_date=""

  if [ "$total_outlines" -gt 0 ]; then
    while IFS= read -r file; do
      local lines=$(wc -l <"$file" 2>/dev/null || echo 0)
      total_lines=$((total_lines + lines))
    done < <(find "$OUTLINES_DIR" -name "*.hnb" -type f 2>/dev/null)

    newest_file=$(find "$OUTLINES_DIR" -name "*.hnb" -type f -exec stat -c '%Y %n' {} \; 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)
    if [ -n "$newest_file" ]; then
      newest_date=$(stat -c %y "$newest_file" 2>/dev/null | cut -d' ' -f1)
    fi
  fi

  printf "Total outlines:     %d\n" "$total_outlines"
  printf "Total outline lines: %d\n" "$total_lines"
  printf "Average lines/outline: %d\n" $((total_outlines > 0 ? total_lines / total_outlines : 0))
  printf "Storage location:   %s\n" "$OUTLINES_DIR"

  if [ -n "$newest_file" ]; then
    printf "Most recent:        %s (%s)\n" "$(basename "$newest_file")" "$newest_date"
  fi

  echo
  echo "Recent files:"
  find "$OUTLINES_DIR" -name "*.hnb" -type f -exec stat -c '%Y %s %n' {} \; 2>/dev/null |
    sort -nr | head -5 | while read timestamp size file; do
    local date=$(date -d "@$timestamp" +%m-%d 2>/dev/null || echo "?")
    local kb=$((size / 1024))
    printf "  %-15s %s %2s KB\n" "$(basename "$file" .hnb)" "$date" "$kb"
  done

  echo
  read -p "Press Enter to continue..."
}

# Main program loop
main() {
  # Initialize system
  init_outlines

  # Check if HNB is available
  if ! check_hnb; then
    read -p "Press Enter to continue anyway..."
  fi

  # Handle command line arguments for direct access
  case "${1:-menu}" in
  "new" | "n")
    new_outline
    ;;
  "tutorial" | "help" | "t")
    launch_tutorial
    ;;
  "quick" | "q")
    quick_outline
    ;;
  "export" | "e")
    export_outline
    ;;
  "import" | "i")
    import_outline
    ;;
  *)
    # Interactive menu mode
    while true; do
      show_main_menu
      read -r choice

      case "${choice,,}" in
      "1" | "tutorial" | "help")
        launch_tutorial
        ;;
      "2" | "new")
        new_outline
        ;;
      "3" | "open")
        open_outline
        ;;
      "4" | "quick")
        quick_outline
        ;;
      "5" | "export")
        export_outline
        ;;
      "6" | "import")
        import_outline
        ;;
      "7" | "browse")
        browse_folder
        ;;
      "8" | "stats")
        show_stats
        ;;
      "q" | "quit" | "")
        echo
        echo -e "${COLOR_SUCCESS}Happy outlining!${COLOR_RESET}"
        exit 0
        ;;
      *)
        echo
        echo "Invalid choice. Please try again."
        sleep 1
        ;;
      esac
    done
    ;;
  esac
}

# ═══════════════════════════════════════════════════════════════════════════════
# USAGE EXAMPLES
# ═══════════════════════════════════════════════════════════════════════════════

# Quick usage for PROCESS menu:
#   outliner.sh           # Interactive menu
#   outliner.sh new       # Create new outline directly
#   outliner.sh tutorial  # Show help/tutorial
#   outliner.sh quick     # Quick temporary outline

# Run main function if executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  main "$@"
fi
