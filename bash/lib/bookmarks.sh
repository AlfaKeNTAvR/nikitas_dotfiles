BOOKMARKS_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/nikitas_dotfiles/bookmarks"

_bm_help() {
    cat <<'EOF'
Usage: bm <command> [args]

Commands:
  bmadd [name]   Bookmark current directory (defaults to dir name)
  bmcd <name>    Jump to a bookmark
  bmrm <name>    Remove a bookmark
  bmls           List all bookmarks

Run any command with --help for details.
EOF
}

# Bookmark current directory (replaces existing bookmark with same name)
bmadd() {
    if [[ "${1:-}" == "--help" ]]; then
        echo "Usage: bmadd [name]"
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
bmcd() {
    if [[ "${1:-}" == "--help" ]]; then
        echo "Usage: bmcd <name>"
        echo "  cd to the directory saved under <name>."
        return 0
    fi
    local dir
    dir=$(grep "^${1:?Usage: bmcd <name>}=" "$BOOKMARKS_FILE" 2>/dev/null | cut -d= -f2-)
    if [[ -n "$dir" ]]; then
        cd "$dir"
    else
        echo "bmcd: bookmark '$1' not found" >&2
        return 1
    fi
}

# Remove a bookmark
bmrm() {
    if [[ "${1:-}" == "--help" ]]; then
        echo "Usage: bmrm <name>"
        echo "  Remove the bookmark named <name>."
        return 0
    fi
    local name="${1:?Usage: bmrm <name>}"
    if grep -q "^$name=" "$BOOKMARKS_FILE" 2>/dev/null; then
        grep -v "^$name=" "$BOOKMARKS_FILE" > "$BOOKMARKS_FILE.tmp"
        mv "$BOOKMARKS_FILE.tmp" "$BOOKMARKS_FILE"
        echo "Removed: $name"
    else
        echo "bmrm: bookmark '$name' not found" >&2
        return 1
    fi
}

# List all bookmarks
bmls() {
    if [[ "${1:-}" == "--help" ]]; then
        echo "Usage: bmls"
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
bm() {
    if [[ "${1:-}" == "--help" || -z "${1:-}" ]]; then
        _bm_help
    else
        echo "bm: unknown command '$1'. Run 'bm --help' for usage." >&2
        return 1
    fi
}

# Tab completion for bmcd and bmrm
_bm_complete() {
    local names
    names=$(cut -d= -f1 "$BOOKMARKS_FILE" 2>/dev/null)
    COMPREPLY=( $(compgen -W "$names" -- "${COMP_WORDS[COMP_CWORD]}") )
}
complete -F _bm_complete bmcd bmrm
