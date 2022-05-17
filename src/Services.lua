local ReplicatedStorage = game:GetService("ReplicatedStorage")
local reactor = script.Parent
local packages = reactor.Parent

local Services = {}

local Handler = {}

function Handler.setService(serviceName: string, module)
	Services[serviceName] = module
end

function Handler.getService(serviceName: string)
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

for i, package in ipairs(packages:GetChildren()) do
	Handler.setService(package.Name, package)
end

return Handler