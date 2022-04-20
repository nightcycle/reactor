local services = script.Parent.Parent
local reactor = services.Parent
local packages = reactor.Parent
local components = reactor:WaitForChild("Components")
local fusion = require(services:WaitForChild("coldfusion"))

local Audio = {}
Audio.__index = Audio

function Audio:Destroy()
	self._Maid:Destroy()
end

function Audio:Build()

end

function Audio.new()
	local self = setmetatable({}, Audio)
	local Maid = require(script.Parent.Parent.Parent:WaitForChild("Components"):WaitForChild("Maid"))
	self._Maid = Maid.new()
	self._Maid:GiveTask(self)
	
	return self
end

return Audio