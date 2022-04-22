local ReplicatedStorage = game:GetService("ReplicatedStorage")
local reactor = script.Parent
local packages = reactor.Parent

local Services = {}

local Handler = {}

function Handler.SetService(serviceName: string, module)
	Services[serviceName] = module
end

function Handler.GetService(serviceName: string)
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

Handler.SetService("draw", packages:WaitForChild("draw"))
Handler.SetService("enum", packages:WaitForChild("enum"))
Handler.SetService("fire", packages:WaitForChild("fire"))
Handler.SetService("format", packages:WaitForChild("format"))
Handler.SetService("string", packages:WaitForChild("string"))
Handler.SetService("texture", packages:WaitForChild("texture"))
Handler.SetService("query", packages:WaitForChild("query"))
Handler.SetService("timesync", packages:WaitForChild("timesync"))
Handler.SetService("voxel", packages:WaitForChild("voxel"))
Handler.SetService("signal", packages:WaitForChild("signal"))
Handler.SetService("maid", packages:WaitForChild("maid"))
Handler.SetService("coldfusion", packages:WaitForChild("coldfusion"))
Handler.SetService("math", packages:WaitForChild("math"))
Handler.SetService("testez", packages:WaitForChild("testez"))

return Handler