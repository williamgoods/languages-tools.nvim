local lib = require("languages-tools.lib")
local check = require("Check")

local M = {}

function M.setup(user_format_path, tasks_pathes, match_rules)
	-- if user do not specify user-defined TasksFormat.json, we will use default TasksFormat.json file
	local taskformatfile = user_format_path .. "/TasksFormat.json"

	if not lib.exists(taskformatfile) then
		taskformatfile = "lua/TasksFormat.json"
	end

	-- local tasksfile = user_tasks_path .. "/tasks.json"
	--
	-- if not lib.exists(tasksfile) then
		-- tasksfile = "lua/tasks.json"
	-- end

	local TasksFormat = lib.DecodeJsonFile(taskformatfile)

	local TasksPathMap = {}

	for _, tasks_path in ipairs(tasks_pathes) do
		-- print("tasks_path: " .. tasks_path)
		local Tasks = lib.DecodeJsonFile(tasks_path)

		TasksPathMap[tasks_path] = Tasks
	end

	return function(timepoints, timepointoperation)
		for tasks_path, Tasks in pairs(TasksPathMap) do
			local ok = true

			for fieldname, field in pairs(TasksFormat) do
				-- print(fieldname)
				ok = ok and check.Check(field, Tasks[fieldname])
			end

			if ok then
				if timepoints.version == Tasks.version then
					-- local taskhandler = tasks['handler'] and tasks['handler'] or DefaultTaskHandler
					local taskhandler = M.DefaultTaskHandler

					for _, task in ipairs(Tasks.tasks) do
						-- tprint(task)
						-- tprint(timepoints.tasks)
						local result = taskhandler(timepoints.tasks, task, timepointoperation, match_rules)

						if result['filter_ok'] then
							M.PutIntoTaskPool(result['name'], result['command'])
						end
					end
				else
					print("your Timepoints.json's version is not compatible with tasks.json")
				end
			else
				print("your TasksFormat.json file is not compatible with " .. tasks_path)
				print("detailed message you can see log of languages-tools projects")
			end
		end
	end
		-- local Tasks = lib.DecodeJsonFile(task_path)
end

function M.DefaultTaskHandler(timepoints, task, timepointoperation, match_rules)
	local result = {}

	result = M.Before(timepoints['before'], result, task, timepointoperation, match_rules)

	result = M.Process(timepoints['process'], result, task, timepointoperation)

	result = M.After(timepoints['after'], result, task, timepointoperation)

	return M.Return(timepoints['return'], result, task, timepointoperation)
end

function M.Before(beforefunctions, result, task, timepointoperation, match_rules)
	for _, beforefunction in ipairs(beforefunctions) do
		result = timepointoperation[ beforefunction ](result, task, match_rules)
	end

	return result
end

function M.Process(processfucntions, result, task, timepointoperation)
	for _, processfunction in ipairs(processfucntions) do
		result = timepointoperation[ processfunction ](result, task)
	end

	return result
end

function M.After(afterfunctions, result, task, timepointoperation)
	for _, afterfunction in ipairs(afterfunctions) do
		result = timepointoperation[ afterfunction ](result, task)
	end

	return result
end

function M.Return(returnfuntions, result, task, timepointoperation)
	return result
end

function M.PutIntoTaskPool(taskname, taskexecution)
	if not _G['languages_tools_tasks_pool'] then
		_G['languages_tools_tasks_pool'] = {}
	end

	local task = {}
	task[#task+1] = taskname
	task[#task+1] = taskexecution
	_G['languages_tools_tasks_pool'][#_G['languages_tools_tasks_pool']+1] = task

	-- print("taskname: " .. taskname .. ", taskexecution: " .. taskexecution)
end

return M
