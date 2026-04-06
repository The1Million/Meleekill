local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// =========================
--// CONFIG
--// =========================

local Coins = 500

local OPEN_SIZE = UDim2.new(0, 475, 0, 280)
local CLOSED_SIZE = UDim2.new(0, 475, 0, 42)

-- Replace these with your real pass IDs later
local COIN_PACKS = {
	{
		Name = "200 Coins",
		PriceText = "20 Robux",
		Coins = 200,
		BonusText = "",
		GamePassId = 1111111111,
	},
	{
		Name = "500 Coins",
		PriceText = "50 Robux",
		Coins = 500,
		BonusText = "",
		GamePassId = 2222222222,
	},
	{
		Name = "1000 Coins",
		PriceText = "100 Robux",
		Coins = 1000,
		BonusText = "",
		GamePassId = 3333333333,
	},
	{
		Name = "6000 Coins",
		PriceText = "500 Robux",
		Coins = 6000, -- 5000 + 1000 bonus
		BonusText = "Includes 1000 bonus Coins",
		GamePassId = 4444444444,
	},
}

local GameData = {
	{
		Name = "Prison Life",
		Description = "Scripts made for Prison Life.",
		Scripts = {
			{
				Name = "Auto Farm",
				Price = 0,
				Description = "Basic autofarm script example for Prison Life.",
				Owned = false,
				RunCallback = function()
					print("Running Prison Life Auto Farm")
				end,
			},
		}
	},
}

--// =========================
--// GUI
--// =========================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScriptHubGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = OPEN_SIZE
mainFrame.Position = UDim2.new(0.5, -237, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 0, 0)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 42)
topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = topBar

local topFix = Instance.new("Frame")
topFix.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
topFix.BorderSizePixel = 0
topFix.Position = UDim2.new(0, 0, 1, -10)
topFix.Size = UDim2.new(1, 0, 0, 10)
topFix.Parent = topBar

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 10, 0, 0)
title.Size = UDim2.new(0, 160, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "Script Hub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local coinLabel = Instance.new("TextLabel")
coinLabel.Name = "CoinLabel"
coinLabel.BackgroundTransparency = 1
coinLabel.Position = UDim2.new(1, -200, 0, 0)
coinLabel.Size = UDim2.new(0, 95, 1, 0)
coinLabel.Font = Enum.Font.GothamBold
coinLabel.Text = "Coins: " .. Coins
coinLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinLabel.TextSize = 14
coinLabel.TextXAlignment = Enum.TextXAlignment.Right
coinLabel.Parent = topBar

local addCoinsButton = Instance.new("TextButton")
addCoinsButton.Name = "AddCoinsButton"
addCoinsButton.Size = UDim2.new(0, 22, 0, 22)
addCoinsButton.Position = UDim2.new(1, -100, 0.5, -11)
addCoinsButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
addCoinsButton.Text = "+"
addCoinsButton.Font = Enum.Font.GothamBold
addCoinsButton.TextColor3 = Color3.fromRGB(255, 215, 0)
addCoinsButton.TextSize = 16
addCoinsButton.Parent = topBar

local addCorner = Instance.new("UICorner")
addCorner.CornerRadius = UDim.new(0, 6)
addCorner.Parent = addCoinsButton

local addStroke = Instance.new("UIStroke")
addStroke.Color = Color3.fromRGB(255, 0, 0)
addStroke.Parent = addCoinsButton

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 28, 0, 24)
minimizeButton.Position = UDim2.new(1, -70, 0.5, -12)
minimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
minimizeButton.Text = "-"
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 16
minimizeButton.Parent = topBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeButton

local minStroke = Instance.new("UIStroke")
minStroke.Color = Color3.fromRGB(255, 0, 0)
minStroke.Parent = minimizeButton

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 28, 0, 24)
closeButton.Position = UDim2.new(1, -36, 0.5, -12)
closeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

local closeStroke = Instance.new("UIStroke")
closeStroke.Color = Color3.fromRGB(255, 0, 0)
closeStroke.Parent = closeButton

