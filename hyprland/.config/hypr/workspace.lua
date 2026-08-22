hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    name = "discord",
    match = { class = "discord" },
    monitor = "DP-2",
    workspace = 1,
})

hl.window_rule({
    name = "spotify",
    match = { class = "Spotify" },
    monitor = "DP-2",
    workspace = 1,
})


hl.window_rule({
    name = "obsidian",
    match = { class = "md.obsidian.Obsidian" },
    monitor = "DP-1",
    workspace = 4,
})


hl.window_rule({
    name = "reader",
    match = { class = "org.gnome.Evince" },
    monitor = "DP-1",
    workspace = 5,
})

hl.workspace_rule({ workspace = 1, monitor = "DP-2", persistent = true, default_name = "secondary" })

hl.workspace_rule({ workspace = 2, monitor = "DP-1", persistent = true, default_name = "web" })
hl.workspace_rule({ workspace = 3, monitor = "DP-1", persistent = true, default_name = "code" })
hl.workspace_rule({ workspace = 4, monitor = "DP-1", persistent = true, default_name = "notes"})
hl.workspace_rule({ workspace = 5, monitor = "DP-1", persistent = true, default_name = "reading" })


-- Noctalia Settings
hl.window_rule({
    match = { class = "dev.noctalia.Noctalia" },
    float = true,
    size = { 1080, 920 },
})
