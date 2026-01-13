--[[
Key System + Pastebin Loader Integration (24h per-use, 7d per-key cooldown)
- The script blocks access to the main Pastebin loader until the key is entered and either counting down or active.
- After successful key activation, loads and executes your Pastebin script.
- On rejoin/reload: if key is valid, auto-loads Pastebin; if key is pending, waits for user to enter it.
- NO autofill or auto-paste of key on join. User must enter it.
- Change PASTEBIN_RAW_URL below to your own Pastebin raw link.
]]

------------------- CONFIG -------------------
local PASTEBIN_RAW_URL = "https://pastebin.com/raw/2zhEEipn" -- <-- Set your pastebin raw link here
local LICENSE_DURATION = 24 * 60 * 60 -- 24 hours
local COOLDOWN = 7 * 24 * 60 * 60    -- 7 days in seconds
local KEY_FILE = "keysystem_userdata_main.json"
local USAGE_FILE = "keysystem_usage_main.json"

local Keys = {
    {key = "F8B2Q7W1XR", linkvertise = "https://direct-link.net/1198587/key"},
    {key = "9JZK5VU2SM", linkvertise = "https://link-target.net/1198587/key1"},
    {key = "XW2C3R8T1P", linkvertise = "https://direct-link.net/1198587/key2"},
    {key = "7QH5M2L9AZ", linkvertise = "https://link-center.net/1198587/key3"},
    {key = "Z48D1P7KSR", linkvertise = "https://link-hub.net/1198587/key4"},
    {key = "M5XJ8Q2BZN", linkvertise = "https://link-target.net/1198587/key5"},
    -- ... add more keys as desired!
}

------------------- SERVICES/UTILS -------------------
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RUN_SERVICE = game:GetService("RunService")
local function fetchPastebinAndRun()
    local suc, resp = pcall(function()
        if syn and syn.request then
            return syn.request({Url=PASTEBIN_RAW_URL, Method="GET"})
        elseif http_request then
            return http_request({Url=PASTEBIN_RAW_URL, Method="GET"})
        elseif request then
            return request({Url=PASTEBIN_RAW_URL, Method="GET"})
        elseif getcustomasset then -- Some environments
            return {Body = game:HttpGet(PASTEBIN_RAW_URL)}
        else
            return {Body = game:HttpGet(PASTEBIN_RAW_URL)}
        end
    end)
    if suc and resp and (resp.Body or type(resp)=="string") then
        local src = resp.Body or resp
        local f, ferr = loadstring(src)
        if f then
            f()
        else
            warn("[KeySystem] Error loading pastebin: "..tostring(ferr))
        end
    else
        warn("[KeySystem] Failed to fetch pastebin: "..tostring(resp))
    end
end

local function saveKeyData(key, activatedAt, expiresAt)
    if writefile then
        local data = {
            UserId = LocalPlayer.UserId,
            Key = key,
            ActivatedAt = activatedAt,
            ExpiresAt = expiresAt
        }
        writefile(KEY_FILE, HttpService:JSONEncode(data))
    end
end

local function loadKeyData()
    if readfile and isfile and isfile(KEY_FILE) then
        local data = HttpService:JSONDecode(readfile(KEY_FILE))
        return data.Key, data.ActivatedAt, data.ExpiresAt, data.UserId
    end
    return nil, nil, nil, nil
end

local function clearKeyData()
    if delfile and isfile and isfile(KEY_FILE) then
        delfile(KEY_FILE)
    end
end

local function loadUsageData()
    if readfile and isfile and isfile(USAGE_FILE) then
        return HttpService:JSONDecode(readfile(USAGE_FILE))
    end
    return {}
end

local function saveUsageData(usage)
    if writefile then
        writefile(USAGE_FILE, HttpService:JSONEncode(usage))
    end
end

local function formatTimeLeft(secs)
    if not secs or secs <= 0 then return "Expired" end
    local h = math.floor(secs/3600)
    local m = math.floor((secs%3600)/60)
    local s = math.floor(secs%60)
    return string.format("%02dh %02dm %02ds", h, m, s)
