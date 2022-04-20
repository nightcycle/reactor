local EnumItem = {}
EnumItem.__index = EnumItem
EnumItem.__type = "EnumItem"

function EnumItem:__tostring()
	return tostring(self.EnumType).."."..self.Name
end

--[[
	@startuml
	!theme crt-amber
	interface Enum {
		+ __index(key: string)
		+ __newindex(key: string, list: [string])
	}
	@enduml
]]--


function newEnumItem(name, val, enum)
	local self = setmetatable({
		Name = name,
		Value = val,
		EnumType = enum,
	}, EnumItem)
	return self
end

local _Enum = {}
_Enum.__index = _Enum
EnumItem.__type = "Enum"

function _Enum:__tostring()
	return "Enums."..self.Name
end

function _Enum:GetEnumItems()
	local list = {}
	for k, v in pairs(self._enumItems) do
		list[k] = v
	end
	return list
end

function _Enum:__index(key)
	-- print(self, key)
	local enum = rawget(self, "_enumItems")[key]
	if enum then
		return enum
	else
		error("No EnumItem found at "..tostring(key))
	end
end

function newEnum(name, itemList)
	assert(name ~= nil, "Bad enum name")
	assert(itemList ~= nil and type(itemList) == "table", "Bad enum item list")
	local self = {}
	self._enumItems = {}
	self.Name = name
	self._enumItems[0] = newEnumItem("None", 0, self)
	for v, k in ipairs(itemList) do
		self._enumItems[k] = newEnumItem(k, v, self)
	end
	setmetatable(self, _Enum)
	return self
end

local Enums = {}
Enums.__index = Enums
Enums.__type = "Enums"

function Enums:GetEnums()
	local list = {}
	for k, v in pairs(self._enums) do
		list[k] = v
	end
	return list
end

function Enums:__newindex(key, list)
	-- print("Setting index", self, key, list)
	if self._enums[key] == nil then
		-- print("I m i n")
		self._enums[key] = newEnum(key, list)
	end
end

function Enums:__index(key)
	-- print(self, key)
	local enum = rawget(self, "_enums")[key]
	if enum then
		return enum
	else
		error("No enum found at "..tostring(key))
	end
end

local outputEnums = setmetatable({_enums = {}}, Enums)
return outputEnums
