local icons = require("horizn.icons")
local s = require("horizn.state")
local hl = require("horizn.highlights").groups

local M = {}

function M.setup()
	local grp = vim.api.nvim_create_augroup("HoriznGroup", { clear = false })
	vim.api.nvim_create_autocmd({ "FocusGained" }, {
		group = grp,
		callback = function(args)
			if vim.api.nvim_buf_is_valid(args.buf) then
				M.get_branch(args.buf)
			end
		end,
	})
end

function M.get_branch(buf)
	local name = vim.api.nvim_buf_get_name(buf)
	local dir = vim.fn.fnamemodify(name, ":p:h")

	vim.system({
		"git",
		"-C",
		dir,
		"branch",
		"--show-current",
		"2>/dev/null",
	}, { text = true }, function(res)
		if res.code == 0 then
			s.state[buf].git_branch = hl.text2 .. icons.branch .. " " .. res.stdout:gsub("%s+", "") .. hl.reset
			vim.schedule(function()
				vim.cmd("redrawstatus")
			end)
		else
			s.state[buf].git_branch = ""
		end
	end)
end

return M
