--------------------------------------------------------------------
--  Blue Command Loader  •  FULL FINAL
--------------------------------------------------------------------

-------------------- SERVICES --------------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-------------------- NOTIFY ----------------------
local function notify(title, text, dur)
	pcall(function()
		game.StarterGui:SetCore("SendNotification", {
			Title = title;
			Text = text;
			Duration = dur or 4;
		})
	end)
end

--------------------------------------------------------------------
-- COMMAND LIST (USED BY GUI)
--------------------------------------------------------------------
local commands = {
	"setammo",
	"keepaway",
	"rainbowzombies",
	"autofarm v1",
	"autofarm v2",
	"killaura",
	"autokill",
	"autopowerup",
	"autocheckpoint",
}

--------------------------------------------------------------------
-- STATE FLAGS
--------------------------------------------------------------------
local states = {
	keepaway = false,
	rainbowzombies = false,
	autofarm_v1 = false,
	autofarm_v2 = false,
	killaura = false,
	autokill = false,
	autopowerup = false,
	autocheckpoint = false,
}

local connections = {}

--------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------
local function getTool(char)
	for _, v in ipairs(char:GetChildren()) do
		if v:IsA("Tool") then return v end
	end
end

local function setSimRadius()
	pcall(function()
		sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
		sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
	end)
end

--------------------------------------------------------------------
-- COMMAND HANDLERS
--------------------------------------------------------------------
local CommandHandlers = {}

--------------------------------------------------------------------
-- !setammo <number>
--------------------------------------------------------------------
CommandHandlers.setammo = function(args)
	local amt = tonumber(args[1])
	if not amt then return notify("Usage","!setammo <number>",4) end

	local function apply(t)
		local info = t:FindFirstChild("Info")
		local cs = info and info:FindFirstChild("ClipSize")
		if cs and cs:IsA("ValueBase") then
			cs.Value = amt
		end
	end

	for _, c in ipairs({LocalPlayer.Backpack, LocalPlayer.Character}) do
		if c then
			for _, t in ipairs(c:GetChildren()) do
				if t:IsA("Tool") then apply(t) end
			end
		end
	end

	notify("SetAmmo","ClipSize set to "..amt,3)
end

--------------------------------------------------------------------
-- !keepaway (TOGGLE)
--------------------------------------------------------------------
CommandHandlers.keepaway = function()
	states.keepaway = not states.keepaway

	if not states.keepaway then
		if connections.keepaway then
			connections.keepaway:Disconnect()
			connections.keepaway = nil
		end
		return notify("KeepAway","OFF",3)
	end

	connections.keepaway = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		for _, h in ipairs(Workspace:GetDescendants()) do
			if h:IsA("Humanoid") and not Players:FindFirstChild(h.Parent.Name) then
				local r = h.Parent:FindFirstChild("HumanoidRootPart")
				if r and (r.Position - hrp.Position).Magnitude <= 50 then
					h.WalkSpeed = 0
					h.JumpPower = 0
					h.JumpHeight = 0
				end
			end
		end
	end)

	notify("KeepAway","ON",3)
end

--------------------------------------------------------------------
-- !rainbowzombies (TOGGLE)
--------------------------------------------------------------------
CommandHandlers.rainbowzombies = function()
	local folder = Workspace:WaitForChild("ActiveZombies")
	states.rainbowzombies = not states.rainbowzombies

	if not states.rainbowzombies then
		for _, z in ipairs(folder:GetChildren()) do
			for _, v in ipairs(z:GetChildren()) do
				if v:IsA("Highlight") then v:Destroy() end
			end
			local tag = z:FindFirstChild("__RB")
			if tag then tag:Destroy() end
		end
		return notify("RainbowZombies","OFF",3)
	end

	local function rainbow(t)
		return Color3.fromHSV((t % 5) / 5, 1, 1)
	end

	local function apply(m)
		if m:FindFirstChild("__RB") then return end
		Instance.new("BoolValue", m).Name = "__RB"

		local hl = Instance.new("Highlight", m)
		hl.Adornee = m
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.FillTransparency = 0.7

		RunService.RenderStepped:Connect(function()
			if states.rainbowzombies and m.Parent then
				local c = rainbow(tick())
				hl.FillColor = c
				hl.OutlineColor = c
			end
		end)
	end

	for _, z in ipairs(folder:GetChildren()) do apply(z) end
	folder.ChildAdded:Connect(function(z)
		task.wait()
		if states.rainbowzombies then apply(z) end
	end)

	notify("RainbowZombies","ON",3)
end

