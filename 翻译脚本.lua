-- // 配置区域
local TARGET_LANG = "zh-CN"       -- 目标语言
local UI_THEME_COLOR = Color3.fromRGB(138, 43, 226) -- 紫色主题 (蓝紫色)
local UI_BG_COLOR = Color3.fromRGB(10, 10, 10)      -- 黑色背景 (接近纯黑)

-- // 服务引用
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- // 等待玩家加载
while not LocalPlayer do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- ==========================================
-- // UI 创建部分 (黑底紫边风格)
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TranslatorUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 主框架
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400) -- 宽度300, 高度400
MainFrame.Position = UDim2.new(0, 10, 0.5, -200) -- 屏幕左侧居中
MainFrame.BackgroundColor3 = UI_BG_COLOR
MainFrame.BorderSizePixel = 4 -- 边框厚度
MainFrame.BorderColor3 = UI_THEME_COLOR -- 紫色边框
MainFrame.Parent = ScreenGui

-- 标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- 稍微亮一点的黑色
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

-- 标题文字
local TitleLabel = Instance.new("Label")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0, 0)
TitleLabel.Text = "🌍 实时翻译器"
TitleLabel.TextColor3 = UI_THEME_COLOR
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- 滚动列表 (用于显示翻译内容)
local ScrollingList = Instance.new("ScrollingFrame")
ScrollingList.Name = "ScrollingList"
ScrollingList.Size = UDim2.new(1, -10, 1, -40) -- 减去标题高度
ScrollingList.Position = UDim2.new(0, 5, 0, 35)
ScrollingList.BackgroundColor3 = Color3.fromRGB(0, 0, 0, 0) -- 透明背景
ScrollingList.BorderSizePixel = 0
ScrollingList.ScrollBarThickness = 6
ScrollingList.ScrollBarImageColor3 = UI_THEME_COLOR -- 紫色滚动条
ScrollingList.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingList.Parent = MainFrame

-- 拖拽功能 (按住标题栏移动窗口)
local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)

-- // 添加翻译条目的函数
local function AddTranslationEntry(playerName, originalText, translatedText)
    -- 创建条目容器
    local Entry = Instance.new("Frame")
    Entry.Name = "Entry"
    Entry.Size = UDim2.new(1, -10, 0, 80) -- 每个条目高度80
    Entry.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- 深灰色背景块
    Entry.BorderSizePixel = 1
    Entry.BorderColor3 = UI_THEME_COLOR -- 紫色细边框
    Entry.Parent = ScrollingList
    
    -- 玩家名字
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Name = "NameLabel"
    NameLabel.Size = UDim2.new(1, -10, 0, 20)
    NameLabel.Position = UDim2.new(0, 5, 0, 5)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = playerName
    NameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    NameLabel.TextSize = 14
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Entry
    
    -- 原文 (小字)
    local OriginalLabel = Instance.new("TextLabel")
    OriginalLabel.Name = "OriginalLabel"
    OriginalLabel.Size = UDim2.new(1, -10, 0, 25)
    OriginalLabel.Position = UDim2.new(0, 5, 0, 25)
    OriginalLabel.BackgroundTransparency = 1
    OriginalLabel.Text = originalText
    OriginalLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    OriginalLabel.TextSize = 12
    OriginalLabel.Font = Enum.Font.Gotham
    OriginalLabel.TextXAlignment = Enum.TextXAlignment.Left
    OriginalLabel.TextWrapped = true
    OriginalLabel.Parent = Entry
    
    -- 译文 (高亮)
    local TranslatedLabel = Instance.new("TextLabel")
    TranslatedLabel.Name = "TranslatedLabel"
    TranslatedLabel.Size = UDim2.new(1, -10, 0, 30)
    TranslatedLabel.Position = UDim2.new(0, 5, 0, 50)
    TranslatedLabel.BackgroundTransparency = 1
    TranslatedLabel.Text = translatedText
    TranslatedLabel.TextColor3 = UI_THEME_COLOR -- 紫色文字
    TranslatedLabel.TextSize = 14
    TranslatedLabel.Font = Enum.Font.GothamBold
    TranslatedLabel.TextXAlignment = Enum.TextXAlignment.Left
    TranslatedLabel.TextWrapped = true
    TranslatedLabel.Parent = Entry
    
    -- 自动调整滚动区域高度
    ScrollingList.CanvasSize = UDim2.new(0, 0, 0, ScrollingList.UIListLayout.AbsoluteContentSize.Y + 20)
    ScrollingList.CanvasPosition = Vector2.new(0, ScrollingList.AbsoluteCanvasSize.Y) -- 自动滚动到底部
    
    -- 5秒后淡出删除 (可选，防止内存溢出)
    task.delay(15, function()
        TweenService:Create(Entry, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
        TweenService:Create(NameLabel, TweenInfo.new(1), {TextTransparency = 1}):Play()
        TweenService:Create(OriginalLabel, TweenInfo.new(1), {TextTransparency = 1}):Play()
        TweenService:Create(TranslatedLabel, TweenInfo.new(1), {TextTransparency = 1}):Play()
        task.wait(1)
        Entry:Destroy()
    end)
end

-- ==========================================
-- // 翻译逻辑部分
-- ==========================================

local function Translate(text)
    if not text or text == "" then return end
    
    local url = string.format(
        "https://api.mymemory.translated.net/get?q=%s&langpair=autodetect|%s",
        HttpService:UrlEncode(text), 
        TARGET_LANG
    )

    local success, result = pcall(function()
        local response = game:HttpGet(url)
        local data = HttpService:JSONDecode(response)
        
        if data.responseStatus == 200 then
            return data.responseData.translatedText
        else
            return nil
        end
    end)

    if success and result then
        return result
    else
        return nil
    end
end

-- // 监听聊天
local function HookChat(player)
    player.Chatted:Connect(function(msg)
        task.spawn(function()
            if string.sub(msg, 1, 1) == "/" or #msg < 2 then return end
            
            local translated = Translate(msg)
            if translated then
                -- 调用UI函数显示
                AddTranslationEntry(player.Name, msg, translated)
            end
        end)
    end)
end

-- // 初始化连接
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then HookChat(player) end
end

Players.PlayerAdded:Connect(function(player)
    HookChat(player)
end)

print(">>> 黑紫UI翻译脚本已启动 <<<")

