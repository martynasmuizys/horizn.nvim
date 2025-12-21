local icons = require("horizn.icons")
local hl = require("horizn.highlights").groups
local s = require("horizn.state")

local M = {}

local function get_count(buf)
	return s.state[buf].diagnostics or { h = 0, w = 0, e = 0 }
end
function M.get_diagnostics(buf)
	local count = get_count(buf)
	if not count or (count.h == 0 and count.w == 0 and count.e == 0) then
		return ""
	end
	local diag = { hl.text2 .. "|" .. hl.reset }

	if count.h > 0 then
		table.insert(diag, hl.hint .. icons.hint .. " " .. count.h .. hl.reset)
	end
	if count.w > 0 then
		table.insert(diag, hl.warn .. icons.warn .. " " .. count.w .. hl.reset)
	end
	if count.e > 0 then
		table.insert(diag, hl.error .. icons.error .. " " .. count.e .. hl.reset)
	end
	local test = table.concat(diag, " ")
	return test
end

function M.async_update(buf)
	vim.schedule(function()
		if not vim.api.nvim_buf_is_valid(buf) then
			return
		end

		local diags = vim.diagnostic.get(buf)
		local count = { h = 0, w = 0, e = 0 }

		for _, d in ipairs(diags) do
			if d.severity == 1 then
				count.e = count.e + 1
			elseif d.severity == 2 then
				count.w = count.w + 1
			elseif d.severity == 4 then
				count.h = count.h + 1
			end
		end

		s.state[buf] = s.state[buf] or {}
		s.state[buf].diagnostics = count
		vim.cmd("redrawstatus")
	end)
end

function M.setup()
	local grp = vim.api.nvim_create_augroup("HoriznGroup", { clear = false })

	vim.api.nvim_create_autocmd({ "InsertLeave" }, {
		group = grp,
		callback = function(args)
			M.async_update(args.buf)
		end,
	})
	vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, {
		group = grp,
		callback = function(args)
			if vim.api.nvim_get_mode().mode:match("^i") then
				return
			end
			M.async_update(args.buf)
		end,
	})
end

return M
