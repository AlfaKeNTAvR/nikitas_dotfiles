#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_LINE="source \"$DOTFILES_DIR/bash/init.sh\""
BASHRC="$HOME/.bashrc"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nikitas_dotfiles"
DEPS_FILE="$DATA_DIR/installed_deps"
APT_FILES_LOG="$DATA_DIR/added_apt_files"

if grep -qF "$SOURCE_LINE" "$BASHRC" 2>/dev/null; then
    grep -vF "$SOURCE_LINE" "$BASHRC" \
        | grep -v '^# nikitas_dotfiles$' \
        > "$BASHRC.tmp"
    mv "$BASHRC.tmp" "$BASHRC"
    echo "Removed from $BASHRC. Open a new shell to take effect."
else
    echo "Not installed — nothing to do."
fi

WEZTERM_CONFIG="${HOME}/.config/wezterm/wezterm.lua"
WEZTERM_BACKUP="$DATA_DIR/wezterm.lua.bak"
if [[ -f "$WEZTERM_BACKUP" ]]; then
    cp "$WEZTERM_BACKUP" "$WEZTERM_CONFIG"
    rm -f "$WEZTERM_BACKUP"
    echo "Restored original wezterm config."
elif [[ -f "$WEZTERM_CONFIG" ]] && head -n1 "$WEZTERM_CONFIG" | grep -qF 'nikitas_dotfiles managed config'; then
    rm -f "$WEZTERM_CONFIG"
    echo "Removed wezterm config."
fi

if [[ -f "$DEPS_FILE" ]]; then
    while IFS= read -r pkg; do
        # Skip if other installed packages depend on this one
        rdeps="$(apt-cache rdepends --installed "$pkg" 2>/dev/null \
                 | tail -n +3 | sed 's/^ *//' | grep -v "^$pkg$" || true)"
        if [[ -n "$rdeps" ]]; then
            echo "Keeping $pkg — required by: $(echo "$rdeps" | paste -sd ', ')"
        else
            echo "Removing $pkg..."
            sudo apt remove -y "$pkg"
        fi
    done < "$DEPS_FILE"
    rm -f "$DEPS_FILE"
fi

# Remove apt repo/key files we added (and only those). Done after package
# removal so the package is gone first.
if [[ -f "$APT_FILES_LOG" ]]; then
    removed_any=0
    while IFS= read -r f; do
        if [[ -f "$f" ]]; then
            sudo rm -f "$f"
            echo "Removed apt file: $f"
            removed_any=1
        fi
    done < "$APT_FILES_LOG"
    rm -f "$APT_FILES_LOG"
    [[ "$removed_any" -eq 1 ]] && sudo apt update
fi
