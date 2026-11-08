-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding. o.rebind takes the same arguments as o.bind.
-- This example replaces the default file manager with Flea.
-- o.rebind("SUPER + SHIFT + F", "File manager", { launch = "flea" })

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, { panel = "omarchy.emojis" })

-- Dictation keys from before Alt + Space and Right Alt became the defaults.
-- Remove these lines to give the keys back to applications.
if o.dictation_installed and o.dictation_installed() then
  o.bind("SUPER + CTRL + X", "Toggle dictation", "omarchy-dictation toggle")
  o.bind_hold("F9", "Start dictation (push-to-talk)", "omarchy-dictation start", "Stop dictation (push-to-talk)", "omarchy-dictation stop")
end

-- SUPER+R was Walker before Quattro; it now opens Quattro's app launcher.
-- ~/.local/bin/omarchy-launch-walker opens the same launcher.
o.bind("SUPER + R", "Launch apps", "omarchy-launch-walker")

-- Pin SUPER+1..9 to DP-1 and SUPER+0 to DP-3, from whichever monitor has focus.
-- Omarchy gives each monitor a block of ten workspace ids (DP-1 1-10, DP-3 11-20)
-- and renumbers any workspace outside its block on reload. Hyprland ids also start
-- at 1, so "workspace 0" on DP-3 is id 20, the tenth slot of DP-3's block, named
-- "0" by its rule in monitors.lua. See
-- $OMARCHY_PATH/default/hypr/monitor-workspaces.lua.
-- Id 20 is also used by Brave's rule in windowrule.lua.
for slot = 1, 10 do
  local key = "code:" .. tostring(slot + 9) -- the number row; slot 10 is key 0
  local monitor = slot == 10 and "DP-3" or "DP-1"
  local id = slot == 10 and "20" or tostring(slot)
  local label = slot == 10 and "0" or tostring(slot)

  o.rebind("SUPER + " .. key, "Switch to workspace " .. label .. " (" .. monitor .. ")",
    o.workspaces.focus(slot, monitor))
  o.rebind("SUPER + SHIFT + " .. key, "Move window to workspace " .. label .. " (" .. monitor .. ")",
    hl.dsp.window.move({ workspace = id, follow = true }))
  o.rebind("SUPER + SHIFT + ALT + " .. key, "Move window silently to workspace " .. label .. " (" .. monitor .. ")",
    hl.dsp.window.move({ workspace = id, follow = false }))
end

-- SUPER+LEFT/RIGHT step around one loop across both monitors: 1..9 on DP-1, then
-- workspace 0 (id 20) on DP-3, then back to 1. (Were: focus left/right window.)
-- On a workspace outside the loop, they step through that monitor's workspaces.
function o.step_workspace(delta)
  local step = function()
    local workspace = hl.get_active_workspace()
    local id = workspace and workspace.id or 0
    local slot = id == 20 and 10 or ((id >= 1 and id <= 9) and id or nil)
    if not slot then
      hl.dispatch(hl.dsp.focus({ workspace = delta > 0 and "m+1" or "m-1" }))
      return
    end

    local target = (slot - 1 + delta) % 10 + 1
    o.workspaces.focus(target, target == 10 and "DP-3" or "DP-1")()
  end

  -- Lets the keybindings menu replay the bind.
  o.bind_expressions[step] = "o.step_workspace(" .. delta .. ")"
  return step
end

o.rebind("SUPER + RIGHT", "Next workspace (across monitors)", o.step_workspace(1))
o.rebind("SUPER + LEFT", "Previous workspace (across monitors)", o.step_workspace(-1))
o.rebind("SUPER + TAB", "Next workspace (across monitors)", o.step_workspace(1))
o.rebind("SUPER + SHIFT + TAB", "Previous workspace (across monitors)", o.step_workspace(-1))
o.rebind("SUPER + mouse_down", "Next workspace (across monitors)", o.step_workspace(1))
o.rebind("SUPER + mouse_up", "Previous workspace (across monitors)", o.step_workspace(-1))