--[[
    WolfUi 11 - full element demo
    Every Tab:Add* element, organized into blocks, plus window/library APIs.
    Run in an executor (needs game:HttpGet + loadstring). Toggle the menu with RightShift.
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/yoyonh/waraku/main/WolfUi.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function humanoid()
    local character = LocalPlayer.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function rootPart()
    local character = LocalPlayer.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

-- Custom themes: register before CreateWindow so they can be the default, or any time
-- after (the theme picker refreshes itself). Colours are written by role; anything you
-- leave out is inherited from "Midnight" (or the theme named in Extends).
Library:AddTheme({
    Name = "Dusk",
    Colors = {
        Window = "#120F16", Surface = "#1A1620", Control = "#241E2C",
        Stroke = "#2F2838", StrongStroke = "#443A50", Muted = "#8F8599", Text = "#F1ECF6",
    },
    Accent = Color3.fromRGB(203, 150, 255),
    -- Background = "rbxassetid://0000000000", -- optional: any image id, shown behind the window
})

local Window = Library:CreateWindow({
    Name = "WolfUi",
    Icon = {"paw-print", "dog"},
    Theme = "Midnight",        -- default theme; "Dusk" would pick the custom one above
    -- Background = {Image = "rbxassetid://0000000000", Transparency = 0.7, ScaleType = "Crop"},
    ToggleKey = "RightShift",
    MenuSettings = true,       -- rail button with scale + theme picker
    Configs = true,            -- required for AddConfigManager
    Folder = "WolfUiDemo",
})

-- Motion is tunable in one place: Speed drives every eased property, Spring the sliding
-- indicators, Rise the window open offset. Enabled = false turns animations off entirely.
Library:SetMotion({Speed = 16, Spring = 26})

------------------------------------------------------------------------
-- Home: stats, notices, text, progress
------------------------------------------------------------------------
local Home = Window:CreateTab({
    Name = "Home",
    Icon = {"home", "house"},
    Description = "Overview and information elements",
})

-- Blocks default to half width and pack into two columns; Width = 1 spans both.
local Overview = Home:AddBlock({Name = "Overview", Icon = {"activity"}, Description = "Live session stats", Width = 1})
local fpsStat = Overview:AddStat({Name = "FPS", Value = "0", Description = "Frames per second", Width = 0.5})
local timeStat = Overview:AddStat({Name = "Session", Value = "0s", Description = "Time since load", Width = 0.5})
local progress = Overview:AddProgressBar({Name = "Loading demo", Default = 0, ShowPercent = true})

local Info = Home:AddBlock({Name = "Information", Icon = {"info"}})
Info:AddNotice({Name = "Welcome", Text = "Every feature lives in a block. Click a block header to collapse it."})
Info:AddLabel({Text = "A plain label"})
Info:AddLabel({Text = "A muted, right-aligned label", Muted = true, Align = "right"})
Info:AddDivider()
Info:AddParagraph({
    Name = "Paragraph",
    Text = "Paragraphs wrap long text across multiple lines. Use them for descriptions, changelogs or instructions.",
})
Info:AddSpacer({Height = 4})
Info:AddImage({Name = "Avatar", Height = 110,
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"})

------------------------------------------------------------------------
-- Player: toggles, sliders, stepper, keybinds
------------------------------------------------------------------------
local PlayerTab = Window:CreateTab({
    Name = "Player",
    Icon = {"user"},
    Description = "Toggles, sliders, steppers and keybinds",
})

local Movement = PlayerTab:AddBlock({Name = "Movement", Icon = {"zap"}, Width = 0.5})
local speedSlider
Movement:AddToggle({
    Name = "Speed boost",
    Description = "Raise WalkSpeed",
    Default = false,
    Keybind = "F",
    Callback = function(enabled)
        local hum = humanoid()
        if hum then hum.WalkSpeed = enabled and (speedSlider and speedSlider:Get() or 32) or 16 end
    end,
})
speedSlider = Movement:AddSlider({
    Name = "Boost speed",
    Min = 16, Max = 120, Default = 32, Suffix = " st/s",
    Callback = function(value)
        if Library:GetFlag("Player.Speed boost") then
            local hum = humanoid()
            if hum then hum.WalkSpeed = value end
        end
    end,
})
Movement:AddSlider({
    Name = "Jump power",
    Min = 0, Max = 200, Default = 50, Decimals = 1,
    Callback = function(value)
        local hum = humanoid()
        if hum then hum.UseJumpPower = true; hum.JumpPower = value end
    end,
})

local Extras = PlayerTab:AddBlock({Name = "Extras", Icon = {"sparkles", "star"}, Width = 0.5})
Extras:AddToggle({
    Name = "Infinite jump",
    Default = false,
    -- Inline color picker and settings popup attached to a toggle
    ColorPicker = {Name = "Jump effect", Default = Color3.fromRGB(124, 136, 255)},
    Settings = {Items = {
        {Type = "Slider", Name = "Jump boost", Flag = "Demo.JumpBoost", Min = 1, Max = 5, Default = 1},
        {Type = "Toggle", Name = "Only while moving", Flag = "Demo.JumpMoving", Default = false},
    }},
})
Extras:AddStepper({Name = "Hip height", Min = 0, Max = 10, Step = 0.5, Decimals = 1, Default = 0,
    Callback = function(value)
        local hum = humanoid()
        if hum then hum.HipHeight = value end
    end,
})
Extras:AddKeybind({
    Name = "Reset key",
    Description = "Press to respawn",
    Default = "K",
    Callback = function()
        local hum = humanoid()
        if hum then hum.Health = 0 end
    end,
})

-- On-screen floating button that is shown/hidden by a toggle
local Quick = PlayerTab:AddBlock({Name = "Quick buttons", Icon = {"mouse-pointer-click", "pointer"}})
Quick:AddMiniButton({
    Name = "Jump button",
    Icon = {"arrow-up"},
    Mode = "Action",
    Default = false,
    Callback = function()
        local hum = humanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end,
})

------------------------------------------------------------------------
-- Inputs: dropdowns, segmented, text boxes, buttons, lists, colors
------------------------------------------------------------------------
local Inputs = Window:CreateTab({
    Name = "Inputs",
    Icon = {"list", "sliders-horizontal"},
    Description = "Selection and text input elements",
})

local Selection = Inputs:AddBlock({Name = "Selection", Icon = {"list-checks", "check"}})
Selection:AddDropdown({
    Name = "Single dropdown",
    Options = {"Legit", "Balanced", "Rage"},
    Default = "Balanced",
    Callback = function(value) print("Mode:", value) end,
})
Selection:AddDropdown({
    Name = "Multi dropdown",
    Options = {"Head", "Torso", "Arms", "Legs"},
    Multiple = true,
    Default = {"Head", "Torso"},
    Callback = function(values) print("Parts:", table.concat(values, ", ")) end,
})
Selection:AddSegmented({
    Name = "Segmented",
    Options = {"Low", "Medium", "High"},
    Default = "Medium",
    Callback = function(value) print("Quality:", value) end,
})
Selection:AddColorPicker({
    Name = "Color picker",
    Description = "With transparency",
    Default = Color3.fromRGB(255, 120, 168),
    UseAlpha = true,
    Callback = function(color, alpha) print("Color:", color, alpha) end,
})

local Text = Inputs:AddBlock({Name = "Text input", Icon = {"type", "text-cursor"}})
Text:AddTextBox({
    Name = "Message",
    Placeholder = "Type and press Enter",
    OnEnter = function(value)
        Library:Notify({Title = "You typed", Text = value, Type = "info", Duration = 3})
    end,
})
Text:AddTextBox({Name = "Amount", Placeholder = "Numbers only", Numeric = true, MaxLength = 6})
Text:AddList({
    Name = "Whitelist",
    Placeholder = "Add a player name",
    Items = {"Builderman"},
    Callback = function(items) print("Whitelist:", #items) end,
})

local Actions = Inputs:AddBlock({Name = "Buttons", Icon = {"mouse-pointer", "pointer"}})
Actions:AddButton({
    Name = "Notify",
    Description = "Show a notification",
    Icon = {"bell"},
    Callback = function()
        Library:Notify({Title = "Hello", Text = "This is a notification.", Type = "success", Duration = 4})
    end,
})
Actions:AddButton({
    Name = "Confirm dialog",
    Description = "Ask before doing something",
    Icon = {"help-circle", "circle-help"},
    Callback = function()
        Library:Dialog({
            Title = "Are you sure?",
            Text = "This will print a message to the console.",
            Confirm = function() print("Confirmed") end,
            Cancel = function() print("Cancelled") end,
        })
    end,
})
Actions:AddButton({
    Name = "Slow task",
    Description = "Shows a loading state while running",
    AutoLoading = true,
    LoadingText = "Working...",
    Callback = function() task.wait(2) end,
})

------------------------------------------------------------------------
-- Players: player dropdown and player list
------------------------------------------------------------------------
local PlayersTab = Window:CreateTab({
    Name = "Players",
    Icon = {"users"},
    Description = "Player pickers and actions",
})

local Target = PlayersTab:AddBlock({Name = "Target", Icon = {"crosshair", "target"}})
local targetDropdown = Target:AddPlayerDropdown({Name = "Target player", IncludeSelf = false})
Target:AddButton({
    Name = "Teleport to target",
    Callback = function()
        local target = targetDropdown:GetPlayer()
        local mine, theirs = rootPart(), target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if mine and theirs then mine.CFrame = theirs.CFrame * CFrame.new(0, 0, 3) end
    end,
})

local Server = PlayersTab:AddBlock({Name = "Server", Icon = {"server", "globe"}, Width = 1})
Server:AddPlayerList({
    Name = "Players in server",
    ShowDistance = true,
    GetRole = function(player)
        return player == LocalPlayer and "You" or ""
    end,
    OnWatch = function(player)
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then workspace.CurrentCamera.CameraSubject = hum end
    end,
    OnTeleport = function(player)
        local mine = rootPart()
        local theirs = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if mine and theirs then mine.CFrame = theirs.CFrame * CFrame.new(0, 0, 3) end
    end,
})

------------------------------------------------------------------------
-- Cards: card grid selector
------------------------------------------------------------------------
local Cards = Window:CreateTab({
    Name = "Cards",
    Icon = {"layout-grid", "grid"},
    Description = "Card grid selection",
})

local Loadout = Cards:AddBlock({Name = "Loadout", Icon = {"package", "box"}, Width = 1})
Loadout:AddCardGrid({
    Name = "Pick up to 2",
    Columns = 3,
    MaxSelected = 2,
    Cards = {
        {Id = "sword", Name = "Sword", Subtitle = "Melee", Icon = {"sword"}},
        {Id = "bow", Name = "Bow", Subtitle = "Ranged", Icon = {"crosshair"}},
        {Id = "shield", Name = "Shield", Subtitle = "Defense", Icon = {"shield"}},
        {Id = "potion", Name = "Potion", Subtitle = "Heal", Icon = {"flask-conical", "heart"}, Badge = "NEW"},
        {Id = "bomb", Name = "Bomb", Subtitle = "Explosive", Icon = {"bomb", "flame"}},
        {Id = "relic", Name = "Relic", Subtitle = "Locked", Icon = {"gem"}, Locked = true},
    },
    Callback = function(selected) print("Selected cards:", #selected) end,
})
Loadout:AddCardGrid({
    Name = "Single choice",
    Mode = "Single",
    Columns = 4,
    Cards = {"Red", "Green", "Blue", "Gold"},
    Default = {"Blue"},
})

------------------------------------------------------------------------
-- Settings: themes, auto-blocks, configs, groups
------------------------------------------------------------------------
local Settings = Window:CreateTab({
    Name = "Settings",
    Section = "Preferences",   -- starts a captioned group in the sidebar
    Icon = {"settings", "cog"},
    Description = "Appearance, configs and menu",
    BlockName = "Appearance",
})

-- No AddBlock here: loose elements go into the "Appearance" block (BlockName)
Settings:AddSegmented({
    Name = "Theme",
    Options = {"Midnight", "Ocean", "Dusk", "Forest"},
    Default = "Midnight",
    Callback = function(name) Library:SetTheme(name) end,
})
Settings:AddDropdown({
    Name = "All themes",
    Options = Library:GetThemes(),
    Default = (Library:GetTheme()),
    Callback = function(name) Library:SetTheme(name) end,
})
Settings:AddToggle({
    Name = "Accent wash",
    Description = "Soft accent gradient behind the window",
    Default = true,
    Callback = function(on)
        local current = Library:GetBackground() or {}
        current.Gradient = on
        Library:SetBackground(current)
    end,
})
Settings:AddColorPicker({
    Name = "Accent color",
    Default = Library.Accent,
    Callback = function(color) Library:SetAccent(color) end,
})

-- AddSection starts a new block automatically
Settings:AddSection("Menu")
Settings:AddKeybind({
    Name = "Menu key",
    Default = "RightShift",
    Callback = function(key) Library:SetToggleKey(key) end,
})
Settings:AddToggle({
    Name = "Watermark",
    Default = false,
    Callback = function(enabled) Library:SetWatermarkEnabled(enabled) end,
})
Settings:AddSettings({
    Name = "Advanced",
    Description = "Opens a settings popup",
    IncludeScrollBarSlider = true,
    Items = {
        {Type = "Toggle", Name = "Fade animations", Flag = "Demo.Fade", Default = true,
            Callback = function(on) Library:SetFadeAnimations(on) end},
    },
})
Settings:AddButton({
    Name = "Unload",
    Description = "Destroy the UI",
    Icon = {"power"},
    Callback = function()
        Library:Dialog({Title = "Unload WolfUi?", Confirm = function() Library:Unload() end})
    end,
})

Settings:AddSection("Configs")
Settings:AddConfigManager({Name = "Configs"})

-- Groups are collapsible blocks that do not capture later loose elements
local Credits = Settings:AddGroup({Name = "Credits", Icon = {"heart"}, Collapsed = true})
Credits:AddParagraph({Name = "WolfUi", Text = "Version " .. tostring(Library.Version)})

------------------------------------------------------------------------
-- Custom elements: register once, then use Tab:AddKeyValue or {Type = "keyvalue"}
------------------------------------------------------------------------
Library:RegisterElement("KeyValue", function(tab, opts)
    local H = Library.Helpers
    local w = tab:_width(opts.Width)
    local card = tab:_card(w, 43, opts.Name or "KeyValue")
    H.muted(card, opts.Name or "Key", 10, 14.5, w - 110, 14, 11)
    local value = H.text(card, tostring(opts.Value or ""), w - 110, 14.5, 100, 14, 12, nil, "right")
    local api = H.baseApi(tab, card, opts.Flag)
    function api:Set(v) value:SetText(v) end
    function api:Get() return value:GetText() end
    return api
end, {"kv"})

Credits:AddKeyValue({Name = "Build", Value = "2026.10"})

------------------------------------------------------------------------
-- Live updates
------------------------------------------------------------------------
Library:OnChange(function(flag, value)
    print("[WolfUi] " .. tostring(flag) .. " =", value)
end)

local started = os.clock()
task.spawn(function()
    for i = 1, 20 do
        progress:Set(i / 20)
        task.wait(0.1)
    end
    Library:Notify({Title = "WolfUi demo", Text = "All elements loaded.", Type = "success", Duration = 4})
end)

task.spawn(function()
    local frames, last = 0, os.clock()
    local connection = game:GetService("RunService").RenderStepped:Connect(function() frames += 1 end)
    Library:OnUnload(function() connection:Disconnect() end)
    while not Library.Destroyed do
        task.wait(1)
        local now = os.clock()
        fpsStat:Set(tostring(math.floor(frames / (now - last) + 0.5)))
        timeStat:Set(string.format("%ds", now - started))
        frames, last = 0, now
    end
end)
