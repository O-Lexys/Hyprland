-- =============================================================================
-- hyprland.lua — Hyprland 0.55+ конфіг (нативний Lua API)
-- https://wiki.hypr.land/Configuring/Start/
-- =============================================================================

------------------
---- МОНІТОРИ ----
------------------

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = 1,
    bitdepth = 8,
    cm       = "hdredid",
})

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

---------------------
---- МОЇ ПРОГРАМИ ----
---------------------

local terminal    = "kitty"
local fileManager = "kitty yazi"
local mainMod     = "SUPER"
local ipc         = "noctalia-shell ipc call"

-------------------
---- АВТОЗАПУСК ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("qpwgraph")
    hl.exec_cmd("noctalia-shell")
    hl.exec_cmd("bash -c 'until dbus-send --session --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.ListNames 2>/dev/null | grep -q StatusNotifierWatcher; do sleep 0.5; done && pw-jack carla /home/lioha/rootcustom/carla/noise.carxp'")
end)

-------------------------------
---- ЗМІННІ СЕРЕДОВИЩА --------
-------------------------------

hl.env("XCURSOR_THEME",        "Nordzy-cursors")
hl.env("XCURSOR_SIZE",         "24")
hl.env("HYPRCURSOR_SIZE",      "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("AQ_DRM_DEVICES", "/dev/dri/card1")

-----------------------
---- ЗОВНІШНІЙ ВИГЛЯД ----
-----------------------

hl.config({
    general = {
        gaps_in          = 5,
        gaps_out         = 10,
        border_size      = 2,
        col = {
            active_border   = { colors = { "rgba(255,255,255,0.6)", "rgba(180,180,255,0.4)" }, angle = 45 },
            inactive_border = "rgba(5a5a5a80)",
        },
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "scrolling",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 10,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = false,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 1,
            passes   = 3,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-------------------
---- АНІМАЦІЇ -----
-------------------

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0,    0},    {1,    1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5,  0.5},  {0.75, 1.0}  } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1,  1}    } })
hl.curve("overshoot",      { type = "bezier", points = { {0.05, 0.9},  {0.1,  1.1}  } })
hl.curve("myBezier",       { type = "bezier", points = { {0.05, 0.9},  {0.1,  1.05} } })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default"       })
hl.animation({ leaf = "border",        enabled = true,  speed = 6,    bezier = "myBezier"      })
hl.animation({ leaf = "windows",       enabled = true,  speed = 6,    bezier = "myBezier",     style = "popin"      })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%"  })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 6,    bezier = "myBezier",     style = "slide"      })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear"  })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear"  })
hl.animation({ leaf = "fade",          enabled = true,  speed = 6,    bezier = "myBezier"      })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint"  })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade"       })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade"       })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear"  })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear"  })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 4, bezier = "overshoot",    style = "slidevert"      })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 4, bezier = "overshoot",    style = "slidevert"      })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 4, bezier = "overshoot",    style = "slidevert"      })

---------------------
---- SCROLLING -------
---------------------

hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
        column_width = 0.8,
        focus_fit_method = 1,
    },
})

hl.window_rule({
    name            = "kitty-scrolling-width",
    match           = { class = "kitty" },
})


local MAX_ZOOM = 6
local MIN_ZOOM = 1
local ZOOM_TOGGLE_FACTOR = 1.5

---@param offset number
---@return nil
local function zoom(offset)
    local current = hl.get_config("cursor.zoom_factor")
    if offset ~= nil then
        current = current + offset
    elseif current ~= MIN_ZOOM then
        current = MIN_ZOOM
    else
        current = ZOOM_TOGGLE_FACTOR
    end
    current = math.max(MIN_ZOOM, math.min(MAX_ZOOM, current))
    hl.config({ cursor = { zoom_factor = current } })
end

--------------
---- MISC ----
--------------

hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },
})

---------------
---- ВВЕДЕННЯ ----
---------------

hl.config({
    input = {
        kb_layout  = "us,ua,de",
        kb_options = "grp:win_space_toggle",
        kb_model   = "",
        kb_rules   = "",
        follow_mouse   = 1,
        sensitivity    = -1,
        force_no_accel = true,
        touchpad = {
            disable_while_typing = false,
            natural_scroll       = true,
        },
    },
})

---------------------
---- КЛАВІШІ ---------
---------------------

