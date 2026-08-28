#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_LINE="source \"$DOTFILES_DIR/bash/init.sh\""
BASHRC="$HOME/.bashrc"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nikitas_dotfiles"
DEPS_FILE="$DATA_DIR/installed_deps"
APT_FILES_LOG="$DATA_DIR/added_apt_files"

# Optional components, in install order. The shell integration (source line in
# ~/.bashrc) is not listed: it is the point of the repo and always installed.
COMPONENT_IDS=(fzf wezterm fonts clipboard)

component_label() {
    case "$1" in
        fzf)       echo "fzf - Ctrl+R fuzzy history search" ;;
        wezterm)   echo "WezTerm terminal + managed config" ;;
        fonts)     echo "eza + Nerd Font icons (113 MB download)" ;;
        clipboard) echo "xclip + wl-clipboard clipboard bridge" ;;
        *)         echo "$1" ;;
    esac
}

# ---------------------------------------------------------------- packages ---

# True only when the apt package is fully installed. Checked instead of the
# binary name because a package need not ship a binary matching its own name
# (wl-clipboard provides wl-copy/wl-paste), and dpkg still knows packages that
# were removed but left their config behind.
is_pkg_installed() {
    local pkg="$1"
    [[ "$(dpkg-query -W -f='${db:Status-Status}' "$pkg" 2>/dev/null)" == "installed" ]]
}

# Install a package only if missing; record it so uninstall can clean up
ensure_dep() {
    local pkg="$1"
    if ! is_pkg_installed "$pkg"; then
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
    return 0
}

# ------------------------------------------------------------- components ---

install_shell_integration() {
    if grep -qF "$SOURCE_LINE" "$BASHRC" 2>/dev/null; then
        echo "Shell integration already in $BASHRC - nothing to do."
    else
        printf '\n# nikitas_dotfiles\n%s\n' "$SOURCE_LINE" >> "$BASHRC"
        echo "Shell integration added to $BASHRC."
    fi
}

install_fzf() {
    ensure_dep fzf
}

install_wezterm() {
    # wezterm lives in its own apt repo, so add that before installing it.
    if ! is_pkg_installed wezterm; then
        ensure_dep curl
        ensure_wezterm_repo
    fi
    ensure_dep wezterm
    bash "$DOTFILES_DIR/setup/wezterm.sh"
}

install_fonts() {
    # eza powers the ls icons; the Nerd Font (via fonts.sh) renders them.
    ensure_dep eza
    ensure_dep curl
    ensure_dep unzip
    bash "$DOTFILES_DIR/setup/fonts.sh"

    # The Nerd Font covers the icon glyphs but not the Misc Technical media-control
    # block (U+23E9-U+23FA), which shows as tofu without it. Noto Sans Symbols 2
    # covers that range; WezTerm picks it up through fontconfig fallback, so no
    # wezterm.lua change is needed.
    ensure_dep fonts-noto-core
}

install_clipboard() {
    # Clipboard bridge for terminal tools that read images/text off the clipboard
    # (e.g. pasting an image into Claude Code). They probe xclip first, then
    # wl-paste, so both are installed to cover X11 and Wayland sessions alike.
    ensure_dep xclip
    ensure_dep wl-clipboard
}

install_component() {
    case "$1" in
        fzf)       install_fzf ;;
        wezterm)   install_wezterm ;;
        fonts)     install_fonts ;;
        clipboard) install_clipboard ;;
        *)         echo "Unknown component: $1" >&2; return 1 ;;
    esac
}

# -------------------------------------------------------------- selection ---

# Components a preset installs, one per line. "full" is the historical
# behaviour (everything); "minimal" is a shell-only setup that touches the
# machine as little as possible.
resolve_preset() {
    case "$1" in
        full)    printf '%s\n' "${COMPONENT_IDS[@]}" ;;
        minimal) printf '%s\n' fzf ;;
        *)       echo "Unknown preset: $1" >&2; return 1 ;;
    esac
}

