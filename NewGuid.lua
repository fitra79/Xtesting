local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
   Name = "Fish It x Cyberfrog",
   LoadingTitle = "Wait a sec..",
   LoadingSubtitle = "by Gev",
   ConfigurationSaving = {
      Enabled = false
   }
})

Rayfield:Notify({
   Title = "Script Loaded!",
   Content = "Welcome to CyberFrog Fish It.",
   Duration = 7,
   Image = 4928339878
})

-- =================================================================
-- Definisi Variabel untuk Semua Remote
-- =================================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetPackage = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

local EquipRodEvent = NetPackage:WaitForChild("RE/EquipToolFromHotbar")
local ChargeRodFunc = NetPackage:WaitForChild("RF/ChargeFishingRod")
local RequestMinigameFunc = NetPackage:WaitForChild("RF/RequestFishingMinigameStarted")
local FishingCompletedEvent = NetPackage:WaitForChild("RE/FishingCompleted")


-- =================================================================
-- Pembuatan Antarmuka (GUI)
-- =================================================================
local MainTab = Window:CreateTab("Main", nil)
MainTab:CreateSection("Auto Farming")

-- Variabel global untuk mengontrol loop
_G.AutoFishing = false

-- PERBAIKAN DI SINI: Toggle dibuat dari 'MainTab', bukan 'FarmingSection'
MainTab:CreateToggle({
   Name = "Auto Fish",
   CurrentValue = false,
   Flag = "AutoFishToggle",
   Callback = function(Value)
        _G.AutoFishing = Value

        local status = Value and "Diaktifkan" or "Dimatikan"
        Rayfield:Notify({Title = "Auto Fish", Content = "Fitur Auto Fish " .. status, Duration = 4})

        if not Value then
            return
        end

        task.spawn(function()
            while _G.AutoFishing do
                pcall(function()
                    
                    EquipRodEvent:FireServer(1)
                    task.wait(0.5)

                    ChargeRodFunc:InvokeServer(tick())
                    task.wait(1.5)

                    RequestMinigameFunc:InvokeServer(6.531571388244629, 0.99)

                    task.wait(2.2)

                    FishingCompletedEvent:FireServer()
                end)                
            end
        end)
   end,
})



