local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local packages = script.Parent

local Fusion = require(packages:WaitForChild("coldfusion"))
local Isotope = require(packages:WaitForChild("isotope"))
local Signal = require(packages:WaitForChild("signal"))
local Dummy = ReplicatedStorage:WaitForChild("Dummy")

local Texture = {}

Texture.__index = Texture
Texture.ClassName = "Texture"

function Texture:Destroy()
	Isotope.Destroy(self)
end

function Texture:Apply(inst)
	inst.Color = self.Color:Get()
	inst.Material = self.Material:Get()
	inst.Reflectance = self.Reflectance:Get()
	inst.Transparency = self.Transparency:Get()
	if self.Map.Color and self.Map.Color:Get() then
		local surfaceAppearance = inst:FindFirstChildOfClass("SurfaceAppearance") or Instance.new("SurfaceAppearance", inst)
		surfaceAppearance.ColorMap = self.Map.Color:Get()
		surfaceAppearance.MetalnessMap = self.Map.Metal:Get()
		surfaceAppearance.NormalMap = self.Map.Normal:Get()
		surfaceAppearance.RoughnessMap = self.Map.Roughness:Get()
	end
end

function Texture.new(config)
	local self = setmetatable(Isotope.new(config), Texture)

	self.Color = config.Color or Fusion.Value(Color3.fromHSV(0,0,1))
	self.Material = config.Material or Fusion.Value(Enum.Material.SmoothPlastic)
	self.Map = config.Map or {
		Color = config.ColorMap or Fusion.Value(nil),
		Metalness = config.MetalnessMap or Fusion.Value(nil),
		Normal = config.NormalMap or Fusion.Value(nil),
		Roughness = config.RoughnessMap or Fusion.Value(nil),
	}

	self.Reflectance = config.Reflectance or Fusion.Value(0)
	self.Transparency = config.Transparency or Fusion.Value(0)
	self.Code = Fusion.Computed(
		self.Color,
		self.Material,
		self.Reflectance,
		self.Transparency,
		function(col, mat, ref, trans)
			-- local rgb = col:ToRGB()
			local colString = tostring(col)
			local matString = tostring(mat.Name)
			local refString = tostring(ref)
			local tranString = tostring(trans)
			return colString.."_"..matString.."_"..refString.."_"..tranString
		end
	)
	return self
end

setmetatable(Texture, Isotope)

return Texture