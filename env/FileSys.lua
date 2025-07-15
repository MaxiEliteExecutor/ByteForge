local env = getfenv(0)
local HttpService = game:GetService('HttpService')
local function sendRequest(options, timeout)
	timeout = tonumber(timeout) or math.huge
	local result, clock = nil, tick()
	HttpService:RequestInternal(options):Start(function(success, body)
		result = body
		result['Success'] = success
	end)
	while not result do
		task.wait()
		if tick() - clock > timeout then
			break
		end
	end
	return result
end
env.writefile = function(path, content, append)
	-- Strict validation
	assert(type(path) == "string" and path ~= "", "writefile: path must be non-empty string")
	assert(path:match("%..+$"), "writefile: file extension required (e.g. '.txt')")
	assert(type(content) == "string", "writefile: content must be string")

	local result = sendRequest({
		Url = "http://localhost:7646/writefile",
		Method = "POST",
		Body = HttpService:JSONEncode({
			path = path,
			content = content,
			append = append and true or false
		}),
		Headers = {["Content-Type"] = "application/json"}
	}, 3)

	return result and result.Success
end

env.readfile = function(path)
	assert(type(path) == "string" and path ~= "", "readfile: path must be non-empty string")

	local result = sendRequest({
		Url = "http://localhost:7646/readfile",
		Method = "POST",
		Body = HttpService:JSONEncode({path = path}),
		Headers = {["Content-Type"] = "application/json"}
	}, 3)

	if not result or not result.Success then return nil end
	local success, decoded = pcall(HttpService.JSONDecode, HttpService, result.Body)
	return success and decoded.content
end

env.makefolder = function(path)
	assert(type(path) == "string" and path ~= "", "makefolder: path must be non-empty string")

	local result = sendRequest({
		Url = "http://localhost:7646/makefolder",
		Method = "POST",
		Body = HttpService:JSONEncode({path = path}),
		Headers = {["Content-Type"] = "application/json"}
	}, 3)

	return result and result.Success
end

env.listfiles = function(path)
	path = path or ""
	local result = sendRequest({
		Url = "http://localhost:7646/listfiles",
		Method = "POST",
		Body = HttpService:JSONEncode({path = path}),
		Headers = {["Content-Type"] = "application/json"}
	}, 3)

	if not result or not result.Success then return {} end
	local success, data = pcall(HttpService.JSONDecode, HttpService, result.Body)
	return success and data or {}
end

env.isfile = function(path)
	if type(path) ~= "string" or path == "" then return false end

	local result = sendRequest({
		Url = "http://localhost:7646/isfile",
		Method = "POST",
		Body = HttpService:JSONEncode({path = path}),
		Headers = {["Content-Type"] = "application/json"}
	}, 2)

	return result and result.Success and result.Body == "true"
end

env.isfolder = function(path)
	if type(path) ~= "string" or path == "" then return false end

	local result = sendRequest({
		Url = "http://localhost:7646/isfolder",
		Method = "POST",
		Body = HttpService:JSONEncode({path = path}),
		Headers = {["Content-Type"] = "application/json"}
	}, 2)

	return result and result.Success and result.Body == "true"
end

env.delfile = function(path)
	assert(type(path) == "string" and path ~= "", "delfile: path must be non-empty string")

	local result = sendRequest({
		Url = "http://localhost:7646/delfile",
		Method = "POST",
		Body = HttpService:JSONEncode({path = path}),
		Headers = {["Content-Type"] = "application/json"}
	}, 3)

	return result and result.Success
end

env.delfolder = function(path)
	assert(type(path) == "string" and path ~= "", "delfolder: path must be non-empty string")

	local result = sendRequest({
		Url = "http://localhost:7646/delfolder",
		Method = "POST",
		Body = HttpService:JSONEncode({path = path}),
		Headers = {["Content-Type"] = "application/json"}
	}, 5)

	return result and result.Success
end

-- Utility Functions
env.appendfile = function(path, content)
	return env.writefile(path, content, true)
end

env.loadfile = function(path)
	local content = env.readfile(path)
	return content and loadstring(content, "@"..path)
end

env.dofile = function(path)
	local chunk, err = env.loadfile(path)
	if not chunk then error(err, 2) end
	return chunk()
end
