BOOKMARKS_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/nikitas_dotfiles/bookmarks"

# Bookmark current directory (replaces existing bookmark with same name)
bm() {
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
bj() {
    local dir
    dir=$(grep "^${1:?Usage: bj <name>}=" "$BOOKMARKS_FILE" 2>/dev/null | cut -d= -f2-)
    if [[ -n "$dir" ]]; then
        cd "$dir"
    else
        echo "bj: bookmark '$1' not found" >&2
        return 1
    fi
}

# Remove a bookmark
brm() {
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

# Tab completion for bj and brm
_bj_complete() {
    local names
    names=$(cut -d= -f1 "$BOOKMARKS_FILE" 2>/dev/null)
    COMPREPLY=( $(compgen -W "$names" -- "${COMP_WORDS[COMP_CWORD]}") )
}
complete -F _bj_complete bj brm

# List all bookmarks
bls() {
    if [[ -f "$BOOKMARKS_FILE" ]]; then
        cat "$BOOKMARKS_FILE"
    else
        echo "No bookmarks saved."
    fi
}
