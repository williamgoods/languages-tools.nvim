local M = {}

-- we should add log model to our parse process

function M.setup()
	M.ParseRules = {
		[ "string" ] = M.ParseString,
		[ "bool" ] = M.ParseBool,
		[ "map" ] = M.ParseMap,
		[ "limitedmap" ]  = M.ParseLimitedMap,
		[ "directory" ] = M.ParseDirectory,
		[ "list" ] = M.ParseList,
		[ "limitedlist" ] = M.ParseLimitedList,
	}

	return M
end

function M.Check(ObjectsFormat, Objects)
	local type = ObjectsFormat["type"]

	local typehandler = M.ParseRules[type]

	return typehandler(ObjectsFormat, Objects)
end

function M.ParseString(_, object)
	print("parse current string: " .. tostring(object))
	if type(object) == "string" then
		return true
	else
		print("ParseString false")
		return false
	end
end

function M.ParseBool(_, object)
	if object == "true" or object == "false" then
		return true
	else
		print("ParseBool false")
		return false
	end
end

function M.ParseMap(ObjectsFormat, Objects)
	print("enter ParseMap")
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
		print("ParseMap false")
		return false
	end

	input_format = valuetype

	if type(valuetype) == "string" then
		input_format = {type = valuetype}
	end

	ok = M.Check(input_format, value)

	if not ok then
		print("ParseMap false")
		return false
	end

	return true
end

function M.ParseLimitedMap(ObjectsFormat, Objects)
	print("enter ParseLimitedMap")
	local format = ObjectsFormat['elemformat']
	local keydefalut = format['key']
	local valuetype = format['value']

	local key = Objects['key']
	local value = Objects['value']

	-- tprint(Objects)
	-- tprint(format)
	print("keydefalut: " .. keydefalut)

	print("----- ParseLimitedMap key: " .. key .. ", value: " .. value)
	if key ~= keydefalut then
		print("ParseLimitedMap false")
		return false
	end

	local input_format = valuetype

	if type(valuetype) == "string" then
		input_format = {type = valuetype}
	end

	local ok = M.Check(input_format, value)

	if not ok then
		print("ParseLimitedMap false")
		return false
	end

	return true
end

function M.ParseExtendFirst(format, Objects)
	local filtermap = M.FilterMapOnExtend(format)

	if not filtermap then
		return true, filtermap
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
		print("---- to Parse***Map function args: ".."{ key = " .. name .. ", value = " .. tostring(object) .. "}")
		ok = M.Check(objectformat, {key = name, value = object})
	else
		ok = M.Check(objectformat, object)
	end

	return ok
end

function M.ParseDirectory(ObjectsFormat, Objects)
	print("enter ParseDirectory")
	local format = ObjectsFormat["elemformat"]

	local directreturn, extendparsefirst = M.ParseExtendFirst(format, Objects)
	if directreturn then
		return extendparsefirst
	end

	tprint(Objects)
		for _, object in pairs(Objects) do
			local ok = M.Check(format, object)

			if not ok then
				print("ParseDirectory false")
				return false
			end
	end

	return true
end

function M.ParseLimitedList(ObjectsFormat, Objects)
	print("enter ParseLimitedList")
	local format = ObjectsFormat["elemformat"]

	local directreturn, extendparsefirst = M.ParseExtendFirst(format, Objects)
	if directreturn then
		return extendparsefirst
	end

	local index = 1

	for name, obj in pairs(Objects) do
		print("\n")
		print("name: " .. name .. ", object: " .. obj)
		print("\n")

		local objformat = format[tostring(index)]

		local ok = M.ParseExtendElemFormat(objformat, name, obj)

		index = index + 1

		if not ok then
				print("ParseLimitedList false")
			return false
		end
	end

	return true
end

function M.ParseList(ObjectsFormat, Objects)
	print("enter ParseList")
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
				print("ParseList false")
				return false
			end
		end
	end

	return true
end

M.setup()


return M
