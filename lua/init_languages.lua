local vim = vim
local version = require("lua.Version")

local M = {}

-- local log = require("languages-tools/log")
local lib = require("languages-tools/lib")
local languages_tools = require("languages-tools")

local ok, gitdir = lib.CheckGitDirectory()

-- project rules presentation
-- use another file to present it
local project_rules = {
	rust = {
		rule1 = {
			"Cargo.toml", "src/main.rs"
		}
	},
	go = {
		rule1 = {
			"go.mod", "src/main.go"
		},
		rule2 = {
			"go.mod", "main.go"
		}
	},
	cpp = {
		rule1 = {
			"main.cpp"
		}
	}
}

local match_rules = {}

if ok then
	local user_rules = vim.g.languages_tools_project_rules

	local rules = vim.tbl_deep_extend("force", {}, project_rules, user_rules or {})
	tprint(rules)

	for language, language_rules in pairs(rules) do
		for rulename, filerules in pairs(language_rules) do
			local language_ok = true

			for _, filename in ipairs(filerules) do
				local file = gitdir .. "/" .. filename
				local exist, _ = lib.exists(file)

				if not exist then
					language_ok = false
				end
			end

			if language_ok then
				if not match_rules[language] then
					match_rules[language] = {}
				else
					match_rules[language][#match_rules[language]+1] = rulename
				end
			end
		end
	end
end

print("gitdir: " .. gitdir)

-- local user_tasks_path = vim.g.languages_tools_tasks_path
-- local system_tasks_path = vim.g.languages_tools_system_task_path
-- local project_tasks_path = gitdir .. "/.language/tasks.json"

local tasks_path = {}

local scan_tasks_driectory = function (tasks_directory)
	if tasks_directory then
		for language, _ in pairs(match_rules) do
			local tasks_json_path = tasks_directory .. "/" .. language .. "/tasks.json"

			if lib.exists(tasks_json_path) then
				tasks_path[#tasks_path+1] = tasks_json_path
			end
		end
	end
end

scan_tasks_driectory(vim.g.languages_tools_tasks_path)
scan_tasks_driectory(vim.g.languages_tools_system_task_path)
tasks_path[#tasks_path+1] = gitdir .. "/.language/tasks.json"

print("I want to know task_path:")
tprint(tasks_path)

-- if vim.g.languages_tools_tasks_path then
	-- for language, _ in pairs(match_rules) do
		-- local tasks_json_path = vim.g.languages_tools_tasks_path .. "/" .. language .. "/tasks.json"
--
		-- if lib.exists(tasks_json_path) then
			-- tasks_path[#tasks_path+1] = tasks_json_path
		-- end
	-- end
-- end

function M.RunProject()
	print("run our project")
	if #match_rules == 0 then
		print("this project can not find any command in languages-tools")
	else
		-- if match some rules, we should push into task pool depend on itself language
		version.setup("", tasks_path, match_rules)
	end

	-- if match_language == "" then
		-- print("this project can not find any command in languages-tools")
	-- else
		-- print("match_language: " .. match_language)
		-- languages_tools.ShowCommands(match_language, gitdir)
	-- end
end

M.RunProject()

return M

