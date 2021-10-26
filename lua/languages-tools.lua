local vim = vim

local log = require("languages-tools/log")
local lib = require("languages-tools/lib")


local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local buidin_cmd = {
	rust = {
		"cargo install --path .",
		"cargo run",
		"cargo build"
	},
	go = {
	}
}

-- project rules presentation
-- use another file to present it 
local project_rules = {
	rust = {
		rule1 = {
			"Cargo.toml", "main.rs"
		}
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

function M.choice_command(language, choice)
	local languagehandler = M.cmd[language]
	log.record(languagehandler[choice])

	M.run_command(languagehandler[choice])
end

-- return command status after running
function M.run_command(command)
	log.record("current command: " .. command)
	local current_path = vim.fn.getcwd()

	vim.api.nvim_command("cd " .. M.gitdir)

	vim.api.nvim_command("botright split")
	vim.api.nvim_command("execute \"terminal " .. command .. "\"")
	vim.api.nvim_command("normal! G")
	log.record("run_command path: " .. vim.fn.getcwd())

	vim.api.nvim_command("cd " .. current_path)
end

function M.UiRender(language)
	M.languages_tools = {}
	local current_language = M.cmd[language]
	if current_language == nil then
		print("current language commands is empty")
	else
		print("current language commands is not empty")
	end

	-- this section copy from rust-tools.nvim
	local function attach_mappings(bufnr, map)
			local function on_select()
					local entry = action_state.get_selected_entry()
					if entry == nil then
						local current_line = action_state.get_current_line()
						log.record("current line: ".. current_line)
						M.run_command(current_line)

						actions.close(bufnr)
					else
						local choice = entry.index

						log.record("my choice is " .. choice)

						M.choice_command(language, choice)

						actions.close(bufnr)
					end
			end

			local function show_history()
				actions.close(bufnr)
				log.record("the operation will show history")
			end

			map('n', '<CR>', on_select)
			map('i', '<CR>', on_select)
			map('n', '<C-h>', show_history)
			map('i', '<C-h>', show_history)

			-- Additional mappings don't push the item to the tagstack.
			return true
	end

	M.languages_tools.ui = nil
	M.languages_tools.ui = function(opts)
		pickers.new(opts, {
			prompt_title = language,
			finder = finders.new_table {
				results = current_language
			},
			sorter = conf.generic_sorter(opts),
			attach_mappings = attach_mappings,
		}):find()
	end
end

function M.ShowCommands(language, gitdir)
		M.gitdir = gitdir
		-- M.setup()
		M.UiRender(language)
		M.languages_tools.ui()
end

return M
