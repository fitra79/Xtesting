--[[ 
    WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Buat GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoordinatesGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.25, 0, 0.15, 0)
frame.Position = UDim2.new(0.37, 0, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 0.6, 0)
label.Position = UDim2.new(0, 0, 0, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(0, 255, 0)
label.TextScaled = true
label.Text = "Loading..."
label.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, 0, 0.4, 0)
button.Position = UDim2.new(0, 0, 0.6, 0)
button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Text = "Copy Coordinates"
button.Parent = frame

-- Update koordinat
local coords = ""
local function updateCoordinates()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    RunService.RenderStepped:Connect(function()
        local position = humanoidRootPart.Position
        coords = string.format("X: %.2f, Y: %.2f, Z: %.2f", position.X, position.Y, position.Z)
        label.Text = coords
    end)
end

-- Copy ke clipboard
button.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(coords)
        button.Text = "Copied!"
        task.wait(1)
        button.Text = "Copy Coordinates"
    else
        button.Text = "Clipboard Not Supported"
        task.wait(1.5)
        button.Text = "Copy Coordinates"
    end
end)

-- Jalankan
updateCoordinates()
