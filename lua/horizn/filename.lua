local icons = require("horizn.icons")
local hl = require("horizn.highlights").groups
local devicons = require("nvim-web-devicons")

local M = {}

local cwd

function M.setup()
	cwd = vim.fn.expand("%:p")
end

function M.get_filename(buf)
	local filetype = vim.bo.filetype
	if filetype == "netrw" then
		local full = vim.api.nvim_buf_get_name(buf)

		if full == "" then
			return " " .. hl.text .. icons.netrw .. " " .. cwd .. hl.reset
		end

		return " " .. hl.text .. icons.netrw .. " " .. full .. hl.reset
	end

	local fname = vim.api.nvim_buf_get_name(0)
	fname = vim.fn.fnamemodify(fname, ":t")
	local fext = vim.fn.expand("%:e")
	local icon = devicons.get_icon(fname, fext, { default = false })
		or devicons.get_icon_by_filetype(filetype)
		or "\u{e6ae}" -- neovim icon
	return " " .. hl.text .. icon .. " " .. fname .. hl.reset
end

return M
