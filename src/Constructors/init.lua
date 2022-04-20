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

for i, mod in ipairs(script:GetChildren()) do
	Constructors[string.lower(mod.Name)] = mod
end

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

-- Handler.set("action", require(packages:WaitForChild("action")))
-- Handler.set("appearance", require(packages:WaitForChild("appearance")))
-- Handler.set("camera", require(packages:WaitForChild("camera")))
-- Handler.set("character", require(packages:WaitForChild("character")))
-- Handler.set("finitestatemachine", require(packages:WaitForChild("finitestatemachine")))
-- Handler.set("isotope", require(packages:WaitForChild("isotope")))
-- Handler.set("movement", require(packages:WaitForChild("movement")))
-- Handler.set("player", require(packages:WaitForChild("player")))
-- Handler.set("ray", require(packages:WaitForChild("ray")))

return Handler