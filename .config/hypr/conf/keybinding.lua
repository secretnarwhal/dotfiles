-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local programs = require("conf/programs")

local mainMod = "SUPER"

hl.bind(mainMod .. " + H", hl.dsp.exec_cmd("~/.config/viegphunt/key_hints.sh"), { description = "Show keybinding hints" })

-- Application Shortcuts
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. " + E",     hl.dsp.exec_cmd(programs.fileManager))
hl.bind(mainMod .. " + B",     hl.dsp.exec_cmd(programs.browser))
hl.bind(mainMod .. " + D",     hl.dsp.exec_cmd(programs.discord))
hl.bind(mainMod .. " + M",     hl.dsp.exec_cmd(programs.music))

hl.bind(mainMod .. " + SHIFT + CTRL + escape", hl.dsp.exit())
hl.bind(mainMod .. " + Q",                     hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q",             hl.dsp.exec_cmd("hyprctl activewindow | grep pid | tr -d 'pid:' | xargs kill"))

hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle

hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("hyprlock"))
hl.bind("ALT + Space",             hl.dsp.exec_cmd("~/.config/viegphunt/app_launcher.sh")) -- Application launcher
hl.bind(mainMod .. " + PERIOD",    hl.dsp.exec_cmd("~/.config/viegphunt/emoji_launcher.sh")) -- Select emoji
hl.bind(mainMod .. " + V",         hl.dsp.exec_cmd("~/.config/viegphunt/clipboard_launcher.sh")) -- Open clipboard
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd("~/.config/viegphunt/wallpaper_select.sh")) -- Select wallpaper
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.config/viegphunt/wallpaper_random.sh")) -- Random wallpaper
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region -o " .. os.getenv("HOME") .. "/Pictures/Screenshots")) -- Screenshot

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = true }))
end

hl.bind(mainMod .. " + SHIFT + ALT + H",  hl.dsp.window.move({ workspace = "special:ghost", follow = true }))
hl.bind(mainMod .. " + SHIFT + CTRL + H", hl.dsp.workspace.toggle_special("ghost"))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",   hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",   hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),         { locked = true, repeating = true })
hl.bind("XF86AudioMute",          hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),        { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",       hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),      { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",    hl.dsp.exec_cmd("brightnessctl s 10%+"),                              { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",  hl.dsp.exec_cmd("brightnessctl s 10%-"),                              { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("code:66",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

-- Toggle flipped audio on and off
hl.bind(mainMod .. " + F10", hl.dsp.exec_cmd("~/.config/viegphunt/toggle_audio_swap.sh"))
