# nikitas_dotfiles

Modular bash functions and aliases, installable on any machine with a single
clone + script. The installer asks what to set up, then installs any missing
dependencies for the chosen components: fzf, wezterm, eza, the Noto symbol
fonts, and the xclip / wl-clipboard clipboard bridge. It can also add the
Russian keyboard layout next to your existing ones.

## Install

```bash
git clone https://github.com/AlfaKeNTAvR/nikitas_dotfiles ~/nikitas_dotfiles
bash ~/nikitas_dotfiles/install.sh
source ~/.bashrc
```

The installer opens a dialog asking for an installation mode:

| Mode | What it installs |
|---|---|
| `full` | Everything (the default, same as before there was a dialog) |
| `minimal` | Shell config + fzf history search only |
| `custom` | A checklist: fzf, WezTerm, fonts/eza icons, clipboard bridge, Russian layout |

The shell integration (the `source` line in `~/.bashrc`) is always installed:
it is the point of the repo. Everything else is optional:

| Component | Contents |
|---|---|
| `fzf` | fzf, used by Ctrl+R fuzzy history search |
| `wezterm` | WezTerm, its apt repo/key, and the managed `wezterm.lua` |
| `fonts` | eza plus the JetBrainsMono Nerd Font (113 MB) and Noto symbol fonts |
| `clipboard` | xclip + wl-clipboard |
| `russian` | Russian xkb layout added to the GNOME input sources, Super+Space switches |

The dialog uses `whiptail` (preinstalled on Ubuntu) and falls back to plain
numbered prompts if it is missing. With no terminal attached (piped installer,
CI) there is nobody to ask, so the full install runs unchanged.

Re-running the installer with a different mode adds the newly selected
components. It never removes previously installed ones: use `uninstall.sh` for
that.

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

## Machine-local WezTerm overrides

`install.sh` copies `wezterm/wezterm.lua` over `~/.config/wezterm/wezterm.lua`,
so any edit made directly to the installed file is lost on the next install or
update. Anything personal or machine-specific belongs in
`~/.config/wezterm/local.lua` instead. That file is never created, overwritten,
or deleted by these dotfiles, so it survives both a reinstall and an uninstall,
and it stays out of this (public) repo.

It returns a function that receives the config table and the `wezterm` module,
and mutates the config in place. It is loaded last, so it can override anything
the managed config sets:

```lua
-- ~/.config/wezterm/local.lua
return function(config, wezterm)
  config.font_size = 12.0

  table.insert(config.ssh_domains, {
    name = "SSH:mybox",
    remote_address = "mybox.example.com",
    username = "nikita",
    multiplexing = "None",  -- plain ssh; nothing to install on the remote
    assume_shell = "Posix", -- lets a split open in the current directory
  })
end
```

SSH domains added this way show up in WezTerm's launcher menu, and a split
inside such a tab opens another channel on the same connection instead of a
second login. `assume_shell = "Posix"` relies on the OSC 7 sequence this
repo's prompt emits, so the dotfiles must also be installed on the remote host
for the current directory to carry over.

A missing `local.lua` is a no-op. A broken one raises a WezTerm config error on
purpose, rather than being skipped silently.

## Uninstall (keep repo)

```bash
bash ~/nikitas_dotfiles/uninstall.sh
```

Removes the source line from `~/.bashrc`, restores the original wezterm
config and keyboard layout settings, and uninstalls any dependencies that were
installed by the script. Open a new shell to take effect.

`~/.config/wezterm/local.lua` is left alone: the dotfiles never created it, so
removing it is not theirs to do. Delete it by hand if you want it gone.

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

## Optional: stop repeated sudo password prompts

Not installed automatically. This touches `/etc`, needs root, and is outside
what `uninstall.sh` can reverse, so it is a manual step (see the reversibility
rule in `CLAUDE.md`).

By default Ubuntu caches sudo credentials for 15 minutes and scopes the cache
to a single terminal, so every new tab or window asks again. A sudoers drop-in
makes the cache global and non-expiring: one password after login, then no
prompts until reboot.

```bash
sudo visudo -f /etc/sudoers.d/timeout
```

Add these two lines, substituting your username:

```
Defaults:<your-username> timestamp_type=global
Defaults:<your-username> timestamp_timeout=-1
```

`visudo` syntax-checks the file on save and refuses to write a broken one, so
a typo cannot lock you out of sudo.

Verify from a different terminal than the one you authenticated in:

```bash
sudo -n true && echo "cached, no prompt"
```

- Force a re-prompt: `sudo -k`
- Remove: `sudo rm /etc/sudoers.d/timeout`

Tradeoff: within the cached window, anything running as your user can reach
root without a prompt. On a guest machine, remove the file when you are done.

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

To add a system dependency, call `ensure_dep <package>` from a component
function in `install.sh` (or add a new component: an `install_<id>` function, an
entry in `COMPONENT_IDS`, a label in `component_label`, and a case in
`install_component`).
It installs only if missing and tracks it for clean removal on uninstall.
Presence is checked against the apt package name via `dpkg-query`, not the
binary name, so packages whose binaries differ from the package name (e.g.
`wl-clipboard` shipping `wl-copy` / `wl-paste`) are detected correctly.

## Layout

```
nikitas_dotfiles/
├── install.sh          # component picker, adds source line to ~/.bashrc, installs deps
├── uninstall.sh        # removes source line, uninstalls tracked deps
├── bash/
│   ├── init.sh         # sources all *.sh files from bash/lib/
│   └── lib/
│       ├── bookmarks.sh # badd, bcd, brm, bls, b
│       ├── dotfiles.sh  # dotfiles-update, dotfiles-nuke, claude-config, claude-dotfiles
│       ├── history.sh   # arrow key history search + Ctrl+R fzf search
│       └── utils.sh     # .. and ...
├── setup/
│   ├── fonts.sh        # install JetBrainsMono Nerd Font into the user font dir
│   ├── keyboard-ru.sh  # add the Russian layout + Super+Space switch (GNOME gsettings)
│   └── wezterm.sh      # install managed wezterm config (keybindings, bell off)
├── tests/
│   ├── test_install_select.sh
│   └── test_uninstall.sh
└── README.md
```

## TODO

- [ ] Test conditional package removal (reverse-dependency check via `apt-cache rdepends --installed` in `uninstall.sh`)
