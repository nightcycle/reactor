local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local packages = script.Parent
local Fusion = require(packages:WaitForChild("coldfusion"))
local Isotope = require(packages:WaitForChild("isotope"))
local Signal = require(packages:WaitForChild("signal"))

local Character = require(script:WaitForChild("Character"))
local Data = require(script:WaitForChild("Data"))

local Player = {}
Player.__index = Player
Player.ClassName = "Player"

if not RunService:IsServer() then return {} end

function Player:Teleport(cf: CFrame, yield: boolean | nil)
	if self.Character:Get() then
		self.Character:Get():Teleport(cf, yield)
	end
end

function Player:Export()
	return {
		Character = self.Character:Export(),
		DisplayName = self.DisplayName:Get(),
	}
end

function Player:Import(data)
	self.Character:Import(data)
	local inst = self.Instance:Get()
	if inst then
		inst:Set(data.DisplayName)
	end
end

function Player:Destroy()
	local playerInst = self.Instance:Get()
	if playerInst and playerInst:IsA("Pseudo") then
		playerInst:Destroy()
	end
	Isotope.Destroy(self)
end

function Player.fromInstance(playerInst)
	local player = Player.new {
		Instance = Fusion.Value(playerInst),
	}
	return player
end

function Player:LoadAppearance()
	local appearanceData
	if not appearanceData then
		local humDesc = Players:GetHumanoidDescriptionFromUserId(tonumber(self.UserId:Get()))
		self.Character:ApplyHumanoidDescription(humDesc)
		humDesc:Destroy()
	end
end

function Player.new(config)

	local self = setmetatable(Isotope.new(config), Player)

	self.UserId = Fusion.Computed(self.Instance, function(playerInst)
		if not playerInst then return end
		return tostring(playerInst.UserId)
	end)
	self.Name = Fusion.Property(self.Instance, "Name")
	self.DisplayName = Fusion.Property(self.Instance, "DisplayName")
	self.Character = Character.new {
		Player = self,
		Instance = Fusion.Signal(Fusion.Computed(self.Instance, function(inst)
			if not inst then return end
			return inst.CharacterAdded
		end), (self.Instance:Get() or {}).Character):CleanUp()
	}
	self.Data = Data.new {
		Player = self,
	}
	self:LoadAppearance()
	self:Construct()
	return self
end

function Player.pseudoInstance(id: number, team: Team | nil): Instance
	-- print("Creating pseudoinst", id)
	local name = "PseudoPlayer"..tostring(id)
	assert(Players:FindFirstChild(name) == nil, "Player already exists")
	local instance = Instance.new("Folder", Players)
	instance.Name = name
	local starterPlayer = game:GetService("StarterPlayer")
	local signals = {}
	local self = {
		AccountAge = 1,
		CanLoadCharacterAppearance = starterPlayer.LoadCharacterAppearance,
		Character = nil,
		HasAppearanceLoaded = false,
		CharacterAppearanceId = id,
		DisplayName = "PseudoPlayer",
		Name = name,
		FollowUserId = 0,
		ClassName = "Player",
		GameplayPaused = false,
		Guest = false,
		LocalId = "en-us",
		MembershipType = Enum.MembershipType.None,
		Neutral = team == nil,
		Team = team,
		TeamColor = if team then team.TeamColor else nil,
		Teleported = false,
		UserId = id,
		CharacterAdded = Signal.new(),
	}

	local meta = {}
	function meta:__index(k)
		if k == "Character" then return rawget(self, k) end
		if rawget(self, k) ~= nil then
			return rawget(self, k)
		elseif meta[k] ~= nil then
			return meta[k]
		else
			local val
			local success = pcall(function()
				val = instance[k]
			end)
			return val
		end
	end
	function meta:__newindex(k, v)
		if rawget(self, k) ~= nil then
			return rawset(self, k, v)
		else
			instance[k] = v
			return instance[k]
		end
	end
	function meta:GetPropertyChangedSignal(key)
		if not signals[key] then
			signals[key] = Signal.new()
		end
		return signals[key]
	end
	function meta:IsA(key)
		return key == "Player" or key == "Instance" or key == "Pseudo"
	end
	function meta:Destroy()
		instance:Destroy()
		for k, sig in pairs(signals) do
			if sig.Disconnect then
				sig:Disconnect()
			end
			signals[k] = nil
		end
		for k, v in pairs(self) do
			self[k] = nil
		end
	end
	return setmetatable(self, meta)
end

setmetatable(Player, Isotope)

return Player
