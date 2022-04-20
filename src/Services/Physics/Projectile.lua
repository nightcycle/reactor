

local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")
local physicsService = game:GetService("PhysicsService")
local ContentProvider = game:GetService("ContentProvider")
local collectionService = game:GetService("CollectionService")

local packages = require(replicatedStorage:WaitForChild("Packages"))
local import = packages("import")

local logger = packages("log").new():AtInfo()

local substance = import("shared/Substance")
local config = import("shared/Config")
local Destruction = import("server/Physics/Destruction")
local Util = import("server/Physics/Util")
local voxelLength = config.VoxelSize
local mapFolder = import("map")

local Projectile = {}
Projectile.__index = Projectile

function onImpact(projectile, hit, lethalProjectiles)
	-- logger:Log("Part impact detected")
	local force = projectile.Velocity * projectile.Mass
	if force.Magnitude < 30 then return end
	local impactSize = Vector3.new(
		math.round(1.5*projectile.Size.X/voxelLength),
		math.round(1.5*projectile.Size.Y/voxelLength),
		math.round(1.5*projectile.Size.Z/voxelLength)
	)
	local impactCFrame = projectile.CFrame * CFrame.new(projectile.Velocity.Unit * projectile.Size.Magnitude * 0.5)

	--handle shattering of projectile
	local projectileSubstanceType = projectile:GetAttribute("SubstanceType")
	local projectileSubstance = substance.get(projectileSubstanceType)
	local shatterMagnitude = projectileSubstance:GetDamageMagnitude(force.Magnitude, projectile.Size.X * projectile.Size.Y * projectile.Size.Z)
	if shatterMagnitude > 0 then
		-- volume: number,
		-- force: Vector3,
		-- substanceType: string,
		-- cframe: CFrame,
		-- size: Vector3,
		-- lethalProjectiles: boolean
		Destruction.splinter(
			projectile.Size.X * projectile.Size.Y * projectile.Size.Z,
			force*shatterMagnitude,
			projectile:GetAttribute("SubstanceType"),
			impactCFrame,
			impactSize,
			lethalProjectiles
		)
		projectile:Destroy()
	end
	local impactForce = force * (1-shatterMagnitude)

	--handle impacted
	if hit:IsDescendantOf(mapFolder) then
		local hitSubstanceType = hit:GetAttribute("SubstanceType")
		if hitSubstanceType then
			local hitSubstance = substance.get(hitSubstanceType)
			local hitDamageMagnitude = hitSubstance:GetDamageMagnitude(impactForce.Magnitude, impactSize.X * impactSize.Y * impactSize.Z)
			if hitDamageMagnitude > 0 then
				local profileDim = math.ceil((impactSize.X + impactSize.Y + impactSize.Z)/(3*voxelLength))
				Destruction.destroyRegion(
					impactCFrame,
					impactSize,
					{
						CFrame = impactCFrame,
						ProfileArea = Vector2.new(profileDim,profileDim),
						MaxDepth = projectile.Velocity.Magnitude,
						Power = hitDamageMagnitude*force.Magnitude,
						TipAngle = math.rad(90),
					}
				)
			end
		end	
	-- elseif hit.Parent:FindFirstChild("Humanoid") and lethalProjectiles then
		
	-- elseif hit.ClassName == "Terrain" then
	-- 	if projectile.Size.Magnitude < 1.5 then --bounce or embed

	-- 	else --bounce or explode

	-- 	end
	end
end

function Projectile.new(part, isLethal)
	if part.Name == "Invisible" then return end
	local touchSignal = part.Touched:Connect(function(hit)
		if not collectionService:HasTag(part, "LethalProjectile")
			and not collectionService:HasTag(part, "NonLethalProjectile") then
			onImpact(part, hit, isLethal)
		end
	end)
	task.delay(10, function()
		if part:IsDescendantOf(workspace) then
			if isLethal then
				collectionService:RemoveTag(part, "LethalProjectile")
			else
				collectionService:RemoveTag(part, "NonLethalProjectile")
			end
		end
		touchSignal:Disconnect()
	end)
end

collectionService:GetInstanceAddedSignal("LethalProjectile"):Connect(function(projectile)
	-- logger:Log("Lethal projectile added")
	Projectile.new(projectile, true)
end)
collectionService:GetInstanceAddedSignal("NonLethalProjectile"):Connect(function(projectile)
	-- logger:Log("Nonlethal projectile added")
	Projectile.new(projectile, false)
end)

return Projectile