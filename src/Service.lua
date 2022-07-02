local reactor = script.Parent
local packages = reactor.Parent

local Handler = {}
Handler.__index = Handler


function Handler:Destroy()
	for k, v in pairs(self._ServiceCaches) do
		if typeof(v) == "table" and v.Destroy then
			v:Destroy()
		end
		self._ServiceCaches[k] = nil
	end
	for k, v in pairs(self._Services) do
		self._Services[k] = nil
	end
end

function Handler:GetService(name: string)
	local service
	name = string.lower(name)
	name = string.gsub(name, "service", "")
	if self._ServiceCaches[name] ~= nil then
		service = self._ServiceCaches[name]
	elseif self._Services[name] ~= nil then
		service = require(self._Services[name])
	else
		pcall(function()
			service = game:GetService(name.."Service")
		end)
		if not service then
			service = game:GetService(name)
		end
	end
	self:CacheService(name, service)
	return service
end

function Handler:BuildService(className: string, parameters: {[any]: any} | nil): Instance
	local service
	local success = pcall(function()
		service = self:GetService(className)
	end)
	if success then
		if typeof(service) == "function" then
			return service(parameters)
		elseif typeof(service) == "table" then
			return service.new(parameters)
		end
	else
		local inst = Instance.new (className)
		for k, v in pairs(parameters or {}) do
			inst[k] = v
		end
		return inst
	end
end

function Handler:SetService(name: string, module: ModuleScript)
	self._Services[string.lower(name)] = module
end

function Handler:CacheService(name: string, content: any)
	self._ServiceCaches[string.lower(name)] = content
end

function Handler:SetPackages()
	for i, package in ipairs(packages:GetChildren()) do
		self:SetService(package.Name, package)
	end
end


return Handler