# nikitas_dotfiles

Modular bash functions and aliases, installable on any machine with a single
clone + script. Installs `fzf` automatically if missing.

## Install

```bash
git clone https://github.com/AlfaKeNTAvR/nikitas_dotfiles ~/nikitas_dotfiles
bash ~/nikitas_dotfiles/install.sh
source ~/.bashrc
```

## Uninstall (keep repo)

```bash
bash ~/nikitas_dotfiles/uninstall.sh
```

Removes the source line from `~/.bashrc`, restores the original Terminator
config, and uninstalls any dependencies that were installed by the script.
Open a new shell to take effect.

## Full removal (guest machine)

After installing and sourcing, run:

```bash
dotfiles-nuke
```

Removes the source line from `~/.bashrc`, uninstalls tracked dependencies, and
deletes the repo. Open a new shell afterwards — no trace remains.

## Update

```bash
dotfiles-update
```

## Commands

### Navigation
| Command | Description |
|---|---|
| `..` | Go up one directory |
| `...` | Go up two directories |

### Bookmarks
| Command | Description |
|---|---|
| `badd [name]` | Bookmark current directory (defaults to dir name) |
| `bcd <name>` | Jump to a bookmark (tab completion supported) |
| `brm <name>` | Remove a bookmark (tab completion supported) |
| `bls` | List all bookmarks |
| `b` / `b --help` | Show all bookmark commands |

### History
| Key | Description |
|---|---|
| `↑ / ↓` | Search history by prefix (what you've already typed) |
| `Ctrl+R` | Fuzzy search through full history with fzf |

### Dotfiles
| Command | Description |
|---|---|
| `dotfiles-update` | Pull latest changes from GitHub |
| `dotfiles-nuke` | Full cleanup — remove everything, no trace remains |
| `claude-config` | Open Claude Code in `~/.claude` |
| `claude-dotfiles` | Open Claude Code in the dotfiles repo |

## Adding functions

Drop a new `*.sh` file into `bash/lib/`. It will be sourced automatically
the next time a shell loads (or after `source ~/.bashrc`).

To add a system dependency, call `ensure_dep <package>` in `install.sh`.
It installs only if missing and tracks it for clean removal on uninstall.

## Layout

```
nikitas_dotfiles/
├── install.sh          # adds source line to ~/.bashrc, installs deps
├── uninstall.sh        # removes source line, uninstalls tracked deps
├── bash/
│   ├── init.sh         # sources all *.sh files from bash/lib/
│   └── lib/
│       ├── bookmarks.sh # badd, bcd, brm, bls, b
│       ├── dotfiles.sh  # dotfiles-update, dotfiles-nuke, claude-config, claude-dotfiles
│       ├── history.sh   # arrow key history search + Ctrl+R fzf search
│       └── utils.sh     # .. and ...
├── setup/
│   └── terminator.sh   # apply custom Terminator keybindings & profile settings
├── tests/
│   └── test_uninstall.sh
└── README.md
```

## TODO

- [ ] Test conditional package removal (reverse-dependency check via `apt-cache rdepends --installed` in `uninstall.sh`)