end

local function findLinkForKey(key)
    for _, k in ipairs(Keys) do
        if k.key == key then
            return k.linkvertise
        end
    end
end

local function getAvailableKeyForUser(userId)
    local now = os.time()
    local usage = loadUsageData()
    local userUsage = usage[userId] or {}
    local available = {}
    for _, keyInfo in ipairs(Keys) do
        local lastUsed = userUsage[keyInfo.key] or 0
        if (now - lastUsed) > COOLDOWN then
            table.insert(available, keyInfo)
        end
    end
    if #available > 0 then
        return available[1]
    end
    return nil
end

local function markKeyAsUsed(userId, key)
    local usage = loadUsageData()
    usage[userId] = usage[userId] or {}
    usage[userId][key] = os.time()
    saveUsageData(usage)
end

------------------- GUI -------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeySystemMain"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 360)
frame.Position = UDim2.new(0.5, -170, 0.5, -180)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 26
title.Text = "Key System"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = frame

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0.8, 0, 0, 36)
keyBox.Position = UDim2.new(0.1, 0, 0.23, 0)
keyBox.PlaceholderText = "Enter your key here"
keyBox.Text = ""
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 18
keyBox.TextColor3 = Color3.fromRGB(0, 0, 0)
keyBox.BackgroundColor3 = Color3.fromRGB(220,220,220)
keyBox.Parent = frame

local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(0.35, 0, 0, 32)
submitBtn.Position = UDim2.new(0.1, 0, 0.42, 0)
submitBtn.Text = "Submit Key"
submitBtn.Font = Enum.Font.GothamBold
submitBtn.TextSize = 18
submitBtn.TextColor3 = Color3.fromRGB(255,255,255)
submitBtn.BackgroundColor3 = Color3.fromRGB(32, 146, 67)
submitBtn.Parent = frame

local getKeyBtn = Instance.new("TextButton")
getKeyBtn.Size = UDim2.new(0.35, 0, 0, 32)
getKeyBtn.Position = UDim2.new(0.55, 0, 0.42, 0)
getKeyBtn.Text = "Get Key"
getKeyBtn.Font = Enum.Font.GothamBold
getKeyBtn.TextSize = 18
getKeyBtn.TextColor3 = Color3.fromRGB(255,255,255)
getKeyBtn.BackgroundColor3 = Color3.fromRGB(13, 105, 172)
getKeyBtn.Parent = frame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0.8, 0, 0, 60)
infoLabel.Position = UDim2.new(0.1, 0, 0.62, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 18
infoLabel.TextColor3 = Color3.fromRGB(255,255,255)
infoLabel.Text = ""
infoLabel.TextWrapped = true
infoLabel.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0, 6)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
closeBtn.Parent = frame

------------------- LOGIC -------------------
local countdownConnection = nil
local pastebinLoaded = false

local function stopCountdown()
    if countdownConnection then
        countdownConnection:Disconnect()
        countdownConnection = nil
    end
end

local function startCountdown(expiresAt)
    stopCountdown()
    countdownConnection = RUN_SERVICE.RenderStepped:Connect(function()
        local now = os.time()
        local timeLeft = expiresAt - now
        if timeLeft > 0 then
            infoLabel.Text = "Key valid!\nTime left: " .. formatTimeLeft(timeLeft)
            infoLabel.TextColor3 = Color3.fromRGB(80,255,80)
            -- Load Pastebin if not yet loaded
            if not pastebinLoaded then
                pastebinLoaded = true
                screenGui.Enabled = false -- Hide key GUI
                fetchPastebinAndRun()
            end
        else
            infoLabel.Text = "Key expired. Please get a new key."
            infoLabel.TextColor3 = Color3.fromRGB(255,80,80)
            clearKeyData()
            pastebinLoaded = false
            screenGui.Enabled = true
            stopCountdown()
        end
    end)
end

