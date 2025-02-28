# cmp-gfm-headings

A Neovim plugin for autocompleting GitLab Flavored Markdown (GFM) headings using the `nvim-cmp`.

## Features

- Autocompletes GFM headings in Markdown files.
- Shows heading levels and a preview of the content below the heading.
- Configurable number of preview lines.

## Installation

Using `lazy.nvim`:

```lua
{
  'bosha/cmp-gfm-headings',
  config = function()
    require('cmp-gfm-headings').setup({
      preview_lines = 5, -- Adjust to the number of lines to preview
    })
  end,
}
```

Set up the new source for `nvim-cmp`:

```lua
	{
		"hrsh7th/nvim-cmp",
		config = function()
			local cmp = require("cmp")
			...
			cmp.setup({
				sources = cmp.config.sources({
					...
					{ name = "cmp-gfm-headings" },
					...
				}),
			})
		end,
	},
```

**Note that part of the `nvim-cmp` configuration is omitted with dots.**
