-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
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

hl.window_rule({
	name = "imv-float",
	match = { class = "imv" },
	float = true,
	size = {"(monitor_w*0.8)", "(monitor_h*0.8)"},
	center = true,
})

hl.window_rule({
	name = "browser-focu",
	match = { class = "google-chrome" },
  focus_on_activate = true,
})

hl.window_rule({
	name = "satty-float",
	match = { class = "com.gabm.satty" },
	float = true,
	size = {"(monitor_w*0.8)", "(monitor_h*0.8)"},
	center = true,
})

hl.window_rule({
  name    = "document viewer",
  match   = { class = "org.gnome.Evince" },
  opacity = "1.0 override 1.0 override",
})

hl.window_rule({
  name    = "opaque-media",
  match = { class = "^(mpv|vlc|feh)$" },
  opacity = "1.0 override 1.0 override",
  fullscreen = true,
  no_blur = true,
})

-- noctalia blur
hl.layer_rule({
	name = "noctalia",
	match = {
		namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
	},
	no_anim = true,
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})

