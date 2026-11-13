-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Disable blur for floating XWayland window
-- NOTE: the original one-liner here (`match:class xwayland:1`) looked like a typo
-- that never actually matched anything under the old parser. Translated to what
-- the comment clearly intends: xwayland + floating windows.
hl.window_rule({
    name  = "no-blur-floating-xwayland",
    match = { xwayland = true, float = true },

    no_blur = true,
})

-- 1. Automatically banish the tiny Windows 98 artifact
hl.window_rule({
    name  = "banish-ba-artifact",
    match = {
        class = "^steam_app_3557620$",
        title = "^\\s*$",
    },

    float             = true,
    no_focus          = true,
    no_initial_focus  = true,
    size              = { 1, 1 },
    opacity           = "0 0",
    move              = { "monitor_w - window_w", "monitor_h - window_h" }, -- old rule used 100% 100%
})

-- 2. Force the actual game to tile and allow resizing
hl.window_rule({
    name  = "force-tile-blue-archive",
    match = {
        class = "^steam_app_3557620$",
        title = "^Blue Archive.*",
    },

    float       = false,
    no_max_size = true,

    suppress_event = "maximize fullscreen",
})
