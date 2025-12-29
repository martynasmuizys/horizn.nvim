local M = {}
local d = require("horizn.diagnostics")
local f = require("horizn.filename")
local hl = require("horizn.highlights")
local s = require("horizn.state")

local config = {
	diagnostics = true,
	colors = {},
}

local build

local function init()
	local buf = vim.api.nvim_get_current_buf()
	if vim.api.nvim_buf_is_valid(buf) then
		s.state[buf] = s.state[buf] or {}
		s.state[buf].fname = f.get_filename(buf)
		s.last_render = build(s.state[buf], buf)
	end
end

local function update(args)
	if vim.api.nvim_buf_is_valid(args.buf) then
		s.state[args.buf] = s.state[args.buf] or {}
		s.state[args.buf].fname = f.get_filename(args.buf)
		vim.api.nvim_exec_autocmds("User", { pattern = "StatuslineUpdate" })
	end
end

function M.setup(opts)
	local grp = vim.api.nvim_create_augroup("Horizn", { clear = true })

	opts = opts or {}
	config = vim.tbl_deep_extend("force", config, opts)

	if config.diagnostics then
		d.setup()
	end

	hl.setup(config.colors)
	init()

	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "BufWritePost", "VimEnter" }, {
		group = grp,
		callback = update,
	})

	vim.api.nvim_create_autocmd({ "FileType" }, {
		group = grp,
		pattern = "netrw",
		callback = update,
	})

	vim.api.nvim_create_autocmd("User", {
		group = grp,
		pattern = "StatuslineUpdate",
		callback = function()
			local ft = vim.o.filetype
			if ft == "oil" then
				vim.opt.winbar = M.render("wb")
				vim.opt.statusline = " "
			else
				vim.opt.statusline = M.render("sl")
				vim.opt.winbar = ""
			end
		end,
	})
end

build = function(state, buf, type)
	local line = {
		state.fname,
	}

	if config.diagnostics then
		table.insert(line, d.get_diagnostics(buf))
	end

	if type ~= "wb" then
		table.insert(line, hl.groups.text2 .. "%=")
		table.insert(line, "[" .. vim.bo[buf].filetype .. "]")
		table.insert(line, "%3l:%-3c %4P" .. hl.groups.reset)
	end

	return table.concat(line, " ")
end

function M.render(type)
	if vim.fn.pumvisible() == 1 then
		return s.last_render
	end
	if vim.api.nvim_win_get_config(0).relative ~= "" then
		return s.last_render
	end
	local bt = vim.bo.buftype
	if bt == "nofile" then
		vim.opt_local.statusline = " "
		return s.last_render
	elseif bt ~= "" then
		return s.last_render
	end

	local buf = vim.api.nvim_get_current_buf()

	s.last_render = build(s.state[buf], buf, type)
	return s.last_render
end

return M
