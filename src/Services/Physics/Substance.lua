local debris = game:GetService("Debris")
local physicsService = game:GetService("PhysicsService")
local collectionService = game:GetService("CollectionService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local packages = require(replicatedStorage:WaitForChild("Packages"))
local import = packages("import")
local maidConstructor = packages("maid")

local enum = import("shared/Enum")
local actions = enum.CursorMode
local mapConfig = import("shared/Config")

function toMeters(units: number)
    return units*0.3124
end

local config = {}
function loadSubstance(inst)
	local subConfig = {
		SubstanceType = inst.Name,
		Color = inst:GetAttribute("Color"),
		Material = inst:GetAttribute("Material"),
		CollisionGroup = inst:GetAttribute("CollisionGroup"),
		Strength = inst:GetAttribute("Strength"), --npm2 point of shattering
		Density = inst:GetAttribute("Density"), --kg/m^3
		Importance = inst:GetAttribute("Importance"),
		RecolorParticles = inst:GetAttribute("RecolorParticles"),
		Sounds = {
			Shatter = inst:GetAttribute("ShatterSound"),
		},
		Actions = {
			[actions.Carve] = inst:GetAttribute("CarveEnabled"),
			[actions.Melee] = inst:GetAttribute("MeleeEnabled"),
			[actions.Bind] = inst:GetAttribute("BindEnabled"),
			[actions.Embed] = inst:GetAttribute("EmbedEnabled"),
			[actions.Throw] = inst:GetAttribute("ThrowEnabled"),
		},
		Particles = {
			Shatter = inst:GetAttribute("ShatterParticles"),
		},
		Variants = {},
	}
	for i, child in ipairs(inst:GetChildren()) do
		table.insert(subConfig.Variants, loadSubstance(child))
	end
	for k, v in pairs(subConfig) do
		if type(v) == "table" then
			local count = 0
			for k2, v2 in pairs(v) do
				count += 1
			end
			if count == 0 then
				subConfig[k] = nil
			end
		end
	end
	if subConfig.Actions then
		subConfig.Actions[actions.None] = true
		subConfig.Actions[actions.Place] = true
		subConfig.Actions[actions.Grip] = true
	end
	return subConfig
end
for i, child in ipairs(replicatedStorage:WaitForChild("Substances"):GetChildren()) do
	table.insert(config, loadSubstance(child))
end

local Substance = {}
Substance.__index = Substance
Substance.__type = script.Name

function Substance:IsA(class)
	for i, c in ipairs(self.Classes) do
		if c == class then return true end
	end
	return false
end

function Substance:Apply(basePart: BasePart)
	basePart.CustomPhysicalProperties = self.PhysicalProperties
	basePart.Color = self.Color
	basePart.Material = self.Material
	basePart.CanCollide = true
	basePart:SetAttribute("SubstanceType", self.SubstanceType)
	for i, classKey in ipairs(self.Classes) do
		collectionService:AddTag(basePart, classKey)
	end
	physicsService:SetPartCollisionGroup(basePart, self.CollisionGroup)
end

function Substance.getConstructionBlock(size, cf)
	local constructionBlock = Instance.new("Part")
	constructionBlock.Size = size
	constructionBlock.CFrame = cf
	constructionBlock.Anchored = true
	constructionBlock.CanCollide = false
	constructionBlock.CanTouch = false
	constructionBlock.CanQuery = false
	constructionBlock.Transparency = 1
	constructionBlock.Parent = workspace
	return constructionBlock
end

function Substance:FireShatterEffects(size, cf)
	local constructionBlock = Substance.getConstructionBlock(size, cf)
	local shatterList = import(self.Sounds.Shatter):GetChildren()
	-- print("ShatterList", shatterList)
	local soundInst = shatterList[math.random(#shatterList)]:Clone()
	soundInst.PlayOnRemove = true
	soundInst.Parent = constructionBlock
	task.spawn(function()
		soundInst:Destroy()
	end)

	-- print("Played")
	local particles = import(self.Particles.Shatter):Clone()
	if self.RecolorParticles == true then
		particles.Color = ColorSequence.new(self.Color)
	end
	particles.Parent = constructionBlock

	local duration = particles:GetAttribute("Duration")
	local range = duration.Max - duration.Min
	debris:AddItem(constructionBlock, 1.5)
	debris:AddItem(particles, duration.Min + math.random()*range)
end

function Substance:GetDamageMagnitude(power: number, volume: number)
	local pressure = power/volume
	local normalizedStrength = (self.Strength / (10^2))
	return math.clamp(((pressure-normalizedStrength)/normalizedStrength), 0, 1)
end

function Substance:GetCutDepth(power: number, area: Vector2, tipAngle: Vector2)
    if power == 0 then return 0 end
    if area == nil then return 0 end
    if tipAngle == nil then return 0 end
    local threshold = self.Strength
    local depth = 0
    local increment = mapConfig.VoxelSize
    local powerRemaining = power
    local function cutDeeper(index)
        if depth > 100 then error("Please keep cuts below 100 units") end
        index = index or 1
        local proposedDepth = depth + increment
        local currentX = math.min(math.tan(tipAngle.X*0.5)*proposedDepth*2, area.X)
        local currentY = math.min(math.tan(tipAngle.Y*0.5)*proposedDepth*2, area.Y)
        local currentArea = toMeters(currentX)*toMeters(currentY)

        local powerRequirement = threshold * increment * currentArea
        -- print("Index", index, "Threshold", threshold, "Pressure", powerRequirement, "Power", powerRemaining, "Area", currentArea)
        if powerRequirement < powerRemaining then
            powerRemaining -= powerRequirement
            depth += increment
            cutDeeper(index+1)
        end
    end
    cutDeeper()
--     warn("Depth: "..tostring(depth))
    return depth
end

function Substance.import(config)
    config = config or {}
    return Substance.new(unpack(config))
end

local library = {}

function Substance.get(substanceType: string)
    substanceType = substanceType or "Unknown"
    return library[substanceType]
end

function Substance.new(config)
	local self = setmetatable({}, Substance)

	-- self.Configuration = config
	for k, v in pairs(config) do self[k] = v end
	self.ClassName = "Substance" :: string
	self.PhysicalProperties = PhysicalProperties.new(
		self.Density*1.5,
		self.Friction or 0.3,
		0,
		1,
		0
	)
    return self
end

type Substance = typeof(Substance.new())

function load(subConfig, parentConfig)
    parentConfig = parentConfig or {
	    Classes = {},
    }
    local finalConfig = {}
    for k, v in pairs(parentConfig) do
        if k ~= "Variants" then
            finalConfig[k] = v
        end
    end
    for k, v in pairs(subConfig) do
        finalConfig[k] = v
    end
    for i, vConfig in ipairs(finalConfig.Variants or {}) do
        load(vConfig, finalConfig)
    end
    table.insert(finalConfig.Classes, finalConfig.SubstanceType)
    library[finalConfig.SubstanceType] = Substance.new(finalConfig)
end

for i, sConfig in ipairs(config) do
    load(sConfig)
end

return Substance
