local ReplicatedStorage = game:GetService("ReplicatedStorage")
local reactor = script.Parent
local packages = reactor.Parent

local Services = {}
for i, module in ipairs(script:GetChildren()) do
	module.Name = string.lower(module.Name)
	Services[module.Name] = module
end
for i, module in ipairs(packages:GetChildren()) do
	module.Name = string.lower(module.Name)
	Services[module.Name] = module
end

function GetService(serviceName: string)
	if Services[string.lower(serviceName)] then
		return require(Services[string.lower(serviceName)])
	elseif packages:FindFirstChild(string.lower(serviceName)) then
		return require(packages:WaitForChild(string.lower(serviceName)))
	else
		local service
		pcall(function()
			service = game:GetService(serviceName.."Service")
		end)
		if not service then
			service = game:GetService(serviceName)
		end
		return service
	end
end

--[[
	@startuml
	!theme crt-amber
	interface ServiceProvider {
		- ColdFusion: ColdFusion
		- Geometry: Geometry
		- Scene: Scene
		- Synthetic: Synthetic
		- Assembly: Assembly
		- Draw: Draw
		- Easing: Easing
		- Encrypter: Encrypter
		- Enum: Enum
		- Math: Math
		- Players: Players
		+ (name: string): Object | Function
	}

	@enduml
]]--

return GetService