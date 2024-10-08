-- MM2 - X Hub
-- Updated ESP, Movement, Utility Features with "Kill All" and Coin/Beachball Farming

local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

--// Services,UI \\--
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

local Window = Library:CreateWindow({
    Title = 'MM2 - X Hub',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.1
})

local Tabs = {
    ESP = Window:AddTab('ESP'),
    Movement = Window:AddTab('Teleport'),
    Utility = Window:AddTab('Utility'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local ESPEnabled = {
    Murderer = false,
    Sheriff = false,
    DroppedGun = false,
}

--// Variables,Functions \\--

local FarmCoinsEnabled = false
local farmCooldown = 0.1 -- Default cooldown for farm
local loopMovementAttributes = false
local killAllEnabled = false

local function notify(msg)
    StarterGui:SetCore("SendNotification", { Title = "MM2 - X Hub", Text = msg, Duration = 5 })
end

-- Function to create a highlight for an object or player
local function addHighlight(part, color, text)
    if not part then return end

    -- Create a highlight for the part or player's character
    local highlight = Instance.new("Highlight", part)
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    if part:IsA("Model") and part:FindFirstChild("Head") then
        -- Create a Billboard GUI to show text above their head (if it's a player)
        local billboard = Instance.new("BillboardGui", part)
        billboard.Adornee = part.Head
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true

        local textLabel = Instance.new("TextLabel", billboard)
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = text
        textLabel.TextColor3 = color
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.SourceSansBold
    end
end

-- Function to remove ESP
local function removeESP(part)
    if part then
        for _, obj in pairs(part:GetChildren()) do
            if obj:IsA("Highlight") or obj:IsA("BillboardGui") then
                obj:Destroy()
            end
        end
    end
end

-- ESP Functions
local function checkForMurderer()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Backpack:FindFirstChild("Knife") then
            removeESP(player.Character)
            addHighlight(player.Character, Color3.new(1, 0, 0), "Murderer - " .. player.Name)
        end
    end
end

local function checkForSheriff()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Backpack:FindFirstChild("Gun") then
            removeESP(player.Character)
            addHighlight(player.Character, Color3.new(0, 0, 1), "Sheriff - " .. player.Name)
        end
    end
end

local function checkForDroppedGun()
    local gunDrop = Workspace:FindFirstChild("Normal") and Workspace.Normal:FindFirstChild("GunDrop")
    if gunDrop then
        removeESP(gunDrop)
        addHighlight(gunDrop, Color3.new(0, 1, 0), "Dropped Gun")
    end
end

-- Groupbox for Murderer ESP
local MurdererESPGroup = Tabs.ESP:AddLeftGroupbox('Murderer ESP')

-- Murderer ESP Toggle
MurdererESPGroup:AddToggle('MurdererESP', {
    Text = 'ESP Murderer',
    Default = false,
    Tooltip = 'Shows the murderer with red highlight and label.',
    Callback = function(Value)
        ESPEnabled.Murderer = Value
        if not Value then
            -- Disable Murderer ESP
            for _, player in pairs(Players:GetPlayers()) do
                removeESP(player.Character)
            end
        end
    end
})

-- Groupbox for Sheriff ESP
local SheriffESPGroup = Tabs.ESP:AddLeftGroupbox('Sheriff ESP')

-- Sheriff ESP Toggle
SheriffESPGroup:AddToggle('SheriffESP', {
    Text = 'ESP Sheriff',
    Default = false,
    Tooltip = 'Shows the sheriff with blue highlight and label.',
    Callback = function(Value)
        ESPEnabled.Sheriff = Value
        if not Value then
            -- Disable Sheriff ESP
            for _, player in pairs(Players:GetPlayers()) do
                removeESP(player.Character)
            end
        end
    end
})

-- Groupbox for Dropped Gun ESP
local DroppedGunESPGroup = Tabs.ESP:AddRightGroupbox('Dropped Gun ESP')

-- Dropped Gun ESP Toggle
DroppedGunESPGroup:AddToggle('DroppedGunESP', {
    Text = 'ESP Dropped Gun',
    Default = false,
    Tooltip = 'Shows the dropped gun with green highlight and label.',
    Callback = function(Value)
        ESPEnabled.DroppedGun = Value
        if not Value then
            -- Disable Dropped Gun ESP
            local gunDrop = Workspace:FindFirstChild("Normal") and Workspace.Normal:FindFirstChild("GunDrop")
            removeESP(gunDrop)
        end
    end
})

-- Update ESP in each RenderStep
RunService.RenderStepped:Connect(function()
    if ESPEnabled.Murderer then
        checkForMurderer()
    end
    if ESPEnabled.Sheriff then
        checkForSheriff()
    end
    if ESPEnabled.DroppedGun then
        checkForDroppedGun()
    end
end)

-- Groupbox for Movement Features
local MovementGroup = Tabs.Movement:AddLeftGroupbox('Movement Features')

-- Walkspeed Slider
local Walkspeed = MovementGroup:AddSlider('WalkspeedSlider', {
    Text = 'Walkspeed',
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        Humanoid.WalkSpeed = Value
        notify("Walkspeed set to: " .. Value)
    end
})

-- Jump Power Slider
local JumpPower = MovementGroup:AddSlider('JumpPowerSlider', {
    Text = 'Jump Power',
    Default = 50,
    Min = 50,
    Max = 890,
    Rounding = 0,
    Callback = function(Value)
        Humanoid.JumpPower = Value
        notify("Jump Power set to: " .. Value)
    end
})

-- Gravity Changer
MovementGroup:AddInput('GravityInput', {
    Default = tostring(Workspace.Gravity),
    Numeric = true,
    Text = 'Change Gravity',
    Tooltip = 'Change the gravity of the game.',
    Placeholder = 'Enter new gravity',
    Callback = function(Value)
        Workspace.Gravity = tonumber(Value)
        notify("Gravity set to: " .. Value)
    end
})

-- Toggle to continuously loop Walkspeed and JumpPower settings
MovementGroup:AddToggle('LoopAttributes', {
    Text = 'Loop Walkspeed/JumpPower',
    Default = false,
    Tooltip = 'Ensures Walkspeed and JumpPower settings persist in case the game resets them.',
    Callback = function(Value)
        loopMovementAttributes = Value
    end
})

-- Loop to reset Walkspeed and JumpPower values if they are changed
RunService.RenderStepped:Connect(function()
    if loopMovementAttributes then
        Humanoid.WalkSpeed = Walkspeed.Value
        Humanoid.JumpPower = JumpPower.Value
    end
end)

-- Groupbox for Utility Features
local UtilityGroup = Tabs.Utility:AddLeftGroupbox('Utility Features')

-- TP To Murderer
UtilityGroup:AddButton({
    Text = 'Teleport to Murderer',
    Func = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player.Backpack:FindFirstChild("Knife") and player.Character then
                LocalPlayer.Character:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
                notify("Teleported to the murderer: " .. player.Name)
                break
            end
        end
    end,
    Tooltip = 'Teleports you to the Murderer.'
})

-- TP To Sheriff
UtilityGroup:AddButton({
    Text = 'Teleport to Sheriff',
    Func = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player.Backpack:FindFirstChild("Gun") and player.Character then
                LocalPlayer.Character:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
                notify("Teleported to the sheriff: " .. player.Name)
                break
            end
        end
    end,
    Tooltip = 'Teleports you to the Sheriff.'
})

-- TP To Gun Button
UtilityGroup:AddButton({
    Text = 'TP To Gun',
    Func = function()
        local gunDrop = Workspace:FindFirstChild("Normal"):FindFirstChild("GunDrop")
        if gunDrop then
            LocalPlayer.Character:SetPrimaryPartCFrame(gunDrop.CFrame)
            notify("Teleported to Gun Drop")
        else
            notify("Gun Drop not found")
        end
    end,
    Tooltip = 'Teleports you to the dropped gun.'
})

UtilityGroup:AddButton({
    Text = 'Execute Infinite Yield',
    Tooltip = 'Executes the IY Admin Script. Can be used for fly and other stuff',
    Func = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end
})

-- Input for Farm Cooldown
UtilityGroup:AddInput('FarmCooldownInput', {
    Default = "0.1",
    Numeric = true,
    Text = 'Coin Farm Cooldown (sec)',
    Tooltip = 'Cooldown between teleports for the coin farm.',
    Placeholder = 'Enter new cooldown',
    Callback = function(Value)
        farmCooldown = tonumber(Value)
        notify("Coin Farm Cooldown set to: " .. Value .. " seconds")
    end
})

-- Farm Beachball and Coins Toggle
local function farmCoinsAndBeachballs()
    local CoinContainer = Workspace:FindFirstChild("Normal"):FindFirstChild("CoinContainer")
    if CoinContainer then
        for _, coin in pairs(CoinContainer:GetChildren()) do
            LocalPlayer.Character:SetPrimaryPartCFrame(coin.CFrame)
            task.wait(farmCooldown) -- Use the cooldown set by the player
        end
    end
end

UtilityGroup:AddToggle('FarmCoins', {
    Text = 'Farm Beachball and Coins',
    Default = false,
    Tooltip = 'Automatically teleports to each child of CoinContainer.',
    Callback = function(Value)
        FarmCoinsEnabled = Value
    end
})

RunService.Heartbeat:Connect(function()
    if FarmCoinsEnabled then
        farmCoinsAndBeachballs()
    end
end)

-- Auto Aim Murderer Toggle
local function aimAtMurderer()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Backpack:FindFirstChild("Knife") and player.Character and LocalPlayer.Backpack:FindFirstChild("Gun") then
            -- Aim at the murderer's head
            local murdererHead = player.Character:FindFirstChild("Head")
            if murdererHead then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position, murdererHead.Position)
            end
        end
    end
end

UtilityGroup:AddToggle('AimMurderer', {
    Text = 'Aim Murderer (If You\'re a Sheriff)',
    Default = false,
    Tooltip = 'Automatically aims at the murderer if you are the sheriff.',
    Callback = function(Value)
        if Value then
            RunService.RenderStepped:Connect(aimAtMurderer)
        else
            RunService.RenderStepped:Disconnect(aimAtMurderer)
        end
    end
})

-- Noclip Toggle
local noclipEnabled = false
UtilityGroup:AddToggle('Noclip', {
    Text = 'Noclip',
    Default = false,
    Tooltip = 'Walk through walls and objects.',
    Callback = function(Value)
        noclipEnabled = Value
    end
})

RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Kill All Players Toggle
UtilityGroup:AddToggle('KillAll', {
    Text = 'Kill All Players',
    Default = false,
    Tooltip = 'Teleports to all players with an "Alive" attribute until they are all dead.',
    Callback = function(Value)
        killAllEnabled = Value
    end
})

local function killAllPlayers()
    while killAllEnabled do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player:GetAttribute("Alive") == true and player.Character then
                LocalPlayer.Character:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
                task.wait(1) -- Teleport cooldown between players
            end
        end
        task.wait(1) -- Loop delay to give time for players to die
    end
end

RunService.Heartbeat:Connect(function()
    if killAllEnabled then
        killAllPlayers()
    end
end)

-- Dropped Gun Status Label
local gunStatusLabel = DroppedGunESPGroup:AddLabel('Dropped Gun Status: Not Dropped')

RunService.RenderStepped:Connect(function()
    local gunDrop = Workspace:FindFirstChild("Normal") and Workspace.Normal:FindFirstChild("GunDrop")
    if gunDrop then
        gunStatusLabel:SetText('Dropped Gun Status: Dropped')
    else
        gunStatusLabel:SetText('Dropped Gun Status: Not Dropped')
    end
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

-- Load theme and save manager
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('MM2-X-Hub')
SaveManager:SetFolder('MM2-X-Hub/configs')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()
