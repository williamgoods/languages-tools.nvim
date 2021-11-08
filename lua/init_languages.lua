local vim = vim
local version = require("Version")
-- local log = require("languages-tools/log")
local lib = require("languages-tools.lib")
local languages_tools = require("languages-tools")

local M = {}

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
local tasks_path = {}

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
					match_rules[language][#match_rules[language]+1] = rulename
				else
					match_rules[language][#match_rules[language]+1] = rulename
				end
			end
		end
	end

	-- local user_tasks_path = vim.g.languages_tools_tasks_path
	-- local system_tasks_path = vim.g.languages_tools_system_task_path
	-- local project_tasks_path = gitdir .. "/.language/tasks.json"

	local scan_tasks_driectory = function (tasks_directory)
		if tasks_directory then
			for language, _ in pairs(match_rules) do
				local tasks_json_path = tasks_directory .. "/" .. language .. "/tasks.json"
				print("add tasks_json_path: " .. tasks_json_path)

				if lib.exists(tasks_json_path) then
					tasks_path[#tasks_path+1] = tasks_json_path
				end
			end
		end
	end

	scan_tasks_driectory(vim.g.languages_tools_tasks_path)
	scan_tasks_driectory(vim.g.languages_tools_system_task_path)
	if lib.exists(gitdir .. "/.language/tasks.json") then
		tasks_path[#tasks_path + 1] = gitdir .. "/.language/tasks.json"
	end

	print("I want to know task_path:")
	tprint(tasks_path)
end

print("gitdir: " .. gitdir)
print("match rules: ")
tprint(match_rules)

function M.RunProject()
	print("run our project")
	tprint(match_rules)
	print("match_rules: " .. vim.tbl_count(match_rules))

	if not ok then
		print("your project should be a git repository")
	else
		if vim.tbl_count(match_rules) == 0 then
			print("this project can not find any command in languages-tools")
		else
			_G['languages_tools_tasks_pool'] = {}
			-- if match some rules, we should push into task pool depend on itself language
			version.setup("/home/williamgoods/Github/languages-tools.nvim/lua", tasks_path, match_rules)
			print("vim.g.languages_tools_tasks_pool: " )
			tprint(_G['languages_tools_tasks_pool'])
			languages_tools.ShowCommands(_G['languages_tools_tasks_pool'], gitdir)
		end
	end
end

-- M.RunProject()

return M

