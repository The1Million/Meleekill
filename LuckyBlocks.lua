-- Initialize Variables
local allowedItems = {}
local isSpamming = false
local spamCoroutine = nil

-- Table for multiple selected items
local selectedOptions = {}

local player = game.Players.LocalPlayer

-- ADDED FOR RESET LOGIC:
local hasSpammedBefore = false
local lastPosCFrame = nil

--------------------------------------------------------------------------------
-- Attempt to avoid resets by default
local function tryRefreshInventoryWithoutReset()
    local success = true
    -- If you truly need a forced kill or reset to refresh your gear, set success = false,
    -- then do it in ClearInventoryButton. For now, we skip it.
    return success
end

--------------------------------------------------------------------------------
-- Create ScreenGui
local LuckyBlock = Instance.new("ScreenGui")
LuckyBlock.Name = "LuckyBlock"
LuckyBlock.Parent = player:WaitForChild("PlayerGui")
LuckyBlock.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Parent = LuckyBlock
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Size = UDim2.new(0, 600, 0, 400)
Frame.Position = UDim2.new(0.2, 0, 0.2, 0)
Frame.Active = true
Frame.Draggable = true

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = Frame
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Lucky Blocks GUI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 24
Title.TextStrokeTransparency = 0.8

-- Close Button
local CloseButton = Instance.new("ImageButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = Frame
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(0.95, -30, 0, 5)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Image = "rbxassetid://3926305904"
CloseButton.ImageRectOffset = Vector2.new(284, 4)
CloseButton.ImageRectSize = Vector2.new(24, 24)

--------------------------------------------------------------------------------
-- Four Dropdown Toggle Buttons + Frames, spaced so they don't overlap
local function createDropdownToggleButton(parent, name, xPos)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = parent
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.Position = UDim2.new(xPos, 0, 0.12, 0)
    btn.Size = UDim2.new(0, 100, 0, 25) -- small toggle button
    btn.Text = "Options"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    return btn
end

local function createDropdownFrame(parent, frameName, xPos, yPos)
    local f = Instance.new("Frame")
    f.Name = frameName
    f.Parent = parent
    f.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    f.Position = UDim2.new(xPos, 0, yPos, 0)
    f.Size = UDim2.new(0, 100, 0, 90)  -- small for side-by-side
    f.Visible = false
    f.ZIndex = 2
    return f
end

local DropdownButton1 = createDropdownToggleButton(Frame, "DropdownButton1", 0.02)
local DropdownFrame1  = createDropdownFrame(Frame, "DropdownFrame1",  0.02, 0.18)

local DropdownButton2 = createDropdownToggleButton(Frame, "DropdownButton2", 0.19)
local DropdownFrame2  = createDropdownFrame(Frame, "DropdownFrame2",  0.19, 0.18)

local DropdownButton3 = createDropdownToggleButton(Frame, "DropdownButton3", 0.36)
local DropdownFrame3  = createDropdownFrame(Frame, "DropdownFrame3",  0.36, 0.18)

local DropdownButton4 = createDropdownToggleButton(Frame, "DropdownButton4", 0.53)
local DropdownFrame4  = createDropdownFrame(Frame, "DropdownFrame4",  0.53, 0.18)

-- Items we can pick in each dropdown
local items = {"RainbowMagicCarpet","SpectralSword","FastPotion"}

local function createDropdownOption(parentFrame, itemName, yPos)
    local btn = Instance.new("TextButton")
    btn.Name = itemName.."Option"
    btn.Parent = parentFrame
    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    btn.Size = UDim2.new(1,0, 0, 25)
    btn.Position = UDim2.new(0,0, 0, yPos)
    btn.Text = itemName
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 13
    btn.ZIndex = 3
    return btn
end

local function populateDropdown(frame)
    local yPos = 0
    for _, item in ipairs(items) do
        local optionBtn = createDropdownOption(frame, item, yPos)
        yPos = yPos + 25

        optionBtn.MouseButton1Click:Connect(function()
            if selectedOptions[item] then
                selectedOptions[item] = nil
                print("Unselected: ", item)
                optionBtn.BackgroundColor3 = Color3.fromRGB(70,70,70) -- revert color
            else
                selectedOptions[item] = true
                print("Selected: ", item)
                optionBtn.BackgroundColor3 = Color3.fromRGB(0,200,0) -- highlight green
            end
        end)
    end
end

populateDropdown(DropdownFrame1)
populateDropdown(DropdownFrame2)
populateDropdown(DropdownFrame3)
populateDropdown(DropdownFrame4)

-- Toggle each dropdown frame
DropdownButton1.MouseButton1Click:Connect(function()
    DropdownFrame1.Visible = not DropdownFrame1.Visible
end)
DropdownButton2.MouseButton1Click:Connect(function()
    DropdownFrame2.Visible = not DropdownFrame2.Visible
end)
DropdownButton3.MouseButton1Click:Connect(function()
    DropdownFrame3.Visible = not DropdownFrame3.Visible
end)
DropdownButton4.MouseButton1Click:Connect(function()
    DropdownFrame4.Visible = not DropdownFrame4.Visible
end)

--------------------------------------------------------------------------------
-- Button Frame (for single-block spawns)
local ButtonFrame = Instance.new("Frame")
ButtonFrame.Name = "ButtonFrame"
ButtonFrame.Parent = Frame
ButtonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ButtonFrame.Position = UDim2.new(0.7, 0, 0.12, 0)
ButtonFrame.Size = UDim2.new(0.25, 0, 0.3, 0)

-- Single-Spawn Buttons
local LuckyBlockButton = Instance.new("TextButton")
LuckyBlockButton.Name = "LuckyBlockButton"
LuckyBlockButton.Parent = ButtonFrame
LuckyBlockButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
LuckyBlockButton.Size = UDim2.new(1, 0, 0.18, 0)
LuckyBlockButton.Position = UDim2.new(0, 0, 0, 0)
LuckyBlockButton.Text = "Lucky Block"
LuckyBlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LuckyBlockButton.Font = Enum.Font.SourceSans
LuckyBlockButton.TextSize = 14

local SuperBlockButton = Instance.new("TextButton")
SuperBlockButton.Name = "SuperBlockButton"
SuperBlockButton.Parent = ButtonFrame
SuperBlockButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
SuperBlockButton.Size = UDim2.new(1, 0, 0.18, 0)
SuperBlockButton.Position = UDim2.new(0, 0, 0.18, 0)
SuperBlockButton.Text = "Super Block"
SuperBlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SuperBlockButton.Font = Enum.Font.SourceSans
SuperBlockButton.TextSize = 14

local GalaxyBlockButton = Instance.new("TextButton")
GalaxyBlockButton.Name = "GalaxyBlockButton"
GalaxyBlockButton.Parent = ButtonFrame
GalaxyBlockButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
GalaxyBlockButton.Size = UDim2.new(1, 0, 0.18, 0)
GalaxyBlockButton.Position = UDim2.new(0, 0, 0.36, 0)
GalaxyBlockButton.Text = "Galaxy Block"
GalaxyBlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GalaxyBlockButton.Font = Enum.Font.SourceSans
GalaxyBlockButton.TextSize = 14

local RainbowBlockButton = Instance.new("TextButton")
RainbowBlockButton.Name = "RainbowBlockButton"
RainbowBlockButton.Parent = ButtonFrame
RainbowBlockButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
RainbowBlockButton.Size = UDim2.new(1, 0, 0.18, 0)
RainbowBlockButton.Position = UDim2.new(0, 0, 0.54, 0)
RainbowBlockButton.Text = "Rainbow Block"
RainbowBlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RainbowBlockButton.Font = Enum.Font.SourceSans
RainbowBlockButton.TextSize = 14

local DiamondBlockButton = Instance.new("TextButton")
DiamondBlockButton.Name = "DiamondBlockButton"
DiamondBlockButton.Parent = ButtonFrame
DiamondBlockButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
DiamondBlockButton.Size = UDim2.new(1, 0, 0.18, 0)
DiamondBlockButton.Position = UDim2.new(0, 0, 0.72, 0)
DiamondBlockButton.Text = "Diamond Block"
DiamondBlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DiamondBlockButton.Font = Enum.Font.SourceSans
DiamondBlockButton.TextSize = 14

-- Spam Button
local SpamButton = Instance.new("TextButton")
SpamButton.Name = "SpamButton"
SpamButton.Parent = Frame
SpamButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
SpamButton.Position = UDim2.new(0.02, 0, 0.35, 0)
SpamButton.Size = UDim2.new(0.3, 0, 0.08, 0)
SpamButton.Text = "Spam Selected"
SpamButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpamButton.Font = Enum.Font.SourceSans
SpamButton.TextSize = 14

-- TextBox for Number of Blocks
local TextBox = Instance.new("TextBox")
TextBox.Name = "TextBox"
TextBox.Parent = ButtonFrame
TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TextBox.Position = UDim2.new(0, 0, 0.9, 0)
TextBox.Size = UDim2.new(1, 0, 0.1, 0)
TextBox.Text = "1"
TextBox.PlaceholderText = "Enter number"
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.Font = Enum.Font.SourceSans
TextBox.TextSize = 14

-- ClearInventoryButton
local ClearInventoryButton = Instance.new("TextButton")
ClearInventoryButton.Name = "ClearInventoryButton"
ClearInventoryButton.Parent = Frame
ClearInventoryButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ClearInventoryButton.Position = UDim2.new(0.02, 0, 0.9, 0)
ClearInventoryButton.Size = UDim2.new(0.15, 0, 0.08, 0)
ClearInventoryButton.Text = "Clear All"
ClearInventoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearInventoryButton.Font = Enum.Font.SourceSans
ClearInventoryButton.TextSize = 12

--------------------------------------------------------------------------------
-- Helper Functions
local function getValidNumber()
    local val = tonumber(TextBox.Text)
    if not val or val <= 0 then
        val = 1
    end
    return val
end

local function spawnBlock(blockName, num)
    local remoteEvent = game.ReplicatedStorage:FindFirstChild("Spawn" .. blockName)
    if remoteEvent and remoteEvent:IsA("RemoteEvent") then
        for i = 1, num do
            local success, errMsg = pcall(function()
                remoteEvent:FireServer()
            end)
            if success then
                print("Successfully fired Spawn" .. blockName)
            else
                warn("Error firing Spawn" .. blockName .. ": ", errMsg)
            end
        end
        print("Spawning " .. num .. " " .. blockName .. "(s).")
    else
        warn("RemoteEvent 'Spawn" .. blockName .. "' not found in ReplicatedStorage.")
    end
end

-- Single-Spawn Buttons
LuckyBlockButton.MouseButton1Click:Connect(function()
    local n = getValidNumber()
    spawnBlock("LuckyBlock", n)
end)

SuperBlockButton.MouseButton1Click:Connect(function()
    local n = getValidNumber()
    spawnBlock("SuperBlock", n)
end)

GalaxyBlockButton.MouseButton1Click:Connect(function()
    local n = getValidNumber()
    spawnBlock("GalaxyBlock", n)
end)

RainbowBlockButton.MouseButton1Click:Connect(function()
    local n = getValidNumber()
    spawnBlock("RainbowBlock", n)
end)

DiamondBlockButton.MouseButton1Click:Connect(function()
    local n = getValidNumber()
    spawnBlock("DiamondBlock", n)
end)

--------------------------------------------------------------------------------
-- The main SPAM logic (kill + wait for Died + wait for new char + teleport)
SpamButton.MouseButton1Click:Connect(function()
    if isSpamming then
        -- Already spamming, so stop
        isSpamming = false
        if spamCoroutine then
            coroutine.resume(spamCoroutine)
            spamCoroutine = nil
        end
        SpamButton.Text = "Spam Selected"
        SpamButton.Active = true
        print("Spamming stopped by user.")
        return
    end

    -- If no items chosen, do nothing
    local chosenCount = 0
    for _, _ in pairs(selectedOptions) do
        chosenCount += 1
    end
    if chosenCount == 0 then
        print("You haven't selected anything in the 4 dropdowns.")
        return
    end

    -- If we've spammed before, kill + wait for respawn
    if hasSpammedBefore then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            lastPosCFrame = char.HumanoidRootPart.CFrame
        end
        if char and char:FindFirstChild("Humanoid") then
            print("Killing current character...")
            local hum = char.Humanoid
            hum.Health = 0

            -- Wait until this humanoid actually dies
            hum.Died:Wait()
            print("Character died. Waiting for respawn...")

            -- Wait for a brand-new Character
            local newChar = player.CharacterAdded:Wait()
            local newHrp = newChar:WaitForChild("HumanoidRootPart", 10)
            if newHrp and lastPosCFrame then
                newHrp.CFrame = lastPosCFrame
            end
        end
    end

    hasSpammedBefore = true

    isSpamming = true
    SpamButton.Text = "Stop Spamming"
    SpamButton.Active = false
    print("Spamming started. Items chosen =>", selectedOptions)

    -- Build allowedItems from selectedOptions
    for k,_ in pairs(allowedItems) do
        allowedItems[k] = nil
    end
    for itemName,_ in pairs(selectedOptions) do
        allowedItems[itemName] = true
    end

    spamCoroutine = coroutine.create(function()
        local backpack = player:WaitForChild("Backpack")

        local burstSize = 5
        local burstInterval = 1
        local cleanupInterval = 5
        local lastCleanup = tick()

        while isSpamming do
            -- spam GalaxyBlock in bursts
            for i = 1, burstSize do
                spawnBlock("GalaxyBlock", 1)
            end
            wait(burstInterval)

            -- Check if all chosen items are in your Backpack
            local allFound = true
            for itemName,_ in pairs(selectedOptions) do
                if not backpack:FindFirstChild(itemName) then
                    allFound = false
                    break
                end
            end
            if allFound then
                print("All chosen items found! Stopping spam automatically.")
                isSpamming = false
            else
                if tick() - lastCleanup >= cleanupInterval then
                    print("Removing Tools not in chosen set.")
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") and (not allowedItems[tool.Name]) then
                            tool:Destroy()
                            print("Removed", tool.Name)
                        end
                    end
                    lastCleanup = tick()
                end
            end
        end

        SpamButton.Text = "Spam Selected"
        SpamButton.Active = true
        print("Spamming ended. Doing final cleanup...")

        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and (not allowedItems[tool.Name]) then
                tool:Destroy()
                print("Removed leftover", tool.Name)
            end
        end
    end)

    coroutine.resume(spamCoroutine)
end)

--------------------------------------------------------------------------------
-- ClearInventoryButton
ClearInventoryButton.MouseButton1Click:Connect(function()
    if isSpamming then
        isSpamming = false
        if spamCoroutine then
            coroutine.resume(spamCoroutine)
            spamCoroutine = nil
        end
        print("Spamming stopped via Clear All.")
    end

    SpamButton.Text = "Spam Selected"
    SpamButton.Active = true

    local backpack = player:WaitForChild("Backpack")
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and (not allowedItems[tool.Name]) then
            tool:Destroy()
            print("Removed", tool.Name)
        end
    end
    print("All non-chosen items cleared out of the Backpack.")

    local success = tryRefreshInventoryWithoutReset()
    if not success then
        print("Could not refresh inventory without reset. Possibly do a manual reset/respawn here.")
    end
end)

--------------------------------------------------------------------------------
-- Close Button
CloseButton.MouseButton1Click:Connect(function()
    Frame.Visible = false
    print("GUI closed.")
end)
