local env = getfenv(0)
local VirtualInputManager = Instance.new("VirtualInputManager")
local oworkspace = game:FindFirstChild("Workspace")
local ogame = game

env.mouse1click = function(x, y)
	x = x or 0
	y = y or 0

	VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, ogame, false)
	task.wait()
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, ogame, false)
end

env.mouse1press = function(x, y)
	x = x or 0
	y = y or 0

	VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, ogame, false)
end

env.mouse1release = function(x, y)
	x = x or 0
	y = y or 0

	VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, ogame, false)
end

env.mouse2click = function(x, y)
	x = x or 0
	y = y or 0

	VirtualInputManager:SendMouseButtonEvent(x, y, 1, true, ogame, false)
	task.wait()
	VirtualInputManager:SendMouseButtonEvent(x, y, 1, false, ogame, false)
end

env.mouse2press = function(x, y)
	x = x or 0
	y = y or 0

	VirtualInputManager:SendMouseButtonEvent(x, y, 1, true, ogame, false)
end

env.mouse2release = function(x, y)
	x = x or 0
	y = y or 0

	VirtualInputManager:SendMouseButtonEvent(x, y, 1, false, ogame, false)
end

env.mousescroll = function(x, y, z)
	VirtualInputManager:SendMouseWheelEvent(x or 0, y or 0, z or false, ogame)
end

env.mousemoverel = function(x, y)
	x = x or 0
	y = y or 0

	local vpSize = oworkspace.CurrentCamera.ViewportSize
	local x = vpSize.X * x
	local y = vpSize.Y * y

	VirtualInputManager:SendMouseMoveEvent(x, y, ogame)
end

env.mousemoveabs = function(x, y)
	x = x or 0
	y = y or 0

	VirtualInputManager:SendMouseMoveEvent(x, y, ogame)
end
