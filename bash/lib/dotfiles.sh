# Pull latest changes from GitHub
dotfiles-update() {
    local repo
    repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    git -C "$repo" pull
}

# Full cleanup for guest machines:
# removes from .bashrc, uninstalls tracked deps, and deletes the repo directory.
dotfiles-nuke() {
    local repo bashrc source_line deps_file
    repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    bashrc="$HOME/.bashrc"
    source_line="source \"$repo/bash/init.sh\""
    deps_file="${XDG_DATA_HOME:-$HOME/.local/share}/nikitas_dotfiles/installed_deps"

    if grep -qF "$source_line" "$bashrc" 2>/dev/null; then
        grep -vF "$source_line" "$bashrc" \
            | grep -v '^# nikitas_dotfiles$' \
            > "$bashrc.tmp"
        mv "$bashrc.tmp" "$bashrc"
    fi

    if [[ -f "$deps_file" ]]; then
        while IFS= read -r pkg; do
            echo "Removing $pkg..."
            sudo apt remove -y "$pkg"
        done < "$deps_file"
        rm -f "$deps_file"
    fi

    rm -rf "$repo"
    echo "Done. Open a new shell — no trace remains."
}
