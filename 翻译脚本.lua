-- Boxiu Translator v6.1 Final
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local PlayerPrefs = game:GetService("PlayerPrefs")
local player = Players.LocalPlayer

local MockData = {
    ["en"] = {["Welcome"] = "Hello Player!"; ["Start"] = "Start Game";},
    ["zh-cn"] = {["Welcome"] = "欢迎玩家！"; ["Start"] = "开始游戏";}
}

local TranslationDictionary = {}
local currentLanguage = PlayerPrefs:GetString("BoxiuLang", "en")

local function safeCall(func, ...)
    pcall(func, ...)
end

local function LoadTranslations(langCode)
    if MockData[langCode] then
        TranslationDictionary[langCode] = MockData[langCode]
    end
end

local oldUI = player.PlayerGui:FindFirstChild("BoxiuUI")
if oldUI then oldUI:Destroy() end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "BoxiuUI"
mainFrame.Parent = player.PlayerGui
mainFrame.ZIndex = 999
mainFrame.Size = UDim2.new(0,260,0,190)
mainFrame.Position = UDim2.new(0.1,0,0.1,0)
mainFrame.BackgroundColor3 = Color3.new(0.12,0.12,0.12)
mainFrame.Active = true
mainFrame.Visible = true

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.new(0.18,0.18,0.18)
title.Text = "Boxiu 翻译器 v6.1"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 14

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = title
closeBtn.Size = UDim2.new(0,26,0,26)
closeBtn.Position = UDim2.new(1,-30,0.5,-13)
closeBtn.BackgroundColor3 = Color3.new(0.8,0,0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

local zhBtn = Instance.new("TextButton")
zhBtn.Parent = mainFrame
zhBtn.Size = UDim2.new(0.42,0,0,32)
zhBtn.Position = UDim2.new(0.06,0,0.32,0)
zhBtn.BackgroundColor3 = Color3.new(0.22,0.22,0.62)
zhBtn.Text = "中文"
zhBtn.TextColor3 = Color3.new(1,1,1)
zhBtn.MouseButton1Click:Connect(function()
    currentLanguage = "zh-cn"
    PlayerPrefs:SetString("BoxiuLang","zh-cn")
    TranslateAllUI()
end)

local enBtn = Instance.new("TextButton")
enBtn.Parent = mainFrame
enBtn.Size = UDim2.new(0.42,0,0,32)
enBtn.Position = UDim2.new(0.52,0,0.32,0)
enBtn.BackgroundColor3 = Color3.new(0.22,0.22,0.62)
enBtn.Text = "English"
enBtn.TextColor3 = Color3.new(1,1,1)
enBtn.MouseButton1Click:Connect(function()
    currentLanguage = "en"
    PlayerPrefs:SetString("BoxiuLang","en")
    TranslateAllUI()
end)

local transBtn = Instance.new("TextButton")
transBtn.Parent = mainFrame
transBtn.Size = UDim2.new(0.88,0,0,36)
transBtn.Position = UDim2.new(0.06,0,0.62,0)
transBtn.BackgroundColor3 = Color3.new(0.22,0.62,0.22)
transBtn.Text = "一键翻译"
transBtn.TextColor3 = Color3.new(1,1,1)
transBtn.MouseButton1Click:Connect(function()
    TranslateAllUI()
end)

local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F9 then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

local function TranslateKey(key)
    local t = TranslationDictionary[currentLanguage]
    return t and t[key] or key
end

function TranslateAllUI()
    if not player.PlayerGui then return end
    for _,v in pairs(player.PlayerGui:GetDescendants()) do
        safeCall(function()
            if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                v.Text = TranslateKey(v.Name)
            end
        end)
    end
end

LoadTranslations("en")
LoadTranslations("zh-cn")
safeCall(TranslateAllUI)
