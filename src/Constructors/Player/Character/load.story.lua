
function init(coreGui)
	local RunService = game:GetService("RunService")

	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.Size = UDim2.fromScale(1,1)
	
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewportFrame

	local camera = Instance.new("Camera")
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera

	local rStep = RunService.RenderStepped:Connect(function(deltaTime)
		camera.CFrame = workspace.CurrentCamera.CFrame
	end)

	viewportFrame.Parent = coreGui
	local function cleanUp()
		rStep:Disconnect()
		viewportFrame:Destroy()
		worldModel:Destroy()
		camera:Destroy()
	end
	return worldModel, cleanUp
end

return function (coreGui)
	-- local printLog = Instance.new("Folder", coreGui)
	-- local printIndex = 0
	-- local function printInst(txt)
	-- 	printIndex += 1
	-- 	local inst = Instance.new("Folder", printLog)
	-- 	inst.Name = printIndex.."_"..txt
	-- end
	-- printInst("loading coregui")
	local worldModel, cleanUp = init(coreGui)
	local packages = script.Parent.Parent.Parent
	local Fusion = require(packages:WaitForChild("coldfusion"))
	local Character = require(script.Parent)
	local Player = require(game.ReplicatedStorage.player)
	local playerInst = Player.pseudoInstance(42223924)
	local player = Player.fromInstance(playerInst)
	local humDesc = game.Players:GetHumanoidDescriptionFromUserId(tonumber(playerInst.UserId))
	local charInst = game.StarterPlayer:WaitForChild("StarterCharacter"):Clone()
	charInst.Parent = worldModel
	charInst.Name = playerInst.Name
	local character = Character.fromInstance(charInst, player)
	character:ApplyHumanoidDescription(humDesc)
	character.Instance:Get().Parent = worldModel
	character:Teleport(game.Workspace.CurrentCamera.CFrame * CFrame.new(0,0,-10)*CFrame.Angles(0,math.rad(180),0))
	return function()
		cleanUp()
		character:Destroy()
		charInst:Destroy()
		playerInst:Destroy()
		player:Destroy()
	end
end