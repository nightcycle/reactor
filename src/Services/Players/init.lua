local PlayerService = game:GetService("Players")

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = script.Parent
local Fusion = require(packages:WaitForChild("coldfusion"))
local Player = require(packages:WaitForChild("player"))
local Maid = require(packages:WaitForChild("maid"))
local Signal = require(packages:WaitForChild("signal"))

if not RunService:IsServer() then return PlayerService end

local Players = {}

Players.PlayerAdded = Signal.new()
Players.PlayerRemoving = Signal.new()

function Players:__index(k)
	if rawget(self, k) then
		return rawget(self, k)
	elseif rawget(Players, k) then
		return Players[k]
	else
		return PlayerService[k]
	end
end

function Players:CreatePseudoPlayer(id: number, team: Team | nil)
	local fakeInstance = Player.pseudoInstance(id, team)
	self:AddPlayer(fakeInstance)
end

function Players:GetPlayer(userId)
	for i, player in ipairs(self:GetChildren()) do
		if tostring(player.UserId:Get()) == tostring(userId) then
			return player
		end
	end
end

function Players:RemoveFakePlayer(id)
	local inst = self:GetPlayer(id).Instance:Get()
	self:RemovePlayer(inst)
	inst:Destroy()
end

function Players:AddPlayer(playerInstance)
	local player = Player.fromInstance(playerInstance)
	local id = player.UserId:Get()
	self._RegisteredPlayers[id] = player
	self.PlayerAdded:Fire(player)
end

function Players:RemovePlayer(playerInstance)
	local player = self:GetPlayer(playerInstance.UserId)
	local id = player.UserId:Get()
	self._RegisteredPlayers[id] = nil
	self.PlayerRemoving:Fire(player)
	player:Destroy()
end

function Players:Destroy()
	self._Maid:Destroy()
end

function Players:GetChildren()
	local list = {}
	-- print(self._RegisteredPlayers)
	for i, plr in pairs(self._RegisteredPlayers) do
		table.insert(list, plr)
	end
	-- print("List", list)
	return list
end

local self = setmetatable({}, Players)
self._Maid = Maid.new()
self._Maid:GiveTask(self)
self._RegisteredPlayers = {}
self._Maid:GiveTask(PlayerService.PlayerAdded:Connect(function(plr)
	self:AddPlayer(plr)
end))

--handle player remove
self._Maid:GiveTask(PlayerService.PlayerRemoving:Connect(function(plr)
	self:RemovePlayer(plr)
end))

for i, player in ipairs(PlayerService:GetChildren()) do
	if player:IsA("Player") then
		self:AddPlayer(player)
	end
end

return self

