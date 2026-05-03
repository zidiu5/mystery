local library = require(game:GetService("ReplicatedStorage"):WaitForChild("Library"))

-- Konfiguration
local targetIds = {["8000"] = true, ["8001"] = true, ["8002"] = true}
_G.FastHatch = false

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")

ScreenGui.Name = "UltraHatcher_V4"
ScreenGui.Parent = game:GetService("CoreGui")

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 200, 0, 260)
MainFrame.Active = true
MainFrame.Draggable = true 
Instance.new("UICorner", MainFrame)

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "ULTRA HATCHER V4"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local function createBtn(name, pos, text, color, parent)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = parent
    btn.BackgroundColor3 = color
    btn.Position = pos
    btn.Size = UDim2.new(0.8, 0, 0, 35)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    Instance.new("UICorner", btn)
    return btn
end

-- Buttons
local ToggleBtn = createBtn("ToggleBtn", UDim2.new(0.1, 0, 0.2, 0), "SPEED: OFF", Color3.fromRGB(150, 0, 0), MainFrame)
local Buy400Btn = createBtn("Buy400Btn", UDim2.new(0.1, 0, 0.37, 0), "BUY 400 EGGS", Color3.fromRGB(0, 120, 255), MainFrame)
local DeleteBtn = createBtn("DeleteBtn", UDim2.new(0.1, 0, 0.54, 0), "DELETE TARGETS", Color3.fromRGB(60, 60, 60), MainFrame)
local KillAnimBtn = createBtn("KillAnimBtn", UDim2.new(0.1, 0, 0.75, 0), "DESTROY ANIMATION", Color3.fromRGB(180, 50, 50), MainFrame)

--- LOGIK ---

-- Animation zerstören
KillAnimBtn.MouseButton1Click:Connect(function()
    local anim = game:GetService("ReplicatedStorage"):FindFirstChild("Exclusive Eggs: Animation")
    if anim then
        anim:Destroy()
        KillAnimBtn.Text = "ANIMATION DELETED"
        KillAnimBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        KillAnimBtn.AutoButtonColor = false
    else
        KillAnimBtn.Text = "ALREADY GONE"
    end
end)

-- 400 Eggs kaufen (4x den 100er Script ausführen)
Buy400Btn.MouseButton1Click:Connect(function()
    Buy400Btn.Text = "BUYING 400..."
    for i = 1, 4 do
        task.spawn(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Exclusive Shop: F2p Egg"):InvokeServer(100)
        end)
        task.wait(0.1) -- Minimaler Delay für Stabilität
    end
    Buy400Btn.Text = "400 BOUGHT!"
    task.wait(2)
    Buy400Btn.Text = "BUY 400 EGGS"
end)

-- Massen-Löschen (Target IDs)
DeleteBtn.MouseButton1Click:Connect(function()
    local save = library.Save.Get()
    local uids = {}
    if save and save.Pets then
        for _, data in pairs(save.Pets) do
            if type(data) == "table" and targetIds[tostring(data.id)] and not data.l and data.uid then
                table.insert(uids, data.uid)
            end
        end
    end
    if #uids > 0 then
        game:GetService("ReplicatedStorage"):WaitForChild("Delete Several Pets"):InvokeServer(uids)
        DeleteBtn.Text = "DELETED " .. #uids
    else
        DeleteBtn.Text = "NO PETS FOUND"
    end
    task.wait(1.5)
    DeleteBtn.Text = "DELETE TARGETS"
end)

-- Hatching Positionen
local posData = {
    Vector3.new(110.71, 90.89, 220.69), Vector3.new(107.42, 90.89, 231.69),
    Vector3.new(120.81, 90.89, 215.24), Vector3.new(112.87, 90.89, 241.79),
    Vector3.new(131.81, 90.89, 218.52), Vector3.new(123.87, 90.89, 245.08),
    Vector3.new(137.26, 90.89, 228.63), Vector3.new(133.97, 90.89, 239.63)
}

-- Fast Hatch Loop
ToggleBtn.MouseButton1Click:Connect(function()
    _G.FastHatch = not _G.FastHatch
    if _G.FastHatch then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        ToggleBtn.Text = "SPEED: INSANE"
        task.spawn(function()
            while _G.FastHatch do
                local save = library.Save.Get()
                local eggUid = nil
                if save and save.Pets then
                    for _, data in pairs(save.Pets) do
                        if type(data) == "table" and tostring(data.id) == "1063" then
                            eggUid = data.uid
                            break
                        end
                    end
                end

                if eggUid then
                    for i = 1, 3 do
                        task.spawn(function() 
                            game:GetService("ReplicatedStorage"):WaitForChild("Exclusive Eggs: Open"):InvokeServer(eggUid, 8, posData) 
                        end)
                    end
                    task.wait(0.01)
                else 
                    task.wait(0.5) 
                end
            end
        end)
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        ToggleBtn.Text = "SPEED: OFF"
    end
end)