--------------------------------------------------------------------
-- !autofarm v1 / v2
--------------------------------------------------------------------
CommandHandlers.autofarm = function(args)
	local mode = args[1]
	if mode ~= "v1" and mode ~= "v2" then
		return notify("Usage","!autofarm v1 | v2",4)
	end

	-- AUTOFARM V1
	if mode == "v1" then
		if states.autofarm_v1 then
			states.autofarm_v1 = false
			if connections.autofarm_v1 then connections.autofarm_v1:Disconnect() end
			return notify("AutoFarm v1","OFF",3)
		end

		states.autofarm_v1 = true
		connections.autofarm_v1 = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end

			for _, h in ipairs(Workspace:GetDescendants()) do
				if h:IsA("Humanoid") and not Players:FindFirstChild(h.Parent.Name) then
					local r = h.Parent:FindFirstChild("HumanoidRootPart")
					if r then
						r.CFrame = hrp.CFrame * CFrame.new(0,0,-10)
					end
				end
			end
		end)

		return notify("AutoFarm v1","ON",3)
	end

	-- AUTOFARM V2
	if states.autofarm_v2 then
		states.autofarm_v2 = false
		return notify("AutoFarm v2","OFF",3)
	end

	states.autofarm_v2 = true
	local FireRemote = ReplicatedStorage.Events.Actions.Fire

	task.spawn(function()
		while states.autofarm_v2 do
			task.wait(0.15)
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then continue end

			local tool = getTool(char)
			if not tool then continue end

			local folder = Workspace:FindFirstChild("ActiveZombies")
			if not folder then continue end

			for _, z in ipairs(folder:GetChildren()) do
				local hum = z:FindFirstChildOfClass("Humanoid")
				local root = z:FindFirstChild("HumanoidRootPart")
				if hum and root and hum.Health > 0 then
					for i=1,4 do
						local o = hrp.Position + Vector3.new(0,1.5,0)
						local p = root.Position
						local d = (p-o).Unit

						FireRemote:FireServer(
							tool.Name,
							{[1]={[1]=root,[2]=p.X,[3]=p.Y,[4]=p.Z,[5]=d.X,[6]=d.Y,[7]=d.Z}},
							{[1]={[1]=tool.Name,[2]=o.X,[3]=o.Y,[4]=o.Z,[5]=p.X,[6]=p.Y,[7]=p.Z,[8]=p.X,[9]=p.Y,[10]=p.Z,[11]=true,[12]=root,[13]=false,[14]=false,[15]="Default",[16]=tool}}
						)
						task.wait(0.04)
					end
				end
			end
		end
	end)

	notify("AutoFarm v2","ON",3)
end

