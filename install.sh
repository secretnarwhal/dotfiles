#!/usr/bin/env bash
# =============================================================================
#  secretnarwhal's Arch + Hyprland setup — full replication installer
#
#  Run on a fresh Arch Linux install (base + base-devel + git), as your normal
#  user (NOT root), from inside the cloned repo:
#
#      git clone https://github.com/secretnarwhal/dotfiles.git ~/dotfiles
#      cd ~/dotfiles && ./install.sh
#
#  The repo MUST live at ~/dotfiles (configs reference ~/dotfiles via symlinks).
# =============================================================================
set -euo pipefail

DOTFILES="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

PINK="\e[35m"; RESET="\e[0m"; YELLOW="\e[33m"; GREEN="\e[32m"; RED="\e[31m"
step()  { echo -e "\n${PINK}────────────────────────────────────────────────────────────\n${YELLOW}[$1]${PINK} $2\n────────────────────────────────────────────────────────────${RESET}"; }
info()  { echo -e "${GREEN}  ->${RESET} $*"; }
warn()  { echo -e "${RED}  !!${RESET} $*"; }
ask()   { local a; read -r -p "$(echo -e "${YELLOW}  ?? $1 [y/N]: ${RESET}")" a; [[ "$a" =~ ^[yY] ]]; }

# --- Sanity checks -----------------------------------------------------------
[[ $EUID -eq 0 ]] && { warn "Run as your normal user, not root."; exit 1; }
[[ -f /etc/arch-release ]] || { warn "This installer targets Arch Linux."; exit 1; }
[[ "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" == "$DOTFILES" ]] || {
    warn "Clone this repo to $DOTFILES and run it from there."; exit 1; }

echo -e "${PINK}
  This will install every package and config needed to replicate the setup:
  Hyprland (Lua config), ghostty, waybar, rofi, swaync, wlogout, hyprlock,
  hypridle, awww, ly, zsh + oh-my-posh, nvim, tmux, fonts, cursors, themes,
  wallpapers, GRUB theme, fingerprint PAM, PipeWire channel-swap sink.${RESET}"
ask "Continue?" || exit 1

cd "$DOTFILES"

# --- 1. pacman.conf: enable multilib (steam, proton, wine deps) --------------
step 1/12 "Enable [multilib] + parallel downloads"
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
    info "multilib enabled"
fi
sudo sed -i 's/^#\?ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf
sudo pacman -Syu --noconfirm

# --- 2. yay (AUR helper) -----------------------------------------------------
step 2/12 "Install yay"
if ! command -v yay >/dev/null; then
    sudo pacman -S --needed --noconfirm git base-devel
    tmp=$(mktemp -d)
    git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
fi

