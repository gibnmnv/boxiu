-- ==========================================
-- Boxiu 翻译脚本 v2.0 (无卡顿版)
-- 特性: 事件驱动不卡顿 + 黑紫UI + 开关 + 翻译按钮
-- ==========================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Chat = game:GetService("Chat")

local LocalPlayer = Players.LocalPlayer

-- 等待玩家加载
while not LocalPlayer do
    Players.LocalPlayerChanged:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- ==========================================
-- 1. UI 配置 (黑底紫边)
-- ==========================================
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BoxiuTranslatorUI"
    ScreenGui.Parent = game.CoreGui

    -- 主框架
    local MainFrame = Instance.new("Frame")
    MainFrame.Parent = ScreenGui
    MainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- 深黑
    MainFrame.BorderColor3 = Color3.fromRGB(148, 0, 211) -- 霓虹紫
    MainFrame.BorderSizePixel = 2
    MainFrame.ClipsDescendants = false

    -- 标题
    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.Text = "Boxiu 翻译器 [v2]"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16

    -- 滚动框架 (用于显示聊天)
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Parent = MainFrame
    ScrollFrame.Position = UDim2.new(0, 0, 0, 30)
    ScrollFrame.Size = UDim2.new(1, 0, 1, -70)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ScrollFrame.BorderColor3 = Color3.fromRGB(100, 0, 150)
    ScrollFrame.ScrollBarThickness = 6

    -- 按钮容器
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Parent = MainFrame
    ButtonFrame.Position = UDim2.new(0, 0, 1, -40)
    ButtonFrame.Size = UDim2.new(1, 0, 0, 40)
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

    -- 按钮样式函数
    local function CreateButton(text, x)
        local btn = Instance.new("TextButton")
        btn.Parent = ButtonFrame
        btn.Position = UDim2.new(x, 5, 0, 5)
        btn.Size = UDim2.new(0, 140, 1, -10)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(50, 5, 80)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.Gotham
        return btn
    end

    -- 创建按钮
    local ToggleBtn = CreateButton("❌ 关闭自动翻译", 0)
    local TranslateBtn = CreateButton("🔄 翻译", 0.5)

    -- ==========================================
    -- 2. 逻辑核心
    -- ==========================================
    local AutoTranslateEnabled = false
    local ChatHistory = {} -- 存储聊天记录

    -- 翻译函数 (使用 MyMemory API)
    local function TranslateText(text)
        local url = string.format("https://api.mymemory.translated.net/get?q=%s&langpair=en|zh-CN", HttpService:UrlEncode(text))
        local response = HttpService:RequestAsync({
            Url = url,
            Method = "GET",
        })
        local data = HttpService:JSONDecode(response.Body)
        if data.responseData and data.responseData.translatedText then
            return data.responseData.translatedText
        end
        return "翻译失败"
    end

    -- 添加消息到 UI
    local function AddMessageToUI(playerName, originalMsg, translatedMsg)
        local msgFrame = Instance.new("Frame")
        msgFrame.Parent = ScrollFrame
        msgFrame.Size = UDim2.new(1, 0, 0, 50)
        msgFrame.BackgroundTransparency = 1

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Parent = msgFrame
        nameLbl.Text = playerName
        nameLbl.TextColor3 = Color3.fromRGB(100, 149, 237)
        nameLbl.Position = UDim2.new(0, 5, 0, 0)
        nameLbl.Size = UDim2.new(0, 100, 0, 15)
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Font = Enum.Font.Gotham

        local orgLbl = Instance.new("TextLabel")
        orgLbl.Parent = msgFrame
        orgLbl.Text = "原文: " .. originalMsg
        orgLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        orgLbl.Position = UDim2.new(0, 5, 0, 15)
        orgLbl.Size = UDim2.new(1, -10, 0, 15)
        orgLbl.TextWrapped = true
        orgLbl.TextXAlignment = Enum.TextXAlignment.Left

        local transLbl = Instance.new("TextLabel")
        transLbl.Parent = msgFrame
        transLbl.Text = "译文: " .. translatedMsg
        transLbl.TextColor3 = Color3.fromRGB(255, 255, 100)
        transLbl.Position = UDim2.new(0, 5, 0, 30)
        transLbl.Size = UDim2.new(1, -10, 0, 15)
        transLbl.TextWrapped = true
        transLbl.TextXAlignment = Enum.TextXAlignment.Left

        -- 自动滚动到底部
        ScrollFrame.CanvasPosition = Vector2.new(0, ScrollFrame.CanvasSize.Y.Offset)
    end

    -- 监听聊天 (这才是不卡顿的关键)
    local function OnNewChatMessage(message, channel, player)
        -- 如果开启了自动翻译
        if AutoTranslateEnabled and player ~= LocalPlayer then
            spawn(function()
                local translated = TranslateText(message)
                AddMessageToUI(player.Name, message, translated)
            end)
        end

        -- 记录历史
        table.insert(ChatHistory, {Player = player.Name, Message = message})
    end

    -- 连接事件
    Chat.ChatAdded:Connect(OnNewChatMessage)

    -- ==========================================
    -- 3. 按钮交互
    -- ==========================================

    -- 切换自动翻译
    ToggleBtn.MouseButton1Click:Connect(function()
        AutoTranslateEnabled = not AutoTranslateEnabled
        if AutoTranslateEnabled then
            ToggleBtn.Text = "✅ 开启自动翻译"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(5, 50, 5)
        else
            ToggleBtn.Text = "❌ 关闭自动翻译"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 5, 5)
        end
    end)

    -- 手动翻译按钮 (点击后翻译最近的消息)
    TranslateBtn.MouseButton1Click:Connect(function()
        if #ChatHistory > 0 then
            local lastMsg = ChatHistory[#ChatHistory]
            spawn(function()
                local translated = TranslateText(lastMsg.Message)
                AddMessageToUI(lastMsg.Player, lastMsg.Message, translated)
            end)
        else
            print("没有可翻译的历史消息")
        end
    end)

    -- 初始化
    print("Boxiu 翻译器已加载 (v2)")
end

-- 执行创建
CreateUI()
