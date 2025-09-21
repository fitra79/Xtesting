-- ===[ CyberFrog Mini UI (LiteField) ]========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LiteField = loadstring(game:HttpGet("https://raw.githubusercontent.com/fitra79/Xtesting/refs/heads/main/componen.lua"))()

local UI = LiteField.CreateWindow({
    Title = "CyberFrog Mini",
    Keybind = Enum.KeyCode.K,
    Theme = "Default",
    ConfigName = "cyberfrog_mini"
})

UI:Notify({
    Title = "Script Loaded!",
    Content = "Welcome to CyberFrog Mini Hub.",
    Duration = 6
})

-- ===[ Remote References ]====================================================
local NetPackage = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local EquipRodEvent         = NetPackage:WaitForChild("RE/EquipToolFromHotbar")
local ChargeRodFunc         = NetPackage:WaitForChild("RF/ChargeFishingRod")
local RequestMinigameFunc   = NetPackage:WaitForChild("RF/RequestFishingMinigameStarted")
local FishingCompletedEvent = NetPackage:WaitForChild("RE/FishingCompleted")
local SellItemFunc          = NetPackage:WaitForChild("RF/SellAllItems")

-- ===[ Build Tabs & Elements ]===============================================
local mainTab = UI:AddTab({
    Name = "Fishing",
    Icon = "rbxassetid://10804731440"
})

local teleportTab = UI:AddTab({
    Name = "Teleport",
    Icon = "rbxassetid://10804731440"
})

local mountTab = UI:AddTab({
    Name = "Mount",
    Icon = "rbxassetid://10804731440"
})

-- Tambah layout di mainTab
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = mainTab.SectionFrame

-- === Fishing Section ===
mainTab:AddSection("Auto Farming")

_G.CyberFrog_AutoFishing = false
_G.CyberFrog_AutoSell = false

mainTab:AddToggle({
    Name = "Auto Fish",
    Flag = "AutoFishToggle",
    Default = false,
    Callback = function(isOn)
        _G.CyberFrog_AutoFishing = isOn
        if not isOn then return end
        task.spawn(function()
            while _G.CyberFrog_AutoFishing do
                pcall(function()
                    EquipRodEvent:FireServer(1)
                    task.wait(0.5)
                    ChargeRodFunc:InvokeServer(tick())
                    task.wait(1.5)
                    RequestMinigameFunc:InvokeServer(6.531571388244629, 0.99)
                    task.wait(2.1)
                    FishingCompletedEvent:FireServer()
                end)
                task.wait(0.5)
            end
        end)
    end
})

mainTab:AddToggle({
    Name = "Auto Sell",
    Flag = "AutoSellToggle",
    Default = false,
    Callback = function(isOn)
        _G.CyberFrog_AutoSell = isOn
        if not isOn then return end
        task.spawn(function()
            while _G.CyberFrog_AutoSell do
                pcall(function()
                    SellItemFunc:InvokeServer()
                end)
                task.wait(3)
            end
        end)
    end
})

-- === Teleport Section ===
teleportTab:AddSection("Teleport")

local player = Players.LocalPlayer
local locations = {
    Shop        = Vector3.new(42.11, 17.28, 2865.98),
    Konoha      = Vector3.new(-600.73, 17.25, 512.04),
    Lava        = Vector3.new(-616.90, 48.35, 186.99),
    PulauHilang = Vector3.new(-3672.32, -135.07, -993.56)
}

for name, pos in pairs(locations) do
    teleportTab:AddButton({
        Name = name,
        Callback = function()
            local character = player.Character or player.CharacterAdded:Wait()
            local root = character:WaitForChild("HumanoidRootPart", 5)
            if root then
                root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            else
                warn("HumanoidRootPart tidak ditemukan. Gagal teleport.")
            end
        end
    })
end

-- === Mount Section ===
mountTab:AddSection("Mount")

local function runLoader(urls)
    for _, link in ipairs(urls) do
        loadstring(game:HttpGet(link))()
    end
end

mountTab:AddButton({
    Name = "Mount Atin",
    Callback = function()
        runLoader({
            "https://raw.githubusercontent.com/fitra79/RbScript/refs/heads/main/maps/atin.lua"
        })
    end
})
