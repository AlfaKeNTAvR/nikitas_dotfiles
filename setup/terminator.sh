#!/usr/bin/env bash
set -euo pipefail

CONFIG="${HOME}/.config/terminator/config"
BACKUP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nikitas_dotfiles"
BACKUP="$BACKUP_DIR/terminator.config.bak"

mkdir -p "$(dirname "$CONFIG")"
[[ -f "$CONFIG" ]] || touch "$CONFIG"

# Back up the original config (only on first install)
if [[ ! -f "$BACKUP" ]]; then
    mkdir -p "$BACKUP_DIR"
    cp "$CONFIG" "$BACKUP"
fi

# Remove existing [keybindings] section
awk '
    /^\[keybindings\]/ { skip=1; next }
    skip && /^\[/ { skip=0 }
    !skip { print }
' "$CONFIG" > "$CONFIG.tmp"
mv "$CONFIG.tmp" "$CONFIG"

# Remove existing [profiles] section
awk '
    /^\[profiles\]/ { skip=1; next }
    skip && /^\[/ { skip=0 }
    !skip { print }
' "$CONFIG" > "$CONFIG.tmp"
mv "$CONFIG.tmp" "$CONFIG"

# Append desired keybindings and profile settings
cat >> "$CONFIG" <<'EOF'
[keybindings]
  zoom_in = <Primary>equal
  zoom_out = <Primary>minus
  split_horiz = <Alt>underscore
  split_vert = <Alt>plus
[profiles]
  [[default]]
    icon_bell = False
    scroll_on_output = False
EOF

echo "Terminator settings applied."
