local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local InsertService = game:GetService("InsertService")

local packages = script.Parent.Parent.Parent

local Fusion = require(packages:WaitForChild("coldfusion"))
local Isotope = require(packages:WaitForChild("isotope"))
local Signal = require(packages:WaitForChild("signal"))
local Texture = require(packages:WaitForChild("texture"))

local Accessory = require(script.Parent:WaitForChild("Accessory"))

local Customization = ReplicatedStorage:WaitForChild("Library"):WaitForChild("Customization")
local ShirtFolder = Customization:WaitForChild("Clothing"):WaitForChild("Shirt")
local PantsFolder = Customization:WaitForChild("Clothing"):WaitForChild("Pants")

local Outfit = {}
Outfit.__index = Outfit
setmetatable(Outfit, Isotope)

function Outfit:AddAccessory(config)
	local accessory = Accessory.new(config)
	if self.Accessories[accessory.Id:Get()] then
		self.Accessories[accessory.Id:Get()]:Destroy()
	end
	self.Accessories[accessory.Id:Get()] = accessory
end

function Outfit.new(config)
	local self = setmetatable(Isotope.new(config), Outfit)
	self.Character = config.Character
	self.Player = self.Character.Player

	self.Shirt = config.Shirt or {
		Type = config.Type or Fusion.Value("Flannel Shirt"),
		ProductId = config.ProductId or Fusion.Value(nil),
		Color = config.Color or Fusion.Value(Color3.fromHSV(0, 0.6,0.7))
	}
	self.Pants = config.Pants or {
		Type = config.Type or Fusion.Value("Jeans"),
		ProductId = config.ProductId or Fusion.Value(nil),
		Color = config.Color or Fusion.Value(Color3.fromHSV(0.6, 0.8,0.7))
	}
	self.Accessories = {}

	self.Shirt.Template = Fusion.Computed(self.Shirt.Type, function(cType)
		if not cType then return end
		return ShirtFolder:FindFirstChild(cType)
	end)
	self.Shirt.Id = Fusion.Computed(self.Shirt.ProductId, self.Shirt.Template, function(pId, temp)
		if pId then
			local model = InsertService:LoadAsset(pId)
			local shirt = model:FindFirstChildOfClass("Shirt")
			local id = shirt.ShirtTemplate
			model:Destroy()
			shirt:Destroy()
			return string.gsub(string.gsub(id, "%p", ""), "httpwwwrobloxcomassetid", "")
		elseif temp then
			return temp.ShirtTemplate
		end
	end)
	self.Shirt.Instance = Fusion.Computed(
		self.Character.Instance,
		self.Shirt.Template,
		self.Shirt.Color,
		function(char, temp, col, maid)
			local id = self.Shirt.Id:Get()
			local clothing
			if id then
				clothing = Instance.new("Shirt")
				clothing.Name = "Shirt"
				clothing.ShirtTemplate = "http://www.roblox.com/asset/?id="..tostring(id)
			elseif temp then
				clothing = temp:Clone()
			elseif not clothing then return end
			if not clothing then return end
			clothing.Color3 = col
			clothing.Parent = char
			maid:GiveTask(clothing)
			return clothing
		end
	)
	self.Pants.Template = Fusion.Computed(self.Pants.Type, function(cType)
		if not cType then return end
		return PantsFolder:FindFirstChild(cType)
	end)
	self.Pants.Id = Fusion.Computed(self.Pants.ProductId, self.Pants.Template, function(pId, temp)
		if pId then
			local model = InsertService:LoadAsset(pId)
			local pants = model:FindFirstChildOfClass("Pants")
			local id = pants.PantsTemplate
			-- print("Id", id)
			model:Destroy()
			pants:Destroy()
			return string.gsub(string.gsub(id, "%p", ""), "httpwwwrobloxcomassetid", "")
		elseif temp then
			return temp.PantsTemplate
		end
	end)
	self.Pants.Instance = Fusion.Computed(
		self.Character.Instance,
		self.Pants.Template,
		self.Pants.Color,
		function(char, temp, col, maid)
			local id = self.Pants.Id:Get()
			local clothing
			if id then
				clothing = Instance.new("Pants")
				clothing.Name = "Pants"
				clothing.PantsTemplate = "http://www.roblox.com/asset/?id="..tostring(id)
			elseif temp then
				clothing = temp:Clone()
			elseif not clothing then return end
			if not clothing then return end
			clothing.Color3 = col
			clothing.Parent = char
			maid:GiveTask(clothing)
			return clothing
		end
	)

	return self
end

return Outfit