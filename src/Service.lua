local reactor = script.Parent
local packages = reactor.Parent

local Handler = {}

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
	local origName = name
	name = string.lower(name)
	name = string.gsub(name, "service", "")
	origName = string.gsub(origName, "Service", "")
	if self._ServiceCaches[name] ~= nil then
		service = self._ServiceCaches[name]
	elseif self._ServiceCaches[name.."service"] ~= nil then
		service = self._ServiceCaches[name.."service"]
	elseif self._Services[name] ~= nil then
		service = require(self._Services[name])
	elseif self._Services[name.."service"] ~= nil then
		service = require(self._Services[name.."service"])
	else
		pcall(function()
			service = game:GetService(origName.."Service")
		end)
		if not service then
			service = game:GetService(origName)
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