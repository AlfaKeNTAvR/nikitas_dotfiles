#!/usr/bin/env bash
set -euo pipefail

# Installs the JetBrainsMono Nerd Font into the user's font dir (no sudo). The
# Nerd Font glyphs are what make the eza icons, git branch symbol, and tab bar
# render. Everything lands in our own subdir so uninstall can remove it cleanly.

FONT_VER="v3.2.1"
FONT_ZIP="JetBrainsMono.zip"
URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VER}/${FONT_ZIP}"
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/nikitas_dotfiles"

# Already installed by us, or present system-wide — nothing to do.
if { [[ -d "$DEST" ]] && compgen -G "$DEST/*.ttf" >/dev/null; } \
    || fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
    echo "JetBrainsMono Nerd Font already available."
    exit 0
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Downloading JetBrainsMono Nerd Font ${FONT_VER} (~113 MB, one time)..."
curl -fsSL -o "$tmp/$FONT_ZIP" "$URL"

mkdir -p "$DEST"
# Only the standard (ligature) family, four styles — not the Mono/NL/Propo variants.
unzip -o "$tmp/$FONT_ZIP" 'JetBrainsMonoNerdFont-*.ttf' -d "$DEST" >/dev/null

fc-cache -f "$DEST" >/dev/null
echo "JetBrainsMono Nerd Font installed to $DEST"
