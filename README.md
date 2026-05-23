# Virtual Desktops (Lua version)

This is a replacement for the virtual_desktops plugin, which breaks after the hyprland v0.55 release.

Luckily, the newly adopted lua scripting functionality allows us to write a replacement with similar functionality.

## How to use

<mark>warning, this will unbind all your existing SUPER+num and SUPER+shift+num bindings</mark>

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
3. In your `hyprland.lua`, add the following line:
```lua
-- incase the virtual_desktops module fails to load, fall back to default settings
local ok, module = pcall(require, "/path/to/virtual_desktops.lua")
if not ok then
    hl.notification.create(
        {
            text = "virtual desktop module failed to load",
            timeout = 10000,
            icon = "error",
        })
end
```


## Functionalities

***We assume you have workspaces_per_monitor set to 10 in your config, with 2 monitors***

### On pressing SUPER+num

#### Switching virtual desktops

With this setup, you can switch between virtual desktops using the SUPER+num keys. I.e. SUPER+1 will switch to workspace 1 and 11, while maintaining focused monitor and cursor position.

#### If you are already on the desired workspace

This will focus on the next monitor. This is useful if your are on scrolling layout.

Original virtual_desktops plugin will swap workspaces between monitors, and only works for a 2 monitors setup.

### On pressing SUPER+shift+num

#### Moving virtual desktops to other virtual desktops

With this setup, you can move virtual desktops using the SUPER+shift+num keys. I.e. SUPER+shift+1 will move current window to virtual desktop 1, on the same monitor as the current workspace.

#### If you are already on the desired workspace

This will move the window to the next monitor.
