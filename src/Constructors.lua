local ReplicatedStorage = game:GetService("ReplicatedStorage")

local reactor = script.Parent
local packages = reactor.Parent
local fusion = require(packages:WaitForChild("coldfusion"))

local Constructors = {
	computed = fusion.Computed,
	attribute = fusion.Attribute,
	signal = fusion.Signal,
	property = fusion.Property,
	table = fusion.Table,
	value = fusion.Value,
	state = fusion.State,
}

local Handler = {}

function Handler.get(componentName: string)
	if Constructors[componentName] then
		local mod = require(Constructors[string.lower(componentName)])
		if type(mod) == "function" then
			return mod
		else
			error("Component Constructor "..tostring(componentName).." is not a function")
		end
	else
		return fusion.new(componentName)
	end
end

function Handler.set(componentName: string, func)
	Constructors[string.lower(componentName)] = func
end

Handler.set("isotope", require(packages:WaitForChild("isotope")))
Handler.set("checkbox", require(packages:WaitForChild("checkbox")))
Handler.set("iconlabel", require(packages:WaitForChild("iconlabel")))
Handler.set("player", require(packages:WaitForChild("player")))
Handler.set("radiobutton", require(packages:WaitForChild("radiobutton")))
Handler.set("switch", require(packages:WaitForChild("switch")))
Handler.set("textlabel", require(packages:WaitForChild("textlabel")))

return Handler