--------------------------------------------------------------------
-- !killaura
--------------------------------------------------------------------
CommandHandlers.killaura = function()
	if states.killaura then
		states.killaura = false
		return notify("KillAura","OFF",3)
	end

	states.killaura = true
	local FireRemote = ReplicatedStorage.Events.Actions.Fire

	task.spawn(function()
		while states.killaura do
			task.wait(0.2)
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then continue end

			local tool = getTool(char)
			if not tool then continue end

			local folder = Workspace:FindFirstChild("ActiveZombies")
			if not folder then continue end

			local list = {}
			for _, z in ipairs(folder:GetChildren()) do
				local hum = z:FindFirstChildOfClass("Humanoid")
				local root = z:FindFirstChild("HumanoidRootPart")
				if hum and root and hum.Health > 0 then
					local dist = (hrp.Position-root.Position).Magnitude
					if dist <= 35 then
						table.insert(list,{z=z,d=dist})
					end
				end
			end

			table.sort(list,function(a,b) return a.d<b.d end)

			for i=1,math.min(3,#list) do
				for s=1,3 do
					local root = list[i].z.HumanoidRootPart
					local o = hrp.Position + Vector3.new(0,1.5,0)
					local p = root.Position
					local d = (p-o).Unit

					FireRemote:FireServer(
						tool.Name,
						{[1]={[1]=root,[2]=p.X,[3]=p.Y,[4]=p.Z,[5]=d.X,[6]=d.Y,[7]=d.Z}},
						{[1]={[1]=tool.Name,[2]=o.X,[3]=o.Y,[4]=o.Z,[5]=p.X,[6]=p.Y,[7]=p.Z,[8]=p.X,[9]=p.Y,[10]=p.Z,[11]=true,[12]=root,[13]=false,[14]=false,[15]="Default",[16]=tool}}
					)
					task.wait(0.05)
				end
			end
		end
	end)

	notify("KillAura","ON",3)
end

--------------------------------------------------------------------
-- !autokill
--------------------------------------------------------------------
CommandHandlers.autokill = function()
	states.autokill = not states.autokill
	notify("AutoKill", states.autokill and "ON" or "OFF", 3)

	if states.autokill then
		for _, d in ipairs(Workspace:GetDescendants()) do
			if d:IsA("Humanoid") and d.Parent ~= LocalPlayer.Character then
				d.Health = 0
				d.MaxHealth = 0
			end
		end
	end
end

--------------------------------------------------------------------
-- !autopowerup / !autocheckpoint
--------------------------------------------------------------------
local function touchLoop(filter)
	setSimRadius()
	task.spawn(function()
		local hrp = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
		while states[filter] do
			task.wait(0.9)
			for _, p in ipairs(game:GetDescendants()) do
				if p:IsA("BasePart") and p:FindFirstChildOfClass("TouchTransmitter") then
					if (filter=="autopowerup" and tonumber(p.Name)==nil)
					or (filter=="autocheckpoint" and tonumber(p.Name)~=nil) then
						firetouchinterest(hrp,p,0)
						task.wait(0.1)
						firetouchinterest(hrp,p,1)
						if filter=="autocheckpoint" then task.wait(1) end
					end
				end
			end
		end
	end)
end

CommandHandlers.autopowerup = function()
	states.autopowerup = not states.autopowerup
	if states.autopowerup then touchLoop("autopowerup") end
	notify("AutoPowerup", states.autopowerup and "ON" or "OFF", 3)
end

CommandHandlers.autocheckpoint = function()
	states.autocheckpoint = not states.autocheckpoint
	if states.autocheckpoint then touchLoop("autocheckpoint") end
	notify("AutoCheckpoint", states.autocheckpoint and "ON" or "OFF", 3)
end

--------------------------------------------------------------------
-- COMMAND RUNNER
--------------------------------------------------------------------
local function runCmd(text)
	local args = text:lower():split(" ")
	local cmd = table.remove(args,1)
	local fn = CommandHandlers[cmd]
	if not fn then return notify("Error","Unknown command",3) end
	fn(args)
end

--------------------------------------------------------------------
-- GUI (UNCHANGED)
--------------------------------------------------------------------
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "BlueCommandGui"
gui.ResetOnSpawn = false

local barBorder = Instance.new("Frame", gui)
barBorder.Size = UDim2.new(0,308,0,38)
barBorder.Position = UDim2.new(0.5,-154,0,40)
barBorder.BackgroundColor3 = Color3.fromRGB(0,60,200)
barBorder.BorderSizePixel = 0
barBorder.Active = true
barBorder.Draggable = true
Instance.new("UICorner", barBorder).CornerRadius = UDim.new(0,12)

local bar = Instance.new("Frame", barBorder)
bar.Size = UDim2.new(0,300,0,30)
bar.Position = UDim2.new(0,4,0,4)
bar.BackgroundColor3 = Color3.fromRGB(25,25,35)
bar.BorderSizePixel = 0
Instance.new("UICorner", bar).CornerRadius = UDim.new(0,10)

local cmdBox = Instance.new("TextBox", bar)
cmdBox.Size = UDim2.new(1,-48,1,-8)
cmdBox.Position = UDim2.new(0,6,0,4)
cmdBox.BackgroundTransparency = 1
cmdBox.Text = ""               -- FIX
cmdBox.PlaceholderText = ""    -- FIX
cmdBox.Font = Enum.Font.Gotham
cmdBox.TextColor3 = Color3.fromRGB(240,240,255)
cmdBox.TextSize = 15
cmdBox.ClearTextOnFocus = false

local menuBtn = Instance.new("TextButton", bar)
menuBtn.Size = UDim2.new(0,30,1,-8)
menuBtn.Position = UDim2.new(1,-36,0,4)
menuBtn.BackgroundColor3 = Color3.fromRGB(0,60,200)
menuBtn.Text = "≡"
menuBtn.Font = Enum.Font.GothamBold
menuBtn.TextColor3 = Color3.new(1,1,1)
menuBtn.TextSize = 18
Instance.new("UICorner", menuBtn).CornerRadius = UDim.new(0,8)

local listBorder = Instance.new("Frame", gui)
listBorder.Size = UDim2.new(0,268,0,160)
listBorder.Position = UDim2.new(0.5,-134,0,86)
listBorder.BackgroundColor3 = Color3.fromRGB(0,60,200)
listBorder.BorderSizePixel = 0
listBorder.Visible = false
Instance.new("UICorner", listBorder).CornerRadius = UDim.new(0,12)

local listFrame = Instance.new("Frame", listBorder)
listFrame.Size = UDim2.new(1,-8,1,-8)
listFrame.Position = UDim2.new(0,4,0,4)
listFrame.BackgroundColor3 = Color3.fromRGB(25,25,35)
listFrame.BorderSizePixel = 0
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0,10)

local scroll = Instance.new("ScrollingFrame", listFrame)
scroll.Size = UDim2.new(1,-12,1,-12)
scroll.Position = UDim2.new(0,6,0,6)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 8
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)

for _, c in ipairs(commands) do
	local b = Instance.new("TextButton", scroll)
	b.Size = UDim2.new(1,-10,0,30)
	b.Text = "!"..c
	b.BackgroundColor3 = Color3.fromRGB(35,35,55)
	b.TextColor3 = Color3.fromRGB(200,220,255)
	b.Font = Enum.Font.Gotham
	b.TextSize = 16
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	b.MouseButton1Click:Connect(function()
		cmdBox.Text = "!"..c.." "
		cmdBox:CaptureFocus()
	end)
end

menuBtn.MouseButton1Click:Connect(function()
	listBorder.Visible = not listBorder.Visible
end)

cmdBox.FocusLost:Connect(function(enter)
	if enter then
		local raw = cmdBox.Text:gsub("^!+","")
		cmdBox.Text = ""
		runCmd(raw)
	end
end)
