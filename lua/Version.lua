local timepoints = require("lua.Timepoints")
local tasks = require("lua.Tasks")
local timepointoperation = require("lua.TimepointOperation")

-- code is simply, but people is complex, so everyone should balance code process and people communication

local M = {}

-- user_format_path is for putting userdefined TasksFormat.json and Timepoints.json file
-- hidden_path is for putting tasks.json which is set all tasks commands and other propertises
function M.setup(user_format_path, tasks_pathes, match_rules, usertimepointoperation)
	if usertimepointoperation then
		timepointoperation = usertimepointoperation
	end

	-- every should specify version in Timepoints.json, if your do not specify, we will use default version
	M.timepoints = timepoints.setup(user_format_path)
	-- tprint(timepoints)

	local taskshandler = tasks.setup(user_format_path, tasks_pathes, match_rules)

	taskshandler(M.timepoints, timepointoperation)
end

-- M.setup("/home/williamgoods", "/home/williamgoods")

return M
