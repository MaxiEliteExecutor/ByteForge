local env = getfenv(0)
local extract = bit32.extract
env.crypt = {}

env.crypt = {}
env.crypt.base64encode = function(input)
	local encodeResponse = sendRequest({
		Url = "https://www.byteforge-getnow.space/api/base64encode.js",
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = HttpService:JSONEncode({ data = input or "Hello Lua!" })
	}, 10)

	if encodeResponse then
		if encodeResponse.Body then
			local bodyData = HttpService:JSONDecode(encodeResponse.Body)
			if bodyData.result then
				return bodyData.result
			else
				warn("No 'result' field found in Body")
				return nil
			end
		else
			warn("No 'Body' field in response")
			return nil
		end
	else
		warn("Request failed or timed out")
		return nil
	end
end
env.crypt.base64decode = function(input)
	local encodeResponse = sendRequest({
		Url = "https://www.byteforge-getnow.space/api/base64decode.js",
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = HttpService:JSONEncode({ data = input or "Hello Lua!" })
	}, 10)

	if encodeResponse then
		if encodeResponse.Body then
			local bodyData = HttpService:JSONDecode(encodeResponse.Body)
			if bodyData.result then
				return bodyData.result
			else
				warn("No 'result' field found in Body")
				return nil
			end
		else
			warn("No 'Body' field in response")
			return nil
		end
	else
		warn("Request failed or timed out")
		return nil
	end
end

env.crypt.generatekey = function(len)
	local key = ''
	local x = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	for i = 1, len or 32 do local n = math.random(1, #x) key = key .. x:sub(n, n) end
	return base64.encode(key)
end
