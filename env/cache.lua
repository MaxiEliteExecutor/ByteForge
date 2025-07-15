local env = getfenv(0)
local cacheState = {}
env.cache = {
	invalidate = function(obj)
		if not obj then return false end
		cacheState[obj] = false
		if env and obj:IsA("Instance") then obj.Name = obj.Name .. "_invalidated" end
		return true
	end,
	iscached = function(obj)
		if not obj then return false end
		return cacheState[obj] ~= false
	end,
	replace = function(obj, rep)
		if not obj or not rep then return obj end
		cacheState[obj] = false
		cacheState[rep] = true
		return rep
	end
}