getKeyBtn.MouseButton1Click:Connect(function()
    local userId = tostring(LocalPlayer.UserId)
    local savedKey, activatedAt, expiresAt, savedUserId = loadKeyData()
    local now = os.time()
    if savedKey and not expiresAt then
        -- Reminder: Copy the link for their pending key again
        local link = findLinkForKey(savedKey)
        infoLabel.Text = "You already have a key ready. Click 'Get Key' to copy your link again."
        infoLabel.TextColor3 = Color3.fromRGB(255, 230, 80)
        if setclipboard and link then
            setclipboard(link)
        end
        return
    elseif savedKey and expiresAt and expiresAt > now then
        infoLabel.Text = "Key valid! Time left: " .. formatTimeLeft(expiresAt - now)
        infoLabel.TextColor3 = Color3.fromRGB(80,255,80)
        return
    end

    local keyInfo = getAvailableKeyForUser(userId)
    if not keyInfo then
        infoLabel.Text = "All keys are on cooldown!\nYou must wait before getting a new key."
        infoLabel.TextColor3 = Color3.fromRGB(255,80,80)
        return
    end
    saveKeyData(keyInfo.key, nil, nil)
    infoLabel.Text = "Linkvertise link copied!\nComplete Linkvertise to get your key."
    infoLabel.TextColor3 = Color3.fromRGB(80,255,80)
    if setclipboard then
        setclipboard(keyInfo.linkvertise)
    end
end)

submitBtn.MouseButton1Click:Connect(function()
    local enteredKey = keyBox.Text
    local userId = tostring(LocalPlayer.UserId)
    local savedKey, activatedAt, expiresAt, savedUserId = loadKeyData()
    local now = os.time()
    if not savedKey then
        infoLabel.Text = "No key assigned. Please get a key first."
        infoLabel.TextColor3 = Color3.fromRGB(255,80,80)
        return
    end
    if savedKey ~= enteredKey then
        infoLabel.Text = "Key does not match your assigned key."
        infoLabel.TextColor3 = Color3.fromRGB(255,80,80)
        return
    end
    if expiresAt and expiresAt > now then
        infoLabel.Text = "Key already activated!\nTime left: " .. formatTimeLeft(expiresAt - now)
        infoLabel.TextColor3 = Color3.fromRGB(80,255,80)
        if not pastebinLoaded then
            pastebinLoaded = true
            screenGui.Enabled = false
            fetchPastebinAndRun()
        end
        startCountdown(expiresAt)
        return
    end
    local expire = now + LICENSE_DURATION
    saveKeyData(savedKey, now, expire)
    markKeyAsUsed(userId, savedKey)
    infoLabel.Text = "Key activated! Time left: " .. formatTimeLeft(LICENSE_DURATION)
    infoLabel.TextColor3 = Color3.fromRGB(80,255,80)
    pastebinLoaded = true
    screenGui.Enabled = false
    fetchPastebinAndRun()
    startCountdown(expire)
end)

closeBtn.MouseButton1Click:Connect(function()
    stopCountdown()
    screenGui:Destroy()
end)

local function showTimeOnJoin()
    local key, activatedAt, expiresAt, savedUserId = loadKeyData()
    local now = os.time()
    keyBox.Text = ""
    pastebinLoaded = false
    if key and expiresAt and expiresAt > now then
        infoLabel.Text = "Key valid! Time left: " .. formatTimeLeft(expiresAt - now)
        infoLabel.TextColor3 = Color3.fromRGB(80,255,80)
        pastebinLoaded = true
        screenGui.Enabled = false
        fetchPastebinAndRun()
        startCountdown(expiresAt)
    elseif key and not expiresAt then
        infoLabel.Text = "You already have a key ready. Click 'Get Key' to copy your link again."
        infoLabel.TextColor3 = Color3.fromRGB(255,255,0)
        -- Optionally: copy link again for convenience
        local link = findLinkForKey(key)
        if setclipboard and link then setclipboard(link) end
    elseif key and expiresAt then
        infoLabel.Text = "Key expired. Please get a new key."
        infoLabel.TextColor3 = Color3.fromRGB(255,80,80)
        clearKeyData()
        stopCountdown()
    end
end

showTimeOnJoin()