# --- 3. Packages -------------------------------------------------------------
step 3/12 "Install official-repo packages (packages/pacman.txt)"
# Skip anything no longer in the repos instead of aborting the whole transaction
mapfile -t available < <(comm -12 <(sort -u packages/pacman.txt) <(pacman -Slq | sort -u))
mapfile -t missing   < <(comm -23 <(sort -u packages/pacman.txt) <(pacman -Slq | sort -u))
((${#missing[@]})) && warn "Not in repos (skipped): ${missing[*]}"
sudo pacman -S --needed --noconfirm "${available[@]}"

step 4/12 "Install AUR packages (packages/aur.txt)"
mapfile -t aur < packages/aur.txt
yay -S --needed --noconfirm "${aur[@]}" || warn "Some AUR packages failed — re-run: yay -S --needed - < packages/aur.txt"

# --- 5. tmux plugin manager --------------------------------------------------
step 5/12 "Clone TPM (tmux plugin manager)"
[[ -d .tmux/plugins/tpm ]] || git clone --depth 1 https://github.com/tmux-plugins/tpm .tmux/plugins/tpm
info "Inside tmux press  prefix + I  once to fetch catppuccin-tmux"

# --- 6. Stow dotfiles --------------------------------------------------------
step 6/12 "Symlink dotfiles into \$HOME with GNU stow"
# Pre-create parents so stow links leaf directories instead of whole trees
mkdir -p "$HOME/.config" "$HOME/.local/share/icons" "$HOME/.local/bin" "$HOME/Pictures/Screenshots"
chmod +x .config/viegphunt/*.sh
# Move any pre-existing conflicting files out of the way
conflicts=$(stow -n -v -t "$HOME" . 2>&1 | sed -nE \
    -e 's/.*existing target is neither a link nor a directory: (.+)$/\1/p' \
    -e 's/.*over existing target (.+) since.*/\1/p' | sort -u)
if [[ -n "$conflicts" ]]; then
    info "Backing up conflicting files to $BACKUP_DIR"
    while IFS= read -r f; do
        mkdir -p "$BACKUP_DIR/$(dirname "$f")"
        mv "$HOME/$f" "$BACKUP_DIR/$f"
    done <<< "$conflicts"
fi
stow -v -t "$HOME" .
[[ -f "$HOME/.zshrc.local" ]] || echo "# Machine-local zsh config (not tracked in git)" > "$HOME/.zshrc.local"

# --- 7. Wallpapers + lockscreen background ----------------------------------
step 7/12 "Wallpapers -> ~/Pictures/Wallpapers"
mkdir -p "$HOME/Pictures/Wallpapers" "$HOME/.cache/awww"
cp -n wallpapers/* "$HOME/Pictures/Wallpapers/"
# hyprlock reads ~/.cache/awww/normal.png (regenerated whenever you change wallpaper)
vipsthumbnail "$HOME/Pictures/Wallpapers/147314954_p0.jpg" -o "$HOME/.cache/awww/normal.png" || true

# --- 8. Cursor, GTK/icon theme, fonts ---------------------------------------
step 8/12 "Cursor / themes / fonts"
# System-wide fallback cursor = macOS (apple_cursor); per-user default = Plana
# (shipped in .icons/default/index.theme + .local/share/icons/Plana via stow)
echo -e "[icon theme]\nInherits=macOS" | sudo tee /usr/share/icons/default/index.theme >/dev/null
fc-cache -f
if [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    "$DOTFILES/.config/viegphunt/gtkthemes.sh"
    gsettings set org.cinnamon.desktop.default-applications.terminal exec ghostty
    gsettings set org.cinnamon.desktop.default-applications.terminal exec-arg '--working-directory'
else
    info "No D-Bus session: gtkthemes.sh will apply on first Hyprland login (it's in autostart)."
    info "After first login also run: gsettings set org.cinnamon.desktop.default-applications.terminal exec ghostty"
fi

# --- 9. Default shell --------------------------------------------------------
step 9/12 "Default shell -> zsh"
[[ "$(getent passwd "$USER" | cut -d: -f7)" == */zsh ]] || chsh -s "$(command -v zsh)"

# --- 10. Services ------------------------------------------------------------
step 10/12 "Enable services"
sudo systemctl enable bluetooth.service NetworkManager.service power-profiles-daemon.service cronie.service systemd-timesyncd.service
# ly display manager on tty2 (this setup does NOT use sddm even though it's installed)
if [[ -e /etc/systemd/system/display-manager.service ]]; then
    warn "Another display manager is enabled ($(readlink -f /etc/systemd/system/display-manager.service)); disable it to use ly."
fi
sudo systemctl disable getty@tty2.service 2>/dev/null || true
sudo systemctl enable ly@tty2.service
systemctl --user enable hypridle.service || true

# --- 11. Optional system files (GRUB theme, fingerprint PAM) ----------------
step 11/12 "System configs (optional)"
if [[ -d /boot/grub ]] && ask "Apply GRUB config (Vimix theme, 5s menu, os-prober on)?"; then
    sudo cp /etc/default/grub "/etc/default/grub.bak.$(date +%s)"
    sudo cp system/etc/default/grub /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
if ! grep -q pam_fprintd /etc/pam.d/system-auth && ask "Enable fingerprint auth in PAM (sudo/hyprlock/login)?"; then
    sudo cp /etc/pam.d/system-auth "/etc/pam.d/system-auth.bak.$(date +%s)"
    sudo cp system/etc/pam.d/system-auth /etc/pam.d/system-auth
    info "Enroll a finger with:  fprintd-enroll"
fi

# --- 12. Extras: waybar VPN module + PipeWire channel swap -------------------
step 12/12 "Extras"
for s in vpn-status.sh vpn-toggle.sh; do
    [[ -e "$HOME/.local/bin/$s" ]] || install -m755 "extras/vpn/$s" "$HOME/.local/bin/$s"
done
info "Edit ~/.local/bin/vpn-toggle.sh with your own swanctl connection names (see comments)."
info "Headphone L/R swap sink: see AUDIO_SWAP_DOCS.md (Super+F10 toggles it)."

echo -e "\n${GREEN}
  Done. Reboot, log in through ly (tty2) and pick the Hyprland session.
  First login: press Super+W and pick 147314954_p0 to restore the exact wallpaper.
  Old conflicting files (if any) were moved to: $BACKUP_DIR${RESET}\n"
