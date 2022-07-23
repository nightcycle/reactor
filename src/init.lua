--!strict
local RunService: RunService = game:GetService("RunService")
local Maid = require(script.Parent.Maid)

if RunService:IsServer() then
	local RemFuncFolder: Instance = if script:FindFirstChild("RemoteFunctions") then script:FindFirstChild("RemoteFunctions") else Instance.new("Folder")
	RemFuncFolder.Name = "RemoteFunctions"
	RemFuncFolder.Parent = script

	local RemEvFolder: Instance = if script:FindFirstChild("RemoteEvents") then script:FindFirstChild("RemoteEvents") else Instance.new("Folder", script)
	RemEvFolder.Name = "RemoteEvents"
	RemEvFolder.Parent = script
	
	local BindFuncFolder: Instance = if script:FindFirstChild("BindableFunctions") then script:FindFirstChild("BindableFunctions") else Instance.new("Folder", script)
	BindFuncFolder.Name = "BindableFunctions"
	BindFuncFolder.Parent = script

	local BindEvFolder: Instance = if script:FindFirstChild("BindableEvents") then script:FindFirstChild("BindableEvents") else Instance.new("Folder", script)
	BindEvFolder.Name = "BindableEvents"
	BindEvFolder.Parent = script
end

local Reactor = {}
Reactor.__index = Reactor

function Reactor:Destroy(): nil
	self._Maid:Destroy()
	for k, v in pairs(self) do
		self[k] = nil
	end
	setmetatable(self, nil)
	return nil
end

function Reactor.typeof(obj): string
	local nativeType = typeof(obj)
	if nativeType == "table" then
		return obj.Type or obj._Type or obj.type or obj._type or obj.__type
	elseif typeof(obj) == "Instance" then
		return obj.ClassName
	end
	return typeof(obj)
end

function Reactor:IsServer(): boolean
	return RunService:IsServer()
end

function Reactor:IsClient(): boolean
	return RunService:IsClient()
end

function Reactor:IsStudio(): boolean
	return RunService:IsStudio()
end

function Reactor:IsRunning(): boolean
	return RunService:IsRunning()
end

function Reactor:GiveTask(disposable: ({Destroy: (self: any) -> nil}) | Instance | RBXScriptConnection): nil
	self._Maid:GiveTask(disposable)
end

function Reactor:GetRemoteEvent(eventName): RemoteEvent
	local remoteEvents = script:WaitForChild("RemoteEvents")
	if RunService:IsServer() then
		if remoteEvents:FindFirstChild(eventName) then
			local remEvent: Instance? = remoteEvents:WaitForChild(eventName)
			assert(remEvent ~= nil and remEvent:IsA("RemoteEvent"))
			return remEvent
		else
			local remoteEvent: RemoteEvent = Instance.new("RemoteEvent")
			remoteEvent.Name = eventName
			remoteEvent.Parent = remoteEvents

			return remoteEvent
		end
	else
		local remEvent: Instance? = remoteEvents:WaitForChild(eventName)
		assert(remEvent ~= nil and remEvent:IsA("RemoteEvent"))
		return remEvent
	end
end

function Reactor:GetRemoteFunction(functionName): RemoteFunction
	local remoteFunctions = script:WaitForChild("RemoteFunctions")
	if RunService:IsServer() then
		if remoteFunctions:FindFirstChild(functionName) then
			return remoteFunctions:FindFirstChild(functionName)
		else
			local remoteFunction = Instance.new("RemoteFunction")
			remoteFunction.Name = functionName
			remoteFunction.Parent = remoteFunctions
			return remoteFunction
		end
	else
		return remoteFunctions:WaitForChild(functionName)
	end
end


function Reactor:GetBindableEvent(eventName): BindableEvent
	local bindableEvents = script:WaitForChild("BindableEvents")
	if RunService:IsServer() then
		if bindableEvents:FindFirstChild(eventName) then
			return bindableEvents:FindFirstChild(eventName)
		else
			local bindableEvent = Instance.new("BindableEvent")
			bindableEvent.Name = eventName
			bindableEvent.Parent = bindableEvents
			return bindableEvent
		end
	else
		return bindableEvents:WaitForChild(eventName)
	end
end

function Reactor:GetBindableFunction(functionName): BindableFunction
	local bindableFunctions = script:WaitForChild("BindableFunctions")
	if RunService:IsServer() then
		if bindableFunctions:FindFirstChild(functionName) then
			return bindableFunctions:FindFirstChild(functionName)
		else
			local bindableFunction = Instance.new("BindableFunction")
			bindableFunction.Name = functionName
			bindableFunction.Parent = bindableFunctions
			return bindableFunction
		end
	else
		return bindableFunctions:WaitForChild(functionName)
	end
end

function Reactor.new()
	local self = setmetatable({
		_Maid = Maid.new()
	}, Reactor)
	return self
end

export type Reactor = typeof(Reactor.new())

return Reactor