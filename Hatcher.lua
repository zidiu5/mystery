local library = require(game:GetService("ReplicatedStorage"):WaitForChild("Library"))
local network = library.Network

_G.FastHatch = false

local function getNextEggFromStack()
    local save = library.Save.Get()
    for _, data in pairs(save.Pets) do
        if type(data) == "table" and tostring(data.id) == "1063" then
            return data.uid
        end
    end
    return nil
end

local posData = {
    Vector3.new(110.713066, 90.89, 220.69),
    Vector3.new(107.424179, 90.89, 231.69),
    Vector3.new(120.816352, 90.89, 215.24),
    Vector3.new(112.876289, 90.89, 241.79),
    Vector3.new(131.815673, 90.89, 218.52),
    Vector3.new(123.875617, 90.89, 245.08),
    Vector3.new(137.267791, 90.89, 228.63),
    Vector3.new(133.978912, 90.89, 239.63)
}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Parent = game:GetService("CoreGui")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Active = true
MainFrame.Draggable = true 
Instance.new("UICorner", MainFrame)

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "ULTRA HATCHER 1063"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1

ToggleBtn.Parent = MainFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 40)
ToggleBtn.Text = "SPEED: NORMAL"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", ToggleBtn)

-- Die "Schnelle" Hatch-Funktion
local function fastHatchLoop()
    while _G.FastHatch do
        local uid = getNextEggFromStack()
        if uid then
            -- Wir spawnen mehrere Requests gleichzeitig
            for i = 1, 3 do -- 3 parallele Anfragen pro Durchgang
                task.spawn(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Exclusive Eggs: Open"):InvokeServer(uid, 8, posData)
                end)
            end
            task.wait(0.01) -- Minimale Pause für Stabilität
        else
            task.wait(0.5)
        end
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    _G.FastHatch = not _G.FastHatch
    if _G.FastHatch then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        ToggleBtn.Text = "SPEED: INSANE"
        task.spawn(fastHatchLoop)
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        ToggleBtn.Text = "SPEED: OFF"
    end
end)
