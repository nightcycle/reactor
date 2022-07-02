local RunService = game:GetService("RunService")

local Game: DataModel = require(script:WaitForChild("Game"))

local Util = require(script:WaitForChild("Util"))
local Service = require(script:WaitForChild("Service"))

local Reactor = {}

function Reactor:Destroy(): nil
	Service.Destroy(self)

	setmetatable(self, nil)
	for k, v in pairs(self) do
		self[k] = nil
	end
end

Reactor.__index = function(s, k)
	local v = rawget(s, k)
	local cV = rawget(s, "_Config")[k]
	if v then
		return v
	elseif cV then
		return cV
	elseif Reactor[k] then
		return Reactor[k]
	elseif Service[k] then
		return Service[k]
	elseif Util[k] then
		return Util[k]
	elseif Game[k] then
		return Game[k]
	else
		return game[k]
	end
end

Reactor.__newindex = function(s, k, v)
	error("Reactor is locked, because uh, radiation or something")
end


function prepConfig(config)
	config = config or {}

	config.Version = config.Version or "Unspecified"
	config.Logging = config.Logging or {
		Levels = {
			Debug = RunService:IsStudio(),
			Info = RunService:IsStudio(),
			Warning = true,
			Error = true,
			Fatal = true,
		},
		Filters = {}
	}

	return config
end

function extractAnalyticsKeys(config): (string | nil, string | nil)
	local titleId: string | nil
	local secretKey: string | nil

	if RunService:IsServer() then
		titleId = config.TitleId
		secretKey = config.DevSecretKey
		config.TitleId = nil
		config.DevSecretKey = nil
	end

	return titleId, secretKey
end


return function(config)
	config = prepConfig(config)
	local titleId, secretKey = extractAnalyticsKeys(config)
	local self = {
		_Config = config,
		_Importer = nil,
		Instance = {}
	}
	setmetatable(self, Reactor)
	self:SetPackages()
	if RunService:IsServer() and titleId and secretKey then
		local analytics = self:GetService("Analytics")
		analytics.init(titleId, secretKey)
		self:CacheService("Analytics", analytics)
	end

	local Enum = self:GetService("Enum")
	Enum.Log = {"Debug", "Info", "Warn", "Error", "Fatal"}
	self:CacheService("Enum", Enum)

	local Importer = self:GetService("import")
	Importer.setConfig({
		useWaitForChild = true,
		scriptAlias = "*",
	})
	Importer.setAliases({
		server = if RunService:IsServer() then game.ServerScriptService:WaitForChild("Server") else nil,
		client = if RunService:IsClient() then
			if RunService:IsRunning() then
				game.Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Client")
			else
				game:WaitForChild("StarterPlayer"):WaitForChild("StarterPlayerScripts"):WaitForChild("Client")
		else nil,
		shared = game.ReplicatedStorage:WaitForChild("Shared"),
		library = game.ReplicatedStorage:WaitForChild("Library"),
		first = if RunService:IsClient() then game.ReplicatedFirst else nil,
		workspace = workspace,
	})
	rawset("_Importer", Importer)
	if self.Instance then
		self.Instance.new = function(...)
			return self:BuildService(...)
		end
	end

	return self
end
