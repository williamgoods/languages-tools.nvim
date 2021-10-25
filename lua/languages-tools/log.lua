local lib = require("languages-tools/lib")

local log = {}

vim.g.languages_tools_log_path = "/home/williamgoods/languages_tools_log"

function log.record(msg)
	lib.FileOpration(vim.g.languages_tools_log_path, "a", function (filehandler)
		filehandler:write(msg .. "\n")
	end)
end

return log



