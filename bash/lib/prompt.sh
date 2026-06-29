# Two-line prompt: current folder + git branch on the first line, input on the
# second. Rebuilt before every prompt via PROMPT_COMMAND, which also means it
# cleanly overrides conda's PS1 prefix (we re-show the env ourselves below).

# Nerd Font git-branch glyph (U+E0A0). Shows as a box without a Nerd Font.
__NIKITA_BRANCH_GLYPH=$''

# Turn a git remote (origin) into a browsable https URL, or print nothing if
# there's no remote or it's a local path. Handles git@host:path, ssh://, https.
__nikita_repo_url() {
    local remote
    remote=$(git remote get-url origin 2>/dev/null) || return
    remote="${remote%.git}"
    case "$remote" in
        git@*:*)    local hp="${remote#git@}"; printf 'https://%s' "${hp/://}" ;;
        ssh://*)    local hp="${remote#ssh://}"; printf 'https://%s' "${hp#git@}" ;;
        http://*|https://*) printf '%s' "$remote" ;;
    esac
}

__nikita_set_prompt() {
    local env_seg="" git_seg="" branch=""

    # Conda / virtualenv name, if any.
    if [[ -n "${CONDA_DEFAULT_ENV:-}" ]]; then
        env_seg="\[\e[2m\](${CONDA_DEFAULT_ENV})\[\e[0m\] "
    elif [[ -n "${VIRTUAL_ENV:-}" ]]; then
        env_seg="\[\e[2m\](${VIRTUAL_ENV##*/})\[\e[0m\] "
    fi

    # Current git branch (or short SHA when detached); empty outside a repo.
    branch=$(git symbolic-ref --short -q HEAD 2>/dev/null) \
        || branch=$(git rev-parse --short -q HEAD 2>/dev/null) \
        || branch=""
    if [[ -n "$branch" ]]; then
        local text="${__NIKITA_BRANCH_GLYPH} ${branch}"
        local url; url=$(__nikita_repo_url)
        if [[ -n "$url" ]]; then
            # OSC 8 hyperlink. Escape sequences (non-printing) are wrapped in
            # \[ \] so bash measures the prompt width correctly; only the branch
            # text between them counts as visible.
            git_seg="  \[\e[32m\e]8;;${url}\a\]${text}\[\e]8;;\a\e[0m\]"
        else
            git_seg="  \[\e[32m\]${text}\[\e[0m\]"
        fi
    fi

    # \W = current dir basename (matches the look you liked; use \w for full path).
    PS1="${env_seg}\[\e[1;36m\]\W\[\e[0m\]${git_seg}\n\$ "
}

# Register without clobbering any existing PROMPT_COMMAND (e.g. conda's hooks).
case ";${PROMPT_COMMAND:-};" in
    *";__nikita_set_prompt;"*) ;;
    *) PROMPT_COMMAND="__nikita_set_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
esac
