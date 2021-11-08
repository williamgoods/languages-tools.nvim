local vim = vim

local log = require("languages-tools.log")
local lib = require("languages-tools.lib")
local buidin_cmd = {
	rust = {
		{"cargo install","cargo install --path ."},
		{"cargo run"},
		{"cargo build"}
	},
	go = {
		{"gorun", "go run main.go"},
		{"gobuild", "go build"},
		{"GoBuildAndRun", "go build -o main && ./main"}
	},
	cpp = {
		{"CplusplusMainRun", "g++ main.cpp -o main && ./main"}
	}
}

local M = setmetatable({cmd = buidin_cmd}, {})

function M.setup()
	M.cmd = buidin_cmd
end

function M.load(custom_commands)
	M.cmd = vim.tbl_deep_extend("force", {}, M.cmd, custom_commands or {})
end

-- custom presentation:
-- 	language key : command identifier list
-- 	eg: {"rust" = {1, 2}}
function M.remove(command)
	for language_handler, remove_list in pairs(command) do
		local language = M.cmd[language_handler]

		if language ~= nil then
			for _, remove_index in ipairs(remove_list) do
				table.remove(language, remove_index)
			end
		else
			log.record("you are remove a language do not support in language-tools")
		end
	end
end

-- custom presentation:
-- 	eg: {rust = {"cargo run", "cargo build"}}
function M.add(command)
	for language_handler, add_list in pairs(command) do
		local language = M.cmd[language_handler]

		if language ~= nil then
			for _, add_command in ipairs(add_list) do
				table.insert(language, add_command)
			end
		else
			log.record("you are add a language do not support in language-tools")
		end
	end
end

function M.choice_command(choice)
	local task = _G['languages_tools_tasks_pool'][choice]
	M.run_command(task[#task])
end

-- return command status after running
function M.run_command(command)
	log.record("current command: " .. command)
	local current_path = vim.fn.getcwd()

	vim.api.nvim_command("cd " .. M.gitdir)

	vim.api.nvim_command("botright split")
	vim.api.nvim_command("execute \"terminal " .. command .. "\"")
	vim.api.nvim_command("normal! G")
	-- log.record("run_command path: " .. vim.fn.getcwd())

	vim.api.nvim_command("cd " .. current_path)
end

function M.UiRender(match_commands)
	local pickers = require "telescope.pickers"
	local finders = require "telescope.finders"
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	M.languages_tools = {}

	if match_commands == nil then
		print("current project commands is empty")
	else
		print("current project commands is not empty")
	end

	-- this section copy from rust-tools.nvim
	local function attach_mappings(bufnr, map)
			local function on_select()
					local entry = action_state.get_selected_entry()
					if entry == nil then
						local current_line = action_state.get_current_line()
						log.record("current line: ".. current_line)

						actions.close(bufnr)
						M.run_command(current_line)
					else
						local choice = entry.index

						log.record("my choice is " .. choice)

						actions.close(bufnr)
						M.choice_command(choice)
					end
			end

			-- local function show_history()
				-- actions.close(bufnr)
				-- log.record("the operation will show history")
			-- end

			map('n', '<CR>', on_select)
			map('i', '<CR>', on_select)
			-- map('n', '<C-h>', show_history)
			-- map('i', '<C-h>', show_history)

			-- Additional mappings don't push the item to the tagstack.
			return true
	end

	M.languages_tools.ui = nil
	M.languages_tools.ui = function(opts)
		pickers.new(opts, {
			prompt_title = "languages-tools",
			finder = finders.new_table {
				results = match_commands,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry[1],
						ordinal = entry[1],
					}
				end
			},
			sorter = conf.generic_sorter(opts),
			attach_mappings = attach_mappings,
		}):find()
	end
end

function M.ShowCommands(match_commands, gitdir)
		M.gitdir = gitdir
		print("ShowCommands match_commands: ")
		tprint(match_commands)
		-- M.setup()
		M.UiRender(match_commands)
		M.languages_tools.ui()
end

return M
