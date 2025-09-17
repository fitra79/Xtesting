-- ===[ CyberFrog Mini UI (LiteField) ]========================================
-- Pastikan kamu sudah punya ModuleScript "LiteField" (dari canvas tadi)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LiteField = loadstring(game:HttpGet("https://raw.githubusercontent.com/fitra79/Xtesting/refs/heads/main/componen.lua"))() -- ganti path jika beda

-- Buat Window utama
local UI = LiteField.CreateWindow({
    Title = "CyberFrog Mini",
    Keybind = Enum.KeyCode.K,     -- tekan K untuk show/hide
    Theme = "Default",            -- "Default" | "Light" | "Ocean" atau custom table
    ConfigName = "cyberfrog_mini" -- opsional, untuk SaveConfig/LoadConfig
})

-- Notifikasi awal
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

-- ===[ Build Tabs & Elements ]===============================================
-- pakai Icon asset Roblox, misalnya UI pack "rbxassetid://3926305904" (ikon menu)
-- kamu bisa ganti dengan id/icon sesuai kebutuhan
local mainTab = UI:AddTab({
    Name = "Fishing",  -- Nama tab
    Icon = "rbxassetid://10804731440"  -- ID ikon gambar
})

mainTab:AddSection("Auto Farming")

_G.CyberFrog_AutoFishing = false

mainTab:AddToggle({
    Name = "Auto Fish",
    Flag = "AutoFishToggle",
    Default = false,
    Callback = function(isOn)
        _G.CyberFrog_AutoFishing = isOn
        UI:Notify({
            Title = "Auto Fish",
            Content = "Fitur Auto Fish " .. (isOn and "Diaktifkan" or "Dimatikan"),
            Duration = 4
        })
        if not isOn then return end
        task.spawn(function()
            while _G.CyberFrog_AutoFishing do
                pcall(function()
                    EquipRodEvent:FireServer(1)
                    task.wait(0.5)
                    ChargeRodFunc:InvokeServer(tick())
                    task.wait(1.5)
                    RequestMinigameFunc:InvokeServer(6.531571388244629, 0.99)
                    task.wait(2.2)
                    FishingCompletedEvent:FireServer()
                end)
                task.wait(0.1)
            end
        end)
    end
})

local delayBetweenCasts = 0.1
mainTab:AddSlider({
    Name = "Delay Antara Cast (detik)",
    Min = 0,
    Max = 2,
    Step = 0.05,
    Default = 0.1,
    Flag = "CastDelay",
    Callback = function(v)
        delayBetweenCasts = v
    end
})

mainTab:AddButton({
    Name = "Test Notify",
    Callback = function()
        UI:Notify({ Title = "CyberFrog", Content = "All systems nominal.", Duration = 3 })
    end
})

mainTab:AddSection("Auto Farming")

_G.CyberFrog_AutoFishing1 = false

mainTab:AddToggle({
    Name = "Auto Fish Test",
    Flag = "AutoFishToggle",
    Default = false,
    Callback = function(isOn)
        _G.CyberFrog_AutoFishing1 = isOn
        UI:Notify({
            Title = "Auto Fish",
            Content = "Fitur Auto Fish " .. (isOn and "Diaktifkan" or "Dimatikan"),
            Duration = 4
        })
        if not isOn then return end
        task.spawn(function()
            while _G.CyberFrog_AutoFishing1 do
                pcall(function()
                    EquipRodEvent:FireServer(1)
                    task.wait(0.5)
                    ChargeRodFunc:InvokeServer(tick())
                    task.wait(1.5)
                    RequestMinigameFunc:InvokeServer(6.531571388244629, 0.99)
                    task.wait(2.2)
                    FishingCompletedEvent:FireServer()
                end)
                task.wait(0.1)
            end
        end)
    end
})

local delayBetweenCasts = 0.1
mainTab:AddSlider({
    Name = "Delay Antara Cast (detik)",
    Min = 0,
    Max = 2,
    Step = 0.05,
    Default = 0.1,
    Flag = "CastDelay",
    Callback = function(v)
        delayBetweenCasts = v
    end
})

mainTab:AddButton({
    Name = "Test Notify",
    Callback = function()
        UI:Notify({ Title = "CyberFrog", Content = "All systems nominal.", Duration = 3 })
    end
})

-- ===[ Build Tabs & Elements ]===============================================
-- pakai Icon asset Roblox, misalnya UI pack "rbxassetid://3926305904" (ikon menu)
-- kamu bisa ganti dengan id/icon sesuai kebutuhan
local TestTab = UI:AddTab({
    Name = "Main", -- kosong biar nggak ada teks
    Icon = "rbxassetid://10804731440"
})

TestTab:AddSection("Auto Farming Test")

_G.CyberFrog_AutoFishing = false

TestTab:AddToggle({
    Name = "Auto Fish",
    Flag = "AutoFishToggle",
    Default = false,
    Callback = function(isOn)
        _G.CyberFrog_AutoFishing = isOn
        UI:Notify({
            Title = "Auto Fish",
            Content = "Fitur Auto Fish " .. (isOn and "Diaktifkan" or "Dimatikan"),
            Duration = 4
        })
        if not isOn then return end
        task.spawn(function()
            while _G.CyberFrog_AutoFishing do
                pcall(function()
                    EquipRodEvent:FireServer(1)
                    task.wait(0.5)
                    ChargeRodFunc:InvokeServer(tick())
                    task.wait(1.5)
                    RequestMinigameFunc:InvokeServer(6.531571388244629, 0.99)
                    task.wait(2.2)
                    FishingCompletedEvent:FireServer()
                end)
                task.wait(0.1)
            end
        end)
    end
})

local delayBetweenCasts = 0.1
TestTab:AddSlider({
    Name = "Delay Antara Cast (detik)",
    Min = 0,
    Max = 2,
    Step = 0.05,
    Default = 0.1,
    Flag = "CastDelay",
    Callback = function(v)
        delayBetweenCasts = v
    end
})

TestTab:AddButton({
    Name = "Test Notify",
    Callback = function()
        UI:Notify({ Title = "CyberFrog", Content = "All systems nominal.", Duration = 3 })
    end
})