--[[ 
    WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Target koordinat
local targetPosition = Vector3.new(49.88, 9.53, 2807.67)

-- Buat GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.25, 0, 0.12, 0)
frame.Position = UDim2.new(0.37, 0, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 0.5, 0)
label.Position = UDim2.new(0, 0, 0, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(0, 255, 0)
label.TextScaled = true
label.Text = string.format("Teleport ke:\nX: %.2f, Y: %.2f, Z: %.2f", targetPosition.X, targetPosition.Y, targetPosition.Z)
label.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, 0, 0.5, 0)
button.Position = UDim2.new(0, 0, 0.5, 0)
button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Text = "Teleport"
button.Parent = frame

-- Fungsi teleport ke koordinat
local function teleportToPosition(position)
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart", 5)
    if root then
        root.CFrame = CFrame.new(position + Vector3.new(0, 3, 0)) -- offset biar nggak nyangkut
    else
        warn("HumanoidRootPart tidak ditemukan. Gagal teleport.")
    end
end

-- Klik tombol
button.MouseButton1Click:Connect(function()
    teleportToPosition(targetPosition)
    button.Text = "Teleported!"
    task.wait(1)
    button.Text = "Teleport"
end)
