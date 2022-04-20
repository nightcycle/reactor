local services = script.Parent
local reactor = services.Parent
local packages = reactor.Parent
local components = reactor:WaitForChild("Components")
local fusion = require(services:WaitForChild("coldfusion"))

local Scene = {}
Scene.__index = Scene

function Scene:Destroy()
	self._maid:Destroy()
end

--[[
	@startuml
	!theme crt-amber
	class Scene {
		- _Maid: Maid
		+ Map: Map
		+ Climate: Climate
		+ Audio: Audio
		+ Destroy()
	}
	@enduml
]]--

return function(config)
	local self = setmetatable({}, Scene)
	local Maid = require(script.Parent.Parent.Parent:WaitForChild("Components"):WaitForChild("Maid"))
	self._Maid = Maid.new()
	self._Maid:GiveTask(self)

	self.Map = require(script:WaitForChild("Map"))(config)
	self.Climate = require(script:WaitForChild("Climate"))(config)
	self.Audio = require(script:WaitForChild("Audio"))(config)

	if _G.Reactor then
		_G.Reactor.Scene:Set(self)
	end
	return self
end
