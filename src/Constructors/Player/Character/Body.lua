--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local packages = script.Parent.Parent.Parent

local Fusion = require(packages:WaitForChild("coldfusion"))
local Isotope = require(packages:WaitForChild("isotope"))
local Signal = require(packages:WaitForChild("signal"))
local Texture = require(packages:WaitForChild("texture"))

local Accessory = require(script.Parent:WaitForChild("Accessory"))

local Body = {}
Body.__index = Body
setmetatable(Body, Isotope)

local bodyFolder = ReplicatedStorage:WaitForChild("Library"):WaitForChild("Customization"):WaitForChild("Body")
local Templates = {}

for i, body in ipairs(bodyFolder:GetChildren()) do
	Templates[body.Name] = {}
	for j, part in ipairs(body:GetChildren()) do
		Templates[body.Name][part.Name] = part
	end
end

function Body:AddHair(config)

	local accessory = Accessory.new(config)
	if self.Hair[accessory.Id:Get()] then
		self.Hair[accessory.Id:Get()]:Destroy()
	end
	self.Hair[accessory.Id:Get()] = accessory
end

function Body:Destroy()
	for k, state in pairs(self.Template) do
		state:Destroy()
		self.Template[k] = nil
	end
	for k, state in pairs(self.Size) do
		state:Destroy()
		self.Size[k] = nil
	end
	Isotope.Destroy(self)
end

