
local replicatedStorage = game:GetService("ReplicatedStorage")


local packages = require(replicatedStorage:WaitForChild("Packages"))
local import = packages("import")
local maidConstructor = packages("maid")
local signalConstructor = packages("signal")
local logger = packages("log").new():AtInfo()
local fusion = packages("cold-fusion")

local lighting = game:GetService("Lighting")
local atmosphere = lighting:WaitForChild("Atmosphere")
local clouds = workspace:WaitForChild("Terrain"):WaitForChild("Clouds")
local sky = lighting:WaitForChild("Sky")
local sunRays = lighting:WaitForChild("SunRays")
local bloom = lighting:WaitForChild("Bloom")

local moonTexture = "rbxassetid://6184011467"
local sunTexture = "rbxassetid://6196665106"

local Controller = {}
Controller.__index = Controller

function Controller:Destroy()
	self._maid:Destroy()
	for k, v in pairs(self) do
		self[k] = nil
	end
	setmetatable(self, nil)
end

local default = {
	[0/24] = { --1 Midnight
		CloudFill = 0.5,
		CloudDensity = 0.4,
		Precipitation = 0,
		Fog = 0.6,
		Wind = 0.05,
		Hue = 0.85,
		Brightness = 0.15,
		Contrast = 0.15,
		CelestialAngle = -0.5,
	},
	[3/24] = { --2 Early morning
		CloudFill = 0.5,
		CloudDensity = 0.4,
		Precipitation = 0,
		Fog = 0.6,
		Wind = 0.05,
		Hue = 0.95,
		Brightness = 0.2,
		Contrast = 0.25,
		CelestialAngle = -0.15,
	},
	[5/24] = { --3 Early morning
		CloudFill = 0.5,
		CloudDensity = 0.4,
		Precipitation = 0,
		Fog = 0.6,
		Wind = 0.05,
		Hue = 0.05,
		Brightness = 0.3,
		Contrast = 0.25,
		CelestialAngle = -0,
	},
	[6/24] = { --4 Dawn
		CloudFill = 0.5,
		CloudDensity = 0.4,
		Precipitation = 0,
		Fog = 0.6,
		Wind = 0.05,
		Hue = 0.05,
		Brightness = 0.5,
		Contrast = 0.25,
		CelestialAngle = 0.01,
	},
	[8/24] = { --5 Sunrise
		CloudFill = 0.5,
		CloudDensity = 0.4,
		Precipitation = 0,
		Fog = 0.5,
		Wind = 0.05,
		Hue = 0.1,
		Brightness = 0.7,
		Contrast = 0.25,
		CelestialAngle = 0.07,
	},
	[9/24] = { --6 Morning
		CloudFill = 0.5,
		CloudDensity = 0.4,
		Precipitation = 0,
		Fog = 0.4,
		Wind = 0.05,
		Hue = 0.6,
		Brightness = 0.8,
		Contrast = 0.1,
		CelestialAngle = 0.15,
	},
	[12/24] = { --7 Noon
		CloudFill = 0.6,
		CloudDensity = 0.7,
		Precipitation = 0,
		Fog = 0.4,
		Wind = 0.05,
		Hue = 0.625,
		Brightness = 1,
		Contrast = 0.05,
		CelestialAngle = 0.5,
	},
	[15/24] = { --8 Afternoon
		CloudFill = 0.5,
		CloudDensity = 0.4,
		Precipitation = 0,
		Fog = 0.4,
		Wind = 0.05,
		Hue = 0.6,
		Brightness = 0.7,
		Contrast = 0.1,
		CelestialAngle = 0.85,
	},
	[16/24] = { --9 Sunset
		CloudFill = 0.5,
		CloudDensity = 0.4,
		Precipitation = 0,
		Fog = 0.5,
		Wind = 0.05,
		Hue = 0.1,
		Brightness = 0.7,
		Contrast = 0.25,
		CelestialAngle = 0.93,
	},
	[18/24] = { --10 Dusk
		CloudFill = 0.7,
		CloudDensity = 0.4,
		Precipitation = 0,
		Fog = 0.6,
		Wind = 0.05,
		Hue = 0.05,
		Brightness = 0.3,
		Contrast = 0.3,
		CelestialAngle = 1,
	},
	[19/24] = { --11 Night
		CloudFill = 0.8,
		CloudDensity = 0.4,
		Precipitation = 0,
		Fog = 0.6,
		Wind = 0.05,
		Hue = 0.6,
		Brightness = 0.1,
		Contrast = 0.3,
		CelestialAngle = -0.99,
	},
	[21/24] = { --12 9 PM
		CloudFill = 0.5,
		CloudDensity = 0.4,
		Precipitation = 0,
		Fog = 0.6,
		Wind = 0.05,
		Hue = 0.75,
		Brightness = 0.1,
		Contrast = 0.25,
		CelestialAngle = -0.85,
	},
}
default[1] = default[0]

