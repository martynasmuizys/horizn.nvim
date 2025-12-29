local icons = require("horizn.icons")
local hl = require("horizn.highlights").groups
local devicons = require("nvim-web-devicons")

local M = {}

function M.get_filename(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return ""
	end
	local path = vim.api.nvim_buf_get_name(buf or 0)
	local ft = vim.bo.filetype
	if ft == "oil" then
		path = require("oil").get_current_dir(buf)
	end

	if ft == "netrw" or ft == "oil" then
		if not path then
			return " " .. hl.text .. icons.netrw .. " " .. vim.api.nvim_buf_get_name(0) .. hl.reset
		end
		return " " .. hl.text .. icons.netrw .. " " .. vim.fn.fnamemodify(path, ":~") .. hl.reset
	end

	path = vim.fn.fnamemodify(path, ":t")
	local fext = vim.fn.expand("%:e")
	local icon = devicons.get_icon(path, fext, { default = false }) or devicons.get_icon_by_filetype(ft) or "\u{e6ae}" -- neovim icon
	return " " .. hl.text .. icon .. " " .. path .. hl.reset
end

return M
