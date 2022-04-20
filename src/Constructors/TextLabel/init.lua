--!strict
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = script.Parent

local Fusion = require(packages:WaitForChild("coldfusion"))
local Isotope = require(packages:WaitForChild("isotope"))
local Signal = require(packages:WaitForChild("signal"))
local Format = require(packages:WaitForChild("format"))
local Icon = require(packages:WaitForChild("icon"))

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
	self.TextTransparency = Isotope.import(config.TextTransparency, 0)
	self.TextXAlignment = Isotope.import(config.TextXAlignment, Enum.TextXAlignment.Center)
	self.TextYAlignment = Isotope.import(config.TextYAlignment, Enum.TextYAlignment.Center)
	self.Text = Isotope.import(config.Text, false)
	self.LeftIcon = Isotope.import(config.LeftIcon)
	self.RightIcon = Isotope.import(config.RightIcon)
	self.IconSize = Fusion.Computed(self.TextSize, function(textSize)
		local size = math.round(textSize*1.25)
		return UDim2.fromOffset(size, size)
	end)
	local parameters = {
		Name = self.Name,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromScale(0,0),
		[Fusion.Children] = {
			Fusion.new "UIListLayout" {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Fusion.Computed(self.TextXAlignment, function(xAlign)
					if xAlign == Enum.TextXAlignment.Center then
						return Enum.HorizontalAlignment.Center
					elseif xAlign == Enum.TextXAlignment.Left then
						return Enum.HorizontalAlignment.Left
					elseif xAlign == Enum.TextXAlignment.Right then
						return Enum.HorizontalAlignment.Right
					end
				end),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Fusion.Computed(self.TextYAlignment, function(yAlign)
					if yAlign == Enum.TextYAlignment.Center then
						return Enum.VerticalAlignment.Center
					elseif yAlign == Enum.TextYAlignment.Top then
						return Enum.VerticalAlignment.Top
					elseif yAlign == Enum.TextYAlignment.Bottom then
						return Enum.VerticalAlignment.Bottom
					end
				end),
				Padding = self.Padding,
			},
			Fusion.new "TextLabel" {
				RichText = true,
				TextColor3 = self.TextColor3,
				TextSize = self.TextSize,
				LayoutOrder = 2,
				TextTransparency = self.TextTransparency,
				Text = Fusion.Computed(self.Text, function(txt)
					return Format(txt)
				end),
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
			},
			Icon.new {
				Size = self.IconSize,
				LayoutOrder = 1,
				Visible = Fusion.Computed(self.LeftIcon, function(icon)
					return icon ~= nil
				end),
				Name = "LeftIcon",
				Icon = self.LeftIcon,
				IconColor3 = self.TextColor3,
				IconTransparency = self.TextTransparency,
			},
			Icon.new {
				Size = self.IconSize,
				LayoutOrder = 1,
				Visible = Fusion.Computed(self.LeftIcon, function(icon)
					return icon ~= nil
				end),
				Name = "RightIcon",
				Icon = self.RightIcon,
				IconColor3 = self.TextColor3,
				IconTransparency = self.TextTransparency,
			},
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