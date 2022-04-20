local RunService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local packages = require(replicatedStorage:WaitForChild("Packages"))
local import = packages("import")
local maidConstructor = packages("maid")
local signalConstructor = packages("signal")
local logger = packages("log").new():AtInfo()

logger:Log("Booting TimeSync")

if RunService:IsClient() then
	-- logger:Log("Booting TimeSync Client")
	local sync = replicatedStorage:WaitForChild("TimeSync")
	local serverOffset
	local lastUpdate = 0
	RunService.RenderStepped:Connect(function(deltaTime)
		-- logger:Log("Step:"..tostring(tick() - lastUpdate))
		if tick() - lastUpdate > 5 then
			-- logger:Log("Updating offset")
			lastUpdate = tick()
			serverOffset = sync:InvokeServer(tick())
		end
	end)
	return function()
		-- logger:Log("Retrieving tick")
		if serverOffset then
			-- logger:Log("Found offset")
			return tick() + serverOffset
		else
			-- logger:Log("Returning nil")
			return nil
		end
	end
else
	-- logger:Log("Booting TimeSync Server")
	local sync = Instance.new("RemoteFunction", replicatedStorage)
	sync.Name = "TimeSync"
	sync.OnServerInvoke = function(player, proposedTick)
		local t = tick()
		--[[
			proposed: 100
			server: 151
			return 151 - travel time - 100
			cli: tick + offset
		]]
		local ping = math.clamp(player:GetNetworkPing(), 0, 1000)
		-- print("Raw ping", player:GetNetworkPing(), "Solved", ping)
		local pDelay = ping/1000
		local offset = t - pDelay - proposedTick
		-- logger:Log("Returning offset: "..tostring(offset))
		return offset
	end
	return function ()
		-- logger:Log("Retrieving tick")
		return tick()
	end
end

