local services = script.Parent.Parent
local reactor = services.Parent
local packages = reactor.Parent
local components = reactor:WaitForChild("Components")
local fusion = require(services:WaitForChild("coldfusion"))

local Map = {}
Map.__index = Map

function Map:Destroy()
	self._Maid:Destroy()
end

return function(config)
	local self = setmetatable({}, Map)
	local Maid = require(script.Parent.Parent.Parent:WaitForChild("Components"):WaitForChild("Maid"))
	self._Maid = Maid.new()
	self._Maid:GiveTask(self)

	local fusion = require(script.Parent.Parent:WaitForChild("ColdFusion"))
	local inst = game.Workspace:FindFirstChild("Map")
	if not inst then
		inst = Instance.new("Folder", workspace)
		inst.Name = "Map"
	end
	self.Instance = fusion.Value(inst)

	return self
end
