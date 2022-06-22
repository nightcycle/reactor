local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")

local packages = script.Parent
local fusion = require(packages:WaitForChild("coldfusion"))

local Reactor = {}

Reactor.__index = function(s, k)
	local v = rawget(s, k)
	if v then
		return v
	elseif Reactor[k] then
		return Reactor[k]
	else
		return game[k]
	end
end

Reactor.__newindex = function(s, k, v)
	error("Reactor is locked, because uh, radiation or something")
end

local ServiceHandler = require(script:WaitForChild("Services"))
function Reactor:GetService(serviceName)
	return ServiceHandler.getService(serviceName)
end
Reactor.Scene = fusion.Value(nil)
Reactor.Enum = ServiceHandler.getService("Enum")
Reactor.Enum.Log = {"Debug", "Info", "Warn", "Error", "Fatal"}

function Reactor.type(obj)
	return tostring(obj.Type or obj.__type or obj.ClassName or obj.Class or typeof(obj) or type(obj))
end

function Reactor:Midas(...)
	return self._Analytics:Midas(...)
end

function Reactor:IsServer()
	return RunService:IsServer()
end

function Reactor:IsClient()
	return RunService:IsClient()
end

function Reactor:IsStudio()
	return RunService:IsStudio()
end

function Reactor:Log(text, severity, ...)
	severity = severity or self.Enum.Log.Info
	local scriptName = debug.info(2, "s")
	if self.Logging.Filters[scriptName] then return end
	local scriptTags = string.split(string.gsub(scriptName, "%p", "_"), "_")
	-- print(scriptTags)
	local finalTag = scriptTags[#scriptTags]
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

local import = ServiceHandler.getService("Import")

import.setConfig({
	useWaitForChild = true,
	scriptAlias = "*",
})
import.setAliases({
	server = if RunService:IsServer() then ServerScriptService:WaitForChild("Server") else nil,
	client = if RunService:IsClient() then
		if RunService:IsRunning() then
			Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Client")
		else
			game:WaitForChild("StarterPlayer"):WaitForChild("StarterPlayerScripts"):WaitForChild("Client")
	else nil,
	shared = ReplicatedStorage:WaitForChild("Shared"),
	library = ReplicatedStorage:WaitForChild("Library"),
	first = if RunService:IsClient() then ReplicatedFirst else nil,
	workspace = workspace,
	reactor = script,
})

function Reactor:Import(path)
	return import(path)
end

-- ported OOP API
function Reactor:BindToClose(...) return game:BindToClose(...) end
function Reactor:IsLoaded(...) return game:IsLoaded(...) end
function Reactor:FindService(...) return game:FindService(...) end
function Reactor:ClearAllChildren(...) return game:ClearAllChildren(...) end
function Reactor:Clone(...) return game:Clone(...) end
function Reactor:Destroy(...) return game:Destroy(...) end
function Reactor:FindFirstAncestor(...) return game:FindFirstAncestor(...) end
function Reactor:FindFirstAncestorOfClass(...) return game:FindFirstAncestorOfClass(...) end
function Reactor:FindFirstChild(...) return game:FindFirstChild(...) end
function Reactor:FindFirstChildOfClass(...) return game:FindFirstChildOfClass(...) end
function Reactor:FindFirstChildWhichIsA(...) return game:FindFirstChildWhichIsA(...) end
function Reactor:FindFirstDescendant(...) return game:FindFirstDescendant(...) end
function Reactor:GetActor(...) return game:GetActor(...) end
function Reactor:GetAttribute(...) return game:GetAttribute(...) end
function Reactor:GetAttributeChangedSignal(...) return game:GetAttributeChangedSignal(...) end
function Reactor:GetAttributes(...) return game:GetAttributes(...) end
function Reactor:GetChildren(...) return game:GetChildren(...) end
function Reactor:GetDescendants(...) return game:GetDescendants(...) end
function Reactor:GetFullName(...) return game:GetFullName(...) end
function Reactor:GetPropertyChangedSignal(...) return game:GetPropertyChangedSignal(...) end
function Reactor:IsA(...) return game:IsA(...) end
function Reactor:IsAncestorOf(...) return game:IsAncestorOf(...) end
function Reactor:IsDescendantOf(...) return game:IsDescendantOf(...) end
function Reactor:SetAttribute(...) return game:SetAttribute(...) end

function Reactor:GetRemoteEvent(eventName)
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

function Reactor:GetRemoteFunction(functionName)
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

function Reactor:SetService(serviceName: string, module: ModuleScript)
	ServiceHandler.setService(string.lower(serviceName), module)
end

return function(config)
	-- handle analytics
	local analytics = ServiceHandler.getService("Analytics")
	if RunService:IsServer() then
		analytics.init(config.TitleId or "", config.DevSecretKey or "")
		config.TitleId = nil
		config.DevSecretKey = nil
	end

	-- set up self
	local self = {}
	for k, v in pairs(config) do
		self[k] = v
	end
	self.Version = self.Version or "Unspecified"
	self.Logging = self.Logging or {
		Levels = {
			Debug = RunService:IsStudio(),
			Info = RunService:IsStudio(),
			Warning = true,
			Error = true,
			Fatal = true,
		},
		Filters = {}
	}

	self._Analytics = analytics

	setmetatable(self, Reactor)

	return self
end