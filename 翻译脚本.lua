-- Boxiu Translator Ultimate
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local TranslationDictionary = {
    ["en"] = {["Welcome"] = "Hello Player!", ["Start"] = "Start Game"},
    ["zh-cn"] = {["Welcome"] = "欢迎玩家！", ["Start"] = "开始游戏"}
}
local currentLanguage = "en"

local function safeCall(f, ...) pcall(f, ...) end

local function TranslateKey(k)
    local t = TranslationDictionary[currentLanguage]
    return t and t[k] or k
end

local function TranslateAllUI()
    if not player.PlayerGui then return end
    for _, v in pairs(player.PlayerGui:GetDescendants()) do
        safeCall(function()
            if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                v.Text = TranslateKey(v.Name)
            end
        end)
    end
end

-- 防删除：循环重建
local function CreateUI()
    safeCall(function()
        if player.PlayerGui:FindFirstChild("BoxiuUI") then return end

        local mainFrame = Instance.new("ScreenGui")
        mainFrame.Name = "BoxiuUI"
        mainFrame.Parent = player.PlayerGui
        mainFrame.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        mainFrame.ResetOnSpawn = false

        local bg = Instance.new("Frame")
        bg.Parent = mainFrame
        bg.Size = UDim2.new(0,260,0,190)
        bg.Position = UDim2.new(0.1,0,0.1,0)
        bg.BackgroundColor3 = Color3.new(0.12,0.12,0.12)

        local title = Instance.new("TextLabel")
        title.Parent = bg
        title.Size = UDim2.new(1,0,0,30)
        title.BackgroundColor3 = Color3.new(0.18,0.18,0.18)
        title.Text = "Boxiu Translator"
        title.TextColor3 = Color3.new(1,1,1)

        local closeBtn = Instance.new("TextButton")
        closeBtn.Parent = title
        closeBtn.Size = UDim2.new(0,26,0,26)
        closeBtn.Position = UDim2.new(1,-30,0.5,-13)
        closeBtn.BackgroundColor3 = Color3.new(0.8,0,0)
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.new(1,1,1)
        closeBtn.MouseButton1Click:Connect(function()
            mainFrame:Destroy()
        end)

        local zhBtn = Instance.new("TextButton")
        zhBtn.Parent = bg
        zhBtn.Size = UDim2.new(0.42,0,0,32)
        zhBtn.Position = UDim2.new(0.06,0,0.32,0)
        zhBtn.BackgroundColor3 = Color3.new(0.22,0.22,0.62)
        zhBtn.Text = "中文"
        zhBtn.TextColor3 = Color3.new(1,1,1)
        zhBtn.MouseButton1Click:Connect(function()
            currentLanguage = "zh-cn"
            TranslateAllUI()
        end)

        local enBtn = Instance.new("TextButton")
        enBtn.Parent = bg
        enBtn.Size = UDim2.new(0.42,0,0,32)
        enBtn.Position = UDim2.new(0.52,0,0.32,0)
        enBtn.BackgroundColor3 = Color3.new(0.22,0.22,0.62)
        enBtn.Text = "English"
        enBtn.TextColor3 = Color3.new(1,1,1)
        enBtn.MouseButton1Click:Connect(function()
            currentLanguage = "en"
            TranslateAllUI()
        end)

        local transBtn = Instance.new("TextButton")
        transBtn.Parent = bg
        transBtn.Size = UDim2.new(0.88,0,0,36)
        transBtn.Position = UDim2.new(0.06,0,0.62,0)
        transBtn.BackgroundColor3 = Color3.new(0.22,0.62,0.22)
        transBtn.Text = "Translate"
        transBtn.TextColor3 = Color3.new(1,1,1)
        transBtn.MouseButton1Click:Connect(TranslateAllUI)

        -- 拖拽
        local dragging, dragStart, startPos
        title.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true dragStart = i.Position startPos = bg.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - dragStart
                bg.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        -- F9 开关
        UserInputService.InputBegan:Connect(function(i)
            if i.KeyCode == Enum.KeyCode.F9 then
                mainFrame.Enabled = not mainFrame.Enabled
            end
        end)
    end)
end

-- 防删除核心：每0.5秒检查一次，没了就重建
task.spawn(function()
    while task.wait(0.5) do
        CreateUI()
    end
end)

safeCall(TranslateAllUI)
