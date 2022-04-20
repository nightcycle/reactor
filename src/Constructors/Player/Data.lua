local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local packages = script.Parent.Parent

local Fusion = require(packages:WaitForChild("coldfusion"))
local Isotope = require(packages:WaitForChild("isotope"))
local Signal = require(packages:WaitForChild("signal"))

local Data = {}
Data.__index = Data
setmetatable(Data, Isotope)

function Data.new(config)
	local self = setmetatable(Isotope.new(config), Data)
	self.Player = config.Player

	return self
end

return Data