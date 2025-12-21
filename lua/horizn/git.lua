local icons = require("horizn.icons")
local s = require("horizn.state")
local hl = require("horizn.highlights").groups

local M = {}

function M.setup()
	local grp = vim.api.nvim_create_augroup("HoriznGroup", { clear = false })
	-- idk if needed
	-- vim.api.nvim_create_autocmd({ "DirChanged" }, {
	-- 	group = grp,
	-- 	callback = function(args)
	-- 		if vim.api.nvim_buf_is_valid(args.buf) then
	-- 			s.state[args.buf].git_branch = M.get_branch()
	-- 		end
	-- 	end,
	-- })
end

function M.get_branch()
	local buf = vim.api.nvim_get_current_buf()
	local name = vim.api.nvim_buf_get_name(buf)

	if name == "" or vim.bo[buf].buftype ~= "" then
		local cwd = vim.fn.expand("%:p")
		local head = vim.fn
			.system({
				"git",
				"-C",
				cwd,
				"branch",
				"--show-current",
				"2>/dev/null",
			})
			:gsub("%s+", "")

		if head then
			return hl.text2 .. icons.branch .. " " .. head .. hl.reset
		end
		return nil
	end

	local dir = vim.fn.fnamemodify(name, ":p:h")

	local ok = vim.fn
		.system({
			"git",
			"-C",
			dir,
			"rev-parse",
			"--is-inside-work-tree",
		})
		:match("true")

	if not ok then
		return nil
	end

	local head = vim.fn
		.system({
			"git",
			"branch",
			"--show-current",
			"2>/dev/null",
		})
		:gsub("%s+", "")
	return hl.text2 .. icons.branch .. " " .. head .. hl.reset
end

return M
