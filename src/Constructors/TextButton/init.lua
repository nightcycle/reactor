--!strict
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = script.Parent

local Fusion = require(packages:WaitForChild("coldfusion"))
local Isotope = require(packages:WaitForChild("isotope"))
local Signal = require(packages:WaitForChild("signal"))
local Format = require(packages:WaitForChild("format"))
local TextLabel = require(packages:WaitForChild("textlabel"))

local GuiObject = {}
GuiObject.__index = GuiObject
setmetatable(GuiObject, Isotope)

function GuiObject:Destroy()
	Isotope.Destroy(self)
end

function GuiObject.new(config)
	local self = setmetatable(Isotope.new(config), GuiObject)
	self.Name = Isotope.import(config.Name, script.Name)
	self.ClassName = Fusion.Computed(function() return script.Name end)

	self.Padding = Isotope.import(config.Padding, UDim.new(0, 2))

	self.TextSize = Isotope.import(config.TextSize, 14)
	self.TextColor3 = Isotope.import(config.TextColor3, Color3.new(1,1,1))
	self.Text = Isotope.import(config.Text, false)

	self.Image = Isotope.import(config.Image, "")
	self.ImageRectOffset = Isotope.import(config.ImageRectOffset, Vector2.new(0,0))
	self.ImageRectSize = Isotope.import(config.ImageRectSize, Vector2.new(0,0))

	self.Height = Fusion.Computed(self.Scale, function(scale)
		return math.round(scale * 20)
	end)
	local parameters = {
		Name = self.Name,
		Size = Fusion.Computed(self.Height, function(height)
			return UDim2.new(0,0,0, height * 2)
		end),
		BackgroundTransparency = 1,
		[Fusion.Children] = {

		}
	}
	for k, v in pairs(config) do
		if parameters[k] == nil and self[k] == nil then
			parameters[k] = v
		end
	end
	-- print("Parameters", parameters, self)
	self.Instance = Fusion.new("Frame")(parameters)
	self:Construct()
	return self
end

return GuiObject