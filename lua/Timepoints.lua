local lib = require("languages-tools.lib")

local M = {}

function M.setup(user_timpoint_path)
	-- find Timepoint file, if user not set, it will be our defined version's Timepoint.json file
	local timepointsfile = user_timpoint_path .. "/Timepoints.json"

	if not lib.exists(timepointsfile) then
		timepointsfile = "lua/Timepoints.json"
	end

	local raw_timepoints = lib.DecodeJsonFile(timepointsfile)

	M.timepoints = {}
	-- put this into user, can make user add a prefix to all about timepoint function
	local prefix = "tasks"
	M.timepoints.tasks = {}
	M.ParseRawTimepoints(prefix, raw_timepoints.tasks)

	M.timepoints.version = raw_timepoints.version

	-- tprint(M.timepoints)

	return M.timepoints
end

function M.ParseRawTimepoints(prefix, raw_timepoints)
	for key, value in pairs(raw_timepoints) do
		if type(value) == "string" then
			if not M.timepoints.tasks[value] then
				M.timepoints.tasks[value] = {}
			end

			table.insert(M.timepoints.tasks[value], #M.timepoints.tasks[value] + 1, prefix .. "_" .. key)
		else
			M.ParseRawTimepoints(prefix .. "_" .. key, value)
		end
	end
end

-- M.setup("/home/williamgoods")

return M
