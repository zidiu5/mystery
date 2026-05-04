-- --- [1. INITIAL SETUP & BEAUTIFIER] ---
local Network = require(game:GetService("ReplicatedStorage"):WaitForChild("Library"):WaitForChild("Client"):WaitForChild("Network"))
local shareddata = getupvalue(getupvalue(getrawmetatable(Network).__index, 1).Invoke, 2)

local function beautify()
    local hashstorage = getupvalue(getupvalue(shareddata, 2), 1)
    local remotestorage = getupvalue(getupvalue(shareddata, 1), 1)
    local nameLookup = {}
    for i = 1, #hashstorage do
        for name, id in next, hashstorage[i] do nameLookup[id] = name end
    end
    for i = 1, #remotestorage do
        for id, remoteObj in next, remotestorage[i] do
            if nameLookup[id] and remoteObj.Name ~= nameLookup[id] then
                remoteObj.Name = nameLookup[id]
            end
        end
    end
end

task.spawn(function()
    while true do
        pcall(beautify)
        task.wait(5)
    end
end)

-- --- [2. SERVICES & VARIABLES] ---
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local ZidiuUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/musicmaker-web/ZidiuUI/refs/heads/main/ZidiuUI.lua"))()

local things = workspace:WaitForChild("__THINGS")
local orbsFolder = things:WaitForChild("Orbs")
local petsWorldFolder = things:WaitForChild("Pets")
local coinsFolder = things:WaitForChild("Coins")
local teleportsFolder = workspace:WaitForChild("__MAP"):WaitForChild("Teleports")

-- Remotes
local joinRemote = ReplicatedStorage:WaitForChild("Join Coin")
local farmRemote = ReplicatedStorage:WaitForChild("Farm Coin")

-- State Variables
local autoFarmActive = false
local farmMode = "Nearest" 
local selectedAreas = {}

-- --- [3. HELPER FUNCTIONS] ---

local function getAllAreas()
    local areas = {}
    for _, part in pairs(teleportsFolder:GetChildren()) do
        if part:IsA("BasePart") then table.insert(areas, part.Name) end
    end
    table.sort(areas)
    return areas
end

local function getMyPetIds()
    local myPetIds = {}
    for _, pet in pairs(petsWorldFolder:GetChildren()) do
        -- Überprüfung auf Owner-Attribute (UserId oder Name)
        local owner = pet:GetAttribute("Owner")
        if tostring(owner) == tostring(localPlayer.UserId) or tostring(owner) == localPlayer.Name then
            table.insert(myPetIds, pet:GetAttribute("ID") or pet.Name)
        end
    end
    -- Falls die Attribute fehlen, nehmen wir alle (Fallout-Sicherung)
    if #myPetIds == 0 then
        for _, pet in pairs(petsWorldFolder:GetChildren()) do
            table.insert(myPetIds, pet:GetAttribute("ID") or pet.Name)
        end
    end
    return myPetIds
end

local function getSortedCoins()
    local coins = {}
    local char = localPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return {} end
    local myPos = char.HumanoidRootPart.Position

    for _, coin in pairs(coinsFolder:GetChildren()) do
        local area = coin:GetAttribute("Area") or ""
        -- Area-Filter
        if #selectedAreas == 0 or table.find(selectedAreas, area) then
            local posPart = coin:FindFirstChild("POS")
            if posPart then
                table.insert(coins, {
                    id = coin:GetAttribute("ID") or coin.Name,
                    hp = coin:GetAttribute("Health") or 0,
                    pos = posPart.Position,
                    dist = (myPos - posPart.Position).Magnitude
                })
            end
        end
    end

    if farmMode == "Nearest" then
        table.sort(coins, function(a, b) return a.dist < b.dist end)
    elseif farmMode == "Lowest Health" then
        table.sort(coins, function(a, b) return a.hp < b.hp end)
    elseif farmMode == "Highest Health" then
        table.sort(coins, function(a, b) return a.hp > b.hp end)
    end
    return coins
end

-- --- [4. GUI SETUP] ---
local Window = ZidiuUI:CreateWindow("Farm Fix 96")
local FarmTab = Window:CreateTab("Farming", "🚜")
local ConfigSec = FarmTab:CreateSection("Batch Engine")

ConfigSec:CreateToggle("Auto Farm (Multi-Target)", false, function(state)
    autoFarmActive = state
end)

ConfigSec:CreateMultiDropdown("Select Areas", getAllAreas(), function(selectedTable)
    selectedAreas = selectedTable
end)

ConfigSec:CreateDropdown("Priority Mode", {"Nearest", "Lowest Health", "Highest Health"}, function(val)
    farmMode = val
end)

-- --- [5. FIXED BATCH FARM LOOP] ---
task.spawn(function()
    while true do
        if autoFarmActive then
            local myPets = getMyPetIds()
            local sortedCoins = getSortedCoins()

            if #myPets > 0 and #sortedCoins > 0 then
                local petsPerCoin = 10 -- Verhindert Spam-Kicks
                local coinIndex = 1
                
                for i = 1, #myPets, petsPerCoin do
                    local group = {}
                    for j = i, math.min(i + petsPerCoin - 1, #myPets) do
                        table.insert(group, myPets[j])
                    end
                    
                    local target = sortedCoins[coinIndex]
                    if target then
                        task.spawn(function()
                            -- Batch Join
                            local s = pcall(function() 
                                joinRemote:InvokeServer(target.id, group) 
                            end)
                            
                            if s then
                                -- Farm-Befehl für die Gruppe
                                for _, pId in ipairs(group) do
                                    farmRemote:FireServer(target.id, pId)
                                end
                            end
                        end)
                        -- Nächsten Coin für die nächste Gruppe wählen
                        coinIndex = (coinIndex % #sortedCoins) + 1
                    end
                end
            end
        end
        task.wait(1.5) -- Stabiler Zyklus gegen "3-Phasen-Kick"
    end
end)

ZidiuUI:Notify("Farm-Logik repariert!", "success", 5)
