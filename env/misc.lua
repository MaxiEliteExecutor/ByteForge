-- Wait for game to load with a timeout
local maxWaitTime = 30 -- 30 seconds timeout
local startTime = tick()
while not game:IsLoaded() do
	task.wait(0.5)
	if tick() - startTime > maxWaitTime then
		warn("Game failed to load within ", maxWaitTime, " seconds")
		return
	end
end
warn('Loaded ByteForge, made by Black Loaf: [https://discord.gg/kCvc3Y65kj]')
local proxiedServices = {
	LinkingService = {{
		"OpenUrl"
	}, game:GetService("LinkingService")},
	ScriptContext = {{
		"SaveScriptProfilingData", 
		"AddCoreScriptLocal",
		"ScriptProfilerService"
	}, game:GetService("ScriptContext")},
	--[[
	MessageBusService = {{
		"Call",
		"GetLast",
		"GetMessageId",
		"GetProtocolMethodRequestMessageId",
		"GetProtocolMethodResponseMessageId",
		"MakeRequest",
		"Publish",
		"PublishProtocolMethodRequest",
		"PublishProtocolMethodResponse",
		"Subscribe",
		"SubscribeToProtocolMethodRequest",
		"SubscribeToProtocolMethodResponse"
	}, game:GetService("MessageBusService")},
	GuiService = {{
		"OpenBrowserWindow",
		"OpenNativeOverlay"
	}, game:GetService("GuiService")},
	MarketplaceService = {{
		"GetRobuxBalance",
		"PerformPurchase",
		"PerformPurchaseV2",
	}, game:GetService("MarketplaceService")},
	HttpRbxApiService = {{
		"GetAsyncFullUrl",
		"PostAsyncFullUrl",
		"GetAsync",
		"PostAsync",
		"RequestAsync"
	}, game:GetService("HttpRbxApiService")},
	CoreGui = {{
		"TakeScreenshot",
		"ToggleRecording"
	}, game:GetService("CoreGui")},
	Players = {{
		"ReportAbuse",
		"ReportAbuseV3"
	}, game:GetService("Players")},
	HttpService = {{
		"RequestInternal"
	}, game:GetService("HttpService")},
	BrowserService = {{
		"ExecuteJavaScript",
		"OpenBrowserWindow",
		"ReturnToJavaScript",
		"OpenUrl",
		"SendCommand",
		"OpenNativeOverlay"
	}, game:GetService("BrowserService")},
	CaptureService = {{
		"DeleteCapture"
	}, game:GetService("CaptureService")},
	OmniRecommendationsService = {{
		"MakeRequest"
	}, game:GetService("OmniRecommendationsService")},
	OpenCloudService = {{
		"HttpRequestAsync"
	}, game:GetService("OpenCloudService")}
	]]
}
local function find(t, x)
	x = string.gsub(tostring(x), '\0', '') -- sometimes people will use null chars to bypass
	for i, v in t do
		if v:lower() == x:lower() then
			return true
		end
	end
end
local char, concat = string.char, table.concat
-- Inject functions directly into the global environment

local fpscap = nil
local CoreGui = game:GetService('CoreGui')
local RunService = game:GetService('RunService')
local RobloxGui = CoreGui:FindFirstChild('RobloxGui')
local Modules = RobloxGui and RobloxGui:FindFirstChild('Modules')
local oworkspace = game:FindFirstChild("Workspace")
local HttpService = game:GetService('HttpService')
local StarterGui = game:GetService('StarterGui')
local cacheState = {}
local VirtualInputManager = Instance.new("VirtualInputManager")

local ScriptsHolder = Instance.new('ObjectValue', CoreGui)
ScriptsHolder.Name = 'ByteForge'

