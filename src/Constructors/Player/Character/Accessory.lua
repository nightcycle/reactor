local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")

local packages = script.Parent.Parent.Parent

local Fusion = require(packages:WaitForChild("coldfusion"))
local Isotope = require(packages:WaitForChild("isotope"))
local Signal = require(packages:WaitForChild("signal"))
local Texture = require(packages:WaitForChild("texture"))

local CustomizationFolder = ReplicatedStorage:WaitForChild("Library"):WaitForChild("Customization")
local AccessoryFolder = CustomizationFolder:WaitForChild("Accessory")
local Accessory = {}
Accessory.__index = Accessory
setmetatable(Accessory, Isotope)

function Accessory.new(config)
	local self = setmetatable(Isotope.new(config), Accessory)

	self.Character = config.Character
	self.Path = config.Path or Fusion.Value(nil)
	self.ProductId = config.ProductId or Fusion.Value(nil)
	self.Order = config.Order or Fusion.Value(1)
	self.Puffiness = config.Puffiness or Fusion.Value(1)
	self.ShrinkFactor = config.ShrinkFactor or Fusion.Value(0)
	self.Id = Fusion.Computed(function()
		local path = self.Path:Get()
		local pId = self.ProductId:Get()
		return tostring(pId or path)
	end)
	self.Texture = config.Texture or Texture.new {
		Color = config.Color,
		Material = config.Material,
		Map = config.Map,
		ColorMap = config.ColorMap,
		MetalnessMap = config.MetalnessMap,
		NormalMap = config.NormalMap,
		RoughnessMap = config.RoughnessMap,
		Reflectance = config.Reflectance,
		Transparency = config.Transparency	,
	}

	self.Instance = Fusion.Computed(
		function(maid)

			local order = self.Order:Get()
			local puffiness = self.Puffiness:Get()
			local shrinkFactor = self.ShrinkFactor:Get()
			local pId = self.ProductId:Get()
			local path = self.Path:Get()
			if pId then
				local model = InsertService:LoadAsset(pId)
				local accessory = model:FindFirstChildOfClass("Accessory")
				local handle = accessory:FindFirstChild("Handle")
				-- if not handle:IsA("MeshPart") then
				local mesh = handle:FindFirstChildOfClass("SpecialMesh")
				-- local id = string.gsub(mesh.MeshId, "rbxassetid://", "")
				-- print("MeshId", mesh.MeshId, tonumber(id))
				-- local meshPartModel = InsertService:LoadAsset(tonumber(id))
				-- local meshPart = meshPartModel:FindFirstChildOfClass("MeshPart")
				-- for i, inst in ipairs(handle:GetChildren()) do
				-- 	if inst ~= mesh then
				-- 		inst.Parent = meshPart
				-- 	end
				-- end
				local wrapLayer = handle:FindFirstAncestorOfClass("WrapLayer")
				if wrapLayer then
					wrapLayer.Order = order
					wrapLayer.Puffiness = puffiness
					wrapLayer.ShrinkFactor = shrinkFactor
				end
				-- meshPart.Name = "Handle"
				-- meshPartModel:Destroy()
				-- handle:Destroy()
					-- meshPart.Parent = accessory
				-- end
				accessory.Parent = nil
				model:Destroy()
				maid:GiveTask(accessory)
				return accessory
			elseif path then
				local keys = string.split(path, "/")
				local cat = keys[1]
				local name = keys[2]
				local aFolder = AccessoryFolder:FindFirstChild(cat)
				if aFolder then
					local template = aFolder:FindFirstChild(name)
					if template then
						local inst = template:Clone()
						maid:GiveTask(inst)
						return inst
					end
				end
			end
		end
	)
	self.SpecialMesh = Fusion.Computed(self.Instance, function(inst)
		if not inst then return end
		local mesh = inst:FindFirstChildOfClass("SpecialMesh")
		if mesh then
			return mesh
		end
	end)
	self._Maid:GiveTask(Fusion.Computed(
		self.SpecialMesh,
		self.Texture.Color,
		self.Texture.Map.Color,
		function(mesh, col, textureId)
			if not mesh then return end
			if col then
				mesh.VertexColor = col
			end
			if textureId then
				mesh.TextureId = textureId
			end
		end
	))
	self._Maid:GiveTask(Fusion.Computed(self.Character.Humanoid, self.Instance, function(hum, inst)
		if not hum or not inst then return end
		-- print("Inst", inst)
		hum:AddAccessory(inst)
		-- inst.Parent = hum.Parent
	end))
	-- self.Handle = Fusion.Computed(self.Instance, function(inst)
	-- 	if not inst then return end
	-- 	return inst:FindFirstChild("Handle")
	-- end)
	-- self.AccessoryAttachment = Fusion.Computed(self.Instance, function(accessory)
	-- 	if not accessory then return end
	-- 	return accessory:FindFirstChildOfClass("Attachment")
	-- end)
	-- self.CharacterAttachment = Fusion.Computed(self.Character.Instance, self.AccessoryAttachment, function(character, attachment)
	-- 	if not character then return end
	-- 	if not attachment then return end
	-- 	local attachmentName = attachment.Name
	-- 	return character:FindFirstChild(attachmentName, true)
	-- end)
	-- self.Part1 = Fusion.Computed(self.CharacterAttachment, function(attach)
	-- 	if not attach then return end
	-- 	return attach.Parent
	-- end)
	-- self.Weld = Fusion.new "Weld" {
	-- 	Part0 = self.Handle,
	-- 	Part1 = self.Part1,
	-- 	C0 = Fusion.Computed(self.Handle, self.AccessoryAttachment, function(part0, attach)
	-- 		if not part0 or not attach then return CFrame.new(0,0,0) end
	-- 		local position = attach.Position
	-- 	end),
	-- 	C1 = Fusion.Computed(self.Part1, self.CharacterAttachment, function(part1, attach)
	-- 		if not part1 or not attach then return CFrame.new(0,0,0) end

	-- 	end)
	-- }
	self:Construct()
	return self
end

return Accessory