function Controller:GetInput(elapsedTime)
	local dayDuration = math.floor(self.Duration / self.Days)
	local day = math.floor(elapsedTime/dayDuration)
	-- print("day", day)
	local index = (elapsedTime/dayDuration) - day
	local prevIndex = 0
	local nextIndex = 1
	-- print("Index")
	for kIndex, v in pairs(default) do
		-- print("K", kIndex)
		if kIndex <= index and prevIndex < kIndex and kIndex < 1 then
			-- print("A")
			prevIndex = kIndex
		elseif kIndex >= index and nextIndex > kIndex and prevIndex < nextIndex and kIndex > 0 then
			-- print("B")
			nextIndex = kIndex
		end
	end
	-- print(prevIndex, nextIndex)
	local alpha = (index - prevIndex)/math.clamp((nextIndex - prevIndex),0.001, 1)
	-- print("Alpha", alpha)
	local function lerp(k)
		local a = self[k](default[prevIndex][k], day+index)
		local b = self[k](default[nextIndex][k], day+index)
		if "CelestialAngle" == k then
			-- from 0.99 (a) to -0.99 (b)
			local sep = math.abs(1 - a) + math.abs(-1 - b)
			if sep < math.abs(b - a) then
				local aSep = alpha * sep
				if alpha < 0.5 then
					return a + aSep
				else
					return -1 + (aSep - (1-a))
				end

			else
				return (b-a)*alpha + a
			end
		elseif "Hue" == k then
			local hMin = 0.5
			local hMax = 0.125
			local maxOffset = (1+hMax) - hMin
			local function normalize(v)
				if v > hMin then
					return (v - hMin)/maxOffset
				else
					return (v + 1 - hMin)/maxOffset
				end
			end
			local hA = normalize(a)
			local hB = normalize(b)
			local l = (hB-hA)*alpha + hA
			local lOffset = hMin + maxOffset * l
			if lOffset > 1 then
				-- print("H", lOffset - 1)
				return lOffset - 1
			else
				-- print("H", lOffset)
				return lOffset
			end
		else
			return (b-a)*alpha + a
		end
	end
	local input = {
		CloudFill = lerp("CloudFill"),
		CloudDensity = lerp("CloudDensity"),
		Precipitation = lerp("Precipitation"),
		Wind = lerp("Wind"),
		Fog = lerp("Fog"),
		Hue = lerp("Hue"),
		Brightness = lerp("Brightness"),
		Contrast = lerp("Contrast"),
		CelestialAngle = lerp("CelestialAngle"),
	}
	-- print("Input", input)
	return input
end



function Controller:Index(i, day)
	local keys = {}
	for k, v in pairs(default) do
		table.insert(keys, k)
	end
	table.sort(keys, function(a,b)
		return a < b
	end)
	-- print("Keys", keys)
	local dayLength = self.Duration / self.Days
	self:Step(dayLength * (day-1) + dayLength * keys[i])
