local isValueObj = {
    BrickColorValue = true,
    CFrameValue = true,
    ObjectValue = true,
    IntValue = true,
    NumberValue = true,
    Vector3Value = true,
    RayValue = true,
    StringValue = true,
    Color3Value = true,
    BoolValue = true,
}

local Watcher = {}
Watcher.__index = Watcher

function Watcher.new(root)
    local self = setmetatable({}, Watcher)

    self.root = root
    self.changedConns = {}
    self.nameChangedConns = {}
    self.descendantAddedConn = nil
    self.descendantRemovingConn = nil
    self.running = false

    return self
end

function Watcher:Destroy()
    if self.running then
        self:WatcherStop()
    end
end

function Watcher:WatcherStart()
    self.running = true

    local function instanceAdded(instance)
        if isValueObj[instance.ClassName] then
            local oldValue = instance.Value
            self.changedConns[instance] = instance.Changed:Connect(function(newValue)
                self:InstanceChanged(instance, oldValue, newValue)
                oldValue = newValue
            end)
        end
        self.nameChangedConns[instance] = instance:GetPropertyChangedSignal("Name"):Connect(function()
            local descendants = instance:GetDescendants()

            for i = #descendants, 1, -1 do
                self:InstanceRemoving(descendants[i])
            end
            self:InstanceRemoving(instance)

            self:InstanceAdded(instance)
            for i = 1, #descendants do
                self:InstanceAdded(descendants[i])
            end
        end)
        self:InstanceAdded(instance)
    end

    self.descendantAddedConn = self.root.DescendantAdded:Connect(instanceAdded)
    self.descendantRemovingConn = self.root.DescendantRemoving:Connect(function(instance)
        self:InstanceRemoving(instance)
        if self.nameChangedConns[instance] then
            self.nameChangedConns[instance]:Disconnect()
            self.nameChangedConns[instance] = nil
        end
        if self.changedConns[instance] then
            self.changedConns[instance]:Disconnect()
            self.changedConns[instance] = nil
        end
    end)

    for _,instance in pairs(self.root:GetDescendants()) do
        instanceAdded(instance)
    end
end

function Watcher:WatcherStop()
    self.descendantAddedConn:Disconnect()
    self.descendantRemovingConn:Disconnect()

    for _,conn in pairs(self.changedConns) do
        conn:Disconnect()
    end
    for _,conn in pairs(self.nameChangedConns) do
        conn:Disconnect()
    end
    self.running = false
end

function Watcher:InstanceAdded(instance)
end

function Watcher:InstanceRemoving(instance)
end

function Watcher:ValueChanged(instance, oldValue, newValue)
end

return Watcher
