local icons = require("horizn.icons")
local hl = require("horizn.highlights").groups
local devicons = require("nvim-web-devicons")

local M = {}

local start
local base

function M.setup()
	start = vim.fn.getcwd(-1, -1)
	base = vim.fn.fnamemodify(start, ":t")
end

function M.get_filename()
	local filetype = vim.bo.filetype
	if filetype == "netrw" then
		local full = vim.api.nvim_buf_get_name(0)

		if full == "" then
			return " " .. hl.text .. icons.netrw .. " " .. base .. hl.reset
		end

		local start_norm = start
		if start_norm:sub(-1) ~= "/" then
			start_norm = start_norm .. "/"
		end

		if full:sub(1, #start_norm) ~= start_norm then
			return " " .. hl.text .. icons.netrw .. " " .. full .. hl.reset
		end

		local rel = full:sub(#start_norm + 1)
		return " " .. hl.text .. icons.netrw .. " " .. base .. "/" .. rel .. hl.reset
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