local contentHolder = Instance.new("Frame")
contentHolder.Name = "ContentHolder"
contentHolder.BackgroundTransparency = 1
contentHolder.Position = UDim2.new(0, 0, 0, 42)
contentHolder.Size = UDim2.new(1, 0, 1, -42)
contentHolder.Parent = mainFrame

local leftPanel = Instance.new("Frame")
leftPanel.Name = "LeftPanel"
leftPanel.Position = UDim2.new(0, 8, 0, 8)
leftPanel.Size = UDim2.new(0, 120, 1, -16)
leftPanel.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
leftPanel.BorderSizePixel = 0
leftPanel.Parent = contentHolder

local leftCorner = Instance.new("UICorner")
leftCorner.CornerRadius = UDim.new(0, 8)
leftCorner.Parent = leftPanel

local leftStroke = Instance.new("UIStroke")
leftStroke.Color = Color3.fromRGB(255, 0, 0)
leftStroke.Thickness = 1
leftStroke.Parent = leftPanel

local gamesTitle = Instance.new("TextLabel")
gamesTitle.BackgroundTransparency = 1
gamesTitle.Position = UDim2.new(0, 8, 0, 5)
gamesTitle.Size = UDim2.new(1, -16, 0, 22)
gamesTitle.Font = Enum.Font.GothamBold
gamesTitle.Text = "Games"
gamesTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
gamesTitle.TextSize = 14
gamesTitle.TextXAlignment = Enum.TextXAlignment.Left
gamesTitle.Parent = leftPanel

local gamesScroll = Instance.new("ScrollingFrame")
gamesScroll.Name = "GamesScroll"
gamesScroll.Position = UDim2.new(0, 8, 0, 28)
gamesScroll.Size = UDim2.new(1, -16, 1, -36)
gamesScroll.BackgroundTransparency = 1
gamesScroll.BorderSizePixel = 0
gamesScroll.ScrollBarThickness = 3
gamesScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
gamesScroll.Parent = leftPanel

local gamesLayout = Instance.new("UIListLayout")
gamesLayout.Padding = UDim.new(0, 6)
gamesLayout.SortOrder = Enum.SortOrder.LayoutOrder
gamesLayout.Parent = gamesScroll

local rightPanel = Instance.new("Frame")
rightPanel.Name = "RightPanel"
rightPanel.Position = UDim2.new(0, 136, 0, 8)
rightPanel.Size = UDim2.new(1, -144, 1, -16)
rightPanel.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
rightPanel.BorderSizePixel = 0
rightPanel.Parent = contentHolder

local rightCorner = Instance.new("UICorner")
rightCorner.CornerRadius = UDim.new(0, 8)
rightCorner.Parent = rightPanel

local rightStroke = Instance.new("UIStroke")
rightStroke.Color = Color3.fromRGB(255, 0, 0)
rightStroke.Thickness = 1
rightStroke.Parent = rightPanel

local headerLabel = Instance.new("TextLabel")
headerLabel.Name = "HeaderLabel"
headerLabel.BackgroundTransparency = 1
headerLabel.Position = UDim2.new(0, 10, 0, 8)
headerLabel.Size = UDim2.new(1, -20, 0, 22)
headerLabel.Font = Enum.Font.GothamBold
headerLabel.Text = "Select a game"
headerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
headerLabel.TextSize = 16
headerLabel.TextXAlignment = Enum.TextXAlignment.Left
headerLabel.Parent = rightPanel

local subLabel = Instance.new("TextLabel")
subLabel.Name = "SubLabel"
subLabel.BackgroundTransparency = 1
subLabel.Position = UDim2.new(0, 10, 0, 29)
subLabel.Size = UDim2.new(1, -20, 0, 18)
subLabel.Font = Enum.Font.Gotham
subLabel.Text = "Choose something from the left side."
subLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
subLabel.TextSize = 11
subLabel.TextXAlignment = Enum.TextXAlignment.Left
subLabel.Parent = rightPanel

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.BackgroundTransparency = 1
contentFrame.Position = UDim2.new(0, 10, 0, 52)
contentFrame.Size = UDim2.new(1, -20, 1, -62)
contentFrame.Parent = rightPanel

