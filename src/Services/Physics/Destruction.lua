
local replicatedStorage = game:GetService("ReplicatedStorage")
local collectionService = game:GetService("CollectionService")

local packages = require(replicatedStorage:WaitForChild("Packages"))
local import = packages("import")
local maidConstructor = packages("maid")

local logger = packages("log").new():AtInfo()

local substance = import("shared/Substance")
local assemblyUtil = import("shared/Assembly")
local config = import("shared/Config")
local Util = import("server/Physics/Util")
local voxelLength = config.VoxelSize
local mapFolder = import("map")

local Destruction = {}
Destruction.__index = Destruction

function Destruction.splinter(volume: number, force: Vector3, substanceType: string, cframe: CFrame, size: Vector3, lethalProjectiles: boolean)

	local targetSubstance = substance.get(substanceType)
	if volume and volume > 4 * 0.25^3 then
		-- logger:Log("Splintering")
		local voxelCount = math.ceil(volume / (voxelLength^3))
		local projectileCount = math.clamp(math.round(voxelCount/(4^3)), 1, 4)
		local avgProjectileVolume = volume / projectileCount
		local avgProjectileDimension = avgProjectileVolume^(1/3)
		for j=1, projectileCount do
			local z = (math.random()*0.5 + 1) * avgProjectileDimension
			local area = avgProjectileVolume / z
			local y = (math.random()*0.5 + 1) * (area^0.5)
			local x = area / y
			x = math.round(x/voxelLength)*voxelLength
			y = math.round(y/voxelLength)*voxelLength
			z = math.round(z/voxelLength)*voxelLength
			local projectileSize = Vector3.new(x,y,z)

			local offsetX = size.X*(math.random()-0.5)
			local offsetY = size.Y*(math.random()-0.5)
			local offsetZ = size.Z*(math.random()-0.5)
			local projectileCF = cframe * CFrame.new(offsetX, offsetY, offsetZ)
		
			local projectile = Instance.new("Part")
			projectile.Size = projectileSize-Vector3.new(1,1,1)*voxelLength
			projectile.Anchored = false
			projectile.CFrame = projectileCF
			projectile.CFrame *= CFrame.Angles(math.random()*math.pi, math.random()*math.pi, math.random()*math.pi)
			targetSubstance:Apply(projectile)
			projectile.Parent = mapFolder
			projectile:ApplyImpulse(force*2)
			
			collectionService:AddTag(projectile, if lethalProjectiles then "LethalProjectile" else "NonLethalProjectile")
		end
		targetSubstance:FireShatterEffects(size, cframe)
	else
		-- logger:Log("Splinter skipped")
	end
end


function Destruction.destroyRegion(cutCFrame, cutSize, impactConfig)
	-- logger:Log("Destroying region")
	local maid = maidConstructor.new()
	local impactCFrame = impactConfig.CFrame
	local profileArea = impactConfig.ProfileArea
	local maxDepth = impactConfig.MaxDepth
	local power = impactConfig.Power
	local tipAngle = impactConfig.TipAngle
	local lethalProjectiles = impactConfig.LethalProjectiles
	local constructionBlock  = Util.getConstructionBlock(cutSize, cutCFrame)
	maid:GiveTask(constructionBlock)
	local coreBlocks = Util.getPartsInBlock({mapFolder}, constructionBlock) or {}
	local offsetCFrame = impactCFrame:Inverse() * cutCFrame
	local substanceKeys = {}
	local partRegistry = {}
	for i, corePart in ipairs(coreBlocks) do
		local targetSubstanceType = corePart:GetAttribute("SubstanceType")
		if targetSubstanceType ~= nil then
			local targetSubstance = substance.get(targetSubstanceType)

			substanceKeys[targetSubstanceType] = true
			corePart.Transparency = 0.7
			
			local depth = 1 + math.min(maxDepth, targetSubstance:GetCutDepth(power, profileArea, tipAngle))

			local substanceCutSize = Vector3.new(profileArea.X, profileArea.Y, depth)
			local depthOffset = depth/2
			if math.sign(depthOffset) ~= math.sign(offsetCFrame.X) then
				depthOffset *= -1
			end
			local cutPosition = (impactCFrame * CFrame.new(0,0,depthOffset-1)).p
			local zVec = (cutCFrame.p - cutPosition).Unit
			local zDot = zVec:Dot(cutCFrame.ZVector)
			local xVec = cutCFrame.XVector
			if zDot < 0 then
				xVec *= -1
			end
			local substanceCutCFrame = CFrame.fromMatrix(impactCFrame.p, xVec, cutCFrame.YVector) * CFrame.new(0,0,depthOffset+1*math.sign(zDot))
			local substanceConstructionBlock = Util.getConstructionBlock(substanceCutSize+Vector3.new(0,0,1), substanceCutCFrame)
			maid:GiveTask(substanceConstructionBlock)

			local cutParts = {substanceConstructionBlock}
			local oldParts = {corePart}
			local newParts, volReduction = Util.cut(corePart.CFrame, oldParts, cutParts)

			for j, newPart in ipairs(newParts) do
				targetSubstance:Apply(newPart)
			end
			local models = Util.swap(newParts, oldParts)
			for k, model in ipairs(models) do
				for j, part in ipairs(model:GetChildren()) do
					if part:IsA("BasePart") then
						partRegistry[part] = true
					end
				end
			end
			Destruction.splinter(volReduction, (cutCFrame.p - impactCFrame.p).Unit * power, targetSubstanceType, cutCFrame, cutSize, lethalProjectiles)
		end
	end
	local partList = {}
	for part, _ in pairs(partRegistry) do
		table.insert(partList, part)
	end
	local models = assemblyUtil.groupByAssemblies(partList, mapFolder)
	for i, assemblyModel in ipairs(models) do
		local assemblyMass = 0
		for j, part in ipairs(assemblyModel:GetChildren()) do
			if part:IsA("BasePart") then
				assemblyMass = math.max(assemblyMass, part.AssemblyMass)
			end
		end
		-- print("Assembly Mass", assemblyMass)
		if assemblyMass < 100*(1000^3) then
			local modelParts = assemblyModel:GetChildren()
			Destruction.weldByCollisionGroup(modelParts)
		end
	end

	task.delay(2, function()
		maid:Destroy()
	end)
	return models
end

return Destruction