local threadIdentity  = 7
local ogetfenv = getfenv
local orequire = require
local oxpcall = xpcall
local otable = table
local odebug = debug
local ogame = game
local ocoroutine = coroutine
local ostring = string
extract = bit32.extract
local AllModules = {}
local ModulesIndex = 1
local Blacklist = {
	['Common'] = true, ['Settings'] = true, ['PlayerList'] = true, ['InGameMenu'] = true,
	['PublishAssetPrompt'] = true, ['TopBar'] = true, ['InspectAndBuy'] = true,
	['VoiceChat'] = true, ['Chrome'] = true, ['PurchasePrompt'] = true, ['VR'] = true,
	['EmotesMenu'] = true, ['FTUX'] = true, ['TrustAndSafety'] = true
}

game.StarterGui:SetCore("SendNotification", {
	Title = "[ByteForge]",
	Text = "Used ingame method. When you leave the game it might crash!"
})
for _, Script in ipairs(Modules and Modules:GetDescendants() or {}) do
	if Script.ClassName == 'ModuleScript' then
		if not Blacklist[Script.Name] then
			local BlacklistedParent = false
			for BlockedName in pairs(Blacklist) do
				if Script:IsDescendantOf(Modules:FindFirstChild(BlockedName)) then
					BlacklistedParent = true
					break
				end
			end
			if not BlacklistedParent then
				local Clone = Script:Clone()
				Clone.Name = 'ByteForge'
				table.insert(AllModules, Clone)
			end
		end
	end
end

-- First, let's modify the GetRandomModule function to ensure we're getting valid modules
local function GetRandomModule()
	ModulesIndex = (ModulesIndex % #AllModules) + 1  -- Circular indexing
	local FetchedModule = AllModules[ModulesIndex]

	-- Validate the module before returning
	if FetchedModule and FetchedModule:IsA("ModuleScript") then
		-- Clear any existing children that might interfere with requiring
		FetchedModule:ClearAllChildren()
		return FetchedModule
	end

	-- If we didn't find a valid module, try the next one
	return GetRandomModule()
end

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
local function safeRequest(options, timeout)
	timeout = timeout or 5
	local success, result = pcall(function()
		return sendRequest({
			Url = options.url,
			Method = options.method or "POST",
			Body = options.body,
			Headers = options.headers or {
				["Content-Type"] = "application/json",
				["Connection"] = "close"
			}
		}, timeout)
	end)

	if not success then
		warn("Filesystem request failed:", result)
		return nil
	end

	if not result then
		warn("Filesystem request timed out")
		return nil
	end

	if result.StatusCode ~= 200 then
		warn("Filesystem operation failed:", result.Body or "no error message")
		return nil
	end

	return result
end

local env = ogetfenv(0)
env.getgenv = function() return env end
env.getinstances = function()
	local instances = {}
	for _, instance in ipairs(ogame:GetDescendants()) do
		otable.insert(instances, instance)
	end
	return instances
end
env.identifyexecutor = function()
	return "ByteForge", "1.0.8"
end

env.getexecutorname = env.identifyexecutor
env.getscripts = function()
	local scripts = {}
	for _, instance in ipairs(env.getinstances()) do
		if instance:IsA('LocalScript') or instance:IsA('ModuleScript') then
			otable.insert(scripts, instance)
		end
	end
	return scripts
end
env.gethui = function() 
	if threadIdentity >= 3 then
		return CoreGui 
	end

end

env.getthreadidentity = function()
		return threadIdentity
	end

	env.getidentity = env.getthreadidentity
	env.getthreadcontext = env.getthreadidentity

	env.setthreadidentity = function(id)
		if type(id) == "number" then threadIdentity = id end
	end

	env.setidentity = env.setthreadidentity
	env.setthreadcontext = env.setthreadidentity
	env.isscriptable = function(object, property)
		local dummy = function(result) return result end
		local success, result = oxpcall(object.GetPropertyChangedSignal, dummy, object, property)
		if not success then
			success = not ostring.find(result, 'scriptable property', nil, true)
		end
		return success
	end
	