local scriptListFrame = Instance.new("Frame")
scriptListFrame.Name = "ScriptListFrame"
scriptListFrame.Size = UDim2.new(1, 0, 1, 0)
scriptListFrame.BackgroundTransparency = 1
scriptListFrame.Visible = false
scriptListFrame.Parent = contentFrame

local scriptListScroll = Instance.new("ScrollingFrame")
scriptListScroll.Name = "ScriptListScroll"
scriptListScroll.Size = UDim2.new(1, 0, 1, 0)
scriptListScroll.BackgroundTransparency = 1
scriptListScroll.BorderSizePixel = 0
scriptListScroll.ScrollBarThickness = 3
scriptListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scriptListScroll.Parent = scriptListFrame

local scriptListLayout = Instance.new("UIListLayout")
scriptListLayout.Padding = UDim.new(0, 8)
scriptListLayout.SortOrder = Enum.SortOrder.LayoutOrder
scriptListLayout.Parent = scriptListScroll

local scriptDetailFrame = Instance.new("Frame")
scriptDetailFrame.Name = "ScriptDetailFrame"
scriptDetailFrame.Size = UDim2.new(1, 0, 1, 0)
scriptDetailFrame.BackgroundTransparency = 1
scriptDetailFrame.Visible = false
scriptDetailFrame.Parent = contentFrame

local detailName = Instance.new("TextLabel")
detailName.BackgroundTransparency = 1
detailName.Position = UDim2.new(0, 0, 0, 0)
detailName.Size = UDim2.new(1, 0, 0, 26)
detailName.Font = Enum.Font.GothamBold
detailName.Text = "Script Name"
detailName.TextColor3 = Color3.fromRGB(255, 255, 255)
detailName.TextSize = 17
detailName.TextXAlignment = Enum.TextXAlignment.Left
detailName.Parent = scriptDetailFrame

local detailPrice = Instance.new("TextLabel")
detailPrice.BackgroundTransparency = 1
detailPrice.Position = UDim2.new(0, 0, 0, 26)
detailPrice.Size = UDim2.new(1, 0, 0, 18)
detailPrice.Font = Enum.Font.GothamBold
detailPrice.Text = "Price: 0 Coins"
detailPrice.TextColor3 = Color3.fromRGB(255, 215, 0)
detailPrice.TextSize = 12
detailPrice.TextXAlignment = Enum.TextXAlignment.Left
detailPrice.Parent = scriptDetailFrame

local detailDescription = Instance.new("TextLabel")
detailDescription.BackgroundTransparency = 1
detailDescription.Position = UDim2.new(0, 0, 0, 50)
detailDescription.Size = UDim2.new(1, 0, 0, 90)
detailDescription.Font = Enum.Font.Gotham
detailDescription.Text = "Description"
detailDescription.TextWrapped = true
detailDescription.TextYAlignment = Enum.TextYAlignment.Top
detailDescription.TextColor3 = Color3.fromRGB(220, 220, 220)
detailDescription.TextSize = 12
detailDescription.TextXAlignment = Enum.TextXAlignment.Left
detailDescription.Parent = scriptDetailFrame

local buyButton = Instance.new("TextButton")
buyButton.Name = "BuyButton"
buyButton.Position = UDim2.new(0, 0, 1, -34)
buyButton.Size = UDim2.new(0, 82, 0, 28)
buyButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
buyButton.Font = Enum.Font.GothamBold
buyButton.TextSize = 12
buyButton.Text = "Buy / Get"
buyButton.Parent = scriptDetailFrame

local buyCorner = Instance.new("UICorner")
buyCorner.CornerRadius = UDim.new(0, 6)
buyCorner.Parent = buyButton

