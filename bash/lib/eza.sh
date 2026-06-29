# Replace ls with eza (icons + colors), but only if eza is installed so the
# shell stays usable on machines without it.
if command -v eza &>/dev/null; then
    # --hyperlink makes each entry a clickable OSC 8 link; wezterm routes those
    # file:// clicks to VSCode (see open-uri handler in wezterm.lua).
    alias ls='eza --icons=auto --hyperlink --group-directories-first'
    alias ll='eza -l --icons=auto --hyperlink --group-directories-first --git'
    alias la='eza -la --icons=auto --hyperlink --group-directories-first --git'
    alias lt='eza --tree --level=2 --icons=auto --hyperlink --group-directories-first'
fi
