local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

local ServierHandler = require(script:WaitForChild("Services"))
function Reactor:GetService(serviceName)
	return ServierHandler.getService(serviceName)
end
Reactor.Players = ServierHandler.getService("Players")
Reactor.Scene = fusion.Value(nil)
Reactor.Enum = ServierHandler.getService("Enum")
Reactor.Enum.Log = {"Debug", "Info", "Warn", "Error", "Fatal"}

local constructorService = require(script:WaitForChild("Constructors"))

local registry = {}

function Reactor.new(componentName)
	local newComponent = constructorService.get(componentName)

	--register instance to registry
	if newComponent then
		if newComponent.Instance and newComponent.Destroying and newComponent._Maid then
			registry[newComponent] = fusion.Value()
			local compState = fusion.Computed(newComponent.Instance, function(inst)
				if not inst then return end
				registry[inst] = registry
				newComponent._Maid._reactorObjectRegState = function()
					registry[inst] = nil
				end
			end)
			local destroySig
			destroySig = newComponent.Destroying:Connect(function()
				destroySig:Disconnect()
				compState:Destroy()
			end)
		end
	end

	return newComponent
end

function Reactor.get(inst)
	return registry[inst]
end

function Reactor.register(key, func)
	constructorService.set(key, func)
end

function Reactor.type(obj)
	return tostring(obj.Type or obj.__type or obj.ClassName or obj.Class or typeof(obj) or type(obj))
end

function Reactor:Midas(...)

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
	if self._Logging.Filters[scriptName] then return end
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

local import = getService("Import")

import.setConfig({
	useWaitForChild = true,
	scriptAlias = "*",
})
import.setAliases({
	server = if RunService:IsServer() then ServerScriptService:WaitForChild("Server") else nil,
	client = if RunService:IsClient() then Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Client") else nil,
	shared = ReplicatedStorage:WaitForChild("Shared"),
	lib = ReplicatedStorage:WaitForChild("Library"),
	reactor = script,
})

function Reactor:Import(path)
	return import(path)
end

return function(config)
	-- local analytics = getService("Analytics")
	-- if RunService:IsServer() then
	-- 	analytics.init(config.TitleId, config.DevSecretKey)
	-- end
	local self = setmetatable({
		-- _Analytics = getService("Analytics"),
		_Version = config.Version,
		_Logging = config.Logging or {
			Levels = {
				Debug = RunService:IsStudio(),
				Info = RunService:IsStudio(),
				Warning = true,
				Error = true,
				Fatal = true,
			},
			Filters = {}
		}
	}, Reactor)
	return self
end