end

function Controller:Step(elapsedTime: number)
	local input = self:GetInput(elapsedTime)
	local value = 0.2 + 0.8*input.Brightness
	local color = Color3.fromHSV(input.Hue, input.Contrast, value)
	-- print("Color", color:ToHSV())
	local celestialAlpha = input.CelestialAngle + 1 / 2
	local angle = math.sin(input.CelestialAngle*0.5)

	if math.abs(input.CelestialAngle) < 0.5 then
		angle += math.sign(input.CelestialAngle) * math.rad(90)
	end
	angle /= math.rad(180)

	clouds.Cover = input.CloudFill
	clouds.Density = input.CloudDensity
	clouds.Color = color

	lighting.Brightness = 0.25 + input.Brightness*2
	lighting.Ambient = color
	lighting.ColorShift_Bottom = color
	lighting.ColorShift_Top = color
	lighting.EnvironmentDiffuseScale = 0.065
	lighting.EnvironmentSpecularScale = 1
	lighting.OutdoorAmbient = color
	lighting.ClockTime = 12
	lighting.ExposureCompensation = (0.5-input.Brightness)
	lighting.ClockTime = 12
	if input.CelestialAngle < 0 then
		lighting.GeographicLatitude = 120 + 180 * math.abs(input.CelestialAngle) - 180
	else
		lighting.GeographicLatitude = 120 + -180 * math.abs(input.CelestialAngle)
	end
	
	atmosphere.Density = 0.1 + 0.3*input.Fog
	atmosphere.Offset = 0.5
	-- print("Angle", angle)

	atmosphere.Color = Color3.fromHSV(input.Hue, input.Contrast, value)
	atmosphere.Decay = Color3.fromHSV(input.Hue, 0.2+0.3*input.Contrast, value)
	atmosphere.Glare = input.Brightness
	if input.CelestialAngle > 0 then

		atmosphere.Haze = 2.05 + (1-input.Brightness)*0.45
	else

		atmosphere.Haze = 2.05 + (1-input.Brightness)*2
	end



	if input.CelestialAngle < 0 then
		sky.SunTextureId = moonTexture
	else
		sky.SunTextureId = sunTexture
	end
	sky.MoonTextureId = ""
	if input.CelestialAngle < 0 then
		sky.SunAngularSize = 4 + 3 * math.abs(input.CelestialAngle-0.5) * 3
	else
		sky.SunAngularSize = 8 + 3 * math.abs(input.CelestialAngle-0.5) * 3
	end

	bloom.Intensity = celestialAlpha
	bloom.Size = 15 * celestialAlpha
	bloom.Threshold = celestialAlpha

	if input.CelestialAngle > 0.1 then
		sunRays.Intensity = math.max(input.CelestialAngle, 0)
	else
		sunRays.Intensity = math.max(input.CelestialAngle, 0)
	end

	sunRays.Spread = 1
end

function Controller.new(duration: number, days: number)
	local self = setmetatable({}, Controller)
	self._maid = maidConstructor.new()
	
	self.Duration = duration
	self.Days = days

	self.Hue = function(def, d) return def end
	self.Brightness = function(def, d)	return def end
	self.CelestialAngle = function(def, d) return def end

	self.CloudFill = function(def, d)
		return def + d*(1-def)/self.Days
	end
	self.CloudDensity = function(def, d)
		return def + d*(1-def)/self.Days
	end
	self.Precipitation = function(def, d)
		return def + d*(1-def)/self.Days
	end
	self.Fog = function(def, d)
		return def + d*(1-def)/self.Days
	end
	self.Wind = function(def, d)
		return def + d*(1-def)/self.Days
	end
	self.Contrast = function(def, d)
		-- print("day", d)
		local c = def + 0.5 * d*(1-def)/self.Days
		-- print("C", c)
		return c
	end

	return self
end

return Controller