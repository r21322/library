# WolfUi

Single-file Roblox UI library (`WolfUi.lua`). Minimalist by default: hairline strokes,
one radius scale, one motion curve, and a theme system that script developers can extend
in a few lines. `example.lua` exercises every element.

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/<you>/library/main/WolfUi.lua"))()
local Window = Library:CreateWindow({Name = "My script", Theme = "Midnight", MenuSettings = true})
local Tab = Window:CreateTab({Name = "Main"})
Tab:AddToggle({Name = "Enabled", Default = true, Callback = print})
```

## Themes

`Midnight` is the default. Six themes ship (`Midnight`, `Graphite`, `Ocean`, `Rose`,
`Forest`, `Black`); the in-menu theme picker lists every registered theme, including yours.

```lua
Library:AddTheme({
    Name = "Dusk",
    Colors = {                      -- by role; omitted roles inherit from `Extends` (default Midnight)
        Window = "#120F16",         -- 1  window body
        Surface = "#1A1620",        -- 2  cards, popups, sidebar highlight
        Muted = "#8F8599",          -- 3  secondary text
        Control = "#241E2C",        -- 4  buttons, fields, checkboxes
        Stroke = "#2F2838",         -- 5  hairlines
        StrongStroke = "#443A50",   -- 6  hover / focus strokes
        Text = "#F1ECF6",           -- 7  primary text
    },
    Accent = Color3.fromRGB(203, 150, 255),
    Background = "rbxassetid://0000000000",   -- optional, see below
    Extends = "Midnight",
})
Library:SetTheme("Dusk")
```

Colours accept `Color3`, `{r, g, b}` or `"#RRGGBB"`. Positional form still works:
`Library:AddTheme("Dusk", {c1, …, c7}, accent)`. There is also a builder:

```lua
Library:Theme("Dusk"):Colors({Window = "#120F16"}):Accent(Color3.new(1, 1, 1)):Apply()
```

| API | Purpose |
| --- | --- |
| `Library:SetTheme(nameOrIndex, keepAccent)` | Switch theme (eases colours over a few frames). |
| `Library:GetTheme()` / `GetThemes()` / `GetThemeInfo(name)` | Inspect. |
| `Library:RemoveTheme(name)` | Drop a custom theme (Midnight cannot be removed). |
| `Library:SetPaletteColor(slot, color)` | Live-override one slot of the active theme. |
| `Library:SetAccent(color, alpha)` | Accent used by checkboxes, sliders, indicators, the backdrop wash. |

## Background

The window has a backdrop layer: an optional image plus a soft accent wash (on by default).

```lua
-- at creation
Library:CreateWindow({Background = {Image = "rbxassetid://123", Transparency = 0.7}})
-- any time
Library:SetBackground("rbxassetid://123")                       -- image only
Library:SetBackground({Image = "123", Transparency = 0.6, Tint = Color3.new(0.8, 0.8, 1),
    ScaleType = "Crop" | "Fit" | "Tile" | "Stretch", TileSize = 256, Gradient = false})
Library:SetBackground({Gradient = Color3.fromRGB(80, 120, 255)})  -- wash in a fixed colour
Library:ClearBackground()                                        -- back to the theme's own
```

A theme's `Background` applies whenever that theme is selected, unless you pinned one with
`SetBackground` yourself.

## Motion

```lua
Library:SetMotion({Speed = 16, Spring = 26, Rise = 8, FadeDuration = 0.22, Enabled = true})
```

`Speed` drives every eased property (hover, checkbox, tab fades), `Spring` the sliding
indicators (nav, segmented), `Rise` the window's open offset. There is no click flash;
pressed state is communicated by the hover wash only.

## Custom elements

```lua
Library:RegisterElement("KeyValue", function(tab, opts)
    local H = Library.Helpers
    local w = tab:_width(opts.Width)
    local card = tab:_card(w, 43, opts.Name)
    H.muted(card, opts.Name, 10, 14.5, w - 110, 14, 11)
    local value = H.text(card, opts.Value or "", w - 110, 14.5, 100, 14, 12, nil, "right")
    local api = H.baseApi(tab, card, opts.Flag)
    function api:Set(v) value:SetText(v) end
    return api
end, {"kv"})

Tab:AddKeyValue({Name = "Build", Value = "1.0"})
Tab:AddElements({{Type = "kv", Name = "Ping", Value = "42 ms"}})
```

`Library.Helpers` exposes the drawing primitives (`rect`, `text`, `muted`, `icon`, `paint`,
`step`, `approach`, `spring`, `baseApi`, `bindTitle`, `palette(slot)`, `accent()`,
`fireChange`). Anything painted with a palette slot re-themes automatically.

## Design tokens

`Library.Design` is frozen: `WindowRadius 8`, `CardRadius 6`, `PopupRadius 6`,
`ControlRadius 4`, `RowRadius 4`. Every control reads these, so the shell stays consistent.
