local vim = vim

local M = {}

local log = require("languages-tools/log")
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
	}
}

gitdir = "/home/williamgoods/Github/RustProject/rust_test"

local match_language = ""

if ok then
	local user_rules = vim.g.languages_tools_project_rules

	local rules = vim.tbl_deep_extend("force", {}, project_rules, user_rules or {})
	tprint(rules)

	for language, language_rules in pairs(rules) do
		local language_ok = true
		for _, filerules in pairs(language_rules) do
			for _, filename in ipairs(filerules) do
				local file = gitdir .. "/" .. filename
				local exist, _ = lib.exists(file)

				if not exist then
					language_ok = false
				end
			end
		end

		if language_ok then
			match_language = language
			break
		end
	end
end

print("gitdir: " .. gitdir)

function M.RunProject()
	if match_language == "" then
		print("this project can not find any command in languages-tools")
	else
		print("match_language: " .. match_language)
		languages_tools.ShowCommands(match_language, gitdir)
	end
end

return M

