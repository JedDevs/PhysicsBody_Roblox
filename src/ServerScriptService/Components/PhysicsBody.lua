local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = require(ReplicatedStorage.Modules.Utilities)
local Knit = require(ReplicatedStorage.Knit)
local Maid = require(Knit.Util.Maid)

local PhysicsBody = {}
PhysicsBody.__index = PhysicsBody

PhysicsBody.Tag = "PhysicsBody"

local AttParameters = {
    ["LimitsEnabled"] = true,
    ["MaxFrictionTorque"] = 0,
    ["Restitution"] = 0,
    ["TwistLimitsEnabled"] = true,
    ["UpperAngle"] = 12.5,
    ["TwistLowerAngle"] = -10,
    ["TwistUpperAngle"] = 10
}

local AttParameters_Spring = {
    ["Damping"] = 20,
    ["FreeLength"] = 2.2,
    ["MaxForce"] = 50000,
    ["Stiffness"] = 250,
}

function PhysicsBody.new(instance)
    
    local self = setmetatable({}, PhysicsBody)
    self._instance = instance
    self._maid = Maid.new()
    self._nodes = {}

    self.CentrePoint = self:CreatePoint(instance)
    self._instance.CanCollide = false
    self._instance.Massless = true

    for _, bone in pairs(instance:GetDescendants()) do
        if not bone:IsA("Bone") then continue end
        self._nodes[bone] = self:CreatePoint(bone)
    end

    return self
end

function PhysicsBody:CreatePoint(point)
    local parent = self._instance:FindFirstChild("Points") or Util.InstanceNew("Folder", self._instance, "Points")
    local position = (point:IsA("Bone") and point.WorldPosition) or (point:IsA("BasePart") and point.Position)
    local len = tostring(Util.dictionaryLen(self._nodes))

    local box = Util.InstanceNew("Part", parent, "node_"..len, position)
    box.Size, box.Transparency = Vector3.new(1,1,1), 1
    local att = Util.InstanceNew("Attachment", box)

    if not self.CentrePoint then
        local weld = Util.InstanceNew("WeldConstraint", box)
        weld.Part0, weld.Part1 = box, self._instance
        box.Name = "CentrePoint"
        return box
    end

    local constraint = Util.InstanceNew("BallSocketConstraint", self.CentrePoint or self._instance)
    constraint.Attachment0, constraint.Attachment1 = att, self.CentrePoint:FindFirstChildOfClass("Attachment")
    att.WorldPosition = self.CentrePoint.Position

    for parameterName, value in pairs(AttParameters) do
        constraint[parameterName] = value
    end
    return box
end

function PhysicsBody:HeartbeatUpdate()
    for bone, node in pairs(self._nodes) do
        bone.WorldPosition = node.Position
    end
end

function PhysicsBody:Init()
end


function PhysicsBody:Deinit()
end


function PhysicsBody:Destroy()
    self._maid:Destroy()
end


return PhysicsBody