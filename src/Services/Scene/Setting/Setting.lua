local Controller = require(script.Parent:WaitForChild("Atmosphere"))

return function ()
	local duration = 1200*3
	local days = 4
	local controller = Controller.new(duration, days)
	local s, m = pcall(function()
		-- for i=1, duration do
		-- 	task.wait()
		-- 	controller:Step(i)
		-- end
		controller:Index(5, 1)
	end)
	if m then warn(m) end
	return function ()
		controller:Destroy()
	end
end