#!/usr/bin/env bash
# Refresh this repo from the live system.
#
# Most configs (hypr, waybar, rofi, nvim, ghostty, ...) are already symlinked
# into ~/dotfiles by stow, so edits land here automatically. This script
# re-copies the files that live as regular files on the original machine and
# re-exports the package lists. Review with `git diff` before committing.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

copy() { # copy <live path relative to $HOME>
    local src="$HOME/$1"
    [[ -L "$src" ]] && return 0          # already stowed -> nothing to do
    [[ -e "$src" ]] || { echo "skip (missing): $1"; return 0; }
    mkdir -p "$(dirname "$1")"
    cp -a "$src" "$1"
}

files=(
    .gtkrc-2.0
    .icons/default/index.theme
    .config/gtk-3.0/settings.ini .config/gtk-3.0/gtk.css .config/gtk-3.0/colors.css
    .config/gtk-4.0/settings.ini .config/gtk-4.0/gtk.css .config/gtk-4.0/colors.css
    .config/pipewire/pipewire.conf.d/headphone-swap.conf
    .config/fcitx5/profile .config/fcitx5/conf/notifications.conf
    .config/xsettingsd/xsettingsd.conf
    .config/lazygit/config.yml
    .config/mimeapps.list
    .config/starship.toml
)
for f in "${files[@]}"; do copy "$f"; done

# Cursor themes
for c in Plana Catppuccin-Mocha-Mauve-Cursors; do
    [[ -L "$HOME/.local/share/icons/$c" ]] || rsync -a --delete "$HOME/.local/share/icons/$c/" ".local/share/icons/$c/"
done

# Wallpapers (add new ones, drop removed ones)
rsync -a --delete "$HOME/Pictures/Wallpapers/" wallpapers/

# Packages (explicitly installed)
pacman -Qqen > packages/pacman.txt
pacman -Qqem | grep -vxE 'yay|yay-debug' > packages/aur.txt

# System files
cp /etc/default/grub system/etc/default/grub
cp /etc/pam.d/system-auth system/etc/pam.d/system-auth
cp /etc/pacman.conf system/etc/pacman.conf

git status --short
