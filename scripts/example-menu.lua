#!/usr/bin/env lua
-- example-menu.lua - Enhanced Demonstrations of the menu_builder library
--
-- Shows all new features: variable/fixed columns, inline decorations,
-- single keypress input, manual screen dimensions, optional components
--
-- Usage: lua example-menu.lua

local menu_builder = require("menu_builder")

-- ═══════════════════════════════════════════════════════════════════════════════
-- EXAMPLE 1: PYTHON SCRIPT REPLICA (Variable Columns + Inline Decorations)
-- ═══════════════════════════════════════════════════════════════════════════════

local python_replica_config = {
	single_keypress = true, -- No Enter required (like Python script)

	title = {
		text = "MICRO JOURNAL 3000",
		color = "bright_cyan",
		decoration = "inline_top", -- ▐▀▀▀▀▀▀ TEXT ▀▀▀▀▀▀▌
		decoration_color = "bright_red",
	},
	subtitle = {
		text = "Portable Writing Station",
		color = "bright_yellow",
		decoration = "inline_bottom", -- ▐▄▄▄ TEXT ▄▄▄▌
		decoration_color = "bright_red",
	},
	columns = 4,
	column_layout = "variable", -- Auto-size like Python script
	menu_items = {
		{ -- Column 1: 16 chars max
			{
				name = "Markdown",
				color = "white",
				hotkey = "M",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "echo Markdown",
			},
			{
				name = "Wordgrinder",
				color = "white",
				hotkey = "W",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "echo WordGrinder",
			},
			{
				name = "Neovim",
				color = "white",
				hotkey = "N",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "echo Neovim",
			},
		},
		{ -- Column 2: 17 chars max
			{
				name = "File Manager",
				color = "white",
				hotkey = "F",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "echo File Manager",
			},
			{
				name = "Share Files",
				color = "white",
				hotkey = "S",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "echo Share Files",
			},
			{
				name = "System Info",
				color = "white",
				hotkey = "I",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "echo System Info",
			},
		},
		{ -- Column 3: 15 chars max
			{
				name = "Network ⬆",
				color = "white",
				hotkey = "U",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "echo Network Up",
			},
			{
				name = "Network ⬇",
				color = "white",
				hotkey = "D",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "echo Network Down",
			},
			{
				name = "Time Clock",
				color = "white",
				hotkey = "T",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "echo Time Clock",
			},
		},
		{ -- Column 4: 15 chars max (no extra space)
			{
				name = "Z Shell",
				color = "white",
				hotkey = "Z",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "echo Z Shell",
			},
			{
				name = "Menu Reload",
				color = "white",
				hotkey = "L",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "echo Menu Reload",
			},
			{
				name = "Shutdown",
				color = "bright_red",
				hotkey = "Q",
				hotkey_color = "bright_red",
				hotkey_style = "expanded",
				command = "echo Shutdown",
			},
		},
	},
	prompt = { text = "Make a selection: ", color = "bright_cyan", location = "center" },
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- EXAMPLE 2: FIXED WIDTH COLUMNS DEMO
-- ═══════════════════════════════════════════════════════════════════════════════

local fixed_width_config = {
	single_keypress = true,

	title = {
		text = "FIXED WIDTH DEMO",
		color = "bright_magenta",
		decoration = "double_line",
		decoration_color = "magenta",
	},
	subtitle = {
		text = "Each column exactly 20 characters",
		color = "bright_blue",
		decoration = "line",
		decoration_color = "blue",
	},
	columns = 3,
	column_layout = "fixed", -- Fixed width mode
	fixed_column_width = 20, -- Exactly 20 chars per column
	menu_items = {
		{ -- All items padded to 20 chars
			{
				name = "Short",
				color = "cyan",
				hotkey = "S",
				hotkey_color = "bright_cyan",
				hotkey_style = "expanded",
				command = "echo Short item",
			},
			{
				name = "Medium Length",
				color = "cyan",
				hotkey = "M",
				hotkey_color = "bright_cyan",
				hotkey_style = "expanded",
				command = "echo Medium",
			},
			{
				name = "Very Long Item Name",
				color = "cyan",
				hotkey = "V",
				hotkey_color = "bright_cyan",
				hotkey_style = "expanded",
				command = "echo Very long",
			},
		},
		{
			{
				name = "Item A",
				color = "yellow",
				hotkey = "A",
				hotkey_color = "bright_yellow",
				hotkey_style = "expanded",
				command = "echo A",
			},
			{
				name = "Item B",
				color = "yellow",
				hotkey = "B",
				hotkey_color = "bright_yellow",
				hotkey_style = "expanded",
				command = "echo B",
			},
			{
				name = "Item C",
				color = "yellow",
				hotkey = "C",
				hotkey_color = "bright_yellow",
				hotkey_style = "expanded",
				command = "echo C",
			},
		},
		{
			{
				name = "Exit Demo",
				color = "red",
				hotkey = "X",
				hotkey_color = "bright_red",
				hotkey_style = "expanded",
				command = function()
					print("Exiting demo...")
				end,
			},
		},
	},
	prompt = { text = "Fixed width test: ", color = "bright_white", location = "center" },
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- EXAMPLE 3: MANUAL SCREEN DIMENSIONS DEMO
-- ═══════════════════════════════════════════════════════════════════════════════

local function create_screen_test_menu(width, height)
	return {
		screen = { width = width, height = height }, -- Manual override
		single_keypress = true,

		title = {
			text = string.format("SCREEN TEST [%dx%d]", width, height),
			color = "bright_green",
			decoration = "box",
			decoration_color = "green",
		},
		subtitle = {
			text = "Testing manual screen dimensions",
			color = "white",
			decoration = "line",
			decoration_color = "white",
		},
		columns = 2,
		column_layout = "variable",
		menu_items = {
			{
				{
					name = "Wide Screen Test",
					color = "white",
					hotkey = "W",
					hotkey_color = "green",
					hotkey_style = "expanded",
					command = "echo Wide",
				},
				{
					name = "Normal Test",
					color = "white",
					hotkey = "N",
					hotkey_color = "green",
					hotkey_style = "expanded",
					command = "echo Normal",
				},
			},
			{
				{
					name = "Narrow Test",
					color = "white",
					hotkey = "A",
					hotkey_color = "green",
					hotkey_style = "expanded",
					command = "echo Narrow",
				},
				{
					name = "Quit Test",
					color = "red",
					hotkey = "Q",
					hotkey_color = "red",
					hotkey_style = "expanded",
					command = function()
						print("Test complete")
					end,
				},
			},
		},
		prompt = { text = "Screen test: ", color = "bright_yellow", location = "center" },
	}
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- EXAMPLE 4: ALL HOTKEY STYLES DEMO
-- ═══════════════════════════════════════════════════════════════════════════════

local hotkey_styles_config = {
	single_keypress = true,

	title = {
		text = "HOTKEY STYLES SHOWCASE",
		color = "bright_white",
		decoration = "inline_top",
		decoration_color = "blue",
	},
	subtitle = {
		text = "Try each style to see the difference",
		color = "bright_blue",
		decoration = "inline_bottom",
		decoration_color = "blue",
	},
	columns = 2,
	column_layout = "variable",
	menu_items = {
		{ -- Column 1: Traditional styles
			{
				name = "Expanded Style",
				color = "green",
				hotkey = "E",
				hotkey_color = "bright_green",
				hotkey_style = "expanded",
				command = "echo 'E - Expanded Style'",
			},
			{
				name = "Bracketed Style",
				color = "blue",
				hotkey = "B",
				hotkey_color = "bright_blue",
				hotkey_style = "bracketed",
				command = "echo '[B]racketed Style'",
			},
		},
		{ -- Column 2: Modern styles
			{
				name = "Colored Style",
				color = "yellow",
				hotkey = "C",
				hotkey_color = "bright_red",
				hotkey_style = "colored",
				command = "echo 'Colored Style'",
			},
			{
				name = "Underlined Style",
				color = "magenta",
				hotkey = "U",
				hotkey_color = "bright_magenta",
				hotkey_style = "underlined",
				command = "echo 'Underlined Style'",
			},
		},
	},
	prompt = { text = "Try a style: ", color = "bright_cyan", location = "center" },
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- EXAMPLE 5: MINIMAL MENU (No Title, No Subtitle)
-- ═══════════════════════════════════════════════════════════════════════════════

local minimal_config = {
	single_keypress = true,
	-- No title or subtitle defined
	columns = 1,
	column_layout = "variable",
	menu_items = {
		{
			{
				name = "Option 1",
				color = "white",
				hotkey = "1",
				hotkey_color = "cyan",
				hotkey_style = "bracketed",
				command = "echo Option 1",
			},
			{
				name = "Option 2",
				color = "white",
				hotkey = "2",
				hotkey_color = "cyan",
				hotkey_style = "bracketed",
				command = "echo Option 2",
			},
			{
				name = "Option 3",
				color = "white",
				hotkey = "3",
				hotkey_color = "cyan",
				hotkey_style = "bracketed",
				command = "echo Option 3",
			},
			{
				name = "Exit",
				color = "red",
				hotkey = "X",
				hotkey_color = "red",
				hotkey_style = "bracketed",
				command = function()
					print("Goodbye!")
				end,
			},
		},
	},
	prompt = { text = ">> ", color = "green", location = "left" },
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- EXAMPLE 6: TRADITIONAL ENTER-KEY MENU
-- ═══════════════════════════════════════════════════════════════════════════════

local traditional_config = {
	single_keypress = false, -- Require Enter key

	title = {
		text = "TRADITIONAL MENU",
		color = "white",
		decoration = "line",
		decoration_color = "white",
	},
	columns = 1,
	column_layout = "variable",
	menu_items = {
		{
			{
				name = "First Option",
				color = "white",
				hotkey = "1",
				hotkey_color = "yellow",
				hotkey_style = "expanded",
				command = "echo First",
			},
			{
				name = "Second Option",
				color = "white",
				hotkey = "2",
				hotkey_color = "yellow",
				hotkey_style = "expanded",
				command = "echo Second",
			},
			{
				name = "Third Option",
				color = "white",
				hotkey = "3",
				hotkey_color = "yellow",
				hotkey_style = "expanded",
				command = "echo Third",
			},
			{
				name = "Quit",
				color = "red",
				hotkey = "Q",
				hotkey_color = "red",
				hotkey_style = "expanded",
				command = function()
					print("Goodbye!")
				end,
			},
		},
	},
	prompt = { text = "Enter choice and press Enter: ", color = "cyan", location = "left" },
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- DEMO SELECTOR MENU
-- ═══════════════════════════════════════════════════════════════════════════════

local function show_demo_selector()
	print()
	print("Enhanced Menu Builder - Feature Demonstrations")
	print("=" .. string.rep("=", 50))
	print()
	print("1) Python Script Replica (Variable columns + Inline decorations)")
	print("2) Fixed Width Columns (20 chars per column)")
	print("3) Manual Screen Dimensions (test different sizes)")
	print("4) Hotkey Styles Showcase (all 4 styles)")
	print("5) Minimal Menu (no title/subtitle)")
	print("6) Traditional Menu (Enter key required)")
	print("7) Quick Menu API Demo")
	print("8) Exit")
	print()
	io.write("Choice (1-8): ")

	local choice = io.read()

	if choice == "1" then
		print("\n--- Python Script Replica Demo ---")
		print("• Variable column widths (auto-calculated)")
		print("• Single keypress input")
		print("• Inline box decorations")
		print("Press any key to start...")
		os.execute("stty raw -echo; read -n 1; stty sane")

		local menu = menu_builder.create(python_replica_config)
		menu:run(true)
	elseif choice == "2" then
		print("\n--- Fixed Width Columns Demo ---")
		print("• Each column exactly 20 characters wide")
		print("• Items padded/truncated to fit")
		print("Press any key to start...")
		os.execute("stty raw -echo; read -n 1; stty sane")

		local menu = menu_builder.create(fixed_width_config)
		menu:run(true)
	elseif choice == "3" then
		print("\n--- Manual Screen Dimensions Test ---")
		print("Enter width and height to test:")
		io.write("Width (default 80): ")
		local width = tonumber(io.read()) or 80
		io.write("Height (default 24): ")
		local height = tonumber(io.read()) or 24

		local test_config = create_screen_test_menu(width, height)
		local menu = menu_builder.create(test_config)
		menu:run(true)
	elseif choice == "4" then
		print("\n--- Hotkey Styles Showcase ---")
		print("• Expanded: 'E - Expanded Style'")
		print("• Bracketed: '[B]racketed Style'")
		print("• Colored: 'Colored Style' (first letter different color)")
		print("• Underlined: 'Underlined Style' (first letter underlined)")
		print("Press any key to start...")
		os.execute("stty raw -echo; read -n 1; stty sane")

		local menu = menu_builder.create(hotkey_styles_config)
		menu:run(true)
	elseif choice == "5" then
		print("\n--- Minimal Menu Demo ---")
		print("• No title or subtitle")
		print("• Single column")
		print("• Left-aligned prompt")
		print("Press any key to start...")
		os.execute("stty raw -echo; read -n 1; stty sane")

		local menu = menu_builder.create(minimal_config)
		menu:run(true)
	elseif choice == "6" then
		print("\n--- Traditional Menu Demo ---")
		print("• Requires Enter key after each choice")
		print("• More traditional terminal behavior")
		print("Press Enter to start...")
		io.read()

		local menu = menu_builder.create(traditional_config)
		menu:run(false) -- false = require Enter key
	elseif choice == "7" then
		print("\n--- Quick Menu API Demo ---")
		print("• Simplified menu creation")
		print("• Good for simple scripts")
		print("Press any key to start...")
		os.execute("stty raw -echo; read -n 1; stty sane")

		local quick_items = {
			{ name = "Quick Option 1", hotkey = "1", hotkey_color = "green", command = "echo Quick 1" },
			{ name = "Quick Option 2", hotkey = "2", hotkey_color = "green", command = "echo Quick 2" },
			{ name = "Quick Option 3", hotkey = "3", hotkey_color = "green", command = "echo Quick 3" },
			{
				name = "Back",
				hotkey = "B",
				hotkey_color = "red",
				command = function()
					print("Returning...")
				end,
			},
		}

		local quick_menu = menu_builder.quick_menu("QUICK MENU DEMO", quick_items, {
			title_color = "bright_yellow",
			title_decoration = "line",
			single_keypress = true,
			columns = 2,
			column_layout = "variable",
			prompt = "Quick choice: ",
			prompt_color = "cyan",
		})

		quick_menu:run(true)
	elseif choice == "8" then
		print("Goodbye!")
		os.exit(0)
	else
		print("Invalid choice!")
		io.read()
		show_demo_selector()
	end

	-- Return to selector after demo
	print("\nReturning to demo selector...")
	io.read()
	show_demo_selector()
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- FEATURE SUMMARY
-- ═══════════════════════════════════════════════════════════════════════════════

local function show_feature_summary()
	print()
	print("Enhanced Menu Builder - New Features Summary")
	print("=" .. string.rep("=", 50))
	print()
	print("COLUMN LAYOUT OPTIONS:")
	print("✅ Variable width: Auto-size based on content (like Python script)")
	print("✅ Fixed width: Specify exact character width per column")
	print("✅ Perfect alignment: No more manual spacing calculations")
	print()
	print("DECORATION ENHANCEMENTS:")
	print("✅ Inline decorations: ▐▀▀▀ TEXT ▀▀▀▌ (matches Python style)")
	print("✅ Box decorations: Full Unicode boxes")
	print("✅ Line decorations: Simple underlines")
	print("✅ Block decorations: Solid color blocks")
	print()
	print("INPUT IMPROVEMENTS:")
	print("✅ Single keypress: Immediate response (no Enter)")
	print("✅ Traditional mode: Require Enter key")
	print("✅ Special key handling: Ctrl+C, Ctrl+D support")
	print()
	print("TESTING FEATURES:")
	print("✅ Manual screen dimensions: Test different terminal sizes")
	print("✅ Screen dimension override: Width/height control")
	print("✅ Responsive layout: Adapts to any screen size")
	print()
	print("OPTIONAL COMPONENTS:")
	print("✅ Optional title: Can be omitted entirely")
	print("✅ Optional subtitle: Can be omitted entirely")
	print("✅ Optional prompt: Can be omitted entirely")
	print("✅ Flexible configuration: Only specify what you need")
	print()
	print("HOTKEY STYLES:")
	print("✅ Expanded: 'H - Home' (traditional)")
	print("✅ Bracketed: '[H]ome' (compact)")
	print("✅ Colored: 'Home' (first letter highlighted)")
	print("✅ Underlined: 'Home' (first letter underlined)")
	print()
	print("API LEVELS:")
	print("✅ Full configuration: Complete control over every aspect")
	print("✅ Quick menu: Simplified API for basic menus")
	print("✅ Template system: Copy and modify examples")
	print()
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- MAIN EXECUTION
-- ═══════════════════════════════════════════════════════════════════════════════

-- Parse command line arguments
if arg and arg[1] then
	if arg[1] == "--help" or arg[1] == "-h" then
		print("Enhanced Menu Builder Examples")
		print()
		print("Usage:")
		print("  lua example-menu.lua              # Interactive demo selector")
		print("  lua example-menu.lua --features   # Show all new features")
		print("  lua example-menu.lua --python     # Python script replica")
		print("  lua example-menu.lua --fixed      # Fixed width demo")
		print("  lua example-menu.lua --minimal    # Minimal menu demo")
		print("  lua example-menu.lua --test W H   # Test screen dimensions")
		os.exit(0)
	elseif arg[1] == "--features" then
		show_feature_summary()
		os.exit(0)
	elseif arg[1] == "--python" then
		local menu = menu_builder.create(python_replica_config)
		menu:run(true)
		os.exit(0)
	elseif arg[1] == "--fixed" then
		local menu = menu_builder.create(fixed_width_config)
		menu:run(true)
		os.exit(0)
	elseif arg[1] == "--minimal" then
		local menu = menu_builder.create(minimal_config)
		menu:run(true)
		os.exit(0)
	elseif arg[1] == "--test" and arg[2] and arg[3] then
		local width = tonumber(arg[2]) or 80
		local height = tonumber(arg[3]) or 24
		local test_config = create_screen_test_menu(width, height)
		local menu = menu_builder.create(test_config)
		menu:run(true)
		os.exit(0)
	end
end

-- Default: Show interactive demo selector
show_demo_selector()
