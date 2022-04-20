local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = require(ReplicatedStorage:WaitForChild("Packages"))
local import = packages("import")
local maidConstructor = packages("maid")
local signalConstructor = packages("signal")
local logger = packages("log").new():AtInfo()

function burn(part)
	if CollectionService:HasTag(part, "Burning") then return end
	if part.Anchored then return end
	CollectionService:AddTag(part, "Burning")
	local burnSpeed = (part.Size.X * part.Size.Y * part.Size.Z)*0.5
	local sound = import("sound/Weather/Fire"):Clone()
	sound.Parent = part
	sound.Looped = true
	sound:Play()
	local tweenInfo = TweenInfo.new(burnSpeed, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	local fire = Instance.new("Fire", part)
	fire.Size = 0
	fire.Heat = 0
	local partTween = TweenService:Create(part, tweenInfo, {
		Transparency = 1
	})
	local fireTween = TweenService:Create(fire, tweenInfo, {
		Size = math.max(part.Size.X, part.Size.Y, part.Size.Z),
		Heat = math.max(part.Size.X, part.Size.Y, part.Size.Z)/2,
	})

	partTween:Play()
	fireTween:Play()
	for i, neighbor in ipairs(part:GetConnectedParts()) do
		task.delay(burnSpeed*0.75, function()
			burn(neighbor)
		end)
	end
	Debris:AddItem(sound, burnSpeed)
	Debris:AddItem(fireTween, burnSpeed)
	Debris:AddItem(partTween, burnSpeed)
	Debris:AddItem(part, burnSpeed)
	Debris:AddItem(fire, burnSpeed)
end

for i, lava in ipairs(CollectionService:GetTagged("Lava")) do
	lava.Touched:Connect(function(hit)
		burn(hit)
	end)
end