local M = {}

if not vim.g.languages_tools_check_log then
	vim.g.languages_tools_check_log  = false
end

-- we should add log model to our parse process

function M.setup()
	M.ParseRules = {
		[ "string" ] = M.ParseString,
		[ "bool" ] = M.ParseBool,
		[ "map" ] = M.ParseMap,
		[ "limitedmap" ]  = M.ParseLimitedMap,
		[ "directory" ] = M.ParseDirectory,
		[ "limiteddirectory" ] = M.ParseLimitedDirectory,
		[ "list" ] = M.ParseList,
		-- [ "limitedlist" ] = M.ParseLimitedList,
	}

	return M
end

function M.Check(ObjectsFormat, Objects)
	local type = ObjectsFormat["type"]

	local typehandler = M.ParseRules[type]

	return typehandler(ObjectsFormat, Objects)
end

function M.ParseString(_, object)
	if vim.g.languages_tools_check_log then
		print("parse current string: " .. tostring(object))
	end
	if type(object) == "string" then
		return true
	else
		if vim.g.languages_tools_check_log then
			print("ParseString false")
		end

		return false
	end
end

function M.ParseBool(_, object)
	if vim.g.languages_tools_check_log then
		print("parse current bool: " .. tostring(object))
	end

	if object == "true" or object == "false" then
		return true
	else
		if vim.g.languages_tools_check_log then
			print("ParseBool false")
		end

		return false
	end
end

function M.ParseMap(ObjectsFormat, Objects)
	if vim.g.languages_tools_check_log then
		print("enter ParseMap")
	end

	local format = ObjectsFormat['elemformat']
	local keytype = format['key']
	local valuetype = format['value']

	local key = Objects['key']
	local value = Objects['value']

	local ok = true
	local input_format = keytype

	if type(keytype) == "string" then
		input_format = {type = keytype}
	end

	ok = M.Check(input_format, key)

	if not ok then
		if vim.g.languages_tools_check_log then
			print("ParseMap false")
		end

		return false
	end

	input_format = valuetype

	if type(valuetype) == "string" then
		input_format = {type = valuetype}
	end

	ok = M.Check(input_format, value)

	if not ok then
		if vim.g.languages_tools_check_log then
			print("ParseMap false")
		end

		return false
	end

	return true
end

function M.ParseLimitedMap(ObjectsFormat, Objects)
	if vim.g.languages_tools_check_log then
		print("enter ParseLimitedMap")
	end

	local format = ObjectsFormat['elemformat']
	local keydefalut = format['key']
	local valuetype = format['value']

	local key = Objects['key']
	local value = Objects['value']

	if key ~= keydefalut then
		if vim.g.languages_tools_check_log then
			print("ParseLimitedMap false")
		end

		return false
	end

	local input_format = valuetype

	if type(valuetype) == "string" then
		input_format = {type = valuetype}
	end

	local ok = M.Check(input_format, value)

	if not ok then
		if vim.g.languages_tools_check_log then
			print("ParseLimitedMap false")
		end

		return false
	end

	return true
end

function M.ParseExtendFirst(format, Objects)
	local filtermap = M.FilterMapOnExtend(format)

	if not filtermap then
		return true, false
	end

	if type(format) == "string" then
		for _, obj in ipairs(Objects) do
			local ok = M.ParseRules[format](format, obj)

			if not ok then
				return true, false
			end
		end

		return true, true
	else
		return false, _
	end
end

function M.FilterMapOnExtend(format)
	if format ~= 'map' then
		return true
	else
		return false
	end
end

function M.ParseExtendElemFormat(objectformat, name, object)
	local ok = true

	-- tprint(objectformat)
	if objectformat['type'] == 'map' or objectformat['type'] == 'limitedmap' then
		if vim.g.languages_tools_check_log then
			print("to Parse***Map function args: ".."{ key = " .. name .. ", value = " .. tostring(object) .. "}")
		end

		ok = M.Check(objectformat, {key = name, value = object})
	else
		ok = M.Check(objectformat, object)
	end

	return ok
end

function M.ParseDirectory(ObjectsFormat, Objects)
	if vim.g.languages_tools_check_log then
		print("enter ParseDirectory")
	end

	local format = ObjectsFormat["elemformat"]

	local directreturn, extendparsefirst = M.ParseExtendFirst(format, Objects)
	if directreturn then
		return extendparsefirst
	end


	if vim.g.languages_tools_check_log then
		tprint(Objects)
	end

	for _, object in pairs(Objects) do
		local ok = M.Check(format, object)

		if not ok then
			if vim.g.languages_tools_check_log then
				print("parsedirectory false")
			end

			return false
		end
	end

	return true
end

function M.ParseLimitedDirectory(ObjectsFormat, Objects)
	if vim.g.languages_tools_check_log then
		print("enter ParseLimitedDirectory")
	end

	local format = ObjectsFormat["elemformat"]

	local directreturn, extendparsefirst = M.ParseExtendFirst(format, Objects)
	if directreturn then
		return extendparsefirst
	end

	for objformatname, objformat in pairs(format) do
		local ok = M.Check(objformat, Objects[objformatname])

		if not ok then
			if vim.g.languages_tools_check_log then
				print("parsedirectory false")
			end

			return false
		end
	end

	-- for objname, obj in pairs(Objects) do
		-- local ok = M.Check(ObjectsFormat[objname], obj)
--
		-- if not ok then
			-- print("parsedirectory false")
			-- return false
		-- end
	-- end

	return true
end

-- function M.ParseLimitedList(ObjectsFormat, Objects)
	-- print("enter ParseLimitedList")
	-- local format = ObjectsFormat["elemformat"]
--
	-- local directreturn, extendparsefirst = M.ParseExtendFirst(format, Objects)
	-- if directreturn then
		-- return extendparsefirst
	-- end
--
	-- -- for index = 1, vim.tbl_count(format) do
		-- -- local objformat = format[tostring(index)]
-- --
		-- -- local limitedkey = objformat['elemformat']['key']
-- --
		-- -- local ok = M.ParseExtendElemFormat(objformat, limitedkey, Objects[limitedkey])
-- --
		-- -- if not ok then
				-- -- print("ParseLimitedList false")
			-- -- return false
		-- -- end
	-- -- end
--
	-- local index = 1
--
	-- for name, obj in pairs(Objects) do
		-- print("\n")
		-- print("name: " .. name .. ", object: " .. obj)
		-- print("\n")
--
		-- local objformat = format[tostring(index)]
--
		-- local ok = M.ParseExtendElemFormat(objformat, name, obj)
--
		-- index = index + 1
--
		-- if not ok then
				-- print("ParseLimitedList false")
			-- return false
		-- end
	-- end
--
	-- return true
-- end

function M.ParseList(ObjectsFormat, Objects)
	if vim.g.languages_tools_check_log then
		print("enter ParseList")
	end

	local format = ObjectsFormat['elemformat']

	local directreturn, extendparsefirst = M.ParseExtendFirst(format, Objects)
	if directreturn then
		return extendparsefirst
	end

	for _, obj in pairs(Objects) do
		for filedname, field in pairs(obj) do
			local objformat = format[filedname]

			local ok = M.ParseExtendElemFormat(objformat, filedname, field)

			if not ok then
				if vim.g.languages_tools_check_log then
					print("ParseList false")
				end

				return false
			end
		end
	end

	return true
end

M.setup()

return M
