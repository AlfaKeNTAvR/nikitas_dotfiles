# Open Claude Code in the Claude config directory
claude-config() {
    cd ~/.claude && claude -c
}

# Open Claude Code in the dotfiles repo
claude-dotfiles() {
    local repo
    repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    cd "$repo" && claude -c
}

# Pull latest changes from GitHub
dotfiles-update() {
    local repo
    repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    git -C "$repo" pull
}

# Full cleanup for guest machines:
# runs uninstall, removes the data directory, and deletes the repo.
dotfiles-nuke() {
    local repo data_dir
    repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/nikitas_dotfiles"

    bash "$repo/uninstall.sh"
    rm -rf "$data_dir"
    rm -rf "$repo"
    echo "Done. Open a new shell — no trace remains."
}
