_DOTFILES_BASH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _f in "$_DOTFILES_BASH/lib"/*.sh; do
    [[ -f "$_f" ]] && source "$_f"
done
unset _f _DOTFILES_BASH
