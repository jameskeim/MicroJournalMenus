-- menu_builder.lua - Enhanced Reusable Menu System for MicroJournal
--
-- Enhanced with variable/fixed column widths, manual screen dimensions,
-- inline decorations, single keypress input, and optional title/subtitle
--
-- Usage:
--   local menu = require('menu_builder')
--   local my_menu = menu.create(config_table)
--   my_menu:show()
--   my_menu:handle_input()

local M = {}

-- ═══════════════════════════════════════════════════════════════════════════════
-- COLOR SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local colors = {
	black = "\027[30m",
	red = "\027[31m",
	green = "\027[32m",
	yellow = "\027[33m",
	blue = "\027[34m",
	magenta = "\027[35m",
	cyan = "\027[36m",
	white = "\027[37m",
	bright_black = "\027[90m",
	bright_red = "\027[91m",
	bright_green = "\027[92m",
	bright_yellow = "\027[93m",
	bright_blue = "\027[94m",
	bright_magenta = "\027[95m",
	bright_cyan = "\027[96m",
	bright_white = "\027[97m",
	reset = "\027[0m",
	bold = "\027[1m",
	dim = "\027[2m",
	underline = "\027[4m",
	blink = "\027[5m",
	reverse = "\027[7m",
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════

local function get_terminal_dimensions()
	-- Try multiple methods to get terminal size
	local width, height = 80, 24 -- defaults

	-- Method 1: tput
	local handle = io.popen("tput cols 2>/dev/null")
	if handle then
		local w = tonumber(handle:read("*a"))
		handle:close()
		if w then
			width = w
		end
	end

	handle = io.popen("tput lines 2>/dev/null")
	if handle then
		local h = tonumber(handle:read("*a"))
		handle:close()
		if h then
			height = h
		end
	end

	-- Method 2: stty (fallback)
	if width == 80 or height == 24 then
		handle = io.popen("stty size 2>/dev/null")
		if handle then
			local size_output = handle:read("*a")
			handle:close()
			local h, w = size_output:match("(%d+)%s+(%d+)")
			if h and w then
				height = tonumber(h) or height
				width = tonumber(w) or width
			end
		end
	end

	return width, height
end

local function strip_colors(text)
	return text:gsub("\027%[[0-9;]*m", "")
end

local function colorize(text, color_name)
	if not color_name or not colors[color_name] then
		return text
	end
	return colors[color_name] .. text .. colors.reset
end

local function center_text(text, width)
	local clean_text = strip_colors(text)
	local padding = math.max(0, (width - #clean_text) / 2)
	return string.rep(" ", math.floor(padding)) .. text
end

local function left_align(text, width)
	return text
end

local function right_align(text, width)
	local clean_text = strip_colors(text)
	local padding = math.max(0, width - #clean_text)
	return string.rep(" ", padding) .. text
end

local function get_single_keypress()
	-- Lua implementation of single keypress (similar to Python's approach)
	os.execute("stty raw -echo")
	local char = io.read(1)
	os.execute("stty sane")
	return char
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- COLUMN WIDTH CALCULATION
-- ═══════════════════════════════════════════════════════════════════════════════

local function calculate_variable_column_widths(menu_items, total_width, columns)
	local col_widths = {}

	-- Find the longest item in each column
	for col = 1, columns do
		local max_width = 0
		local column_items = menu_items[col] or {}

		for _, item in ipairs(column_items) do
			if item then
				local formatted_text = format_menu_item(item)
				local clean_text = strip_colors(formatted_text)
				max_width = math.max(max_width, #clean_text)
			end
		end

		-- Add spacing between columns (except last column)
		if col < columns then
			col_widths[col] = max_width + 1
		else
			col_widths[col] = max_width -- No extra space for last column
		end
	end

	return col_widths
end

local function calculate_fixed_column_widths(total_width, columns, fixed_width)
	local col_widths = {}

	if fixed_width then
		-- Use specified fixed width for all columns
		for col = 1, columns do
			col_widths[col] = fixed_width
		end
	else
		-- Distribute width evenly
		local width_per_col = math.floor(total_width / columns)
		for col = 1, columns do
			col_widths[col] = width_per_col
		end
	end

	return col_widths
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- DECORATION FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════

local function create_block_decoration(text, width, decoration_color)
	local block_char = "█"
	local decoration = colorize(string.rep(block_char, width), decoration_color)
	return decoration
end

local function create_line_decoration(text, width, decoration_color, char)
	char = char or "="
	local clean_text = strip_colors(text)
	local text_width = #clean_text
	local line_width = math.max(text_width, math.min(width, text_width + 4))
	local decoration = colorize(string.rep(char, line_width), decoration_color)
	return center_text(decoration, width)
end

local function create_inline_box_decoration(text, width, decoration_color, style)
	-- Inline box decorations (like your Python script)
	local clean_text = strip_colors(text)
	local text_width = #clean_text

	if style == "top" then
		-- Top border: ▐▀▀▀▀▀▀ TEXT ▀▀▀▀▀▀▌
		local border_width = math.max(6, (width - text_width - 2) / 2)
		local left_border = colorize("▐" .. string.rep("▀", math.floor(border_width)), decoration_color)
		local right_border = colorize(string.rep("▀", math.floor(border_width)) .. "▌", decoration_color)
		return center_text(left_border .. " " .. text .. " " .. right_border, width)
	elseif style == "bottom" then
		-- Bottom border: ▐▄▄▄ TEXT ▄▄▄▌
		local border_width = math.max(3, (width - text_width - 2) / 2)
		local left_border = colorize("▐" .. string.rep("▄", math.floor(border_width)), decoration_color)
		local right_border = colorize(string.rep("▄", math.floor(border_width)) .. "▌", decoration_color)
		return center_text(left_border .. " " .. text .. " " .. right_border, width)
	elseif style == "sides" then
		-- Side borders only: ▐ TEXT ▌
		local left_border = colorize("▐", decoration_color)
		local right_border = colorize("▌", decoration_color)
		return center_text(left_border .. " " .. text .. " " .. right_border, width)
	end

	return center_text(text, width)
end

local function create_box_decoration(text, width, decoration_color)
	local clean_text = strip_colors(text)
	local text_width = #clean_text
	local box_width = math.max(text_width + 4, 20)

	local top = colorize("╔" .. string.rep("═", box_width - 2) .. "╗", decoration_color)
	local middle = colorize("║", decoration_color)
		.. string.rep(" ", box_width - 2)
		.. colorize("║", decoration_color)
	local bottom = colorize("╚" .. string.rep("═", box_width - 2) .. "╝", decoration_color)

	return {
		center_text(top, width),
		center_text(middle, width),
		center_text(bottom, width),
	}
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- HOTKEY STYLING FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════

local function format_hotkey_expanded(name, hotkey, color, hotkey_color)
	local formatted_hotkey = colorize(hotkey:upper(), hotkey_color)
	local formatted_name = colorize(name, color)
	return formatted_hotkey .. " - " .. formatted_name
end

local function format_hotkey_bracketed(name, hotkey, color, hotkey_color)
	local formatted_hotkey = "[" .. colorize(hotkey:upper(), hotkey_color) .. "]"
	local rest_of_name = name:sub(2)
	local formatted_name = colorize(rest_of_name, color)
	return formatted_hotkey .. formatted_name
end

local function format_hotkey_colored(name, hotkey, color, hotkey_color)
	local first_char = colorize(hotkey:upper(), hotkey_color)
	local rest_of_name = colorize(name:sub(2), color)
	return first_char .. rest_of_name
end

local function format_hotkey_underlined(name, hotkey, color, hotkey_color)
	local formatted_hotkey = colorize(colors.underline .. hotkey:upper() .. colors.reset, hotkey_color)
	local rest_of_name = colorize(name:sub(2), color)
	return formatted_hotkey .. rest_of_name
end

local hotkey_formatters = {
	expanded = format_hotkey_expanded,
	bracketed = format_hotkey_bracketed,
	colored = format_hotkey_colored,
	underlined = format_hotkey_underlined,
}

-- Forward declaration for menu item formatting
function format_menu_item(item)
	local formatter = hotkey_formatters[item.hotkey_style or "expanded"]
	return formatter(item.name, item.hotkey, item.color, item.hotkey_color)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- MENU CLASS
-- ═══════════════════════════════════════════════════════════════════════════════

local Menu = {}
Menu.__index = Menu

function Menu:new(config)
	local menu = setmetatable({}, Menu)
	menu.config = config

	-- Screen dimensions (with manual override support)
	if config.screen and config.screen.width and config.screen.height then
		menu.width = config.screen.width
		menu.height = config.screen.height
	else
		menu.width, menu.height = get_terminal_dimensions()
	end

	menu.hotkey_map = {}

	-- Build hotkey mapping for fast lookup
	menu:build_hotkey_map()

	return menu
end

function Menu:build_hotkey_map()
	if not self.config.menu_items then
		return
	end

	for col_idx, column in ipairs(self.config.menu_items) do
		for _, item in ipairs(column) do
			if item.hotkey then
				self.hotkey_map[item.hotkey:lower()] = item
			end
		end
	end
end

function Menu:render_title()
	if not self.config.title then
		return {}
	end

	local lines = {}
	local title_config = self.config.title
	local text = colorize(title_config.text, title_config.color)

	-- Add accent color if specified
	if title_config.accent_color then
		text = colorize(text, title_config.accent_color)
	end

	-- Add decorations
	if title_config.decoration == "block" then
		table.insert(
			lines,
			center_text(create_block_decoration(text, self.width, title_config.decoration_color), self.width)
		)
		table.insert(lines, center_text(text, self.width))
		table.insert(
			lines,
			center_text(create_block_decoration(text, self.width, title_config.decoration_color), self.width)
		)
	elseif title_config.decoration == "line" then
		table.insert(lines, center_text(text, self.width))
		table.insert(lines, create_line_decoration(text, self.width, title_config.decoration_color))
	elseif title_config.decoration == "double_line" then
		table.insert(lines, create_line_decoration(text, self.width, title_config.decoration_color, "═"))
		table.insert(lines, center_text(text, self.width))
		table.insert(lines, create_line_decoration(text, self.width, title_config.decoration_color, "═"))
	elseif title_config.decoration == "inline_top" then
		table.insert(lines, create_inline_box_decoration(text, self.width, title_config.decoration_color, "top"))
	elseif title_config.decoration == "inline_sides" then
		table.insert(lines, create_inline_box_decoration(text, self.width, title_config.decoration_color, "sides"))
	elseif title_config.decoration == "box" then
		local box_lines = create_box_decoration(text, self.width, title_config.decoration_color)
		for _, line in ipairs(box_lines) do
			table.insert(lines, line)
		end
		-- Insert text in the middle of the box
		table.insert(lines, #lines - 1, center_text(text, self.width))
	else
		table.insert(lines, center_text(text, self.width))
	end

	return lines
end

function Menu:render_subtitle()
	if not self.config.subtitle then
		return {}
	end

	local lines = {}
	local subtitle_config = self.config.subtitle
	local text = colorize(subtitle_config.text, subtitle_config.color)

	if subtitle_config.accent_color then
		text = colorize(text, subtitle_config.accent_color)
	end

	if subtitle_config.decoration == "line" then
		table.insert(lines, center_text(text, self.width))
		table.insert(lines, create_line_decoration(text, self.width, subtitle_config.decoration_color, "-"))
	elseif subtitle_config.decoration == "block" then
		table.insert(
			lines,
			center_text(create_block_decoration(text, self.width, subtitle_config.decoration_color), self.width)
		)
		table.insert(lines, center_text(text, self.width))
	elseif subtitle_config.decoration == "inline_bottom" then
		table.insert(lines, create_inline_box_decoration(text, self.width, subtitle_config.decoration_color, "bottom"))
	elseif subtitle_config.decoration == "inline_sides" then
		table.insert(lines, create_inline_box_decoration(text, self.width, subtitle_config.decoration_color, "sides"))
	else
		table.insert(lines, center_text(text, self.width))
	end

	return lines
end

function Menu:render_menu_items()
	if not self.config.menu_items or #self.config.menu_items == 0 then
		return {}
	end

	local lines = {}
	local columns = self.config.columns or 1

	-- Calculate column widths
	local col_widths
	if self.config.column_layout == "fixed" then
		col_widths = calculate_fixed_column_widths(self.width, columns, self.config.fixed_column_width)
	else
		-- Default to variable width (like your Python script)
		col_widths = calculate_variable_column_widths(self.config.menu_items, self.width, columns)
	end

	-- Find the maximum number of items in any column
	local max_items = 0
	for _, column in ipairs(self.config.menu_items) do
		max_items = math.max(max_items, #column)
	end

	-- Render each row
	for row = 1, max_items do
		local line_parts = {}

		for col = 1, columns do
			local column_items = self.config.menu_items[col] or {}
			local item = column_items[row]

			if item then
				local formatted_item = format_menu_item(item)

				if col == columns then
					-- Last column, just add the item
					table.insert(line_parts, formatted_item)
				else
					-- Not last column, pad to column width
					local clean_item = strip_colors(formatted_item)
					local padding = math.max(0, col_widths[col] - #clean_item)
					table.insert(line_parts, formatted_item .. string.rep(" ", padding))
				end
			else
				-- Empty cell
				if col < columns then
					table.insert(line_parts, string.rep(" ", col_widths[col]))
				end
			end
		end

		local full_line = table.concat(line_parts)
		table.insert(lines, center_text(full_line, self.width))
	end

	return lines
end

function Menu:render_prompt()
	if not self.config.prompt then
		return {}
	end

	local prompt_config = self.config.prompt
	local text = colorize(prompt_config.text, prompt_config.color)

	local line
	if prompt_config.location == "left" then
		line = left_align(text, self.width)
	elseif prompt_config.location == "right" then
		line = right_align(text, self.width)
	else
		line = center_text(text, self.width)
	end

	return { line }
end

function Menu:show()
	os.execute("clear")

	local all_lines = {}

	-- Render all components (only if they exist)
	local title_lines = {}
	local subtitle_lines = {}
	local menu_lines = {}
	local prompt_lines = {}

	if self.config.title then
		title_lines = self:render_title()
	end

	if self.config.subtitle then
		subtitle_lines = self:render_subtitle()
	end

	if self.config.menu_items then
		menu_lines = self:render_menu_items()
	end

	if self.config.prompt then
		prompt_lines = self:render_prompt()
	end

	-- Combine all lines with spacing
	if #title_lines > 0 then
		table.insert(all_lines, "") -- Top spacing
		for _, line in ipairs(title_lines) do
			table.insert(all_lines, line)
		end
	end

	if #subtitle_lines > 0 then
		if #title_lines > 0 then
			table.insert(all_lines, "") -- Spacing between title and subtitle
		else
			table.insert(all_lines, "") -- Top spacing if no title
		end
		for _, line in ipairs(subtitle_lines) do
			table.insert(all_lines, line)
		end
	end

	if #menu_lines > 0 then
		table.insert(all_lines, "") -- Spacing before menu
		for _, line in ipairs(menu_lines) do
			table.insert(all_lines, line)
		end
	end

	if #prompt_lines > 0 then
		table.insert(all_lines, "") -- Spacing before prompt
		for _, line in ipairs(prompt_lines) do
			table.insert(all_lines, line)
		end
	end

	-- Print all lines
	for _, line in ipairs(all_lines) do
		print(line)
	end

	-- Position cursor after prompt if needed
	if self.config.prompt then
		io.write("") -- Keep cursor at end of prompt
	end
end

function Menu:handle_input(single_keypress)
	local choice

	if single_keypress == nil then
		single_keypress = self.config.single_keypress or false
	end

	if single_keypress then
		choice = get_single_keypress()
		-- Handle special keys
		if choice == "\003" then -- Ctrl+C
			return false
		elseif choice == "\004" then -- Ctrl+D
			return false
		end
	else
		choice = io.read()
	end

	if not choice then
		return false
	end

	choice = choice:lower():gsub("%s+", "") -- Clean input

	local item = self.hotkey_map[choice]
	if item and item.command then
		if type(item.command) == "function" then
			item.command()
		elseif type(item.command) == "string" then
			print()
			print(center_text(colorize("Launching...", "bright_yellow"), self.width))
			os.execute(item.command)
		end
		return true
	else
		print(center_text(colorize("Invalid choice: " .. choice, "bright_red"), self.width))
		if not single_keypress then
			io.read() -- Wait for user to press enter (only if not single keypress mode)
		else
			os.execute("sleep 1") -- Brief pause for single keypress mode
		end
		return true
	end
end

function Menu:run(single_keypress)
	while true do
		self:show()
		if not self:handle_input(single_keypress) then
			break
		end
	end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- PUBLIC API
-- ═══════════════════════════════════════════════════════════════════════════════

function M.create(config)
	return Menu:new(config)
end

-- Convenience function for simple menus
function M.quick_menu(title, items, options)
	options = options or {}

	local config = {
		columns = options.columns or 1,
		menu_items = { items },
		column_layout = options.column_layout or "variable",
		single_keypress = options.single_keypress or false,
	}

	-- Only add title if provided
	if title then
		config.title = {
			text = title,
			color = options.title_color or "bright_cyan",
			decoration = options.title_decoration or "line",
			decoration_color = options.decoration_color or "white",
		}
	end

	-- Only add prompt if provided
	if options.prompt then
		config.prompt = {
			text = options.prompt,
			color = options.prompt_color or "bright_yellow",
			location = options.prompt_location or "center",
		}
	end

	-- Manual screen dimensions if provided
	if options.screen_width and options.screen_height then
		config.screen = {
			width = options.screen_width,
			height = options.screen_height,
		}
	end

	return Menu:new(config)
end

return M
