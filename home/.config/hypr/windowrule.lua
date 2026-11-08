-- windowrules.lua
-- Migrated from windowrule.conf (hyprlang) to Hyprland Lua config (0.55+)
-- Rules are evaluated top to bottom, so order matters.

-- Opacity preset used by several editors: active 1, inactive 0.9, fullscreen 0.9 (all absolute)
local editor_opacity = "1 override 0.9 override 0.9 override"

-- Small dialog preset: floating, centered, 500x100
local function small_dialog(title)
  hl.window_rule({
    match  = { title = title },
    float  = true,
    center = true,
    size   = { 500, 100 },
  })
end

--------------------------------------------------------------------------------
-- Apps
--------------------------------------------------------------------------------
hl.window_rule({ match = { class = "org.telegram.desktop" }, float = true, size = { 1200, 800 } })
hl.window_rule({ match = { class = "Docker Desktop" },       float = true, size = { 1200, 800 } })
hl.window_rule({ match = { class = "nemo", title = ".*Properties" }, float = true })
hl.window_rule({ match = { class = "microsoft-edge" }, fullscreen = true, opacity = "1" })
hl.window_rule({ match = { class = "brave-browser" }, workspace = "20", opacity = "1" }) -- DP-3's workspace (see bindings.lua)
hl.window_rule({ match = { class = "Postman" },       opacity = "1" })
hl.window_rule({ match = { class = "steam_app_.*" },  opacity = "1 override" })
hl.window_rule({ match = { class = "piper" }, float = true, size = { 1200, 800 } })
hl.window_rule({
  match   = { class = "io.github.amit9838.mousam" },
  float   = true,
  size    = { 1200, 800 },
  opacity = "0.8",
})

--------------------------------------------------------------------------------
-- Develop
--------------------------------------------------------------------------------
-- hl.window_rule({ match = { class = "code" }, workspace = "2 silent", opacity = editor_opacity })

for _, class in ipairs({
  "antigravity",
  "codium",
  "OpenCode",
  "obsidian",
  "dev.zed.Zed",
}) do
  hl.window_rule({ match = { class = class }, opacity = editor_opacity })
end

hl.window_rule({ match = { class = "jetbrains-idea" }, opacity = "1" })

--------------------------------------------------------------------------------
-- Media
--------------------------------------------------------------------------------
hl.window_rule({ match = { class = "mpv" }, fullscreen = true })
hl.window_rule({ match = { class = "vlc", title = ".*VLC media player" }, fullscreen = true })
-- hl.window_rule({ match = { class = "spotify" }, float = true, size = { 1200, 800 } })
hl.window_rule({ match = { class = "com.github.PintaProject.Pinta" }, float = true, size = { 1520, 820 } })
hl.window_rule({ match = { class = "org.kde.kolourpaint" },           float = true, size = { 1520, 800 } })
small_dialog("Resize / Scale — KolourPaint")
small_dialog("Save Image As — KolourPaint")

--------------------------------------------------------------------------------
-- Gnome
--------------------------------------------------------------------------------
hl.window_rule({ match = { class = "org.gnome.Calendar" },   float = true, size = { 1200, 800 }, opacity = "0.8" })
hl.window_rule({ match = { class = "org.gnome.Weather" },    float = true, size = { 1200, 800 }, opacity = "0.8" })
hl.window_rule({ match = { class = "org.gnome.Loupe" },      fullscreen = true })
hl.window_rule({ match = { class = "org.gnome.TextEditor" }, float = true, size = { 1200, 800 } })
hl.window_rule({ match = { class = "org.gnome.Characters" }, float = true, size = { 1000, 800 }, opacity = "0.8" })

--------------------------------------------------------------------------------
-- Utils
--------------------------------------------------------------------------------
hl.window_rule({ match = { class = "io.missioncenter.MissionCenter" }, float = true, size = { 1200, 800 } })
hl.window_rule({ match = { class = "nm-connection-editor" }, float = true })
hl.window_rule({
  match   = { class = "org.qbittorrent.qBittorrent" },
  float   = true,
  size    = { 1420, 800 },
  opacity = "0.9",
})
small_dialog([[Remove torrent\(s\)]])  -- [[ ]] keeps the regex backslashes literal
small_dialog("About qBittorrent")
small_dialog("Renaming")
hl.window_rule({ match = { class = "kitty" }, opacity = "0.8" })
hl.window_rule({ match = { class = "org.kde.kdeconnect.app" }, float = true, size = { 1200, 800 } })
hl.window_rule({ match = { class = "xdg-desktop-portal-gtk" }, float = true, size = { 1200, 800 } })
hl.window_rule({ match = { class = "nwg-look" },               float = true, size = { 1200, 800 } })
hl.window_rule({
  match = { class = "virt-manager", title = ".* QEMU/KVM" },
  float = true,
  size  = { 1420, 820 },
})
hl.window_rule({ match = { class = "fdm" }, float = true, size = { 1420, 800 }, opacity = "0.9" })