local lib = require("lua.languages-tools.lib")
local check = require("lua.Check").setup()

local M = {}

function M.setup(user_format_path, user_tasks_path)
	-- if user do not specify user-defined TasksFormat.json, we will use default TasksFormat.json file
	local taskformatfile = user_format_path .. "/TasksFormat.json"

	if not lib.exists(taskformatfile) then
		taskformatfile = "lua/TasksFormat.json"
	end

	local tasksfile = user_tasks_path .. "/tasks.json"

	if not lib.exists(tasksfile) then
		tasksfile = "lua/tasks.json"
	end

	local TasksFormat = lib.DecodeJsonFile(taskformatfile)
	local Tasks = lib.DecodeJsonFile(tasksfile)

	tprint(TasksFormat)
	tprint(Tasks)

	local ok = true

	for fieldname, field in pairs(TasksFormat) do
		print(fieldname)
		ok = ok and check.Check(field, Tasks[fieldname])
	end

	print("~~~~~~~~~~~~~~~~~~~~~~ok: " .. tostring(ok))

	return function(timepoints)
		if ok then
			if timepoints.version == Tasks.version then
				-- local taskhandler = tasks['handler'] and tasks['handler'] or DefaultTaskHandler
				local taskhandler = M.DefaultTaskHandler

				for _, task in ipairs(Tasks.tasks) do
					local result = taskhandler(timepoints, task)

					if result[ 'belong' ] then
						M.PutIntoTaskPool(result['name'], result['command'])
					end
				end
			else
				print("your Timepoints.json's version is not compatible with tasks.json")
			end
		else
			print("your TasksFormat.json file is not compatible with tasks.json")
			print("detailed message you can see log of languages-tools projects")
		end
	end
end

function M.DefaultTaskHandler(timepoints, task)
	if M.Before(timepoints['before'], task) then
		local result = M.Process(timepoints['process'], task)

		result = M.After(timepoints['after'], result, task)

		return M.Return(timepoints['return'], result, task)
	end
end

function M.Before(beforefunctions, task)
	local result = true

	for _, beforefunction in ipairs(beforefunctions) do
		result = result and beforefunction(task)
	end

	return result
end

function M.Process(processfucntions, task)
	local result = {}

	for name, processfunction in pairs(processfucntions) do
		result[name] = processfunction(task)
	end

	return result
end

function M.After(afterfunctions, result, task)
	for _, afterfunction in ipairs(afterfunctions) do
		result = afterfunction(result, task)
	end

	return result
end

function M.Return(returnfuntions, result, task)
	return result
end

function M.PutIntoTaskPool(taskanme, taskexecution)
end

M.setup("/home/williamgoods", "/home/williamgoods")

return M
