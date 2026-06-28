#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_LINE="source \"$DOTFILES_DIR/bash/init.sh\""
BASHRC="$HOME/.bashrc"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nikitas_dotfiles"
DEPS_FILE="$DATA_DIR/installed_deps"
APT_FILES_LOG="$DATA_DIR/added_apt_files"

# Install a package only if missing; record it so uninstall can clean up
ensure_dep() {
    local pkg="$1"
    if ! command -v "$pkg" &>/dev/null; then
        echo "Installing $pkg..."
        sudo apt install -y "$pkg"
        mkdir -p "$(dirname "$DEPS_FILE")"
        echo "$pkg" >> "$DEPS_FILE"
    fi
}

# Add the WezTerm apt repo + signing key if absent. Each file we create is
# recorded in APT_FILES_LOG so uninstall removes only what we added (and never
# a repo/key the machine already had).
ensure_wezterm_repo() {
    local keyring="/usr/share/keyrings/wezterm-fury.gpg"
    local listfile="/etc/apt/sources.list.d/wezterm.list"
    local need_update=0

    if [[ ! -f "$keyring" ]]; then
        echo "Adding WezTerm signing key..."
        curl -fsSL https://apt.fury.io/wez/gpg.key \
            | sudo gpg --yes --dearmor -o "$keyring"
        mkdir -p "$(dirname "$APT_FILES_LOG")"
        echo "$keyring" >> "$APT_FILES_LOG"
        need_update=1
    fi
    if [[ ! -f "$listfile" ]]; then
        echo "Adding WezTerm apt repo..."
        echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' \
            | sudo tee "$listfile" >/dev/null
        mkdir -p "$(dirname "$APT_FILES_LOG")"
        echo "$listfile" >> "$APT_FILES_LOG"
        need_update=1
    fi
    [[ "$need_update" -eq 1 ]] && sudo apt update
}

if grep -qF "$SOURCE_LINE" "$BASHRC" 2>/dev/null; then
    echo "Already installed — nothing to do."
else
    printf '\n# nikitas_dotfiles\n%s\n' "$SOURCE_LINE" >> "$BASHRC"
    echo "Installed. Run: source ~/.bashrc"
fi

ensure_dep fzf

# wezterm lives in its own apt repo, so add that before installing it.
if ! command -v wezterm &>/dev/null; then
    ensure_dep curl
    ensure_wezterm_repo
fi
ensure_dep wezterm
bash "$DOTFILES_DIR/setup/wezterm.sh"
