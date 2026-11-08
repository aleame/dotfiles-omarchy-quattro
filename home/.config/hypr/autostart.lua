-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Personal apps at login. Workspace ids match bindings.lua: 1-9 are on DP-1.
-- Brave needs no workspace here: its rule in windowrule.lua sends it to
-- workspace 0 on DP-3 (id 20). It waits a few seconds so the others open first.
hl.on("hyprland.start", function()
  o.focus_alacritty_after_brave = true
  hl.exec_cmd("sleep 5 && " .. o.launch("brave"))
  hl.exec_cmd(o.launch("alacritty"), { workspace = "1" })
  hl.exec_cmd("sleep 5 && " .. o.launch("nemo"), { workspace = "3 silent" })
  -- -silent starts Steam in the tray, with no window.
  hl.exec_cmd("sleep 20 && " .. o.launch("steam -silent"))
  -- -startintray starts Telegram in the tray, with no window.
  hl.exec_cmd("sleep 15 && " .. o.launch("Telegram -startintray"))

  -- Brave windows opened later still take focus as usual.
  hl.timer(function()
    o.focus_alacritty_after_brave = false
  end, { timeout = 60000, type = "oneshot" })
end)

-- Brave's rule takes focus to DP-3 when its first window opens at login, so
-- bring it back to workspace 1, where Alacritty is.
hl.on("window.open", function(window)
  if not (o.focus_alacritty_after_brave and window and window.class == "brave-browser") then return end
  o.focus_alacritty_after_brave = false
  hl.timer(function()
    o.workspaces.focus(1, "DP-1")()
  end, { timeout = 300, type = "oneshot" })
end)
