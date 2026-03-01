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

Removes the source line from `~/.bashrc` and uninstalls any dependencies that
were installed by the script. Open a new shell to take effect.

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
│       ├── dotfiles.sh # dotfiles-update, dotfiles-nuke
│       ├── history.sh  # arrow key history search + Ctrl+R fzf search
│       └── utils.sh    # .. and ...
└── README.md
```
