--!strict
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = script.Parent

local Fusion = require(packages:WaitForChild("coldfusion"))
local Isotope = require(packages:WaitForChild("isotope"))
local Signal = require(packages:WaitForChild("signal"))

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
	self.Scale = Isotope.import(config.Scale, 1)
	self.TextColor3 = Isotope.import(config.TextColor3, Color3.new(1,1,1))
	self.BackgroundColor3 = Isotope.import(config.BackgroundColor3, Color3.fromHSV(0,0,0.9))
	self.Color3 = Isotope.import(config.Color3, Color3.fromHSV(0.6,1,1))
	self.BubbleColor3 = Isotope.import(config.BubbleColor3, Color3.fromHSV(0,0,0.7))
	self.Value = Isotope.import(config.Value, false)
	self.EnableSound = Isotope.import(config.EnableSound):CleanUp()
	self.DisableSound = Isotope.import(config.DisableSound):CleanUp()
	self.Padding = Fusion.Computed(self.Scale, function(scale)
		return math.round(6 * scale)
	end)
	self.Width = Fusion.Computed(self.Scale, function(scale)
		return math.round(scale * 20)
	end)
	self.Activated = Signal.new()
	self.BubbleEnabled = Fusion.Value(false)
	self._Maid:GiveTask(self.Activated:Connect(function()
		self.Value:Set(not self.Value:Get())
		if self.Value:Get() == true then
			local clickSound = self.EnableSound:Get()
			if clickSound then
				clickSound.Parent = self.Instance
				clickSound:Play()
			end
		else
			local clickSound = self.DisableSound:Get()
			if clickSound then
				clickSound.Parent = self.Instance
				clickSound:Play()
			end
		end
		if self.BubbleEnabled:Get() == false then
			self.BubbleEnabled:Set(true)
			task.wait(0.2)
			self.BubbleEnabled:Set(false)
		end
	end))

	local parameters = {
		Size = Fusion.Computed(self.Width, function(width)
			return UDim2.fromOffset(width * 2, width * 2)
		end),
		BackgroundTransparency = 1,
		[Fusion.Children] = {
			Fusion.new "ImageButton" {
				Name = "Button",
				ZIndex = 3,
				BackgroundTransparency = 1,
				ImageTransparency = 1,
				Position = UDim2.fromScale(0.5,0.5),
				Size = UDim2.fromScale(1,1),
				AnchorPoint = Vector2.new(0.5,0.5),
				[Fusion.Event "Activated"] = function()
					self.Activated:Fire()
				end
			},
			Fusion.new "Frame" {
				Name = "Frame",
				ZIndex = 1,
				Size = Fusion.Computed(self.Width, self.Padding, function(width, padding)
					local w = width - padding*2
					return UDim2.new(0, 2*w, 1, 0)
				end),
				Position = UDim2.fromScale(0.5,0.5),
				AnchorPoint = Vector2.new(0.5,0.5),
				BackgroundTransparency = 1,
				[Fusion.Children] = {
					Fusion.new "Frame" {
						Name = "Track",
						ZIndex = 1,
						BackgroundTransparency = 0.5,
						Position = UDim2.fromScale(0.5,0.5),
						AnchorPoint = Vector2.new(0.5,0.5),
						Size = Fusion.Computed(self.Width, self.Padding, function(width, padding)
							local w = math.round(width - padding*1.75)
							return UDim2.new(1, 0, 0, w)
						end),
						BackgroundColor3 = Fusion.Computed(
							self.Value,
							self.Color3, function(val, col)
							local h,s,v = col:ToHSV()
							if val then
								return Color3.fromHSV(h, 0.5, 1)
							else
								return Color3.fromHSV(h, 0, 1)
							end
						end):Tween(),
						[Fusion.Children] = {
							Fusion.new "UICorner" {
								CornerRadius = UDim.new(0.5,0),
							}
						},
					},
					Fusion.new "Frame" {
						Name = "Knob",
						ZIndex = 2,
						Position = Fusion.Computed(
							self.Value,
							function(val)
								if val then
									return UDim2.fromScale(1,0.5)
								else
									return UDim2.fromScale(0,0.5)
								end
							end
						):Tween(),
						-- Position = UDim2.fromScale(0.5,0.5),
						-- AnchorPoint = Fusion.Computed(
						-- 	self.Value,
						-- 	function(val)
						-- 		if val then
						-- 			return Vector2.new(0,0.5)
						-- 		else
						-- 			return Vector2.new(1,0.5)
						-- 		end
						-- 	end
						-- ):Tween(),
						AnchorPoint = Vector2.new(0.5,0.5),

						Size = UDim2.fromScale(1,1),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						BackgroundTransparency = 1,
						[Fusion.Children] = {
							Fusion.new "Frame" {
								Name = "Frame",
								ZIndex = 2,
								Position = UDim2.fromScale(0.5,0.5),
								AnchorPoint = Vector2.new(0.5,0.5),
								BackgroundColor3 = Fusion.Computed(
									self.Value,
									self.BackgroundColor3,
									self.Color3,
									function(val, back, col)
										if val then
											return col
										else
											return back
										end
									end
								):Tween(),
								Size = Fusion.Computed(self.Width, self.Padding, function(width, padding)
									return UDim2.fromOffset(width-padding, width-padding)
								end),
								BorderSizePixel = 0,
								[Fusion.Children] = {
									Fusion.new "UICorner" {
										CornerRadius = Fusion.Computed(self.Padding, function(padding)
											return UDim.new(1,0)
										end)
									},
									Fusion.new "UIStroke" {
										ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
										Thickness = Fusion.Computed(self.Padding, function(padding)
											return 1--math.round(padding*0.25)
										end),
										Transparency = 0.8,
									}
								}
							},
							Fusion.new "Frame" {
								Name = "Bubble",
								Position = UDim2.fromScale(0.5,0.5),
								AnchorPoint = Vector2.new(0.5,0.5),
								BorderSizePixel = 0,
								ZIndex = 1,
								BackgroundColor3 = self.BubbleColor3,
								Size = Fusion.Computed(self.BubbleEnabled, self.Value, function(bVal, val)
									if val then
										return UDim2.fromScale(1, 1)
									else
										return UDim2.fromScale(0, 0)
									end
								end):Tween(),
								BackgroundTransparency = Fusion.Computed(self.BubbleEnabled, self.Value, function(bVal, val)
									if bVal == false then
										return 1
									else
										return 0
									end
								end):Tween(0.5),
								[Fusion.Children] = {
									Fusion.new "UICorner" {
										CornerRadius = UDim.new(0.5,0),
									},
								}
							},
						},
					}
				}
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