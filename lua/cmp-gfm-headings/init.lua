local M = {}

-- Default configuration
M.config = {
	preview_lines = 5, -- Number of lines to show in the documentation preview
}

-- Function to extract headings from the current buffer
local function get_headings()
	local headings = {}
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	for i, line in ipairs(lines) do
		-- Match Markdown headings (e.g., ## Heading)
		local level, heading = line:match("^(#+)%s+(.+)$")
		if level and heading then
			-- Convert to GFM format: lowercase and replace spaces with dashes
			local gfm_heading = heading:lower():gsub("%s+", "-")
			-- Get the next few lines for documentation (up to `preview_lines` lines, excluding other headings)
			local documentation = {}
			for j = i + 1, i + M.config.preview_lines do
				if j > #lines then
					break
				end
				local next_line = lines[j]
				if next_line:match("^#+%s+") then
					break
				end -- Stop if another heading is found
				table.insert(documentation, next_line)
			end
			table.insert(headings, {
				level = level,                         -- Heading level (e.g., ##)
				heading = heading,                     -- Original heading text
				gfm_heading = gfm_heading,             -- GFM-formatted heading
				documentation = table.concat(documentation, "\n"), -- Content below the heading
			})
		end
	end

	return headings
end

local source = {}

source.new = function()
	return setmetatable({}, { __index = source })
end

-- Only trigger when typing `[<any character>](#` in a Markdown file
source.get_trigger_characters = function()
	return { "#" } -- Trigger on `#` after `[<any character>](`
end

source.is_available = function()
	-- Only enable in Markdown files
	return vim.bo.filetype == "markdown"
end

source.complete = function(self, request, callback)
	local line = vim.api.nvim_get_current_line()
	local cursor_col = request.context.cursor.col

	-- Check if the pattern `[<any character>](#` is present before the cursor
	local text_before_cursor = line:sub(1, cursor_col)
	if not text_before_cursor:match("%[[^%]]+%]%(%#%s*$") then
		return callback({ items = {}, isIncomplete = false })
	end

	-- Get headings and format them as completion items
	local headings = get_headings()
	local items = {}

	for _, h in ipairs(headings) do
		table.insert(items, {
			label = h.level .. " " .. h.heading,
			insertText = h.gfm_heading,
			documentation = {
				kind = "markdown",
				value = "**" .. h.gfm_heading .. "**\n\n" .. h.documentation,
			}, -- Show heading and content below
		})
	end

	callback({ items = items, isIncomplete = false })
end

-- Register the source with nvim-cmp
M.setup = function(opts)
	-- Merge user options with defaults
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	require("cmp").register_source("gfm_headings", source.new())
end

return M
