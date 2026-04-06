-- Hi don't look at the code it is trash just use it :)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local RunService = game:GetService("RunService")
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local plr = players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = plr:GetMouse()

--> [< Variables >] <--

local hue = 0
local rainbowFov = false
local rainbowSpeed = 0.005

local aimFov = 100
local aiming = false
local predictionStrength = 0.065

local gmEnabled = false

local fireRate = 0.3
local pelletAmount = 1
local reloadTime = 0
local damageDropOff = 0
local isAuto = true
local delayedShell = false
local recoilEnabled = false
local Recoil = Vector3.new(0, 0, 0)
local viewmodelEnabled = false
local viewModelOffset = Vector3.new(0.1, -1.7, 0)

local hitEffectEnabled = false
local aimbotEnabled = false

local hitEffect = "Gib_F"

local e = false

--> [< Variables >] <--

local Window = Rayfield:CreateWindow({
	Name = "▶ Gun Grounds FFA ◀",
	LoadingTitle = "Loading...",
	LoadingSubtitle = "by Agreed 🥵",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "GunGroundsFFA",
		FileName = "byAgreed"
	},
})

local Main = Window:CreateTab("Gun Mods 🔫")
local Aimbot = Window:CreateTab("Aimbot 🎯")
local ViewModel = Window:CreateTab("Viewmodel 👀")

--> [< Gun Mods >] <--

local forcereset = Main:CreateKeybind({
	Name = "Force Reset",
	CurrentKeybind = "T",
	HoldToInteract = false,
	Flag = "ForceReset",
	Callback = function(Keybind)
        if plr.Character then
            plr.Character.Humanoid:TakeDamage(plr.Character.Humanoid.Health)
            Rayfield:Notify({
                Title = "Force Reset",
                Content = "Done!",
                Duration = 1,
                Image = 4483362458,
            })
        end
	end,
})

local gunmods = Main:CreateToggle({
    Name = "Gun Mods Enabled",
    CurrentValue = false,
    Flag = "GunModsEnabled",
    Callback = function(Value)
        gmEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Gun Mod",
                Content = "Reset to enable!",
                Duration = 1,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = "Gun Mod",
                Content = "Reset to disable!",
                Duration = 1,
                Image = 4483362458,
            })
        end
        while gmEnabled do
            if plr.Character then
                local folder = plr.Character:FindFirstChildWhichIsA("Tool")
                
                if folder and folder:FindFirstChild("Configuration") then
                    for _, v in ipairs(folder.Configuration:GetChildren()) do
                        if v.Name == "FireRate" and not e then
                            e = true
                            v.Value = v.Value * fireRate
                        end
                        if v.Name == "reloadTime" then
                            v.Value = reloadTime
                        end
                        if v.Name == "DamageDropoff" then
                            v.Value = damageDropOff
                        end
                        if v.Name == "isAuto" then
                            v.Value = isAuto
                        end
                        if v.Name == "DelayedShell" then
                            v.Value = delayedShell
                        end
                        if v.Name == "Recoil" then
                            if recoilEnabled then
                                v.Value = Recoil
                            end
                        end
                    end
                    if hitEffectEnabled then
                        local heffect = folder.Configuration:FindFirstChild("HitEffect")
                        if heffect then
                            heffect.Value = hitEffect
                        else
                            heffect = Instance.new("StringValue")
                            heffect.Name = "HitEffect"
                            heffect.Value = hitEffect
                            heffect.Parent = folder.Configuration
                        end
                    end
                else
                    e = false
                end
            end
            wait()
        end 
    end
})

local firerate = Main:CreateSlider({
	Name = "Fire Rate",
	Range = {0, 1},
	Increment = 0.1,
	CurrentValue = 0.3,
	Flag = "FireRate",
	Callback = function(Value)
        fireRate = Value
        Rayfield:Notify({
            Title = "Fire Rate",
            Content = "Reset to update!",
            Duration = 1,
            Image = 4483362458,
        })
	end,
})

local reloadtime = Main:CreateSlider({
	Name = "Reload Time",
	Range = {0, 100},
	Increment = 1,
	CurrentValue = 0,
	Flag = "ReloadTime",
	Callback = function(Value)
        reloadTime = Value
        Rayfield:Notify({
            Title = "Reload Time",
            Content = "Reset to update!",
            Duration = 1,
            Image = 4483362458,
        })
	end,
})

local dmgdropoff = Main:CreateSlider({
	Name = "Damage Drop Off",
	Range = {0, 100},
	Increment = 1,
	CurrentValue = 0,
	Flag = "DamageDropOff",
	Callback = function(Value)
        damageDropOff = Value
        Rayfield:Notify({
            Title = "Damage Drop Off",
            Content = "Reset to update!",
            Duration = 1,
            Image = 4483362458,
        })
	end,
})

local forceauto = Main:CreateToggle({
    Name = "Force Auto",
    CurrentValue = true,
    Flag = "ForceAuto",
    Callback = function(Value)
        isAuto = Value
        Rayfield:Notify({
            Title = "Force Auto",
            Content = "Reset to update!",
            Duration = 1,
            Image = 4483362458,
        })
    end
})

