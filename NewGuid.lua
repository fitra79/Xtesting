local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
   Name = "CyberFrog",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "CyberFrog Fish it",
   LoadingSubtitle = "by CyberFrog",
   ShowText = "CyberFrog", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
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
local FishingCompletedEvent = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RE/FishingCompleted")


-- =================================================================
-- Pembuatan Antarmuka (GUI)
-- =================================================================
local MainTab = Window:CreateTab("Main", 4483362458)
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

                    local change = ChargeRodFunc:InvokeServer(tick())
                    print("Hasil RequestMinigameFunc:", change)
                    task.wait(1.5)

                    local minigameResult = RequestMinigameFunc:InvokeServer(6.531571388244629, 0.99)
                    print("Hasil RequestMinigameFunc:", minigameResult)

                    task.wait(2.2)

                    local fish = FishingCompletedEvent:FireServer()
                    print(fish)
                end)                
            end
        end)
   end,
})



