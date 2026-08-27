# nikitas_dotfiles

Modular bash functions and aliases, installable on any machine with a single
clone + script. Installs any missing dependencies automatically: fzf, wezterm,
eza, and the xclip / wl-clipboard clipboard bridge.

## Install

```bash
git clone https://github.com/AlfaKeNTAvR/nikitas_dotfiles ~/nikitas_dotfiles
bash ~/nikitas_dotfiles/install.sh
source ~/.bashrc
```

## Windows (manual setup)

`install.sh` is `apt`-based and Ubuntu-only. On Windows there's no installer —
WezTerm launches Git Bash, which sources the same dotfiles, so the prompt,
bookmarks, history, and eza listings all carry over.

**Prerequisites** (install once):

- [WezTerm](https://wezfurlong.org/wezterm/install/windows.html)
- [Git for Windows](https://git-scm.com/download/win) — provides the `bash.exe`
  WezTerm launches.
- eza (optional, for `ls` icons): `winget install eza-community.eza`
- VS Code (optional, for Ctrl+Click to open files/folders) — a standard user
  install is auto-detected; for a system-wide install in `Program Files`, edit
  `vscode_exe` in `wezterm.lua`.

**Setup:**

1. Clone the repo:
   ```bash
   git clone https://github.com/AlfaKeNTAvR/nikitas_dotfiles "$USERPROFILE/nikitas_dotfiles"
   ```
2. From Git Bash, point your shell at the dotfiles (adjust the path to where you
   cloned):
   ```bash
   printf '\n# nikitas_dotfiles\nsource "/c/Users/<you>/nikitas_dotfiles/bash/init.sh"\n' >> ~/.bashrc
   printf '[[ -f ~/.bashrc ]] && source ~/.bashrc\n' >> ~/.bash_profile
   ```
3. Copy the WezTerm config and apply the two Windows-specific changes:
   ```bash
   mkdir -p ~/.config/wezterm
   cp ~/nikitas_dotfiles/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua
   ```
   Then edit `~/.config/wezterm/wezterm.lua`:
   - Add `default_prog` so WezTerm launches Git Bash as a login+interactive
     shell (adjust the path to your Git install):
     ```lua
     config.default_prog = { "C:/Program Files/Git/usr/bin/bash.exe", "-l", "-i" }
     ```
   - Change the font to the built-in `wezterm.font("JetBrains Mono")` — the
     separately-installed Nerd Font isn't reliably picked up on Windows. Icon
     glyphs still render via WezTerm's bundled "Symbols Nerd Font" fallback.

Restart WezTerm to take effect.

**Differences from Ubuntu:**

- The prompt ends with `>` instead of `$` (matches the native Windows shell).
- The git-branch glyph shows as a box unless a Nerd Font is loaded.

## Uninstall (keep repo)

```bash
bash ~/nikitas_dotfiles/uninstall.sh
```

Removes the source line from `~/.bashrc`, restores the original wezterm
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
Presence is checked against the apt package name via `dpkg-query`, not the
binary name, so packages whose binaries differ from the package name (e.g.
`wl-clipboard` shipping `wl-copy` / `wl-paste`) are detected correctly.

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
│   └── wezterm.sh      # install managed wezterm config (keybindings, bell off)
├── tests/
│   └── test_uninstall.sh
└── README.md
```

## TODO

- [ ] Test conditional package removal (reverse-dependency check via `apt-cache rdepends --installed` in `uninstall.sh`)
