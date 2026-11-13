-- Hyprland Lua config (migrated from hyprland.conf, hyprlang deprecated since 0.55)
-- https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------
require("conf/monitors")

-------------------
---- AUTOSTART ----
-------------------
require("conf/autostart")

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
require("conf/environment")

-----------------------
---- LOOK AND FEEL ----
-----------------------
require("conf/appearance")
require("conf/animation")
require("conf/layout")
require("conf/misc")

---------------
---- INPUT ----
---------------
require("conf/input")

---------------------
---- KEYBINDINGS ----
---------------------
require("conf/keybinding")

----------------------
---- WINDOWS RULE ----
----------------------
require("conf/windowrule")

-------------------------
---- WORKSPACES RULE ----
-------------------------
require("conf/workspaces")
