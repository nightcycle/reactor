local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return function (coreGui)
	local module = require(script.Parent)
	local demo = {
		Scale = 2,
		Color3 = Color3.fromHSV(0.75,1,1),
		Position = UDim2.fromScale(0.5,0.5),
		AnchorPoint = Vector2.new(0.5,0.5),
		Parent = coreGui,
		EnableSound = SoundService.All.UI.Button.Confirm["1"]:Clone(),
		DisableSound = SoundService.All.UI.Button.Cancel:Clone(),
	}
	local object = module.new(demo)
	return function()
		object:Destroy()
	end
end