-- Основні дії
hl.bind("SUPER + mouse_up", function()      zoom(-4)     end, { global = true })
hl.bind("SUPER + mouse_down", function()    zoom(2)    end, { global = true })
hl.bind(mainMod .. " + Q",      hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + A",      hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + C",      hl.dsp.window.close())
hl.bind(mainMod .. " + M",      hl.dsp.exit())
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R",      hl.dsp.exec_cmd(ipc .. " launcher toggle"))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd(ipc .. " systemMonitor toggle"))
hl.bind(mainMod .. " + T",      hl.dsp.exec_cmd(ipc .. " controlCenter toggle"))
hl.bind(mainMod .. " + L",      hl.dsp.exec_cmd(ipc .. " lockScreen lock"))
hl.bind(mainMod .. " + W",      hl.dsp.exec_cmd(ipc .. " wallpaper toggle"))
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd("~/rootcustom/scripts/screenshot_area.sh"))
hl.bind(mainMod .. " + X",      hl.dsp.exec_cmd("kitty /home/lioha/rootcustom/assistant/assitant.sh"))
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd("~/.local/bin/msi-fan"))

hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("/home/lioha/rootcustom/scripts/language.sh"))
hl.bind("ALT + 2",       hl.dsp.exec_cmd("killall paplay"))
hl.bind("ALT + 4",       hl.dsp.exec_cmd("kitty ~/rootcustom/assistant/assistant.sh"))
hl.bind("ALT + 1",       hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("/home/lioha/rootcustom/scripts/mut.sh"), { locked = true })

-- Фокус вікон стрілками
hl.bind(mainMod .. " + left",   hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + right",  hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",     hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + down",   hl.dsp.focus({ direction = "down"  }))

-- Scrolling layout: рух по колонках
hl.bind(mainMod .. " + period", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + comma",  hl.dsp.layout("move -col"))

-- Fullscreen
hl.bind("WIN + F",          hl.dsp.window.fullscreen({ mode = 0 }))
hl.bind("WIN + SHIFT + F",  hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind("WIN + CTRL + F",   hl.dsp.window.fullscreen_state({ internal = 0, client = 2 }))

-- Воркспейси 1–10
for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic2"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic2" }))

-- Мишею
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Гучність і яскравість (з повторенням)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

hl.bind("SUPER + tab", function ()
    local layouts     = { "scrolling", "dwindle" }
    local workspace   = hl.get_active_workspace()
    local next_layout = "dwindle"

    if not workspace then
        return
    end

    for i = 1, #layouts do
        if layouts[i] == workspace.tiled_layout then
            local next_layout_idx = (i % #layouts) + 1
            next_layout = layouts[next_layout_idx]
            break
        end
    end

    hl.workspace_rule({ workspace = workspace.name, layout = next_layout })
end)
------------------------------
---- ПРАВИЛА ДЛЯ ВІКОН -------
------------------------------

-- XWayland: фікс перетягування
hl.window_rule({
    name     = "fix-xwayland-drags",
    match    = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Блокуємо maximize-запити від застосунків
hl.window_rule({
    name           = "suppress-maximize",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

------------------------------
---- ПРАВИЛА ДЛЯ ШАРІВ -------
------------------------------
local noctalia_layers = {
    ".*noctalia-launcher-overlay.*$",
    ".*noctalia-background-.*$",
    ".*noctalia-osd.*$",
    ".*noctalia-bar-content.*$",
    ".*noctalia-notifications.*$",
    ".*noctalia-toast.*$",
    ".*noctalia-desktop-widgets.*$",
    ".*noctalia-dock.*$",
    ".*wvkbd.*$",
}

for _, ns in ipairs(noctalia_layers) do
    hl.layer_rule({
        match = {
            namespace = ns,
        },
        blur = true,
        no_anim = true,
        blur_popups = true,
        ignore_alpha = 0.000,
    })
end

hl.layer_rule({
    match = {
        namespace = ".*noctalia-notifications.*$",
    },
    no_screen_share = true,
})

hl.layer_rule({
    name            = "noctalia-notifications",
    match           = { namespace = ".*noctalia-notifications.*" },
    blur            = true,
    blur_popups     = true,
    ignore_alpha    = 0.001,
    no_screen_share = true,
})


---------------
---- ПЛАГІНИ ----
---------------

hl.config({
    plugin = {
    },
})


-- This loads Noctalia-generated Hyprland colors.
dofile("/home/lioha/.config/hypr/noctalia/noctalia-colors.lua")