local buyStroke = Instance.new("UIStroke")
buyStroke.Color = Color3.fromRGB(255, 0, 0)
buyStroke.Parent = buyButton

local runButton = Instance.new("TextButton")
runButton.Name = "RunButton"
runButton.Position = UDim2.new(0, 88, 1, -34)
runButton.Size = UDim2.new(0, 70, 0, 28)
runButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
runButton.TextColor3 = Color3.fromRGB(255, 255, 255)
runButton.Font = Enum.Font.GothamBold
runButton.TextSize = 12
runButton.Text = "Run"
runButton.Parent = scriptDetailFrame

local runCorner = Instance.new("UICorner")
runCorner.CornerRadius = UDim.new(0, 6)
runCorner.Parent = runButton

local runStroke = Instance.new("UIStroke")
runStroke.Color = Color3.fromRGB(255, 0, 0)
runStroke.Parent = runButton

local backButton = Instance.new("TextButton")
backButton.Name = "BackButton"
backButton.Position = UDim2.new(0, 164, 1, -34)
backButton.Size = UDim2.new(0, 70, 0, 28)
backButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
backButton.Font = Enum.Font.GothamBold
backButton.TextSize = 12
backButton.Text = "Back"
backButton.Parent = scriptDetailFrame

local backCorner = Instance.new("UICorner")
backCorner.CornerRadius = UDim.new(0, 6)
backCorner.Parent = backButton

local backStroke = Instance.new("UIStroke")
backStroke.Color = Color3.fromRGB(255, 0, 0)
backStroke.Parent = backButton

-- Coin shop page
local coinShopFrame = Instance.new("Frame")
coinShopFrame.Name = "CoinShopFrame"
coinShopFrame.Size = UDim2.new(1, 0, 1, 0)
coinShopFrame.BackgroundTransparency = 1
coinShopFrame.Visible = false
coinShopFrame.Parent = contentFrame

local coinShopScroll = Instance.new("ScrollingFrame")
coinShopScroll.Size = UDim2.new(1, 0, 1, 0)
coinShopScroll.BackgroundTransparency = 1
coinShopScroll.BorderSizePixel = 0
coinShopScroll.ScrollBarThickness = 3
coinShopScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
coinShopScroll.Parent = coinShopFrame

local coinShopLayout = Instance.new("UIListLayout")
coinShopLayout.Padding = UDim.new(0, 8)
coinShopLayout.SortOrder = Enum.SortOrder.LayoutOrder
coinShopLayout.Parent = coinShopScroll

--// =========================
--// DRAG
--// =========================

local dragging = false
local dragInput
local dragStart
local startPos

topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

topBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

--// =========================
--// LOGIC
--// =========================

local selectedGame = nil
local selectedScript = nil
local minimized = false
local tweening = false
local currentView = "none"

local function updateCoinLabel()
	coinLabel.Text = "Coins: " .. Coins
end

local function clearChildrenExceptLayout(parent)
	for _, child in ipairs(parent:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
end

local function updateScrollingSize(scrollingFrame, layout)
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 6)
end

gamesLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	updateScrollingSize(gamesScroll, gamesLayout)
end)

scriptListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	updateScrollingSize(scriptListScroll, scriptListLayout)
end)

coinShopLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	updateScrollingSize(coinShopScroll, coinShopLayout)
end)

local function hideAllRightViews()
	scriptListFrame.Visible = false
	scriptDetailFrame.Visible = false
	coinShopFrame.Visible = false
end

local function showScriptDetail(scriptInfo)
	selectedScript = scriptInfo
	currentView = "scriptDetail"
	hideAllRightViews()

	scriptDetailFrame.Visible = true
	headerLabel.Text = selectedGame.Name
	subLabel.Text = "Viewing script information"

	detailName.Text = scriptInfo.Name
	detailPrice.Text = "Price: " .. tostring(scriptInfo.Price) .. " Coins"
	detailDescription.Text = scriptInfo.Description or "No description."

	if scriptInfo.Owned or scriptInfo.Price == 0 then
		buyButton.Text = "Owned / Free"
	else
		buyButton.Text = "Buy"
	end
