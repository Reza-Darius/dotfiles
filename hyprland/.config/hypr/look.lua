-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 0,
		gaps_out = 0,
		border_size = 1,
	},

	decoration = {
		rounding = 0,
		rounding_power = 2,

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = 0xee1a1a1a,
		},

		blur = {
			enabled = true,
			size = 3,
			passes = 2,
			vibrancy = 0.1696,
		},
	},
})

-- Animations
hl.curve("water", {
	type = "bezier",
	points = {
		{ 0.22, 0.9 },
		{ 0.36, 1.0 },
	},
})
hl.curve("flow", {
	type = "bezier",
	points = {
		{ 0.25, 0.1 },
		{ 0.25, 1.0 },
	},
})
hl.curve("ripple", {
	type = "bezier",
	points = {
		{ 0.33, 0.0 },
		{ 0.2, 1.0 },
	},
})
hl.curve("stream", {
	type = "bezier",
	points = {
		{ 0.4, 0.0 },
		{ 0.4, 1.0 },
	},
})
hl.curve("cascade", {
	type = "bezier",
	points = {
		{ 0.19, 1.0 },
		{ 0.22, 1.0 },
	},
})
hl.curve("md3_standard", {
	type = "bezier",
	points = {
		{ 0.2, 0.0 },
		{ 0.0, 1.0 },
	},
})
hl.curve("md3_accel", {
	type = "bezier",
	points = {
		{ 0.3, 0.0 },
		{ 0.8, 0.15 },
	},
})
hl.curve("overshot", {
	type = "bezier",
	points = {
		{ 0.05, 0.9 },
		{ 0.1, 1.05 },
	},
})

hl.animation({ leaf = "windows", enabled = true, speed = 3.0, bezier = "water" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2.5, bezier = "cascade", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.4, bezier = "stream", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1.6, bezier = "flow" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.4, bezier = "water" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2.0, bezier = "cascade" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.8, bezier = "ripple" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 2.0, bezier = "water" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 1.4, bezier = "flow" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 1.5, bezier = "overshot", style = "popin 80%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.3, bezier = "md3_accel", style = "popin 90%" })
hl.animation({ leaf = "layers", enabled = true, speed = 1.5, bezier = "md3_standard" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.5, bezier = "flow" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.5, bezier = "water" })
hl.animation({ leaf = "border", enabled = true, speed = 2.9, bezier = "water" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 3.5, bezier = "flow" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({
	name = "no-gaps-wtv1",
	match = { float = false, workspace = "w[tv1]" },
	border_size = 0,
	rounding = 0,
})
hl.window_rule({
	name = "no-gaps-f1",
	match = { float = false, workspace = "f[1]" },
	border_size = 0,
	rounding = 0,
})

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
	dwindle = {
		preserve_split = true, -- You probably want this
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
	master = {
		new_status = "master",
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
	scrolling = {
		fullscreen_on_one_column = true,
	},
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
