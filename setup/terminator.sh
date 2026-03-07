#!/usr/bin/env bash
set -euo pipefail

CONFIG="${HOME}/.config/terminator/config"
mkdir -p "$(dirname "$CONFIG")"
[[ -f "$CONFIG" ]] || touch "$CONFIG"

# Remove existing [keybindings] section, then append desired settings
awk '
    /^\[keybindings\]/ { skip=1; next }
    skip && /^\[/ { skip=0 }
    !skip { print }
' "$CONFIG" > "$CONFIG.tmp"

cat >> "$CONFIG.tmp" <<'EOF'
[keybindings]
  zoom_in = <Primary>equal
  zoom_out = <Primary>minus
  split_horiz = <Alt>underscore
  split_vert = <Alt>plus
EOF

mv "$CONFIG.tmp" "$CONFIG"
echo "Terminator keybindings applied."
