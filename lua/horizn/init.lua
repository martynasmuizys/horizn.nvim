local M = {}
local d = require("horizn.diagnostics")
local f = require("horizn.filename")
local hl = require("horizn.highlights")
local git = require("horizn.git")
local s = require("horizn.state")

local config = {
	diagnostics = true,
	git = true,
	colors = {},
}

M.render = function()
	return " "
end
local render
local build

local function init()
	local buf = vim.api.nvim_get_current_buf()
	if vim.api.nvim_buf_is_valid(buf) then
		s.state[buf] = s.state[buf] or {}
		d.async_update(buf)
		git.get_branch(buf)
		s.state[buf].fname = f.get_filename()
		s.last_render = build(s.state[buf], buf)
		M.render = render
	end
end

function M.setup(opts)
	local grp = vim.api.nvim_create_augroup("HoriznGroup", { clear = true })

	opts = opts or {}
	config = vim.tbl_deep_extend("force", config, opts)

	if config.diagnostics then
		d.setup()
	end
	if config.git then
		git.setup()
	end

	f.setup()
	hl.setup(config.colors)
	init()

	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "BufWritePost", "Filetype" }, {
		group = grp,
		callback = function(args)
			if vim.api.nvim_buf_is_valid(args.buf) then
				s.state[args.buf] = s.state[args.buf] or {}

				d.async_update(args.buf)
				git.get_branch(args.buf)
				s.state[args.buf].fname = f.get_filename(args.buf)
			end
		end,
	})

	vim.opt.statusline = "%!v:lua.require'horizn'.render()"
end

build = function(state, buf)
	local line = {
		state.fname,
	}

	if config.git then
		table.insert(line, state.git_branch)
	end

	if config.diagnostics then
		table.insert(line, d.get_diagnostics(buf))
	end

	table.insert(line, hl.groups.text2 .. "%=")
	table.insert(line, "[" .. vim.bo[buf].filetype .. "]")
	table.insert(line, "%3l:%-3c %4P" .. hl.groups.reset)

	return table.concat(line, " ")
end

render = function()
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
	local state = s.state[buf]
	-- if state then
	-- 	return s.last_render
	-- end

	s.last_render = build(state, buf)
	return s.last_render
end

return M
