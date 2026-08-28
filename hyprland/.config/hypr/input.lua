---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "de",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        repeat_rate = 40,
        repeat_delay = 200,

        touchpad = {
            natural_scroll = false,
        },

        sensitivity = 0.0, -- -1.0 - 1.0, 0 means no modification.
        accel_profile = "flat",
        scroll_factor = 3,
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})
