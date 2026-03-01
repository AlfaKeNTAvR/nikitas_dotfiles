#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_LINE="source \"$DOTFILES_DIR/bash/init.sh\""
BASHRC="$HOME/.bashrc"
DEPS_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/nikitas_dotfiles/installed_deps"

if grep -qF "$SOURCE_LINE" "$BASHRC" 2>/dev/null; then
    grep -vF "$SOURCE_LINE" "$BASHRC" \
        | grep -v '^# nikitas_dotfiles$' \
        > "$BASHRC.tmp"
    mv "$BASHRC.tmp" "$BASHRC"
    echo "Removed from $BASHRC. Open a new shell to take effect."
else
    echo "Not installed — nothing to do."
fi

if [[ -f "$DEPS_FILE" ]]; then
    while IFS= read -r pkg; do
        echo "Removing $pkg..."
        sudo apt remove -y "$pkg"
    done < "$DEPS_FILE"
    rm -f "$DEPS_FILE"
fi
