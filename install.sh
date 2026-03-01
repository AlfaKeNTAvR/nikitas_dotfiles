#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_LINE="source \"$DOTFILES_DIR/bash/init.sh\""
BASHRC="$HOME/.bashrc"
DEPS_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/nikitas_dotfiles/installed_deps"

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

if grep -qF "$SOURCE_LINE" "$BASHRC" 2>/dev/null; then
    echo "Already installed — nothing to do."
else
    printf '\n# nikitas_dotfiles\n%s\n' "$SOURCE_LINE" >> "$BASHRC"
    echo "Installed. Run: source ~/.bashrc"
fi

ensure_dep fzf
