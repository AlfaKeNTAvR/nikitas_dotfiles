#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_CONFIG="$DOTFILES_DIR/wezterm/wezterm.lua"
CONFIG="${HOME}/.config/wezterm/wezterm.lua"
BACKUP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nikitas_dotfiles"
BACKUP="$BACKUP_DIR/wezterm.lua.bak"

mkdir -p "$(dirname "$CONFIG")"

# Back up a pre-existing config once, so uninstall can restore it. If there is
# no existing config, no backup is made and uninstall knows the file is ours.
if [[ ! -f "$BACKUP" && -f "$CONFIG" ]]; then
    mkdir -p "$BACKUP_DIR"
    cp "$CONFIG" "$BACKUP"
fi

cp "$SOURCE_CONFIG" "$CONFIG"

echo "wezterm settings applied."
