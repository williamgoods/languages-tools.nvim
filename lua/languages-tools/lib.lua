local lib = {}
local json = require("json")

function lib.delete_buf(bufnr)
	if bufnr ~= nil then
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end
end

function lib.split(vertical, bufnr)
	local cmd = vertical and "vsplit" or "split"

	vim.cmd(cmd)
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, bufnr)
end

function lib.resize(vertical, amount)
	local cmd = vertical and "vertical resize " or "resize"
	cmd = cmd .. amount

	vim.cmd(cmd)
end

function lib.FileOpration(filename, operation, filefunc)
	local file = io.open(filename, operation)
	filefunc(file)
	file:close()
end

function lib.DecodeJsonFile(filename)
	local return_content = ""

	lib.FileOpration(filename, "r", function (filehandler)
		return_content = json.decode(filehandler:read("*all"))
	end)

	return return_content
end

function lib.CheckGitDirectory()
	local gitdir = vim.fn.substitute(
		vim.fn.system("git rev-parse --show-toplevel 2>&1 | grep -v fatal:"),
		'\n',
		'',
		'g')

	local return_result = 0

	if gitdir ~= '' and vim.fn.isdirectory(gitdir) then
		return_result = 1
	end

	return return_result, gitdir
end

function lib.exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

function tprint (tbl, indent)
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
		local formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "table" then
			print(formatting)
			tprint(v, indent+1)
		else
			print(formatting .. v)
		end
	end
end

return lib