local rapidshotguns = Main:CreateToggle({
    Name = "Rapid Shotguns",
    CurrentValue = true,
    Flag = "RapidShotguns",
    Callback = function(Value)
        delayedShell = not Value
        Rayfield:Notify({
            Title = "Rapid Shotguns",
            Content = "Reset to update!",
            Duration = 1,
            Image = 4483362458,
        })
    end
})

local recoilmodifier = Main:CreateToggle({
    Name = "Recoil Modifier",
    CurrentValue = false,
    Flag = "RecoilModifier",
    Callback = function(Value)
        recoilEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Recoil Modifier",
                Content = "Reset to enable!",
                Duration = 1,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = "Recoil Modifier",
                Content = "Reset to disable!",
                Duration = 1,
                Image = 4483362458,
            })
        end
    end
})

local recoilx = Main:CreateSlider({
	Name = "Recoil X",
	Range = {0, 100},
	Increment = 1,
	CurrentValue = 0,
	Flag = "RecoilX",
	Callback = function(Value)
        Recoil = Vector3.new(Value, Recoil.Y, Recoil.Z)
        Rayfield:Notify({
            Title = "Recoil X",
            Content = "Reset to update!",
            Duration = 1,
            Image = 4483362458,
        })
	end,
})

local recoily = Main:CreateSlider({
	Name = "Recoil Y",
	Range = {0, 100},
	Increment = 1,
	CurrentValue = 0,
	Flag = "RecoilY",
	Callback = function(Value)
        Recoil = Vector3.new(Recoil.X, Value, Recoil.Z)
        Rayfield:Notify({
            Title = "Recoil Y",
            Content = "Reset to update!",
            Duration = 1,
            Image = 4483362458,
        })
	end,
})

local recoilz = Main:CreateSlider({
	Name = "Recoil Z",
	Range = {0, 100},
	Increment = 1,
	CurrentValue = 0,
	Flag = "RecoilZ",
	Callback = function(Value)
        Recoil = Vector3.new(Recoil.X, Recoil.Y, Value)
        Rayfield:Notify({
            Title = "Recoil Z",
            Content = "Reset to update!",
            Duration = 1,
            Image = 4483362458,
        })
	end,
})

local hiteffectE = Main:CreateToggle({
    Name = "Hit Effect [FE]",
    CurrentValue = false,
    Flag = "HitEffectEnabled",
    Callback = function(Value)
        hitEffectEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Hit Effect",
                Content = "Reset to enable!",
                Duration = 1,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = "Hit Effect",
                Content = "Reset to disable!",
                Duration = 1,
                Image = 4483362458,
            })
        end
    end
})

local hiteffect = Main:CreateDropdown({
	Name = "Select Hit Effect",
	Options = {"Gib_W", "Gib_G", "Gib_H", "Gib_T", "Gib_F"},
	CurrentOption = "Gib_F",
	Flag = "HitEffect",
	Callback = function(Option)
        if type(Option) == "table" then
            hitEffect = Option[1]
        else
            hitEffect = Option
        end
        Rayfield:Notify({
            Title = "Hit Effect",
            Content = "Reset to update!",
            Duration = 1,
            Image = 4483362458,
        })
	end,
})

--> [< Gun Mods >] <--

--> [< Aimbot >] <--

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 12
fovCircle.Radius = aimFov
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(255, 0, 0)
fovCircle.Visible = false

local currentTarget = nil

local function isWallBetween(targetCharacter)
    local targetHead = targetCharacter:FindFirstChild("Head")
    if not targetHead then return true end

    local origin = camera.CFrame.Position
    local direction = (targetHead.Position - origin).unit * (targetHead.Position - origin).magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {plr.Character, targetCharacter}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    return raycastResult and raycastResult.Instance ~= nil
end

local function getNearestPlayer()
    local nearestPlayer = nil
    local shortestCursorDistance = aimFov
    local shortestPlayerDistance = math.huge
    local cameraPos = camera.CFrame.Position

    for _, player in ipairs(players:GetPlayers()) do
        if player ~= plr and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local headPos = camera:WorldToViewportPoint(head.Position)
            local screenPos = Vector2.new(headPos.X, headPos.Y)
            local mousePos = Vector2.new(mouse.X, mouse.Y)
            local cursorDistance = (screenPos - mousePos).Magnitude
            local playerDistance = (head.Position - cameraPos).Magnitude

            if cursorDistance < shortestCursorDistance and headPos.Z > 0 then
                if not isWallBetween(player.Character) then
                    if playerDistance < shortestPlayerDistance then
                        shortestPlayerDistance = playerDistance
                        shortestCursorDistance = cursorDistance
                        nearestPlayer = player
                    end
                end
            end
        end
    end

    return nearestPlayer
end

local function predictPlayerPosition(player)
    if player and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("HumanoidRootPart") then
        local head = player.Character.Head
        local hrp = player.Character.HumanoidRootPart
        local velocity = hrp.Velocity
        local predictedPosition = head.Position + (velocity * predictionStrength)
        return predictedPosition
    end
    return nil
