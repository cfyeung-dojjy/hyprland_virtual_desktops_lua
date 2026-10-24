# Virtual Desktops (Lua version)

This is a replacement for the virtual_desktops plugin, which breaks after the hyprland v0.55 release.

Luckily, the newly adopted lua scripting functionality allows us to write a replacement with similar functionality.

Workspace `i` on every monitor forms virtual desktop `i`: with 10 workspaces per monitor, monitor 1 owns workspaces 1-10, monitor 2 owns 11-20, and so on. Virtual desktop 3 is workspaces 3, 13, 23, ...

## How to use

1. Setup your workspace-monitor assignments with workspace_rules, here is my setup:
```lua
for i = 1, 10 do
    hl.workspace_rule({ workspace = i, monitor = main_monitor, default = (i == 1) })
end

for i = 11, 20 do
    hl.workspace_rule({ workspace = i, monitor = left_monitor, default = (i == 11) })
end
```
2. Add this repository to your hyprland config directory. (I recommend adding this as a submodule in your dotfiles repository)
3. Load the module and bind its functions to whatever keys you like. The module binds no keys itself. The example below reproduces the original plugin's keys, and falls back to plain workspace binds if the module fails to load:
```lua
local ok, vd = pcall(function()
    return require("virtual_desktops.virtual_desktops").setup({ workspaces_per_monitor = 10 })
end)
if ok then
    for i = 1, 10 do
        local key = i % 10
        hl.bind("SUPER + " .. key, function() vd.switch(i) end)
        hl.bind("SUPER + SHIFT + " .. key, function() vd.move_window(i) end)
    end
    hl.bind("SUPER + TAB", function() vd.focus_monitor(1) end)
    hl.bind("SUPER + SHIFT + TAB", function() vd.focus_monitor(-1) end)
else
    hl.notification.create({
        text = "virtual desktop module failed to load: " .. tostring(vd),
        timeout = 10000,
        icon = "error",
    })
    for i = 1, 10 do
        local key = i % 10
        hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
        hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    end
end
```

## Configuration

`setup()` takes an optional table and returns the module:

| Option | Default | Description |
| --- | --- | --- |
| `workspaces_per_monitor` | `10` | Number of workspaces each monitor owns |

## Functions

| Function | Description |
| --- | --- |
| `switch(i)` | Switch to virtual desktop `i`; if already on it, focus the next monitor |
| `move_window(i)` | Move the active window to virtual desktop `i` on the current monitor; if already on it, move the window to the next monitor |
| `focus_monitor(direction)` | Focus the next (`1`) or previous (`-1`) monitor, staying on the same virtual desktop. Wraps around |
| `focus_virtual_desktop(i)` | Switch every monitor to virtual desktop `i`, without the "next monitor" behaviour of `switch` |

## Functionalities

***Using the example keybinds above, with workspaces_per_monitor set to 10 and 2 monitors***

### On pressing SUPER+num

#### Switching virtual desktops

With this setup, you can switch between virtual desktops using the SUPER+num keys. I.e. SUPER+1 will switch to workspace 1 and 11, while maintaining focused monitor and cursor position.

#### If you are already on the desired workspace

This will focus on the next monitor. This is useful if your are on scrolling layout.

Original virtual_desktops plugin will swap workspaces between monitors, and only works for a 2 monitors setup.

### On pressing SUPER+shift+num

#### Moving windows to other virtual desktops

With this setup, you can move windows using the SUPER+shift+num keys. I.e. SUPER+shift+1 will move current window to virtual desktop 1, on the same monitor as the current workspace.

#### If you are already on the desired workspace

This will move the window to the next monitor.

### On pressing SUPER+TAB / SUPER+shift+TAB

SUPER+TAB focuses the next monitor, SUPER+shift+TAB focuses the previous monitor (wrapping around), staying on the same virtual desktop. Monitor order follows your workspace groups, i.e. workspaces 1-10 are monitor 1, 11-20 are monitor 2, etc.
