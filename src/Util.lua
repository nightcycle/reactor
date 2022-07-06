local RunService: RunService = game:GetService("RunService")

if RunService:IsServer() then
	local RemFuncFolder: Folder = if script:FindFirstChild("RemoteFunctions") then script:FindFirstChild("RemoteFunctions") else Instance.new("Folder", script)
	RemFuncFolder.Name = "RemoteFunctions"

	local RemEvFolder: Folder = if script:FindFirstChild("RemoteEvents") then script:FindFirstChild("RemoteEvents") else Instance.new("Folder", script)
	RemEvFolder.Name = "RemoteEvents"

	local BindFuncFolder: Folder = if script:FindFirstChild("BindableFunctions") then script:FindFirstChild("BindableFunctions") else Instance.new("Folder", script)
	BindFuncFolder.Name = "BindableFunctions"

	local BindEvFolder: Folder = if script:FindFirstChild("BindableEvents") then script:FindFirstChild("BindableEvents") else Instance.new("Folder", script)
	BindEvFolder.Name = "BindableEvents"
end

local Util = {}

export type Typeable = {
	ClassName: string | nil,

	type: string | nil,
	_type: string | nil,
	__type: string | nil,

	Type: string | nil,
	_Type: string | nil,
}

function Util.typeof(obj: Typeable)
	local nativeType = typeof(obj)
	if nativeType == "table" then
		return obj.Type or obj._Type or obj.type or obj._type or obj.__type
	elseif typeof(obj) == "Instance" then
		return obj.ClassName
	end
	return typeof(obj)
end

export type typeof = (Typeable) -> string

function Util:Import(path: string)
	return self._Importer(path)
end

function Util:Midas(...)
	return self._Analytics:Midas(...)
end

function Util:IsServer()
	return RunService:IsServer()
end

function Util:IsClient()
	return RunService:IsClient()
end

function Util:IsStudio()
	return RunService:IsStudio()
end

function Util:IsRunning()
	return RunService:IsRunning()
end

function Util:Log(...)
	local severity = self.Enum.Log.Info
	local scriptName = debug.info(2, "s")
	if self.Logging.Filters[scriptName] then return end
	local scriptTags = string.split(string.gsub(scriptName, "%p", "_"), "_")
	-- print(scriptTags)
	local finalTag = scriptTags[#scriptTags]

	local text = ""
	local values = {}
	local count = 0
	for k, v in pairs({...}) do
		count += 1
		values[k] = v
	end
	for i, v in ipairs(unpack(values, 1, math.max(count, 0, 1))) do
		if string.len(text) ~= 0 then
			text ..= ", "
		end
		text ..= tostring(v)
	end
	-- print(finalTag)
	if severity == self.Enum.Log.Debug then
		print(text.." ["..finalTag.."] ".."["..severity.Name.."]", ...)
	elseif severity == self.Enum.Log.Info then
		print(text.." ["..finalTag.."] ".."["..severity.Name.."]", ...)
	elseif severity == self.Enum.Log.Warn then
		warn(text.." ["..finalTag.."] ".."["..severity.Name.."]", ...)
	elseif severity == self.Enum.Log.Error then
		error(text.." ["..finalTag.."] ".."["..severity.Name.."]", ...)
	elseif severity == self.Enum.Log.Fatal then
		error(text.." ["..finalTag.."] ".."["..severity.Name.."]", ...)
	end
end

function Util:GetRemoteEvent(eventName)
	local remoteEvents = script:WaitForChild("RemoteEvents")
	if RunService:IsServer() then
		if remoteEvents:FindFirstChild(eventName) then
			return remoteEvents:FindFirstChild(eventName)
		else
			local remoteEvent = Instance.new("RemoteEvent", remoteEvents)
			remoteEvent.Name = eventName
			return remoteEvent
		end
	else
		return remoteEvents:WaitForChild(eventName)
	end
end

function Util:GetRemoteFunction(functionName)
	local remoteFunctions = script:WaitForChild("RemoteFunctions")
	if RunService:IsServer() then
		if remoteFunctions:FindFirstChild(functionName) then
			return remoteFunctions:FindFirstChild(functionName)
		else
			local remoteFunction = Instance.new("RemoteFunction", remoteFunctions)
			remoteFunction.Name = functionName
			return remoteFunction
		end
	else
		return remoteFunctions:WaitForChild(functionName)
	end
end


function Util:GetBindableEvent(eventName)
	local bindableEvents = script:WaitForChild("BindableEvents")
	if RunService:IsServer() then
		if bindableEvents:FindFirstChild(eventName) then
			return bindableEvents:FindFirstChild(eventName)
		else
			local bindableEvent = Instance.new("BindableEvent", bindableEvents)
			bindableEvent.Name = eventName
			return bindableEvent
		end
	else
		return bindableEvents:WaitForChild(eventName)
	end
end

function Util:GetBindableFunction(functionName)
	local bindableFunctions = script:WaitForChild("BindableFunctions")
	if RunService:IsServer() then
		if bindableFunctions:FindFirstChild(functionName) then
			return bindableFunctions:FindFirstChild(functionName)
		else
			local bindableFunction = Instance.new("BindableFunction", bindableFunctions)
			bindableFunction.Name = functionName
			return bindableFunction
		end
	else
		return bindableFunctions:WaitForChild(functionName)
	end
end



return Util