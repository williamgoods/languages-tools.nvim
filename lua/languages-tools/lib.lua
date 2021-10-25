local lib = {}


function lib.FileOpration(filename, operation, filefunc)
	local file = io.open(filename, operation)
	filefunc(file)
	file:close()
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

return lib


