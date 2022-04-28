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

Handler.setService("draw", packages:WaitForChild("draw"))
Handler.setService("enum", packages:WaitForChild("enum"))
Handler.setService("fire", packages:WaitForChild("fire"))
Handler.setService("format", packages:WaitForChild("format"))
Handler.setService("string", packages:WaitForChild("string"))
Handler.setService("texture", packages:WaitForChild("texture"))
Handler.setService("query", packages:WaitForChild("query"))
Handler.setService("timesync", packages:WaitForChild("timesync"))
Handler.setService("voxel", packages:WaitForChild("voxel"))
Handler.setService("signal", packages:WaitForChild("signal"))
Handler.setService("maid", packages:WaitForChild("maid"))
Handler.setService("coldfusion", packages:WaitForChild("coldfusion"))
Handler.setService("math", packages:WaitForChild("math"))
Handler.setService("testez", packages:WaitForChild("testez"))
Handler.setService("import", packages:WaitForChild("import"))

return Handler