# Arrow up/down searches history based on what's already typed
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Ctrl+R — fuzzy search through full history with fzf
if command -v fzf &>/dev/null; then
    __fzf_history__() {
        local selected
        selected=$(history | sort -rn | awk '!seen[$0]++' | sed 's/^ *[0-9]* *//' \
            | fzf --no-sort --query="$READLINE_LINE")
        if [[ -n "$selected" ]]; then
            READLINE_LINE="$selected"
            READLINE_POINT=${#selected}
        fi
    }
    bind -x '"\C-r": __fzf_history__'
fi
