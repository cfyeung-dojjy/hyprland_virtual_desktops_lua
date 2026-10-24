-- Virtual desktops: workspace i on every monitor forms virtual desktop i.
-- Monitor m (0-based) owns workspaces m * workspaces_per_monitor + 1 .. (m + 1) * workspaces_per_monitor.

local M = {}

local config = {
    workspaces_per_monitor = 10,
}

-- 0-based monitor group and 1-based virtual desktop of a workspace id.
local function position(workspace_id)
    local n = config.workspaces_per_monitor
    return (workspace_id - 1) // n, (workspace_id - 1) % n + 1
end

local function workspace_id(monitor_idx, virtual_desktop_id)
    return monitor_idx * config.workspaces_per_monitor + virtual_desktop_id
end

-- Whether the focused workspace belongs to virtual desktop i.
function M.is_on_virtual_desktop(i)
    local active = hl.get_active_workspace()
    return active ~= nil and select(2, position(active.id)) == i
end

-- Switch every monitor to virtual desktop i, keeping the focused monitor and cursor position.
function M.switch(i)
    local active = hl.get_active_workspace()
    if active == nil then
        return
    end
    local monitor_idx = position(active.id)
    -- focusing another workspace moves the cursor to its center, so remember where it was
    local cursor_pos = hl.get_cursor_pos()

    for idx = 0, #hl.get_monitors() - 1 do
        hl.dispatch(hl.dsp.focus({ workspace = workspace_id(idx, i) }))
    end
    -- focusing by monitor (hl.get_monitor_at_cursor()) doesn't work, so refocus by workspace
    hl.dispatch(hl.dsp.focus({ workspace = workspace_id(monitor_idx, i) }))

    if cursor_pos ~= nil then
        hl.dispatch(hl.dsp.cursor.move({ x = cursor_pos.x, y = cursor_pos.y }))
    end
end

-- Focus the next (direction = 1) or previous (direction = -1) monitor, staying on the same
-- virtual desktop. Wraps around.
function M.focus_monitor(direction)
    local active = hl.get_active_workspace()
    if active == nil then
        return
    end
    local monitor_idx, virtual_desktop_id = position(active.id)
    local target_idx = (monitor_idx + direction) % #hl.get_monitors()
    hl.dispatch(hl.dsp.focus({ workspace = workspace_id(target_idx, virtual_desktop_id) }))
end

-- Move the active window to workspace target, then switch to virtual desktop i so every
-- monitor stays on the same desktop and focus returns to the current monitor.
local function move_window_to(target, i)
    hl.dispatch(hl.dsp.window.move({ workspace = target }))

    -- local current_window_size = hl.get_active_window().size
    -- if not hl.get_active_window().floating then
    --     -- When moving floating windows, their size is preserved, but not tiled windows
    --     hl.dispatch(hl.dsp.window.resize({}))
    -- end

    M.switch(i)
end

-- Move the active window to virtual desktop i on the current monitor.
function M.move_window(i)
    local active = hl.get_active_workspace()
    if active == nil then
        return
    end
    local monitor_idx = position(active.id)
    move_window_to(workspace_id(monitor_idx, i), i)
end

-- Move the active window to the next (direction = 1) or previous (direction = -1) monitor,
-- staying on the same virtual desktop. Wraps around.
function M.move_window_to_monitor(direction)
    local active = hl.get_active_workspace()
    if active == nil then
        return
    end
    local monitor_idx, virtual_desktop_id = position(active.id)
    local target_idx = (monitor_idx + direction) % #hl.get_monitors()
    move_window_to(workspace_id(target_idx, virtual_desktop_id), virtual_desktop_id)
end

-- Binds no keys; bind the functions above yourself.
-- opts.workspaces_per_monitor: workspaces owned by each monitor (default 10)
function M.setup(opts)
    opts = opts or {}
    config.workspaces_per_monitor = opts.workspaces_per_monitor or config.workspaces_per_monitor
    return M
end

return M
