-- menu_config_template.lua - Enhanced Configuration Template
--
-- Copy this template and modify it to create your own custom menus
-- for the MicroJournal system. Now includes variable/fixed column widths,
-- manual screen dimensions, inline decorations, and optional components.
--
-- Usage:
--   1. Copy this file to your own config (e.g., my_menu.lua)
--   2. Modify the configuration below
--   3. Load and use:
--      local menu_builder = require('menu_builder')
--      local config = require('my_menu')
--      local menu = menu_builder.create(config)
--      menu:run(true) -- true for single keypress mode

-- ═══════════════════════════════════════════════════════════════════════════════
-- ENHANCED CONFIGURATION TEMPLATE
-- ═══════════════════════════════════════════════════════════════════════════════

local menu_config = {

	-- ┌─────────────────────────────────────────────────────────────────────────┐
	-- │ SCREEN DIMENSIONS (Optional - Manual Override)                         │
	-- └─────────────────────────────────────────────────────────────────────────┘
	screen = {
		width = 80, -- Manual width override (optional)
		height = 24, -- Manual height override (optional)
		-- Remove this section to auto-detect terminal size
	},

	-- ┌─────────────────────────────────────────────────────────────────────────┐
	-- │ INPUT BEHAVIOR                                                          │
	-- └─────────────────────────────────────────────────────────────────────────┘
	single_keypress = true, -- true: no Enter required, false: press Enter

	-- ┌─────────────────────────────────────────────────────────────────────────┐
	-- │ TITLE CONFIGURATION (Optional - can be omitted entirely)               │
	-- └─────────────────────────────────────────────────────────────────────────┘
	title = {
		text = "YOUR MENU TITLE", -- The main title text
		color = "bright_cyan", -- Text color (see color options below)
		accent_color = nil, -- Optional: additional color overlay
		decoration = "inline_top", -- Decoration type (see enhanced options below)
		decoration_color = "bright_red", -- Color of the decoration
	},

	-- ┌─────────────────────────────────────────────────────────────────────────┐
	-- │ SUBTITLE CONFIGURATION (Optional - can be omitted entirely)            │
	-- └─────────────────────────────────────────────────────────────────────────┘
	subtitle = {
		text = "Your subtitle here", -- Subtitle text (optional)
		color = "bright_yellow", -- Subtitle color
		accent_color = nil, -- Optional: additional color
		decoration = "inline_bottom", -- Decoration type
		decoration_color = "bright_red", -- Decoration color
	},

	-- ┌─────────────────────────────────────────────────────────────────────────┐
	-- │ LAYOUT CONFIGURATION                                                    │
	-- └─────────────────────────────────────────────────────────────────────────┘
	columns = 4, -- Number of columns (1-5)
	column_layout = "variable", -- "variable" or "fixed"
	fixed_column_width = 20, -- Used when column_layout = "fixed" (optional)

	-- ┌─────────────────────────────────────────────────────────────────────────┐
	-- │ MENU ITEMS CONFIGURATION                                                │
	-- └─────────────────────────────────────────────────────────────────────────┘
	menu_items = {
		{ -- COLUMN 1 (calculated: longest item + 1 space in variable mode)
			{
				name = "Markdown", -- Display name
				color = "white", -- Text color
				hotkey = "M", -- Single letter/number hotkey
				hotkey_color = "bright_green", -- Hotkey color
				hotkey_style = "expanded", -- Style (see options below)
				command = "~/.microjournal/scripts/newMarkDown.sh",
			},
			{
				name = "Wordgrinder",
				color = "white",
				hotkey = "W",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "~/.microjournal/scripts/newwrdgrndr.sh",
			},
			{
				name = "Neovim",
				color = "white",
				hotkey = "N",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "nvim",
			},
			{
				name = "Word Count",
				color = "white",
				hotkey = "C",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "~/.microjournal/scripts/wordcount.sh",
			},
		},
		{ -- COLUMN 2
			{
				name = "File Manager",
				color = "white",
				hotkey = "F",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "yazi",
			},
			{
				name = "Share Files",
				color = "white",
				hotkey = "S",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "~/.microjournal/scripts/share.sh",
			},
			{
				name = "System Info",
				color = "white",
				hotkey = "I",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "~/.microjournal/scripts/sysinfo.sh",
			},
			{
				name = "Pi Config",
				color = "white",
				hotkey = "P",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "~/.microjournal/scripts/config.sh",
			},
		},
		{ -- COLUMN 3
			{
				name = "Network ⬆",
				color = "white",
				hotkey = "U",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "~/.microjournal/scripts/network-enable.sh",
			},
			{
				name = "Network ⬇",
				color = "white",
				hotkey = "D",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "~/.microjournal/scripts/network-disable.sh",
			},
			{
				name = "Time Clock",
				color = "white",
				hotkey = "T",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "tty-clock -c -t -B -S -C 3",
			},
			{
				name = "Matrix",
				color = "white",
				hotkey = "X",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "neo -c cyan",
			},
		},
		{ -- COLUMN 4 (no extra space in variable mode since it's last)
			{
				name = "Z Shell",
				color = "white",
				hotkey = "Z",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = function()
					os.execute("clear")
					print("Starting shell...")
					print("Type 'exit' to return to menu")
					print()
					os.execute("/bin/zsh")
				end,
			},
			{
				name = "Menu Reload",
				color = "white",
				hotkey = "L",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = function()
					print("Restarting menu...")
					os.execute("sleep 1")
					-- In real implementation, would restart script
				end,
			},
			{
				name = "Shutdown",
				color = "bright_red",
				hotkey = "Q",
				hotkey_color = "bright_red",
				hotkey_style = "expanded",
				command = "~/.microjournal/scripts/shutdown.sh",
			},
			{
				name = "Reboot",
				color = "bright_red",
				hotkey = "R",
				hotkey_color = "bright_red",
				hotkey_style = "expanded",
				command = "~/.microjournal/scripts/reboot.sh",
			},
		},
		-- Add more columns by adding more tables: {}, {}, etc.
	},

	-- ┌─────────────────────────────────────────────────────────────────────────┐
	-- │ PROMPT CONFIGURATION (Optional - can be omitted)                       │
	-- └─────────────────────────────────────────────────────────────────────────┘
	prompt = {
		text = "Make a selection: ", -- Prompt text
		color = "bright_cyan", -- Prompt color
		location = "center", -- Position: "left", "center", "right"
	},
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- ENHANCED CONFIGURATION OPTIONS REFERENCE
-- ═══════════════════════════════════════════════════════════════════════════════

--[[

COLOR OPTIONS:
═════════════
Standard Colors:     Bright Colors:
• black              • bright_black
• red                • bright_red  
• green              • bright_green
• yellow             • bright_yellow
• blue               • bright_blue
• magenta            • bright_magenta
• cyan               • bright_cyan
• white              • bright_white

Special Colors:
• reset              • bold              • dim
• underline          • blink             • reverse

ENHANCED DECORATION OPTIONS:
═══════════════════════════
Standard Decorations:
• "none"           - No decoration
• "line"           - Simple line (===)
• "double_line"    - Double lines (═══) above and below
• "block"          - Solid block decoration (███)
• "box"            - Unicode box around text (╔══╗)

NEW: Inline Decorations (like your Python script):
• "inline_top"     - ▐▀▀▀▀▀▀ TEXT ▀▀▀▀▀▀▌ (top border)
• "inline_bottom"  - ▐▄▄▄ TEXT ▄▄▄▌ (bottom border)
• "inline_sides"   - ▐ TEXT ▌ (side borders only)

COLUMN LAYOUT OPTIONS:
══════════════════════
• "variable"       - Auto-size columns based on content (like Python script)
                     Column 1: longest_item_length + 1 space
                     Column 2: longest_item_length + 1 space  
                     Column N: longest_item_length (no extra space)

• "fixed"          - Fixed-width columns
                     Use with fixed_column_width setting
                     If fixed_column_width not set, divides screen evenly

HOTKEY STYLE OPTIONS:
════════════════════
• "expanded"       - "H - Home"          (full format)
• "bracketed"      - "[H]ome"            (brackets around hotkey)
• "colored"        - "Home"              (first letter colored differently)
• "underlined"     - "Home"              (first letter underlined)

INPUT BEHAVIOR:
══════════════
• single_keypress = true   - Immediate response (like Python script)
• single_keypress = false  - Require Enter key

OPTIONAL COMPONENTS:
═══════════════════
Any of these can be omitted entirely:
• title = nil      - No title will be displayed
• subtitle = nil   - No subtitle will be displayed  
• prompt = nil     - No prompt will be displayed
• screen = nil     - Auto-detect terminal size

MANUAL SCREEN DIMENSIONS:
════════════════════════
screen = {
    width = 80,    - Override terminal width detection
    height = 24    - Override terminal height detection  
}
Useful for:
• Testing on different screen sizes
• Consistent layout across devices
• When terminal detection fails

COMMAND OPTIONS:
═══════════════
• String:          - Shell command to execute
  "nano file.txt"
  "~/.microjournal/scripts/script.sh"

• Function:        - Lua function to call
  function() 
      print("Hello!")
      if not single_keypress then io.read() end
  end

VARIABLE COLUMN WIDTH EXAMPLE:
═════════════════════════════
With these items:
Column 1: "W - Wordgrinder" (15 chars) → width = 16 (15 + 1 space)
Column 2: "F - File Manager" (16 chars) → width = 17 (16 + 1 space)
Column 3: "U - Network Up" (14 chars) → width = 15 (14 + 1 space)
Column 4: "L - Menu Reload" (15 chars) → width = 15 (15, no space)

This creates perfectly aligned columns like your Python script!

ADVANCED TIPS:
═════════════
1. Single keypress mode for responsive UI:
   single_keypress = true
   menu:run(true)

2. Inline decorations for title/subtitle frames:
   title = {decoration = "inline_top"}
   subtitle = {decoration = "inline_bottom"}

3. Variable columns for perfect alignment:
   column_layout = "variable"  -- Auto-calculates like Python script

4. Manual screen size for testing:
   screen = {width = 120, height = 30}

5. Optional components for minimal menus:
   -- Omit title, subtitle, or prompt entirely
   title = nil

6. Hidden hotkeys (not displayed but functional):
   -- Add extra items beyond visible rows
   -- They won't show but hotkeys still work

]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- PYTHON SCRIPT COMPATIBILITY
-- ═══════════════════════════════════════════════════════════════════════════════

--[[

This Lua implementation now matches your Python script features:

✅ Variable column widths (auto-calculated like Python)
✅ Single keypress input (no Enter required)  
✅ Inline box decorations (▐▀▀▀ style)
✅ Manual screen dimensions
✅ Optional title/subtitle
✅ Proper column alignment
✅ Hidden hotkey support

Usage examples:

-- Exact Python script replacement:
local menu = menu_builder.create(menu_config)
menu:run(true)  -- Single keypress mode

-- Quick menu with auto-sizing:
local items = {{name = "Option", hotkey = "O", command = "echo hi"}}
local menu = menu_builder.quick_menu("TITLE", items, {
    single_keypress = true,
    column_layout = "variable"
})
menu:run(true)

]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- RETURN THE CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════════════════

return menu_config
