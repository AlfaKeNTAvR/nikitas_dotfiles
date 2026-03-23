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

## Terminator
| Shortcut | Description |
|---|---|
| `Alt+Shift+-` | Split horizontally |
| `Alt+Shift++` | Split vertically |
| `Ctrl+D` | Close terminal |

### Config (`~/.config/terminator/config`)
```ini
[keybindings]
  zoom_in = <Primary>equal
  zoom_out = <Primary>minus
  split_horiz = <Alt>underscore
  split_vert = <Alt>plus
[profiles]
  [[default]]
    icon_bell = False
    scroll_on_output = False
```

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
