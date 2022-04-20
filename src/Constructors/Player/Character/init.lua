local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local packages = script.Parent.Parent

local Fusion = require(packages:WaitForChild("coldfusion"))
local Isotope = require(packages:WaitForChild("isotope"))
local Signal = require(packages:WaitForChild("signal"))

local Outfit = require(script:WaitForChild("Outfit"))
local Body = require(script:WaitForChild("Body"))

local Character = {}

Character.__index = Character
Character.ClassName = "Character"

function Character:Teleport(cf: CFrame, yield: boolean | nil)
	if RunService:IsServer() then
		local hrp = self.HumanoidRootPart:Get()
		if not hrp then return end
		hrp.CFrame = cf
	end
end

function Character:Export()
	return {
		Body = Body:Export(),
		Outfit = Outfit:Export(),
	}
end

function Character:Import(data)
	self.Body:Import(data.Body)
	self.Outfit:Import(data.Outfit)
end

function Character:Destroy()
	local playerInst = self.Instance:Get()
	if playerInst and playerInst:IsA("Pseudo") then
		playerInst:Destroy()
	end
	Isotope.Destroy(self)
end

function Character.fromInstance(model: Model, player:Player)
	local char = Character.new {
		Player = player,
		Instance = Fusion.Value(model),
	}
	return char
end

function Character.getBodyPartNames(includeHRP: boolean)
	local list = {
		"Head",
		"UpperTorso",
		"LowerTorso",
		"RightUpperArm",
		"RightLowerArm",
		"RightHand",
		"LeftUpperArm",
		"LeftLowerArm",
		"LeftHand",
		"RightUpperLeg",
		"RightLowerLeg",
		"RightFoot",
		"LeftUpperLeg",
		"LeftLowerLeg",
		"LeftFoot",
	}
	if includeHRP then
		table.insert(list, "HumanoidRootPart")
	end
	return list
end

function Character:ApplyHumanoidDescription(humDesc)

	self.Body.Scale.Base:Set(1)

	local headScale = tonumber(1)
	if headScale then self.Body.Scale.Head:Set(headScale) end
	local heightScale = tonumber(humDesc.HeightScale)
	if heightScale then self.Body.Scale.Height:Set(heightScale) end
	
	local widthScale = tonumber(humDesc.WidthScale)
	local depthScale = tonumber(humDesc.DepthScale)
	self.Body.Scale.Weight:Set(math.max(widthScale,depthScale))

	self.Body.Skin.Color:Set(humDesc.HeadColor)
	self.Body.Skin.Color:Set(humDesc.HeadColor)

	self.Outfit.Shirt.ProductId:Set(humDesc.Shirt)
	self.Outfit.Shirt.Color:Set(Color3.new(1,1,1))
	self.Outfit.Pants.ProductId:Set(humDesc.Pants)
	self.Outfit.Pants.Color:Set(Color3.new(1,1,1))

	for _, info in ipairs(humDesc:GetAccessories(false)) do
		self.Outfit:AddAccessory({
			Character = self,
			ProductId = Fusion.Value(info.AssetId),
			Order = Fusion.Value(info.Order),
		})
	end

	for _, k in ipairs({"Back", "Face", "Front", "Hat", "Neck", "Shoulders", "Waist"}) do
		for order, id in ipairs(string.split(humDesc[k.."Accessory"], ",")) do
			if tonumber(id) ~= nil then
				self.Outfit:AddAccessory({
					Character = self,
					ProductId = Fusion.Value(id),
				})
			end
		end
	end
	for order, id in ipairs(string.split(humDesc["HairAccessory"], ",")) do
		if tonumber(id) ~= nil then
			self.Body:AddHair({
				Character = self,
				ProductId = Fusion.Value(id),
			})
		end
	end

	-- self.Animation.Animations.Climbing:Set(humDesc.ClimbAnimation)
	-- self.Animation.Animations.FallingDown:Set(humDesc.FallAnimation)
	-- self.Animation.Animations.Jumping:Set(humDesc.JumpAnimation)
	-- self.Animation.Animations.Running:Set(humDesc.RunAnimation)
	-- self.Animation.Animations.Swimming:Set(humDesc.SwimAnimation)

end

function Character.new(config)
	local self = setmetatable(Isotope.new(config), Character)
	self.Player = config.Player
	self.Instance = config.Instance
	self.Humanoid = Fusion.Value(nil)
	self.HumanoidSignal = function(maid)
		local hum = self.Humanoid:Get()
		if not hum then return end
		return hum.StateChanged
	end
	self.HumanoidState = Fusion.Value(nil)
	self._Maid:GiveTask(Fusion.Computed(function(maid)
		local hum = self.Humanoid:Get()
		if not hum then return end
		maid:GiveTask(hum.StateChanged:Connect(function(oldState, newState) --this order is absurd
			self.HumanoidState:Set(newState)
		end))
	end))
	self.HumanoidRootPart = Fusion.Value(nil)
	-- self.Animation = Animation.new({
	-- 	Character = self,
	-- })
	self.Body = Body.new {
		Character = self,
	}
	self.Outfit = Outfit.new {
		Character = self,
	}
	local function handleCharacterInst(inst)
		-- print("New inst", inst)
		if inst:IsA("BasePart") then
			if inst.Name == "HumanoidRootPart" then
				self[inst.Name]:Set(inst)
			end
		elseif inst:IsA("Humanoid") then
			self.Humanoid:Set(inst)
		end
	end
	self._InitNewBodyParts = Fusion.Computed(self.Instance, function(charInst)
		if not charInst then return end
		for i, inst in ipairs(charInst:GetChildren()) do
			handleCharacterInst(inst)
		end
		self._Maid._newBodyPart = charInst.ChildAdded:Connect(handleCharacterInst)
	end)
	self:Construct()
	return self
end

setmetatable(Character, Isotope)

return Character