end

local function createScriptButton(scriptInfo)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -2, 0, 44)
	button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	button.Text = ""
	button.Parent = scriptListScroll

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 0, 0)
	stroke.Parent = button

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.new(0, 8, 0, 4)
	nameLabel.Size = UDim2.new(1, -16, 0, 18)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Text = scriptInfo.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = button

	local priceLabel = Instance.new("TextLabel")
	priceLabel.BackgroundTransparency = 1
	priceLabel.Position = UDim2.new(0, 8, 0, 21)
	priceLabel.Size = UDim2.new(1, -16, 0, 16)
	priceLabel.Font = Enum.Font.Gotham
	priceLabel.Text = "Price: " .. tostring(scriptInfo.Price) .. " Coins"
	priceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	priceLabel.TextSize = 11
	priceLabel.TextXAlignment = Enum.TextXAlignment.Left
	priceLabel.Parent = button

	button.MouseButton1Click:Connect(function()
		showScriptDetail(scriptInfo)
	end)
end

local function showScriptsForGame(gameInfo)
	selectedGame = gameInfo
	selectedScript = nil
	currentView = "scriptList"
	hideAllRightViews()

	headerLabel.Text = gameInfo.Name
	subLabel.Text = gameInfo.Description or "No description."

	scriptListFrame.Visible = true
	clearChildrenExceptLayout(scriptListScroll)

	for _, scriptInfo in ipairs(gameInfo.Scripts) do
		createScriptButton(scriptInfo)
	end

	updateScrollingSize(scriptListScroll, scriptListLayout)
end

local function createGameButton(gameInfo)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -2, 0, 36)
	button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	button.Text = gameInfo.Name
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 12
	button.Parent = gamesScroll

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 0, 0)
	stroke.Parent = button

	button.MouseButton1Click:Connect(function()
		showScriptsForGame(gameInfo)
	end)
end

local function createCoinPackButton(packInfo)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -2, 0, 68)
	button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	button.Text = ""
	button.Parent = coinShopScroll

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 0, 0)
	stroke.Parent = button

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.new(0, 8, 0, 4)
	nameLabel.Size = UDim2.new(1, -100, 0, 18)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Text = packInfo.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = button

	local priceLabel = Instance.new("TextLabel")
	priceLabel.BackgroundTransparency = 1
	priceLabel.Position = UDim2.new(0, 8, 0, 22)
	priceLabel.Size = UDim2.new(1, -100, 0, 16)
	priceLabel.Font = Enum.Font.Gotham
	priceLabel.Text = "Cost: " .. packInfo.PriceText
	priceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	priceLabel.TextSize = 11
	priceLabel.TextXAlignment = Enum.TextXAlignment.Left
	priceLabel.Parent = button

	local bonusLabel = Instance.new("TextLabel")
	bonusLabel.BackgroundTransparency = 1
	bonusLabel.Position = UDim2.new(0, 8, 0, 39)
	bonusLabel.Size = UDim2.new(1, -100, 0, 16)
	bonusLabel.Font = Enum.Font.Gotham
	bonusLabel.Text = packInfo.BonusText ~= "" and packInfo.BonusText or ("Gives " .. packInfo.Coins .. " Coins")
	bonusLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
	bonusLabel.TextSize = 10
	bonusLabel.TextXAlignment = Enum.TextXAlignment.Left
	bonusLabel.Parent = button

	local buyPackButton = Instance.new("TextButton")
	buyPackButton.Size = UDim2.new(0, 76, 0, 28)
	buyPackButton.Position = UDim2.new(1, -84, 0.5, -14)
	buyPackButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	buyPackButton.Text = "Buy"
	buyPackButton.Font = Enum.Font.GothamBold
	buyPackButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyPackButton.TextSize = 12
	buyPackButton.Parent = button

	local buyPackCorner = Instance.new("UICorner")
	buyPackCorner.CornerRadius = UDim.new(0, 6)
	buyPackCorner.Parent = buyPackButton

	local buyPackStroke = Instance.new("UIStroke")
	buyPackStroke.Color = Color3.fromRGB(255, 0, 0)
	buyPackStroke.Parent = buyPackButton

	buyPackButton.MouseButton1Click:Connect(function()
		MarketplaceService:PromptGamePassPurchase(player, packInfo.GamePassId)
	end)
