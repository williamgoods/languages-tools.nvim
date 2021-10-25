vim.api.nvim_command([[
	let &runtimepath = &runtimepath .. ",/home/williamgoods/Github/languages-tools.nvim"
]])

local languages_tools = require("languages-tools")

-- languages_tools.add({go = {"go build"}})
languages_tools.ShowCommands("rust")
