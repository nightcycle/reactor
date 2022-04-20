

local collectionService = game:GetService("CollectionService")

local Query = {}
Query.__index = Query

function Query:Destroy()
	self:SetWhitelist({})
	for k, v in pairs(self) do
		self[k] = nil
	end
	setmetatable(self, nil)
end

function Query.subtract(...) --adds tables, instead of keys
	local tables = {...}
	local registry = {}
	local table1 = tables[1]
	for i, inst in ipairs(table1) do
		registry[inst] = true
		for j=2, #tables do
			for _, otherInst in ipairs(tables[j]) do
				if inst == otherInst then
					registry[inst] = nil
				end
			end
		end
	end
	local list = {}
	for inst, _ in pairs(registry) do
		table.insert(list, inst)
	end
	return list
end

function Query:Subtract(...)
	local keys = {...}
	local registry = {}
	local key1 = keys[1]
	for inst, _ in pairs(self.Tags[key1]) do
		registry[inst] = true
		for i=2, #keys do
			if self.Tags[keys[i]][inst] then
				registry[inst] = nil
			end
		end
	end
	local list = {}
	for inst, _ in pairs(registry) do
		table.insert(list, inst)
	end
	return list
end

function Query:Get(key)
	local list = {}

	for inst, _ in pairs(self.Tags[key]) do
		table.insert(list, inst)
	end

	return list
end

function Query.add(...) --adds tables, instead of keys
	local registry = {}
	for i, tabl in ipairs({...}) do
		for _, inst in ipairs(tabl) do
			registry[inst] = true
		end
	end
	local list = {}
	for inst, _ in pairs(registry) do
		table.insert(list, inst)
	end
	return list
end

function Query:Add(...)
	local tables = {}
	for i, key in ipairs({...}) do
		-- print("Key add", key)
		tables[key] = tables[key] or {}
		for inst, _ in pairs(self.Tags[key]) do
			table.insert(tables[key], inst)
		end
	end
	-- print("Next", tables)
	local lists = {}
	for k, lis in pairs(tables) do
		table.insert(lists, lis)
	end
	-- print("Table", lists, self.Tags)
	return Query.add(unpack(lists))
end

function Query:RunSeries(constraints)
	local finalList = {}
	local filterResults = {}
	local filterPops = {}
	-- print(constraints)
	local filterSizes = {}
	for key, func in pairs(constraints) do
		filterResults[key] = {}
		filterPops[key] = 0
		table.insert(filterSizes, key)
		for i, inst in ipairs(self:Run(key, func)) do
			filterResults[key][inst] = true
			filterPops[key] += 1
		end
	end
	table.sort(filterSizes, function(a, b)
		return filterPops[a] < filterPops[b]
	end)
	-- print("Filter", filterResults)
	for inst, _ in pairs(filterResults[filterSizes[1]]) do
		local viable = true
		for key, _ in pairs(constraints) do
			if not filterResults[key][inst] then
				viable = false
			end
		end
		if viable then
			table.insert(finalList, inst)
		end
	end
	-- print("Final", finalList)
	return finalList
end

function Query:Run(key, func)
	local finalList = {}

	for inst, _ in pairs(self.Tags[key] or {}) do
		if func(Query.getValueFromKey(inst, key)) == true then
			table.insert(finalList, inst)
		end
	end

	return finalList
end

function Query:GetSmallestTagCollection(): {[number]: Instance}
	local list = {}
	for inst, _ in pairs(self.Tags[self.TagSizeOrder[1]]) do
		table.insert(list, inst)
	end
	return list
end

function Query:SetWhitelist(whitelist)
	self.Whitelist = whitelist or {}
	self.Populations = {}
	self.TagSizeOrder = {}
	for key, registry in pairs(self.Tags) do
		for inst, _ in pairs(registry) do
			registry[inst] = nil
		end
		local list = {}
		for i, inst in ipairs(self.Whitelist) do
			if Query.hasKTag(inst, key) then
				registry[inst] = true
				table.insert(list, inst)
			end
		end
		self.Populations[key] = #list
		table.insert(self.TagSizeOrder, key)
	end
	table.sort(self.TagSizeOrder, function(a,b)
		return self.Populations[a] < self.Populations[b]
	end)
end

function Query.new(...)
	local self = setmetatable({}, Query)
	self.Tags = {}
	self.Populations = {}
	self.TagSizeOrder = {}
	for i, tag in ipairs({...}) do
		self.Tags[tag] = {}
	end
	return self
end

function Query.getKVTagged(key, value)
	local keyVal = Query.getKVTagFormat(key, value)
	local list = collectionService:GetTagged(keyVal)
	-- print(list, keyVal)
	return list
end

function Query.getKTagged(key)
	return collectionService:GetTagged(key)
end

function Query.getKVTagFormat(key, value)
	return key.."_"..tostring(value)
end

function Query.getValueFromKey(inst, key)
	for i, tag in ipairs(collectionService:GetTags(inst)) do
		local index = string.find(tag, "_")
		if index then
			local tKey = string.sub(tag, 1, index-1)
			if tKey == key and index then
				local result = string.sub(tag, index+1)
				return result
			end
		end
	end
end

function Query.removeKVTag(inst, key)
	local value = Query.getValueFromKey(inst, key)
	if value then
		collectionService:RemoveTag(inst, key)
		collectionService:RemoveTag(inst, Query.getKVTagFormat(key, value))
	end
	inst:SetAttribute(key, nil)
	collectionService:RemoveTag(inst, key)
end

function Query.hasKTag(inst, key)
	return collectionService:HasTag(inst, key)
end

function Query.addKVTag(inst, key, value)
	Query.removeKVTag(inst, key)
	collectionService:AddTag(inst, key)
	collectionService:AddTag(inst, Query.getKVTagFormat(key, value))
	inst:SetAttribute(key, tostring(value))
end

function Query.getAllKVTags(key, value): {[number]: string}
	return collectionService:GetTagged(Query.getKVTagFormat(key, value))
end

return Query