# horizn.nvim

Minimalistic and easy to use statusline. Works out of the box. I think.

![screenshot1](./images/screenshot1.png)

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    "martynasmuizys/horizn.nvim",
	dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
	config = function()
		require("horizn").setup({})
	end,
}
```

## Configuration
```lua
require("horizn").setup({
	diagnostics = true,
	git = true,
    -- Optionally you can configure custom colors.
    -- Configuration also possible through theme config.
	colors = {
        text = "#00ffff", -- StatusLine
        text2 = "#6e6a86", -- StatusLineNC
        hint = "#00ffff", -- DiagnosticsHint
        warn = "#f6c117", -- DiagnosticsWarn
        error = "#fc7f72", -- DiagnosticsError

    },
})
```
