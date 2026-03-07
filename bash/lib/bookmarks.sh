BOOKMARKS_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/nikitas_dotfiles/bookmarks"

_b_help() {
    cat <<'EOF'
Usage: b [--help]

Commands:
  badd [name]   Bookmark current directory (defaults to dir name)
  bcd <name>    Jump to a bookmark
  brm <name>    Remove a bookmark
  bls           List all bookmarks

Run any command with --help for details.
EOF
}

# Bookmark current directory (replaces existing bookmark with same name)
badd() {
    if [[ "${1:-}" == "--help" ]]; then
        echo "Usage: badd [name]"
        echo "  Bookmark current directory. Defaults to the directory name."
        return 0
    fi
    local name="${1:-$(basename "$PWD")}"
    mkdir -p "$(dirname "$BOOKMARKS_FILE")"
    if [[ -f "$BOOKMARKS_FILE" ]]; then
        grep -v "^$name=" "$BOOKMARKS_FILE" > "$BOOKMARKS_FILE.tmp"
        mv "$BOOKMARKS_FILE.tmp" "$BOOKMARKS_FILE"
    fi
    echo "$name=$PWD" >> "$BOOKMARKS_FILE"
    echo "Bookmarked: $name -> $PWD"
}

# Jump to a bookmark
bcd() {
    if [[ "${1:-}" == "--help" ]]; then
        echo "Usage: bcd <name>"
        echo "  cd to the directory saved under <name>."
        return 0
    fi
    local dir
    dir=$(grep "^${1:?Usage: bcd <name>}=" "$BOOKMARKS_FILE" 2>/dev/null | cut -d= -f2-)
    if [[ -n "$dir" ]]; then
        cd "$dir"
    else
        echo "bcd: bookmark '$1' not found" >&2
        return 1
    fi
}

# Remove a bookmark
brm() {
    if [[ "${1:-}" == "--help" ]]; then
        echo "Usage: brm <name>"
        echo "  Remove the bookmark named <name>."
        return 0
    fi
    local name="${1:?Usage: brm <name>}"
    if grep -q "^$name=" "$BOOKMARKS_FILE" 2>/dev/null; then
        grep -v "^$name=" "$BOOKMARKS_FILE" > "$BOOKMARKS_FILE.tmp"
        mv "$BOOKMARKS_FILE.tmp" "$BOOKMARKS_FILE"
        echo "Removed: $name"
    else
        echo "brm: bookmark '$name' not found" >&2
        return 1
    fi
}

# List all bookmarks
bls() {
    if [[ "${1:-}" == "--help" ]]; then
        echo "Usage: bls"
        echo "  List all saved bookmarks."
        return 0
    fi
    if [[ -f "$BOOKMARKS_FILE" ]]; then
        cat "$BOOKMARKS_FILE"
    else
        echo "No bookmarks saved."
    fi
}

# Top-level help
b() {
    if [[ "${1:-}" == "--help" || -z "${1:-}" ]]; then
        _b_help
    else
        echo "b: unknown command '$1'. Run 'b --help' for usage." >&2
        return 1
    fi
}

# Tab completion for bcd and brm
_b_complete() {
    local names
    names=$(cut -d= -f1 "$BOOKMARKS_FILE" 2>/dev/null)
    COMPREPLY=( $(compgen -W "$names" -- "${COMP_WORDS[COMP_CWORD]}") )
}
complete -F _b_complete bcd brm