function Body.new(config)
	local self = setmetatable(Isotope.new(config), Body)

	--Configuration
	self.Character = config.Character

	self.Hair = {}

	self.Scale = {
		Height = config.HeightScale or Fusion.Value(1),
		Weight = config.WeightScale or Fusion.Value(1),
		Base = config.BaseScale or Fusion.Value(1),
		Head = config.HeadScale or Fusion.Value(1),
	}

	self.Skin = config.SkinTexture or Texture.new {
		Color = config.EyeColor or Fusion.Value(Color3.fromHSV(0.075,0.2,0.9)),
		Material = config.Material or Fusion.Value(Enum.Material.SmoothPlastic),
		Reflectance = config.Reflectance or Fusion.Value(0),
		Transparency = config.Transparency or Fusion.Value(0),
	}

	self.Style = {
		Head = config.HeadStyle or Fusion.Value("Boy"),
		Torso = config.TorsoStyle or Fusion.Value("Boy"),
		LeftArm = config.LeftArmStyle or Fusion.Value("Boy"),
		RightArm = config.RightArmStyle or Fusion.Value("Boy"),
		LeftLeg = config.LeftLegStyle or Fusion.Value("Boy"),
		RightLeg = config.RightLegStyle or Fusion.Value("Boy"),
	}

	self.Transform = {
		Neck = config.NeckTransform or Fusion.Value(CFrame.Angles(0,0,0)),
		Waist = config.WaistTransform or Fusion.Value(CFrame.Angles(0,0,0)),
		Root = config.RootTransform or Fusion.Value(CFrame.Angles(0,0,0)),
		LeftHip = config.LeftHipTransform or Fusion.Value(CFrame.Angles(0,0,0)),
		LeftKnee = config.LeftKneeTransform or Fusion.Value(CFrame.Angles(0,0,0)),
		LeftAnkle = config.LeftAnkleTransform or Fusion.Value(CFrame.Angles(0,0,0)),
		RightHip = config.RightHipTransform or Fusion.Value(CFrame.Angles(0,0,0)),
		RightKnee = config.RightKneeTransform or Fusion.Value(CFrame.Angles(0,0,0)),
		RightAnkle = config.RightAnkleTransform or Fusion.Value(CFrame.Angles(0,0,0)),
		LeftShoulder = config.LeftShoulderTransform or Fusion.Value(CFrame.Angles(0,0,0)),
		LeftElbow = config.LeftElbowTransform or Fusion.Value(CFrame.Angles(0,0,0)),
		LeftWrist = config.LeftWristTransform or Fusion.Value(CFrame.Angles(0,0,0)),
		RightShoulder = config.RightShoulderTransform or Fusion.Value(CFrame.Angles(0,0,0)),
		RightElbow = config.RightElbowTransform or Fusion.Value(CFrame.Angles(0,0,0)),
		RightWrist = config.RightWristTransform or Fusion.Value(CFrame.Angles(0,0,0)),
	}

	self.Template = {
		Head = Fusion.Computed(self.Style.Head,function(style) return Templates[style].Head end),
		UpperTorso = Fusion.Computed(self.Style.Torso, function(style) return Templates[style].UpperTorso end),
		LowerTorso = Fusion.Computed(self.Style.Torso, function(style) return Templates[style].LowerTorso end),
		HumanoidRootPart = Fusion.Computed(self.Style.Torso, function(style) return Templates[style].HumanoidRootPart end),
		LeftUpperArm = Fusion.Computed(self.Style.LeftArm, function(style) return Templates[style].LeftUpperArm end),
		LeftLowerArm = Fusion.Computed(self.Style.LeftArm, function(style) return Templates[style].LeftLowerArm end),
		LeftHand = Fusion.Computed(self.Style.LeftArm, function(style) return Templates[style].LeftHand end),
		RightUpperArm = Fusion.Computed(self.Style.RightArm, function(style) return Templates[style].RightUpperArm end),
		RightLowerArm = Fusion.Computed(self.Style.RightArm, function(style) return Templates[style].RightLowerArm end),
		RightHand = Fusion.Computed(self.Style.RightArm, function(style) return Templates[style].RightHand end),
		LeftUpperLeg = Fusion.Computed(self.Style.LeftLeg, function(style) return Templates[style].LeftUpperLeg end),
		LeftLowerLeg = Fusion.Computed(self.Style.LeftLeg, function(style) return Templates[style].LeftLowerLeg end),
		LeftFoot = Fusion.Computed(self.Style.LeftLeg, function(style) return Templates[style].LeftFoot end),
		RightUpperLeg = Fusion.Computed(self.Style.RightLeg, function(style) return Templates[style].RightUpperLeg end),
		RightLowerLeg = Fusion.Computed(self.Style.RightLeg, function(style) return Templates[style].RightLowerLeg end),
		RightFoot = Fusion.Computed(self.Style.RightLeg, function(style) return Templates[style].RightFoot end),
	}

	local function getSize(temp, base, y, xz)
		if not temp then return Vector3.new(1,1,1) end
		return temp.Size * base * Vector3.new(xz,y,xz)
	end

	self.Size = {
		HumanoidRootPart = Fusion.Computed(self.Character.HumanoidRootPart, function(hrp)
			if hrp then
				return hrp.Size
			else
				return Vector3.new(1,1,1)
			end
		end),
		Head = Fusion.Computed(self.Template.Head, self.Scale.Base, self.Scale.Head, self.Scale.Head, getSize),
		UpperTorso = Fusion.Computed(self.Template.UpperTorso, self.Scale.Base, self.Scale.Height, self.Scale.Weight, getSize),
		LowerTorso = Fusion.Computed(self.Template.LowerTorso, self.Scale.Base, self.Scale.Height, self.Scale.Weight, getSize),
		LeftUpperArm = Fusion.Computed(self.Template.LeftUpperArm, self.Scale.Base, self.Scale.Height, self.Scale.Weight, getSize),
		LeftLowerArm = Fusion.Computed(self.Template.LeftLowerArm, self.Scale.Base, self.Scale.Height, self.Scale.Weight, getSize),
		LeftHand = Fusion.Computed(self.Template.LeftHand, self.Scale.Base, self.Scale.Height, self.Scale.Weight, getSize),
		RightUpperArm = Fusion.Computed(self.Template.RightUpperArm, self.Scale.Base, self.Scale.Height, self.Scale.Weight, getSize),
		RightLowerArm = Fusion.Computed(self.Template.RightLowerArm, self.Scale.Base, self.Scale.Height, self.Scale.Weight, getSize),
		RightHand = Fusion.Computed(self.Template.RightHand, self.Scale.Base, self.Scale.Height, self.Scale.Weight, getSize),
		LeftUpperLeg = Fusion.Computed(self.Template.LeftUpperLeg, self.Scale.Base, self.Scale.Height, self.Scale.Weight, getSize),
		LeftLowerLeg = Fusion.Computed(self.Template.LeftLowerLeg, self.Scale.Base, self.Scale.Height, self.Scale.Weight, getSize),
		LeftFoot = Fusion.Computed(self.Template.LeftFoot, self.Scale.Base, self.Scale.Height, self.Scale.Weight, getSize),
		RightUpperLeg = Fusion.Computed(self.Template.RightUpperLeg, self.Scale.Base, self.Scale.Height, self.Scale.Weight, getSize),
		RightLowerLeg = Fusion.Computed(self.Template.RightLowerLeg, self.Scale.Base, self.Scale.Height, self.Scale.Weight, getSize),
		RightFoot = Fusion.Computed(self.Template.RightFoot, self.Scale.Base, self.Scale.Height, self.Scale.Weight, getSize),
	}

	self._Maid:GiveTask(self.Character.Humanoid:Connect(function(hum)
		Fusion.mount(hum){
			HipHeight = Fusion.Computed(self.Scale.Base, self.Scale.Height, function(base, height)
				return 2 * base * height
			end)
		}
	end))

	local function getPart(char, temp, size, maid)
		local inst = temp:Clone()
		inst.Size = size
		inst.Parent = char
		maid:GiveTask(inst)
		return inst
	end

	self.Part = {
		Head = Fusion.Computed(self.Character.Instance, self.Template.Head, self.Size.Head, getPart),
		UpperTorso = Fusion.Computed(self.Character.Instance, self.Template.UpperTorso, self.Size.UpperTorso, getPart),
		LowerTorso = Fusion.Computed(self.Character.Instance, self.Template.LowerTorso, self.Size.LowerTorso, getPart),
		LeftUpperArm = Fusion.Computed(self.Character.Instance, self.Template.LeftUpperArm, self.Size.LeftUpperArm, getPart),
		LeftLowerArm = Fusion.Computed(self.Character.Instance, self.Template.LeftLowerArm, self.Size.LeftLowerArm, getPart),
		LeftHand = Fusion.Computed(self.Character.Instance, self.Template.LeftHand, self.Size.LeftHand, getPart),
		RightUpperArm = Fusion.Computed(self.Character.Instance, self.Template.RightUpperArm, self.Size.RightUpperArm, getPart),
		RightLowerArm = Fusion.Computed(self.Character.Instance, self.Template.RightLowerArm, self.Size.RightLowerArm, getPart),
		RightHand = Fusion.Computed(self.Character.Instance, self.Template.RightHand, self.Size.RightHand, getPart),
		LeftUpperLeg = Fusion.Computed(self.Character.Instance, self.Template.LeftUpperLeg, self.Size.LeftUpperLeg, getPart),
		LeftLowerLeg = Fusion.Computed(self.Character.Instance, self.Template.LeftLowerLeg, self.Size.LeftLowerLeg, getPart),
		LeftFoot = Fusion.Computed(self.Character.Instance, self.Template.LeftFoot, self.Size.LeftFoot, getPart),
		RightUpperLeg = Fusion.Computed(self.Character.Instance, self.Template.RightUpperLeg, self.Size.RightUpperLeg, getPart),
		RightLowerLeg = Fusion.Computed(self.Character.Instance, self.Template.RightLowerLeg, self.Size.RightLowerLeg, getPart),
		RightFoot = Fusion.Computed(self.Character.Instance, self.Template.RightFoot, self.Size.RightFoot, getPart),
		HumanoidRootPart = self.Character.HumanoidRootPart,
	}

	self.Face = Fusion.Computed(self.Part.Head, function(head)
		if not head then return end
		return head:FindFirstChildOfClass("FaceControls")
	end)

	local function constructJoint(JointName, Part0, Part1)
		JointName = Fusion.Value(JointName)
		return Fusion.Computed(
			JointName,
			Part0,
			Part1,
			function(jointName, part0, part1, maid)
				if not part0 or not part1 then return end
				-- print("\nMaking joint", jointName)
				local function getCF(template, size, transform)
					local attachment = template:FindFirstChild(jointName.."RigAttachment")
					local unitOffset = attachment.Position / template.Size
					-- print("CF", jointName, part0, part1, template, size, transform)
					return CFrame.fromMatrix(
						unitOffset * size,
						Vector3.new(1,0,0),
						Vector3.new(0,1,0),
						Vector3.new(0,0,1)
					) * transform
				end

				local joint = Fusion.new "Motor6D" {
					Name = jointName,
					Part0 = part0,
					Part1 = part1,
					Parent = part1,
					C0 = Fusion.Computed(
						self.Template[part0.Name],
						self.Size[part0.Name],
						self.Transform[jointName],
						getCF
					),
					C1 = Fusion.Computed(
						self.Template[part1.Name],
						self.Size[part1.Name],
						self.Transform[jointName],
						getCF
					),
				}
				maid:GiveTask(joint)
				return joint
			end
		)
	end

	for bodyPartName, State in pairs(self.Part) do
		if bodyPartName ~= "HumanoidRootPart" then
			self._Maid:GiveTask(Fusion.Computed(State, function(newBodyPart)
				self.Skin:Apply(newBodyPart)
			end))
		end
	end

	self.Joints = {
		Neck = constructJoint("Neck", self.Part.UpperTorso, self.Part.Head),
		Waist = constructJoint("Waist", self.Part.LowerTorso, self.Part.UpperTorso),
		Root = constructJoint("Root", self.Character.HumanoidRootPart, self.Part.LowerTorso),
		LeftHip = constructJoint("LeftHip", self.Part.LowerTorso,self.Part.LeftUpperLeg),
		LeftKnee = constructJoint("LeftKnee", self.Part.LeftUpperLeg, self.Part.LeftLowerLeg),
		LeftAnkle = constructJoint("LeftAnkle", self.Part.LeftLowerLeg, self.Part.LeftFoot),
		RightHip = constructJoint("RightHip",self.Part.LowerTorso,self.Part.RightUpperLeg),
		RightKnee = constructJoint("RightKnee", self.Part.RightUpperLeg, self.Part.RightLowerLeg),
		RightAnkle = constructJoint("RightAnkle", self.Part.RightLowerLeg, self.Part.RightFoot),
		LeftShoulder = constructJoint("LeftShoulder",self.Part.UpperTorso, self.Part.LeftUpperArm),
		LeftElbow = constructJoint("LeftElbow", self.Part.LeftUpperArm, self.Part.LeftLowerArm),
		LeftWrist = constructJoint("LeftWrist", self.Part.LeftLowerArm, self.Part.LeftHand),
		RightShoulder = constructJoint("RightShoulder",self.Part.UpperTorso,self.Part.RightUpperArm),
		RightElbow = constructJoint("RightElbow", self.Part.RightUpperArm, self.Part.RightLowerArm),
		RightWrist = constructJoint("RightWrist", self.Part.RightLowerArm, self.Part.RightHand),
	}

	return self
end

return Body