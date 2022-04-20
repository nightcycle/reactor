local Util = {}

--[[
	@startuml
	!theme crt-amber
	interface Assembly {
		getAssembly(part: BasePart, partRegistry: table | nil, assemblyId: string | nil): [BasePart]
		getAssemblies(parts: [BasePart]): [AssemblyBasePartList]
		groupByAssemblies(parts: [BasePart], parent: Instance | nil) -> [Model]
	}
	@enduml
]]--

function Util.getAssembly(assemblyPart: BasePart, partRegistry: {[BasePart]: string} | nil, assemblyId: string | nil)
	partRegistry = partRegistry or {}
	assemblyId = assemblyId or true
	local parts = {}
	local function mapAssembly(part)
		if part.ClassName == "Terrain" or part.Transparency == 1 then return end
		partRegistry[part] = assemblyId
		table.insert(parts, part)
		for i, neighbor in ipairs(part:GetConnectedParts()) do
			if partRegistry[neighbor] == nil then
				mapAssembly(neighbor)
			end
		end
	end
	-- print(partRegistry, parts)
	mapAssembly(assemblyPart)
	return parts
end


function Util.getAssemblies(parts)
	local assemblyCount = 0
	local partRegistry = {}
	for i, part in ipairs(parts) do
		assemblyCount += 1
		if partRegistry[part] == nil then
			Util.getAssembly(part, partRegistry, tostring(assemblyCount))
		end
	end
	local assemblyRegistry = {}
	for part, assemblyId in pairs(partRegistry) do
		assemblyRegistry[assemblyId] = assemblyRegistry[assemblyId] or {}
		table.insert(assemblyRegistry[assemblyId], part)
	end
	local assemblies = {}
	for id, assembly in pairs(assemblyRegistry) do
		table.insert(assemblies, assembly)
	end
	return assemblies
end

function Util.groupByAssemblies(parts, parent)
	local assemblies = Util.getAssemblies(parts)
	local models = {}
	for i, partList in ipairs(assemblies) do
		local finalModel = Instance.new("Model", parent)
		finalModel.Name = "Assembly"
		table.insert(models, finalModel)
		for j, part in ipairs(partList) do
			local parentToDestroy
			pcall(function()
				if part:IsDescendantOf(game) and part.Parent ~= nil and #part.Parent:GetChildren() == 1 then
					parentToDestroy = part.Parent
				end				
				part.Parent = finalModel
				if parentToDestroy then
					parentToDestroy:Destroy()
				end
				if part.AssemblyRootPart == part then
					finalModel.PrimaryPart = part
					finalModel:SetAttribute("Mass", part.AssemblyMass)
				end
			end)
		end
	end
	return models
end

return Util