end

local function showCoinShop()
	selectedGame = nil
	selectedScript = nil
	currentView = "coinShop"
	hideAllRightViews()

	headerLabel.Text = "Buy Coins"
	subLabel.Text = "Choose a Coin pack."

	coinShopFrame.Visible = true
	clearChildrenExceptLayout(coinShopScroll)

	for _, packInfo in ipairs(COIN_PACKS) do
		createCoinPackButton(packInfo)
	end

	updateScrollingSize(coinShopScroll, coinShopLayout)
end

local function loadGames()
	clearChildrenExceptLayout(gamesScroll)

	for _, gameInfo in ipairs(GameData) do
		createGameButton(gameInfo)
	end

	updateScrollingSize(gamesScroll, gamesLayout)
end

buyButton.MouseButton1Click:Connect(function()
	if not selectedScript then
		return
	end

	if selectedScript.Owned or selectedScript.Price == 0 then
		selectedScript.Owned = true
		buyButton.Text = "Owned / Free"
		print("Script unlocked: " .. selectedScript.Name)
		return
	end

	if Coins >= selectedScript.Price then
		Coins -= selectedScript.Price
		selectedScript.Owned = true
		updateCoinLabel()
		buyButton.Text = "Owned / Free"
		print("Bought script: " .. selectedScript.Name)
	else
		print("Not enough Coins")
	end
end)

runButton.MouseButton1Click:Connect(function()
	if not selectedScript then
		return
	end

	if selectedScript.Price == 0 or selectedScript.Owned then
		if selectedScript.RunCallback then
			selectedScript.RunCallback()
		else
			print("No RunCallback set for " .. selectedScript.Name)
		end
	else
		print("You must buy this script first")
	end
end)

backButton.MouseButton1Click:Connect(function()
	if currentView == "scriptDetail" and selectedGame then
		showScriptsForGame(selectedGame)
	elseif currentView == "coinShop" then
		headerLabel.Text = "Select a game"
		subLabel.Text = "Choose something from the left side."
		hideAllRightViews()
		currentView = "none"
	end
end)

addCoinsButton.MouseButton1Click:Connect(function()
	showCoinShop()
end)

local function toggleMinimize()
	if tweening then
		return
	end
	tweening = true

	local tweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

	if not minimized then
		minimized = true
		minimizeButton.Text = "+"
		for _, obj in ipairs(contentHolder:GetDescendants()) do
			if obj:IsA("GuiObject") then
				obj.Visible = false
			end
		end

		local sizeTween = TweenService:Create(mainFrame, tweenInfo, {Size = CLOSED_SIZE})
		sizeTween:Play()
		sizeTween.Completed:Wait()
	else
		minimized = false
		minimizeButton.Text = "-"

		local sizeTween = TweenService:Create(mainFrame, tweenInfo, {Size = OPEN_SIZE})
		sizeTween:Play()
		sizeTween.Completed:Wait()

		leftPanel.Visible = true
		rightPanel.Visible = true

		for _, obj in ipairs(contentHolder:GetDescendants()) do
			if obj:IsA("GuiObject") then
				obj.Visible = true
			end
		end

		hideAllRightViews()
		if currentView == "scriptDetail" and selectedScript then
			scriptDetailFrame.Visible = true
		elseif currentView == "scriptList" and selectedGame then
			scriptListFrame.Visible = true
		elseif currentView == "coinShop" then
			coinShopFrame.Visible = true
		end
	end

	tweening = false
end

minimizeButton.MouseButton1Click:Connect(toggleMinimize)

closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

updateCoinLabel()
loadGames()
