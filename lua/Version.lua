local timepoints = require("Timepoints")
local tasks = require("Tasks")

-- code is simply, but people is complex, so everyone should balance code process and people communication

local M = {}

-- user_format_path is for putting userdefined TasksFormat.json and Timepoints.json file
-- hidden_path is for putting tasks.json which is set all tasks commands and other propertises
function M.setup(user_format_path, user_tasks_path)
	-- every should specify version in Timepoints.json, if your do not specify, we will use default version
	M.timepoints = timepoints.setup(user_format_path)

	local taskshandler = tasks.setup(user_format_path, user_tasks_path)

	taskshandler(M.timepoints)
end

return M
