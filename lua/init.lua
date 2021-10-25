local vim = vim

local log = require("languages-tools/log")
local lib = require("languages-tools/lib")
local languages_tools = require("languages-tools")

local ok, gitdir = lib.CheckGitDirectory()

-- project rules presentation
-- use another file to present it 
local project_rules = {
	rust = {
		rule1 = {
			"Cargo.toml", "main.rs"
		}
	}
}

local match_language = ""

if ok then
	local user_rules = vim.g.languages_tools_project_rules

	local rules = vim.tbl_deep_extend("force", {}, project_rules, user_rules or {})

	for language, language_rules in pairs(rules) do
		local language_ok = true
		for _, filename in ipairs(language_rules) do
			local exist, _ = lib.exists(gitdir .. "/" .. filename)
			if not exist then
				language_ok = false
			end
		end

		if language_ok then
			match_language = language
			break
		end
	end
end

function RunProject()
	if match_language == "" then
		vim.fn.nvim_command("echo this project can not find any command in languages-tools")
	else
		languages_tools.ShowCommands(match_language)
	end
end

RunProject()
