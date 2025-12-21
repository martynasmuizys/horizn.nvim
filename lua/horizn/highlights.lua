local M = {}

function M.setup(colors)
	if colors.text then
		vim.api.nvim_set_hl(0, "StatusLine", { fg = colors.text })
	end
	if colors.text2 then
		vim.api.nvim_set_hl(0, "StatusLineNC", { fg = colors.text2 })
	end
	if colors.hint then
		vim.api.nvim_set_hl(0, "StatusHint", { fg = colors.hint })
	end
	if colors.warn then
		vim.api.nvim_set_hl(0, "StatusWarn", { fg = colors.warn })
	end
	if colors.err then
		vim.api.nvim_set_hl(0, "StatusError", { fg = colors.error })
	end
end

M.groups = {
	text = "%#StatusLine#",
	text2 = "%#StatusLineNC#",
	error = "%#DiagnosticError#",
	warn = "%#DiagnosticWarn#",
	hint = "%#DiagnosticHint#",
	reset = "%*",
}

return M
