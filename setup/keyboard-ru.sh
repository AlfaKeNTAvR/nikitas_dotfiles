#!/usr/bin/env bash
# Add the Russian xkb layout next to whatever layouts the machine already has,
# and bind Super+Space to the layout switch. Everything lives in gsettings, so the
# previous values are backed up once and restored by uninstall.sh.
set -euo pipefail

BACKUP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nikitas_dotfiles"
BACKUP="$BACKUP_DIR/gnome-input-sources.bak"

SOURCES_SCHEMA="org.gnome.desktop.input-sources"
KEYBINDINGS_SCHEMA="org.gnome.desktop.wm.keybindings"

# The layout list is a GNOME setting, so a session without it has nothing to
# configure. Skip instead of failing, so the rest of the install still runs.
if ! command -v gsettings >/dev/null 2>&1; then
    echo "gsettings not found - skipping Russian layout (not a GNOME session)."
    exit 0
fi
if ! gsettings writable "$SOURCES_SCHEMA" sources >/dev/null 2>&1; then
    echo "GNOME input-sources schema unavailable - skipping Russian layout."
    exit 0
fi

# Record the current value of one gsettings key, in a "schema key value" line
# that uninstall.sh can feed straight back into `gsettings set`.
append_setting_backup() {
    local schema="$1" key="$2" file="$3"
    printf '%s %s %s\n' "$schema" "$key" "$(gsettings get "$schema" "$key")" >> "$file"
}

# Back up the pre-existing settings once. A second install run must not
# overwrite the backup with the values this script itself wrote.
if [[ ! -f "$BACKUP" ]]; then
    mkdir -p "$BACKUP_DIR"
    tmp="$BACKUP.tmp"
    : > "$tmp"
    append_setting_backup "$SOURCES_SCHEMA" sources "$tmp"
    append_setting_backup "$KEYBINDINGS_SCHEMA" switch-input-source "$tmp"
    append_setting_backup "$KEYBINDINGS_SCHEMA" switch-input-source-backward "$tmp"
    mv "$tmp" "$BACKUP"
fi

current_sources="$(gsettings get "$SOURCES_SCHEMA" sources)"

if grep -qE "\('xkb', *'ru'\)" <<< "$current_sources"; then
    echo "Russian layout already in the input sources."
elif [[ "$current_sources" == "@a(ss) []" || "$current_sources" == "[]" ]]; then
    # An empty list means GNOME falls back to the system default layout, which
    # is not listed anywhere we can append to. Spell out both entries instead.
    gsettings set "$SOURCES_SCHEMA" sources "[('xkb', 'us'), ('xkb', 'ru')]"
    echo "Input sources set to us, ru."
else
    gsettings set "$SOURCES_SCHEMA" sources "${current_sources%]}, ('xkb', 'ru')]"
    echo "Russian layout appended to the existing input sources."
fi

gsettings set "$KEYBINDINGS_SCHEMA" switch-input-source "['<Super>space']"
gsettings set "$KEYBINDINGS_SCHEMA" switch-input-source-backward "['<Shift><Super>space']"

echo "Super+Space switches layouts (takes effect immediately, no logout needed)."