end

local function aimAtPlayer(player)
    local predictedPosition = predictPlayerPosition(player)
    if predictedPosition then
        camera.CFrame = CFrame.new(camera.CFrame.Position, predictedPosition)
    end
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local offset = 50
        fovCircle.Position = Vector2.new(mouse.X, mouse.Y + offset)

        if rainbowFov then
            hue = hue + rainbowSpeed
            if hue > 1 then hue = 0 end
            fovCircle.Color = Color3.fromHSV(hue, 1, 1)
        end

        if aiming then
            if currentTarget and isWallBetween(currentTarget.Character) then
                currentTarget = nil
            end

            if not currentTarget then
                currentTarget = getNearestPlayer()
            end

            if currentTarget then
                aimAtPlayer(currentTarget)
            end
        else
            currentTarget = nil
        end
    end
end)

mouse.Button2Down:Connect(function()
    if aimbotEnabled then
        aiming = true
    end
end)

mouse.Button2Up:Connect(function()
    if aimbotEnabled then
        aiming = false
    end
end)

local aimbot = Aimbot:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(Value)
        aimbotEnabled = Value
        fovCircle.Visible = Value
    end
})

local aimbotfov = Aimbot:CreateSlider({
	Name = "Aimbot Fov",
	Range = {0, 360},
	Increment = 1,
	CurrentValue = 100,
	Flag = "AimbotFov",
	Callback = function(Value)
        aimFov = Value
        fovCircle.Radius = aimFov
	end,
})

local circlecolor = Aimbot:CreateColorPicker({
    Name = "Fov Color",
    Color = fovCircle.Color,
    Callback = function(Color)
        fovCircle.Color = Color
    end
})

local circlerainbow = Aimbot:CreateToggle({
    Name = "Rainbow Fov",
    CurrentValue = false,
    Flag = "RainbowFov",
    Callback = function(Value)
        rainbowFov = Value
    end
})

local rainbowspeed = Aimbot:CreateSlider({
	Name = "Rainbow Speed",
	Range = {1, 10},
	Increment = 1,
	CurrentValue = 5,
	Flag = "RainbowSpeed",
	Callback = function(Value)
        rainbowSpeed = Value * 0.001
	end,
})

local predictionstrength = Aimbot:CreateSlider({
	Name = "Prediction Strength",
	Range = {0, 20},
	Increment = 0.1,
	CurrentValue = 6.5,
	Flag = "AimbotStrength",
	Callback = function(Value)
        predictionStrength = Value * 0.001
	end,
})

--> [< Aimbot >] <--

--> [< View Model Offset >] <--

local viewmodeleditor = ViewModel:CreateToggle({
    Name = "View Model Editor",
    CurrentValue = false,
    Flag = "RecoilModifier",
    Callback = function(Value)
        viewmodelEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "View Model Editor",
                Content = "Reset to enable!",
                Duration = 1,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = "View Model Editor",
                Content = "Reset to disable!",
                Duration = 1,
                Image = 4483362458,
            })
        end
        while viewmodelEnabled do
            if plr.Character then
                local folder = plr.Character:FindFirstChildWhichIsA("Tool")
                
                if folder and folder:FindFirstChild("Configuration") then
                    for _, v in ipairs(folder.Configuration:GetChildren()) do
                        if v.Name == "ViewModelOffset" then
                            if viewmodelEnabled then
                                v.Value = viewModelOffset
                            end
                        end
                    end
                end
            end
            wait()
        end
    end
})

local viewmodelz = ViewModel:CreateSlider({
	Name = "View Model X",
	Range = {-10, 10},
	Increment = 1,
	CurrentValue = 0,
	Flag = "ViewModelX",
	Callback = function(Value)
        viewModelOffset = Vector3.new(Value, viewModelOffset.Y, viewModelOffset.Z)
        Rayfield:Notify({
            Title = "View Model X",
            Content = "Reset to update!",
            Duration = 1,
            Image = 4483362458,
        })
	end,
})

local viewmodely = ViewModel:CreateSlider({
	Name = "View Model Y",
	Range = {-10, 10},
	Increment = 1,
	CurrentValue = -4,
	Flag = "ViewModelY",
	Callback = function(Value)
        viewModelOffset = Vector3.new(viewModelOffset.X, Value, viewModelOffset.Z)
        Rayfield:Notify({
            Title = "View Model Y",
            Content = "Reset to update!",
            Duration = 1,
            Image = 4483362458,
        })
	end,
})

local viewmodelz = ViewModel:CreateSlider({
	Name = "View Model Z",
	Range = {-10, 10},
	Increment = 1,
	CurrentValue = 0,
	Flag = "ViewModelZ",
	Callback = function(Value)
        viewModelOffset = Vector3.new(viewModelOffset.X, viewModelOffset.Y, Value)
        Rayfield:Notify({
            Title = "View Model Z",
            Content = "Reset to update!",
            Duration = 1,
            Image = 4483362458,
        })
	end,
})

--> [< View Model Offset >] <--
