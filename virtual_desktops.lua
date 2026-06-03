local mainMod = "SUPER" -- change me if you use a different key as mainMod

local workspaces_per_monitor = 10

-- make sure it works as expected when hyprland reloads on whatever workspace you are on
if hl.get_active_workspace() then
    local current_virtual_desktop_id = hl.get_active_workspace().id % workspaces_per_monitor
else
    local current_virtual_desktop_id = 1
end

-- Unbind existing
for virtual_desktop_id = 1, workspaces_per_monitor do
    local key = virtual_desktop_id % workspaces_per_monitor
    hl.unbind(mainMod .. " + " .. key)
    hl.unbind(mainMod .. " + SHIFT + " .. key)
end

local function focus_on_virtual_desktop(i)
    local monitors = #hl.get_monitors()
    -- focusing to another workspace reset the cursor position to center, record its original location
    local cursor_pos = hl.get_cursor_pos()
    local current_workspace_group_idx = hl.get_active_workspace().id // workspaces_per_monitor
    -- switch workspace on both monitors
    for monitor = 1, monitors do
        hl.dispatch(hl.dsp.focus({ workspace = i + workspaces_per_monitor * (monitor - 1) }))
    end

    -- focus back to the monitor where it was originally focused
    -- I tried to use `hl.dispatch(hl.dsp.focus({ monitor = hl.get_monitor_at_cursor() }))`
    -- but it didn't work
    hl.dispatch(hl.dsp.focus({ workspace = i + workspaces_per_monitor * current_workspace_group_idx }))

    -- focus cursor to original location
    if cursor_pos ~= nil then
        hl.dispatch(hl.dsp.cursor.move({ x = cursor_pos.x, y = cursor_pos.y }))
    end

    current_virtual_desktop_id = i
end

local function focus_next_monitor()
    local current_workspace_id = hl.get_active_workspace().id
    local next_workspace_id = (current_workspace_id + workspaces_per_monitor) %
        (#hl.get_monitors() * workspaces_per_monitor)
    hl.dispatch(hl.dsp.focus({ workspace = next_workspace_id }))
end

for virtual_desktop_id = 1, workspaces_per_monitor do
    local key = virtual_desktop_id % workspaces_per_monitor
    hl.bind(mainMod .. " + " .. key, function()
        if current_virtual_desktop_id == virtual_desktop_id then
            focus_next_monitor()
        else
            focus_on_virtual_desktop(virtual_desktop_id)
        end
    end)
    hl.bind(mainMod .. " + SHIFT + " .. key, function()
        local current_workspace_id = hl.get_active_workspace().id
        local target_monitor = current_workspace_id // workspaces_per_monitor
        local target_workspace = workspaces_per_monitor * target_monitor + virtual_desktop_id
        if target_workspace == current_workspace_id then
            -- Move to next monitor
            target_workspace = (current_workspace_id + workspaces_per_monitor) %
                (#hl.get_monitors() * workspaces_per_monitor)
        end
        hl.dispatch(hl.dsp.window.move({ workspace = target_workspace }))

        focus_on_virtual_desktop(virtual_desktop_id)
    end)
end
