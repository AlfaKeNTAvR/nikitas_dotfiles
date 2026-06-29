# Commands

## Bookmarks
| Command | Description |
|---|---|
| `badd [name]` | Bookmark current directory (defaults to dir name) |
| `bcd <name>` | Jump to a bookmark (tab completion supported) |
| `brm <name>` | Remove a bookmark (tab completion supported) |
| `bls` | List all bookmarks |
| `b` / `b --help` | Show all bookmark commands |

## Ubuntu
| Shortcut | Description |
|---|---|
| `Super+Left/Right` | Snap window to left/right half of screen |
| `Super+Shift+Left/Right` | Move window to previous/next monitor |
| `Super+Tab` | Switch focus between apps |
| `Super+Esc` | Switch focus between open windows |
| `Super+\`` | Switch between windows of the same app |
| `Super+Page Up/Down` | Switch workspaces |
| `Super+Shift+Page Up/Down` | Move focused window to another workspace |
| `Super+Up` | Un-snap window (required before moving a snapped window to another monitor) |

> To move a snapped window to another monitor: `Super+Up` → `Super+Shift+Left/Right` → `Super+Left/Right` to re-snap.

## WezTerm
| Shortcut | Description |
|---|---|
| `Ctrl+=` | Zoom in (increase font size) |
| `Ctrl+-` | Zoom out (decrease font size) |
| `Ctrl+0` | Reset font size |
| `Alt+Shift+-` | Split top/bottom |
| `Alt+Shift++` | Split left/right |
| `Ctrl+D` | Close pane (shell EOF) |
| `Ctrl+Click` (on a file/folder in `ls`) | Open it in VSCode |

> Split keys are bound on the physical key position (so `Alt+Shift` combos fire
> regardless of keyboard layout). `Alt+Shift+-` splits top/bottom, `Alt+Shift++`
> splits left/right.
>
> **No broadcast:** WezTerm has no native broadcast-to-all-panes equivalent.

### Config (`~/.config/wezterm/wezterm.lua`)
Managed copy of `wezterm/wezterm.lua` from this repo. Sets JetBrainsMono Nerd
Font, disables the audible bell, formats tabs as `N:folder`, and routes
`file://` link clicks to VSCode. The font is installed by `setup/fonts.sh`.

## Shell prompt & listings
| Command | Description |
|---|---|
| `ls` / `ll` / `la` / `lt` | `eza` with icons, git status, and clickable (hyperlinked) entries |

> The prompt is two lines: `(env) folder  branch` then the input line below.
> The folder is a clickable link that opens the current directory in VSCode; the
> branch is a clickable link to the repo's web page. Requires a Nerd Font
> (installed via `setup/fonts.sh`) for the icons and branch glyph.

## Ubuntu Settings
| Command | Description |
|---|---|
| `gsettings set org.gnome.shell.extensions.tiling-assistant enable-tiling-popup false` | Disable app suggestions when snapping a window |

## Dotfiles
| Command | Description |
|---|---|
| `dotfiles-update` | Pull latest changes from GitHub |
| `dotfiles-nuke` | Full cleanup — remove everything, no trace remains |
| `claude-config` | Open Claude Code in `~/.claude` |
| `claude-dotfiles` | Open Claude Code in the dotfiles repo |
