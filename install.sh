#!/bin/bash
# Install these dotfiles into $HOME on an Omarchy Quattro system.
# Any existing file that differs is kept next to it as <file>.bak.<timestamp>.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/home"
stamp="$(date +%s)"

cd "$src"
find . -type f -print0 | while IFS= read -r -d '' file; do
  rel="${file#./}"
  target="$HOME/$rel"
  mkdir -p "$(dirname "$target")"
  if [[ -e $target ]] && ! cmp -s "$file" "$target"; then
    cp -a "$target" "$target.bak.$stamp"
    echo "backed up ~/$rel -> ~/$rel.bak.$stamp"
  fi
  cp "$file" "$target"
done

chmod +x "$HOME/.local/bin/omarchy-launch-walker" "$HOME"/.config/omarchy/bar/scripts/* \
  "$HOME/.config/alacritty/print_colors.sh"

# The bar font: a renamed copy of JetBrainsMono Nerd Font Bold.
fc-cache -f "$HOME/.local/share/fonts" >/dev/null

# Icon theme Yaru+FlatRemix+Plus. Omarchy's app launcher ignores the selected
# theme and takes the first icon it finds, searching ~/.icons before
# ~/.local/share/icons, so the theme lives in ~/.icons to win, with a link at
# its usual path.
icon_theme="Custom-Yaru-FlatRemix"
icon_dir="$HOME/.icons/$icon_theme"
icon_link="$HOME/.local/share/icons/$icon_theme"
if [[ ! -d $icon_dir ]]; then
  mkdir -p "$HOME/.icons"
  if [[ -d $icon_link && ! -L $icon_link ]]; then
    mv "$icon_link" "$icon_dir"
  else
    git clone git@github.com:aleame/Yaru-FlatRemix-Plus.git "$icon_dir" \
      || git clone https://github.com/aleame/Yaru-FlatRemix-Plus.git "$icon_dir"
  fi
fi
if [[ ! -e $icon_link ]]; then
  mkdir -p "$(dirname "$icon_link")"
  ln -s "$icon_dir" "$icon_link"
fi
gsettings set org.gnome.desktop.interface icon-theme "$icon_theme"
for ini in "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"; do
  [[ -f $ini ]] && sed -i "s/^gtk-icon-theme-name=.*/gtk-icon-theme-name=$icon_theme/" "$ini"
done
xsettings="$HOME/.config/xsettingsd/xsettingsd.conf"
[[ -f $xsettings ]] && sed -i "s/^Net\/IconThemeName .*/Net\/IconThemeName \"$icon_theme\"/" "$xsettings"

# Zsh plugins and the Powerlevel10k prompt, sourced by ~/.zshrc.
clone_if_missing() {
  [[ -d $2 ]] || git clone --depth 1 "$1" "$2"
}
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-completions.git "$HOME/.zsh/zsh-completions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh/zsh-syntax-highlighting"
clone_if_missing https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"
[[ -f $HOME/.zshrc.secrets ]] || echo "Note: create ~/.zshrc.secrets for private exports (BrowserStack credentials)."

# Notification sound, played for Omarchy notifications.
systemctl --user daemon-reload
systemctl --user enable --now notification-sound.service

# Omarchy notifications replace SwayNC; keep SwayNC from starting if installed.
if systemctl --user cat swaync.service >/dev/null 2>&1; then
  systemctl --user disable --now swaync.service || true
  systemctl --user mask swaync.service || true
fi

if command -v hyprctl >/dev/null && [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  hyprctl reload >/dev/null
  errors="$(hyprctl configerrors)"
  [[ -n $errors ]] && echo "Hyprland config errors:" && echo "$errors"
  omarchy restart shell
fi

echo "Done. Weather location is not included; set it with:"
echo "  omarchy-weather-location --set \"<place>\" \"<lat>,<lon>\""
