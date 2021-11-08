
local M = {}

function M.tasks_belongrules(result, task, match_rules)
	local belongrules = task.belongrules
	local ok = false

	for language, rules in pairs(belongrules) do
		local filter_rules = match_rules[language]

		for _, rule in ipairs(rules) do
			-- test if rule in match_rules[language]
			ok = vim.tbl_contains(filter_rules, rule)

			if ok then
				break
			end
		end

		if ok then
			break
		end
	end

	result['filter_ok'] = ok

	return result
end

function M.tasks_default(result, task, match_rules)
	local default = task.default

	return result
end

function M.tasks_class(result, task, match_rules)
	local class = task.class

	return result
end

function M.tasks_name(result, task)
	local name = task.name

	result['name'] = name

	return result
end

function M.tasks_command(result, task)
	local commands = task.command

	local final_commmand = "clear"

	for _, command in ipairs(commands) do
		-- table.insert(result['command'], #result['command'], command)
		final_commmand = final_commmand .. "&&" .. command
	end

	result['command'] = final_commmand
	return result
end

function M.tasks_options_cwd(result, task)
	local cwd = task['options'].cwd

	-- set cwd

	return result
end

function M.tasks_options_shell(result, task)
	local shell = task['options'].shell

	--set your shell

	return result
end

return M
