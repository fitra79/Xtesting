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
local SellFishFunc = NetPackage:WaitForChild("RF/SellFish")

local layout = Instance.new("UIListLayout", mainTab)
layout.Padding = UDim.new(0, 10)  -- Menambahkan jarak 10px antar elemen
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- ===[ Build Tabs & Elements ]===============================================
-- pakai Icon asset Roblox, misalnya UI pack "rbxassetid://3926305904" (ikon menu)
-- kamu bisa ganti dengan id/icon sesuai kebutuhan
local mainTab = UI:AddTab({
    Name = "Fishing",  -- Nama tab
    Icon = "rbxassetid://10804731440"  -- ID ikon gambar
})

local teloportTab = UI:AddTab({
    Name = "Teleport",  -- Nama tab
    Icon = "rbxassetid://10804731440"  -- ID ikon gambar
})



mainTab:AddSection("Auto Farming")

_G.CyberFrog_AutoFishing = false
_G.CyberFrog_AutoSell = false

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
                    task.wait(2.1)
                    FishingCompletedEvent:FireServer()
                end)
            end
        end)
    end
})

mainTab:AddToggle({
    Name = "Auto Sell Fish",
    Flag = "AutoSellToggle",
    Default = false,
    Callback = function(state)
        _G.CyberFrog_AutoSell = state
        UI:Notify({
            Title = "Auto Sell",
            Content = "Fitur Auto Sell " .. (state and "Diaktifkan" or "Dimatikan"),
            Duration = 4
        })

        if not state then return end
        task.spawn(function()
            while _G.CyberFrog_AutoSell do
                pcall(function()
                    -- panggil remote jual ikan
                    SellFishFunc:InvokeServer("All") -- kadang pakai argumen "All" atau daftar ikan
                end)
                task.wait(5) -- setiap 5 detik auto sell
            end
        end)
    end
})

mainTab:AddInput({
    Name = "Delay Antara Cast (detik)",
    Placeholder = "Masukkan waktu delay",
    Default = tostring(delayBetweenCasts),
    Callback = function(inputText)
        local inputValue = tonumber(inputText)
        if inputValue then
            delayBetweenCasts = inputValue
            print("Delay updated to: " .. delayBetweenCasts)
        else
            print("Invalid input. Please enter a valid number.")
        end
    end
})

---- Teloport ----
teloportTab:AddSection("Teleport")

local player = Players.LocalPlayer

-- Target koordinat Shop
local shop = Vector3.new(42.11, 17.28, 2865.98)
local konoha = Vector3.new(-600.73, 17.25, 512.04)
local lava = Vector3.new(-616.90, 48.35, 186.99)
local pulauHilang = Vector3.new(-3672.32, -135.07, -993.56)


teloportTab:AddButton({
    Name = "Shop",
    Callback = function()
        UI:Notify({
            Title = "Teleport Shop",
            Content = "Fitur Teleport Shop Auto",
            Duration = 4
        })
        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart", 5)
        if root then
            root.CFrame = CFrame.new(shop + Vector3.new(0, 3, 0))
        else
            warn("HumanoidRootPart tidak ditemukan. Gagal teleport.")
        end
    end
})

teloportTab:AddButton({
    Name = "Konoha",
    Callback = function()
        UI:Notify({
            Title = "Teleport Konoha",
            Content = "Fitur Teleport Konoha Auto",
            Duration = 4
        })
        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart", 5)
        if root then
            root.CFrame = CFrame.new(konoha + Vector3.new(0, 3, 0))
        else
            warn("HumanoidRootPart tidak ditemukan. Gagal teleport.")
        end
    end
})

teloportTab:AddButton({
    Name = "Lava",
    Callback = function()
        UI:Notify({
            Title = "Teleport lava",
            Content = "Fitur Teleport Lava Auto",
            Duration = 4
        })
        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart", 5)
        if root then
            root.CFrame = CFrame.new(lava + Vector3.new(0, 3, 0))
        else
            warn("HumanoidRootPart tidak ditemukan. Gagal teleport.")
        end
    end
})

teloportTab:AddButton({
    Name = "Pulau Hilang",
    Callback = function()
        UI:Notify({
            Title = "Teleport Pulau Hilang",
            Content = "Fitur Teleport Pulau Hilang Auto",
            Duration = 4
        })
        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart", 5)
        if root then
            root.CFrame = CFrame.new(pulauHilang + Vector3.new(0, 3, 0))
        else
            warn("HumanoidRootPart tidak ditemukan. Gagal teleport.")
        end
    end
})