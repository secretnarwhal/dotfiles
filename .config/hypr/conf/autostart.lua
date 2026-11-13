-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
local programs = require("conf/programs")

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("awww-daemon & sleep 0.5 & awww init")
    hl.exec_cmd("nm-applet --indicator")

    -- Setup fcitx5
    hl.exec_cmd("export GTK_IM_MODULE=fcitx5")
    hl.exec_cmd("export QT_IM_MODULE=fcitx5")
    hl.exec_cmd("export XMODIFIERS=@im=fcitx5")
    hl.exec_cmd("export INPUT_METHOD=fcitx5")
    hl.exec_cmd("export SDL_IM_MODULE=fcitx5")
    hl.exec_cmd("fcitx5")

    -- Setup screen sharing
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Setup clipboard
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Setup themes
    hl.exec_cmd("~/.config/viegphunt/gtkthemes.sh")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- Screen timeout and locking
    hl.exec_cmd("hypridle")

    -- Open terminal on startup with pacman command pre-filled
    hl.exec_cmd("env STARTUP_COMMAND=\"sudo pacman -Syu\" " .. programs.terminal)
end)
