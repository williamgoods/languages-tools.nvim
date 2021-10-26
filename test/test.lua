-- vim.api.nvim_command([[
	-- let &runtimepath = &runtimepath .. ",/home/williamgoods/Github/languages-tools.nvim"
-- ]])
--
-- local languages_tools = require("languages-tools")
--
-- -- languages_tools.add({go = {"go build"}})
-- languages_tools.ShowCommands("rust")

-- local gitdir = vim.fn.substitute(vim.fn.system("git rev-parse --show-toplevel 2>&1 | grep -v fatal:"), '\n','','g')
--
-- local return_result = 0
--
-- if gitdir ~= '' and vim.fn.isdirectory(gitdir) then
	-- return_result = 1
-- end
--
-- print("gitdir: " .. gitdir)
-- print("return_result " .. return_result)

-- local function tprint (tbl, indent)
	-- if not indent then indent = 0 end
	-- for k, v in pairs(tbl) do
		-- local formatting = string.rep("  ", indent) .. k .. ": "
		-- if type(v) == "table" then
			-- print(formatting)
			-- tprint(v, indent+1)
		-- else
			-- print(formatting .. v)
		-- end
	-- end
-- end
--
-- local buildin_rules = {
	-- rust = {
		-- rule1 = {
			-- "Cargo.toml", "main.rs"
		-- }
	-- }
-- }
--
-- local user_rules = {
	-- rust = {
		-- rule1 = {
			-- "go.mod"
		-- }
	-- }
-- }
--
-- local rules = vim.tbl_deep_extend("keep", {}, buildin_rules, user_rules or {})
--
-- tprint(rules, 1)
vim.api.nvim_command([[
	let &runtimepath = &runtimepath .. ",/home/williamgoods/Github/languages-tools.nvim"
]])

local init_languages = require("lua/init")
init_languages.RunProject()
