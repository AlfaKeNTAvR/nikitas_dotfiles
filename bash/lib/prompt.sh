# Two-line prompt: current folder + git branch on the first line, input on the
# second. Rebuilt before every prompt via PROMPT_COMMAND, which also means it
# cleanly overrides conda's PS1 prefix (we re-show the env ourselves below).

# Nerd Font git-branch glyph (U+E0A0). Shows as a box without a Nerd Font.
__NIKITA_BRANCH_GLYPH=$''

# Prompt symbol on the input line. '>' on Windows (Git Bash) to match the native
# shell convention; '\$' elsewhere (the \$ stays root-aware: '#' when UID 0).
case "$OSTYPE" in
    msys*|cygwin*) __NIKITA_PROMPT_SYMBOL='>' ;;
    *)             __NIKITA_PROMPT_SYMBOL='\$' ;;
esac

# Percent-encode a path for use in a file:// URL (spaces, etc.). wezterm's
# open-uri handler percent-decodes before handing the path to VSCode.
__nikita_url_encode() {
    local s="$1" out="" c i
    for (( i = 0; i < ${#s}; i++ )); do
        c="${s:i:1}"
        case "$c" in
            [a-zA-Z0-9/._~-]) out+="$c" ;;
            *) printf -v c '%%%02X' "'$c"; out+="$c" ;;
        esac
    done
    printf '%s' "$out"
}

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
        # Trailing * when the working tree has uncommitted changes (incl. untracked).
        local dirty=""
        [[ -n "$(git status --porcelain 2>/dev/null)" ]] && dirty="*"
        local text="${__NIKITA_BRANCH_GLYPH} ${branch}${dirty}"
        local url; url=$(__nikita_repo_url)
        if [[ -n "$url" ]]; then
            # OSC 8 hyperlink. Escape sequences (non-printing) are wrapped in
            # \[ \] so bash measures the prompt width correctly; only the branch
            # text between them counts as visible.
            git_seg=" \[\e[32m\e]8;;${url}\a\]${text}\[\e]8;;\a\e[0m\]"
        else
            git_seg=" \[\e[32m\]${text}\[\e[0m\]"
        fi
    fi

    # \W = current dir basename (matches the look you liked; use \w for full path).
    # Wrap it in an OSC 8 file:// hyperlink to $PWD so Ctrl+Click opens the folder
    # in VSCode (same open-uri handler that routes eza's file:// links).
    local dir_url; dir_url="file://$(__nikita_url_encode "$PWD")"
    local dir_seg="\[\e[1;36m\e]8;;${dir_url}\a\]\W\[\e]8;;\a\e[0m\]"
    PS1="${env_seg}${dir_seg}${git_seg}\n${__NIKITA_PROMPT_SYMBOL} "
}

# Register without clobbering any existing PROMPT_COMMAND (e.g. conda's hooks).
case ";${PROMPT_COMMAND:-};" in
    *";__nikita_set_prompt;"*) ;;
    *) PROMPT_COMMAND="__nikita_set_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
esac
