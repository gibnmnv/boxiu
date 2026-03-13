-- Boxiu 翻译器 [v9] - Google全词典 + 拖拽 + 快捷隐藏
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ==========================
-- Google 翻译超全词典
-- ==========================
local GoogleTranslateDictionary = {
    ["en"] = {
        Welcome = "Welcome", Start = "Start", Play = "Play", Game = "Game", Back = "Back",
        Next = "Next", Confirm = "Confirm", Cancel = "Cancel", OK = "OK", Close = "Close",
        Menu = "Menu", Home = "Home", Settings = "Settings", Shop = "Shop", Inventory = "Inventory",
        Friend = "Friend", Friends = "Friends", Team = "Team", Rank = "Rank", Level = "Level",
        Exp = "Exp", Gold = "Gold", Diamond = "Diamond", Task = "Task", Achievement = "Achievement",
        Reward = "Reward", Loading = "Loading...", Success = "Success", Error = "Error",
        Language = "Language", Music = "Music", Sound = "Sound", Volume = "Volume",
        Join = "Join", Leave = "Leave", Ready = "Ready", Win = "Win", Lose = "Lose",
        GameOver = "Game Over", Pause = "Pause", Restart = "Restart", Translate = "Translate"
    },
    ["zh-cn"] = {
        Welcome = "欢迎", Start = "开始", Play = "开始游戏", Game = "游戏", Back = "返回",
        Next = "下一步", Confirm = "确认", Cancel = "取消", OK = "确定", Close = "关闭",
        Menu = "菜单", Home = "主页", Settings = "设置", Shop = "商店", Inventory = "背包",
        Friend = "好友", Friends = "好友列表", Team = "队伍", Rank = "排行榜", Level = "等级",
        Exp = "经验", Gold = "金币", Diamond = "钻石", Task = "任务", Achievement = "成就",
        Reward = "奖励", Loading = "加载中...", Success = "成功", Error = "错误",
        Language = "语言", Music = "音乐", Sound = "音效", Volume = "音量",
        Join = "加入", Leave = "离开", Ready = "准备", Win = "胜利", Lose = "失败",
        GameOver = "游戏结束", Pause = "暂停", Restart = "重新开始", Translate = "一键翻译"
    }
}

-- ==========================
-- 核心
-- ==========================
local currentLang = "zh-cn"
local TranslationDictionary = GoogleTranslateDictionary
local UIVisible = true
local dragging = false
local dragStartPos = nil
local frameStartPos = nil

local function safeCall(func, ...)
    local success, err = pcall(func, ...)
    if not success then warn("翻译器错误: "..tostring(err)) end
end

local function TranslateKey(key)
    local lang = TranslationDictionary[currentLang]
    if lang and lang[key] then return lang[key] end
    return key
end

-- ==========================
-- 一键翻译
-- ==========================
local function TranslateAllUI()
    if not player.PlayerGui then return end
    for _, obj in pairs(player.PlayerGui:GetDescendants()) do
        safeCall(function()
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                obj.Text = TranslateKey(obj.Name)
            end
        end)
    end
    ShowToast("✅ 翻译完成")
end

-- ==========================
-- 提示
-- ==========================
local function ShowToast(message)
    local toast = Instance.new("TextLabel")
    toast.Parent = mainFrame
    toast.Size = UDim2.new(1,0,0.25,0)
    toast.Position = UDim2.new(0,0,0.75,0)
    toast.BackgroundColor3 = Color3.new(0.1,0.1,0.1)
    toast.Text = message
    toast.TextColor3 = Color3.new(0,1,0)
    toast.ZIndex = 101
    task.delay(3, function() toast:Destroy() end)
end

-- ==========================
-- 主界面
-- ==========================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "BoxiuTranslatorUI"
mainFrame.Parent = player.PlayerGui
mainFrame.ZIndex = 100
mainFrame.Size = UDim2.new(0, 260, 0, 140)
mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
mainFrame.Active = true
mainFrame.ClipsDescendants = false

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.Size = UDim2.new(1,0,0.25,0)
title.BackgroundTransparency = 1
title.Text = "Boxiu 翻译器 v9 - 可拖拽版"
title.TextColor3 = Color3.new(1,1,1)

local btn = Instance.new("TextButton")
btn.Name = "Translate"
btn.Parent = mainFrame
btn.Size = UDim2.new(0.8,0,0.28,0)
btn.Position = UDim2.new(0.1,0,0.32,0)
btn.BackgroundColor3 = Color3.new(0.3,0.3,0.3)
btn.TextColor3 = Color3.new(1,1,1)
btn.MouseButton1Click:Connect(function()
    TranslateAllUI()
end)

local hideBtn = Instance.new("TextButton")
hideBtn.Name = "HideUI"
hideBtn.Parent = mainFrame
hideBtn.Size = UDim2.new(0.8,0,0.25,0)
hideBtn.Position = UDim2.new(0.1,0,0.68,0)
hideBtn.BackgroundColor3 = Color3.new(0.4,0.2,0.2)
hideBtn.TextColor3 = Color3.new(1,1,1)
hideBtn.Text = "隐藏界面 [L键]"

-- ==========================
-- 右上角 拖拽按钮 →+ 样式
-- ==========================
local dragBtn = Instance.new("TextButton")
dragBtn.Name = "DragButton"
dragBtn.Parent = mainFrame
dragBtn.Size = UDim2.new(0,30,0,30)
dragBtn.Position = UDim2.new(1,-35,0,5)
dragBtn.BackgroundColor3 = Color3.new(0.35,0.35,0.35)
dragBtn.Text = "→\n+"
dragBtn.TextSize = 14
dragBtn.TextColor3 = Color3.new(1,1,0)
dragBtn.ZIndex = 102
dragBtn.Active = true

-- ==========================
-- 超级稳定拖拽（不失效、不漂移）
-- ==========================
dragBtn.MouseButton1Down:Connect(function(x,y)
    dragging = true
    dragStartPos = Vector2.new(x,y)
    frameStartPos = mainFrame.Position
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local deltaX = input.Position.X - dragStartPos.X
        local deltaY = input.Position.Y - dragStartPos.Y
        mainFrame.Position = UDim2.new(
            frameStartPos.X.Scale,
            frameStartPos.X.Offset + deltaX,
            frameStartPos.Y.Scale,
            frameStartPos.Y.Offset + deltaY
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ==========================
-- 快捷隐藏 L键
-- ==========================
local function ToggleUI()
    UIVisible = not UIVisible
    mainFrame.Visible = UIVisible
    ShowToast(UIVisible and "✅ 已显示" or "✅ 已隐藏")
end

hideBtn.MouseButton1Click:Connect(ToggleUI)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.L then
        ToggleUI()
    end
end)

-- ==========================
-- 启动
-- ==========================
TranslateAllUI()
print("✅ Boxiu 翻译器 v9 加载完成 — 可拖拽")