# Turn a user-typed answer ("1,3" / "1 3" / "" / "none") into component ids.
# Empty input means "all", matching the [Enter] = accept-defaults convention.
parse_component_choice() {
    local input="$1"
    local -a picked=()
    local token index

    input="${input//,/ }"
    if [[ -z "${input// /}" ]]; then
        printf '%s\n' "${COMPONENT_IDS[@]}"
        return 0
    fi
    if [[ "${input,,}" == "none" ]]; then
        return 0
    fi

    for token in $input; do
        if [[ ! "$token" =~ ^[0-9]+$ ]]; then
            echo "Not a number: $token" >&2
            return 1
        fi
        index=$(( token - 1 ))
        if (( index < 0 || index >= ${#COMPONENT_IDS[@]} )); then
            echo "Out of range: $token" >&2
            return 1
        fi
        picked+=("${COMPONENT_IDS[index]}")
    done
    printf '%s\n' "${picked[@]}"
}

choose_components_whiptail() {
    local -a entries=()
    local id selection
    for id in "${COMPONENT_IDS[@]}"; do
        entries+=("$id" "$(component_label "$id")" ON)
    done

    # whiptail draws on stdout, so its result is swapped onto fd 3.
    selection="$(whiptail --title "nikitas_dotfiles" \
        --checklist "Space toggles, Enter confirms:" \
        16 72 "${#COMPONENT_IDS[@]}" \
        "${entries[@]}" 3>&1 1>&2 2>&3)" || return 1

    tr -d '"' <<< "$selection" | tr ' ' '\n' | grep -v '^$' || true
}

choose_components_plain() {
    local id answer index=1
    {
        echo
        echo "Components:"
        for id in "${COMPONENT_IDS[@]}"; do
            printf '  %d) %s\n' "$index" "$(component_label "$id")"
            index=$(( index + 1 ))
        done
        echo
    } >&2

    while true; do
        read -r -p "Pick numbers (space/comma separated, Enter = all, 'none' = shell only): " answer >&2
        if parse_component_choice "$answer"; then
            return 0
        fi
    done
}

choose_preset_whiptail() {
    whiptail --title "nikitas_dotfiles" --menu "Installation mode:" 15 72 3 \
        full    "Everything (recommended)" \
        minimal "Shell config + fzf history search only" \
        custom  "Pick components" 3>&1 1>&2 2>&3
}

choose_preset_plain() {
    local answer
    {
        echo
        echo "Installation mode:"
        echo "  1) full    - everything (recommended)"
        echo "  2) minimal - shell config + fzf history search only"
        echo "  3) custom  - pick components"
        echo
    } >&2
    while true; do
        read -r -p "Mode [1]: " answer >&2
        case "${answer:-1}" in
            1|full)    echo full;    return 0 ;;
            2|minimal) echo minimal; return 0 ;;
            3|custom)  echo custom;  return 0 ;;
            *)         echo "Pick 1, 2 or 3." >&2 ;;
        esac
    done
}

# Filled by select_components. A global array rather than a printed list so the
# dialog keeps the real terminal on stdin/stdout: run inside a command
# substitution, whiptail would see a pipe and refuse to draw.
SELECTED_COMPONENTS=()

set_components_from_lines() {
    SELECTED_COMPONENTS=()
    local line
    while IFS= read -r line; do
        [[ -n "$line" ]] && SELECTED_COMPONENTS+=("$line")
    done <<< "$1"
}

# Ask what to install and record it in SELECTED_COMPONENTS. Without a terminal
# (piped installer, CI) there is nobody to ask, so the historical full install
# is used unchanged.
select_components() {
    local preset selection

    if [[ ! -t 0 || ! -t 1 ]]; then
        echo "No terminal for the installer dialog - installing everything."
        set_components_from_lines "$(resolve_preset full)"
        return 0
    fi

    if command -v whiptail >/dev/null 2>&1; then
        preset="$(choose_preset_whiptail)" || { echo "Cancelled." >&2; return 1; }
        if [[ "$preset" != custom ]]; then
            set_components_from_lines "$(resolve_preset "$preset")"
            return 0
        fi
        selection="$(choose_components_whiptail)" || { echo "Cancelled." >&2; return 1; }
    else
        preset="$(choose_preset_plain)"
        if [[ "$preset" != custom ]]; then
            set_components_from_lines "$(resolve_preset "$preset")"
            return 0
        fi
        selection="$(choose_components_plain)"
    fi
    set_components_from_lines "$selection"
}

# ------------------------------------------------------------------- main ---

main() {
    local id
    select_components

    install_shell_integration
    for id in "${SELECTED_COMPONENTS[@]}"; do
        install_component "$id"
    done

    echo
    if (( ${#SELECTED_COMPONENTS[@]} > 0 )); then
        echo "Installed: shell integration, ${SELECTED_COMPONENTS[*]}"
    else
        echo "Installed: shell integration only."
    fi
    echo "Run: source ~/.bashrc"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
